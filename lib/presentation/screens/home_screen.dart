import 'package:flutter/material.dart';
import '../../data/local/db_service.dart';
import '../../domain/entities/medicine.dart';
import 'scan_screen.dart';
import 'medicine_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _todaySchedules = [];
  List<Medicine> _medicines = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = DbService();
    final schedules = await db.getTodaySchedules();
    final medicines = await db.getMedicines();
    if (mounted) {
      setState(() {
        _todaySchedules = schedules;
        _medicines = medicines;
        _isLoading = false;
      });
    }
  }

  Future<void> _markTaken(int scheduleId) async {
    await DbService().recordIntake(scheduleId);
    _load();
  }

  Future<void> _confirmDelete(Medicine m) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('약 삭제'),
        content: Text('${m.name}을(를) 삭제할까요?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await DbService().deleteMedicine(m.id!);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F4),
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.medication, color: Colors.white, size: 22),
            SizedBox(width: 8),
            Text('MediMate', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: const Color(0xFF2e7d32),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2e7d32)))
          : RefreshIndicator(
              color: const Color(0xFF2e7d32),
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _todaySection(),
                  const SizedBox(height: 20),
                  _medicinesSection(),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const ScanScreen()));
          _load();
        },
        backgroundColor: const Color(0xFF2e7d32),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.camera_alt),
        label: const Text('약 스캔', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _todaySection() {
    final now = DateTime.now();
    final dateStr = '${now.month}월 ${now.day}일 오늘의 복용';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(dateStr, style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        if (_todaySchedules.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Text('오늘 복용할 약이 없습니다', style: TextStyle(color: Colors.grey)),
            ),
          )
        else
          ...(_todaySchedules.map((s) => _scheduleCard(s))),
      ],
    );
  }

  Widget _scheduleCard(Map<String, dynamic> s) {
    final taken = s['log_id'] != null;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: taken ? const Color(0xFFe8f5e9) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: taken ? const Color(0xFF4CAF50) : Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: taken ? const Color(0xFF4CAF50) : const Color(0xFFeeeeee),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              s['schedule_time'] as String,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: taken ? Colors.white : Colors.black54,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s['medicine_name'] as String,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                if (s['medicine_dosage'] != null)
                  Text(s['medicine_dosage'] as String,
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          if (!taken)
            ElevatedButton(
              onPressed: () => _markTaken(s['schedule_id'] as int),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2e7d32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                textStyle: const TextStyle(fontSize: 12),
              ),
              child: const Text('복용 완료'),
            )
          else
            const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 28),
        ],
      ),
    );
  }

  Widget _medicinesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '등록된 약 ${_medicines.length}종',
          style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        if (_medicines.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
            child: const Center(
              child: Text('등록된 약이 없습니다\n아래 버튼으로 스캔하세요',
                  textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            ),
          )
        else
          ...(_medicines.map((m) => _medicineCard(m))),
      ],
    );
  }

  Widget _medicineCard(Medicine m) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: ListTile(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MedicineDetailScreen(medicine: m)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: const Color(0xFF2e7d32),
          child: Text(m.name[0].toUpperCase(),
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        title: Text(m.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(m.dosage ?? '용량 정보 없음', style: const TextStyle(color: Colors.grey)),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          onPressed: () => _confirmDelete(m),
        ),
      ),
    );
  }
}
