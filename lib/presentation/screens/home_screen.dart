import 'package:flutter/material.dart';
import '../../data/local/db_service.dart';
import '../../domain/entities/medicine.dart';
import '../theme/app_theme.dart';
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
    final takenCount = _todaySchedules.where((s) => s['log_id'] != null).length;
    final totalCount = _todaySchedules.length;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _load,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _header(takenCount, totalCount)),
            if (_isLoading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _sectionLabel('오늘의 복용'),
                    const SizedBox(height: 10),
                    if (_todaySchedules.isEmpty)
                      _emptyCard(Icons.medication_outlined, '오늘 복용할 약이 없습니다')
                    else
                      ..._todaySchedules.map((s) => _scheduleCard(s)),
                    const SizedBox(height: 28),
                    _sectionLabel('등록된 약 ${_medicines.length}종'),
                    const SizedBox(height: 10),
                    if (_medicines.isEmpty)
                      _emptyCard(Icons.add_a_photo_outlined, '등록된 약이 없습니다\n아래 버튼으로 스캔하세요')
                    else
                      ..._medicines.map((m) => _medicineCard(m)),
                  ]),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const ScanScreen()));
          _load();
        },
        icon: const Icon(Icons.camera_alt_rounded),
        label: const Text('약 스캔'),
      ),
    );
  }

  Widget _header(int taken, int total) {
    final now = DateTime.now();
    final progress = total == 0 ? 0.0 : taken / total;

    return Container(
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 16, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.navy, AppColors.tealDeep],
        ),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.medication_rounded, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              const Text('MediMate', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            '${now.month}월 ${now.day}일 오늘의 복용',
            style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('$taken', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)),
              Text(' / $total건 완료', style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 15, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.15),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF5EEAD4)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: const TextStyle(fontSize: 13, color: AppColors.muted, fontWeight: FontWeight.w700, letterSpacing: 0.2),
      );

  Widget _emptyCard(IconData icon, String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          Icon(icon, size: 36, color: AppColors.muted.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          Text(text, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted, height: 1.5)),
        ],
      ),
    );
  }

  Widget _scheduleCard(Map<String, dynamic> s) {
    final taken = s['log_id'] != null;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: taken ? AppColors.tealSoft : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: taken ? const Color(0xFF99F6E4) : AppColors.line),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: taken ? AppColors.teal : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              s['schedule_time'] as String,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                color: taken ? Colors.white : AppColors.muted,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s['medicine_name'] as String,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.ink)),
                if (s['medicine_dosage'] != null)
                  Text(s['medicine_dosage'] as String,
                      style: const TextStyle(color: AppColors.muted, fontSize: 12)),
              ],
            ),
          ),
          if (!taken)
            ElevatedButton(
              onPressed: () => _markTaken(s['schedule_id'] as int),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                textStyle: const TextStyle(fontSize: 12),
              ),
              child: const Text('복용 완료'),
            )
          else
            const Icon(Icons.check_circle_rounded, color: AppColors.teal, size: 28),
        ],
      ),
    );
  }

  Widget _medicineCard(Medicine m) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: ListTile(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MedicineDetailScreen(medicine: m)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppColors.navy, AppColors.tealDeep]),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(m.name[0].toUpperCase(),
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
        ),
        title: Text(m.name, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink)),
        subtitle: Text(m.dosage ?? '용량 정보 없음', style: const TextStyle(color: AppColors.muted)),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          onPressed: () => _confirmDelete(m),
        ),
      ),
    );
  }
}
