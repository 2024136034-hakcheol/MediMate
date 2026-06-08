import 'package:flutter/material.dart';
import '../../data/api/gemini_service.dart';
import 'result_screen.dart';

const _green = Color(0xFF2e7d32);
const _lightGreen = Color(0xFF4CAF50);

class ScanResultListScreen extends StatefulWidget {
  final List<MedicineInfo> medicines;
  const ScanResultListScreen({super.key, required this.medicines});

  @override
  State<ScanResultListScreen> createState() => _ScanResultListScreenState();
}

class _ScanResultListScreenState extends State<ScanResultListScreen> {
  late List<bool> _saved;

  @override
  void initState() {
    super.initState();
    _saved = List.filled(widget.medicines.length, false);
  }

  Future<void> _openDetail(int index) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ResultScreen(medicineInfo: widget.medicines[index])),
    );
    if (saved == true && mounted) {
      setState(() => _saved[index] = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.medicines.length;
    final savedCount = _saved.where((s) => s).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F4),
      appBar: AppBar(
        title: Text('인식된 약 $total종'),
        backgroundColor: _green,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('사진 한 장에서 약을 여러 종류 인식했습니다',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 6),
                Text('항목을 눌러 내용을 확인하고 각각 등록해주세요  ($savedCount/$total 등록 완료)',
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: total,
              itemBuilder: (context, index) {
                final info = widget.medicines[index];
                final saved = _saved[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: saved ? _lightGreen : Colors.grey.shade200, width: saved ? 1.4 : 1),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: ListTile(
                    onTap: () => _openDetail(index),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    leading: CircleAvatar(
                      radius: 22,
                      backgroundColor: saved ? _lightGreen : _green,
                      child: Icon(saved ? Icons.check : Icons.medication, color: Colors.white),
                    ),
                    title: Text(info.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    subtitle: Text(info.dosage ?? '용량 정보 없음', style: const TextStyle(color: Colors.grey)),
                    trailing: saved
                        ? const Text('등록 완료', style: TextStyle(color: _lightGreen, fontWeight: FontWeight.bold, fontSize: 12))
                        : const Icon(Icons.chevron_right),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _green,
                    side: const BorderSide(color: _green),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(savedCount == total ? '완료' : '나중에 계속하기'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
