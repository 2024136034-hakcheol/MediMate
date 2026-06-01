import 'package:flutter/material.dart';
import '../../data/local/db_service.dart';
import '../../domain/entities/medicine.dart';
import 'scan_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Medicine> _medicines = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await DbService().getMedicines();
    if (mounted) {
      setState(() {
        _medicines = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _confirmDelete(Medicine m) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('약 삭제'),
        content: Text('${m.name}을(를) 목록에서 삭제할까요?'),
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
            Icon(Icons.medication, color: Colors.white, size: 24),
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
              child: _medicines.isEmpty ? _emptyState() : _medicineList(),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ScanScreen()),
          );
          _load();
        },
        backgroundColor: const Color(0xFF2e7d32),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.camera_alt),
        label: const Text('약 스캔', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _emptyState() {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
        const Column(
          children: [
            Icon(Icons.medication_outlined, size: 80, color: Color(0xFFa5d6a7)),
            SizedBox(height: 16),
            Text(
              '등록된 약이 없습니다',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text('아래 버튼을 눌러 약 포장을 스캔하세요', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  Widget _medicineList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            '복용 중인 약 ${_medicines.length}종',
            style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _medicines.length,
            itemBuilder: (_, i) => _medicineCard(_medicines[i]),
          ),
        ),
      ],
    );
  }

  Widget _medicineCard(Medicine m) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: const Color(0xFF2e7d32),
          child: Text(
            m.name[0].toUpperCase(),
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(m.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (m.dosage != null && m.dosage!.isNotEmpty)
              Text(m.dosage!, style: const TextStyle(color: Color(0xFF555555))),
            if (m.cautions != null && m.cautions!.isNotEmpty)
              Text(
                m.cautions!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          onPressed: () => _confirmDelete(m),
        ),
      ),
    );
  }
}
