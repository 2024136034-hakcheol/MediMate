import 'package:flutter/material.dart';
import '../../domain/entities/medicine.dart';
import '../../data/local/db_service.dart';
import '../../domain/entities/schedule.dart';

class MedicineDetailScreen extends StatefulWidget {
  final Medicine medicine;
  const MedicineDetailScreen({super.key, required this.medicine});

  @override
  State<MedicineDetailScreen> createState() => _MedicineDetailScreenState();
}

class _MedicineDetailScreenState extends State<MedicineDetailScreen> {
  List<Schedule> _schedules = [];

  @override
  void initState() {
    super.initState();
    DbService().getSchedulesByMedicine(widget.medicine.id!).then((list) {
      if (mounted) setState(() => _schedules = list);
    });
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.medicine;
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F4),
      appBar: AppBar(
        title: Text(m.name),
        backgroundColor: const Color(0xFF0f766e),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 기본 정보 카드
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: const Color(0xFF0f766e),
                      child: Text(m.name[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          if (m.dosage != null)
                            Text(m.dosage!, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                _infoRow('등록일', m.createdAt.substring(0, 10)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // 복용 스케줄
          _sectionTitle('복용 스케줄'),
          _card(
            child: _schedules.isEmpty
                ? const Center(child: Text('등록된 스케줄 없음', style: TextStyle(color: Colors.grey)))
                : Column(
                    children: _schedules.map((s) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time, color: Color(0xFF0f766e), size: 18),
                          const SizedBox(width: 8),
                          Text(s.time, style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          Text('${s.startDate} ~', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          if (s.endDate != null)
                            Text(s.endDate!, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    )).toList(),
                  ),
          ),
          const SizedBox(height: 12),
          // 주의사항 (F-05)
          if (m.cautions != null && m.cautions!.isNotEmpty) ...[
            _sectionTitle('주의사항 (AI 요약)'),
            _card(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(m.cautions!, style: const TextStyle(height: 1.6, fontSize: 14)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: child,
    );
  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(title, style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w600)),
      );

  Widget _infoRow(String label, String value) => Row(
        children: [
          Text('$label  ', style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      );
}
