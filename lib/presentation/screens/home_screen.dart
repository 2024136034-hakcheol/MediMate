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
    if (mounted) setState(() { _medicines = list; _isLoading = false; });
  }

  Future<void> _delete(Medicine m) async {
    await DbService().deleteMedicine(m.id!);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MediMate'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2e7d32)))
          : _medicines.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.medication_outlined, size: 72, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('등록된 약이 없습니다',
                          style: TextStyle(fontSize: 18, color: Colors.grey)),
                      SizedBox(height: 8),
                      Text('아래 버튼을 눌러 약을 스캔하세요',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _medicines.length,
                    itemBuilder: (_, i) {
                      final m = _medicines[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        elevation: 2,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF2e7d32),
                            child: Text(
                              m.name[0].toUpperCase(),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(m.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(m.dosage ?? '용량 정보 없음'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.redAccent),
                            onPressed: () => showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('삭제'),
                                content: Text('${m.name}을(를) 삭제할까요?'),
                                actions: [
                                  TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('취소')),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _delete(m);
                                    },
                                    child: const Text('삭제',
                                        style:
                                            TextStyle(color: Colors.redAccent)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
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
        label: const Text('약 스캔'),
      ),
    );
  }
}
