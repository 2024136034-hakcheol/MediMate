import 'package:flutter/material.dart';
import '../../data/api/gemini_service.dart';
import '../../data/local/db_service.dart';
import '../../data/local/notification_service.dart';
import '../../domain/entities/medicine.dart';
import '../../domain/entities/schedule.dart';

class ResultScreen extends StatefulWidget {
  final MedicineInfo medicineInfo;
  const ResultScreen({super.key, required this.medicineInfo});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _dosageCtrl;
  late TextEditingController _timingCtrl;
  late TextEditingController _cautionsCtrl;
  TimeOfDay _scheduleTime = const TimeOfDay(hour: 8, minute: 0);
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.medicineInfo.name);
    _dosageCtrl = TextEditingController(text: widget.medicineInfo.dosage ?? '');
    _timingCtrl = TextEditingController(text: widget.medicineInfo.timing ?? '');
    _cautionsCtrl = TextEditingController(text: widget.medicineInfo.cautions ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dosageCtrl.dispose();
    _timingCtrl.dispose();
    _cautionsCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('약 이름을 입력해주세요')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final db = DbService();
      final medicine = Medicine(
        name: _nameCtrl.text.trim(),
        dosage: _dosageCtrl.text.trim().isEmpty ? null : _dosageCtrl.text.trim(),
        cautions: _cautionsCtrl.text.trim().isEmpty ? null : _cautionsCtrl.text.trim(),
        createdAt: DateTime.now().toIso8601String(),
      );
      final medicineId = await db.insertMedicine(medicine);

      final frequency = widget.medicineInfo.frequency ?? 1;
      for (int i = 0; i < frequency; i++) {
        final hour = (_scheduleTime.hour + i * (24 ~/ frequency)) % 24;
        final minute = _scheduleTime.minute;
        final time = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
        await db.insertSchedule(Schedule(
          medicineId: medicineId,
          time: time,
          startDate: DateTime.now().toIso8601String().substring(0, 10),
          endDate: widget.medicineInfo.durationDays != null
              ? DateTime.now()
                  .add(Duration(days: widget.medicineInfo.durationDays!))
                  .toIso8601String()
                  .substring(0, 10)
              : null,
        ));
        // 매일 반복 알림 등록
        await NotificationService().scheduleDailyDose(
          id: medicineId * 10 + i,
          medicineName: _nameCtrl.text.trim(),
          hour: hour,
          minute: minute,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_nameCtrl.text} 등록 완료')),
      );
      Navigator.pop(context, true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _field(String label, TextEditingController ctrl,
      {String? hint, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('인식 결과 확인'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'AI 인식 결과를 확인하고 필요하면 수정하세요',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            _field('약 이름 *', _nameCtrl),
            _field('1회 복용량', _dosageCtrl, hint: '예: 500mg, 1정'),
            _field('복용 시점', _timingCtrl, hint: '예: 식후 30분'),
            _field('주의사항', _cautionsCtrl, maxLines: 3),
            const Text('첫 복용 시간',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: Colors.grey),
              ),
              leading: const Icon(Icons.access_time, color: Color(0xFF0f766e)),
              title: Text(
                  '${_scheduleTime.format(context)}  (1일 ${widget.medicineInfo.frequency ?? 1}회)'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: _scheduleTime,
                );
                if (picked != null) setState(() => _scheduleTime = picked);
              },
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0f766e),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('저장'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
