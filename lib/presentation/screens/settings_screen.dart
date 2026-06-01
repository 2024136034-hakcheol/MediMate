import 'package:flutter/material.dart';
import '../../data/local/db_service.dart';
import '../../data/local/notification_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F4),
      appBar: AppBar(
        title: const Text('설정'),
        backgroundColor: const Color(0xFF2e7d32),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 12),
          _sectionHeader('알림'),
          _tile(
            context,
            icon: Icons.notifications_outlined,
            title: '알림 설정',
            subtitle: '등록된 약의 복용 알림 시간 확인',
            onTap: () => _showNotificationSettings(context),
          ),
          _tile(
            context,
            icon: Icons.notifications_off_outlined,
            title: '모든 알림 취소',
            subtitle: '등록된 복용 알림 전체 해제',
            onTap: () => _cancelAllNotifications(context),
            danger: true,
          ),
          const SizedBox(height: 8),
          _sectionHeader('앱'),
          _tile(
            context,
            icon: Icons.info_outline,
            title: '앱 정보',
            subtitle: 'MediMate v1.0.0 · PillNova',
            onTap: () => _showAppInfo(context),
          ),
          _tile(
            context,
            icon: Icons.code,
            title: '개발자 정보',
            subtitle: '문학철 · Flutter + Gemini API',
            onTap: () => _showDeveloperInfo(context),
          ),
          const SizedBox(height: 8),
          _sectionHeader('데이터'),
          _tile(
            context,
            icon: Icons.delete_sweep_outlined,
            title: '모든 데이터 초기화',
            subtitle: '등록된 약·복용 기록 전체 삭제',
            onTap: () => _resetAllData(context),
            danger: true,
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        child: Text(title,
            style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
      );

  Widget _tile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool danger = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: danger ? Colors.redAccent : const Color(0xFF2e7d32)),
        title: Text(title, style: TextStyle(color: danger ? Colors.redAccent : Colors.black)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
        onTap: onTap,
      ),
    );
  }

  // 알림 설정 — 등록된 스케줄 목록 표시
  void _showNotificationSettings(BuildContext context) async {
    final medicines = await DbService().getMedicines();
    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('알림 설정'),
        content: SizedBox(
          width: double.maxFinite,
          child: medicines.isEmpty
              ? const Text('등록된 약이 없습니다.\n약을 스캔하면 자동으로 알림이 등록됩니다.',
                  style: TextStyle(color: Colors.grey))
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('알림 등록된 약 목록:', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 8),
                    ...medicines.map((m) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.alarm, size: 16, color: Color(0xFF4CAF50)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(m.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    if (m.dosage != null)
                                      Text(m.dosage!, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('닫기')),
        ],
      ),
    );
  }

  // 모든 알림 취소
  void _cancelAllNotifications(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('모든 알림 취소'),
        content: const Text('등록된 모든 복용 알림을 해제합니다.\n약은 삭제되지 않습니다.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('해제', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await NotificationService().cancelAll();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모든 알림이 해제됐습니다')),
      );
    }
  }

  // 앱 정보
  void _showAppInfo(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'MediMate',
      applicationVersion: 'v1.0.0',
      applicationIcon: const Icon(Icons.medication, color: Color(0xFF2e7d32), size: 40),
      children: const [
        SizedBox(height: 8),
        Text('AI 약 복용 관리 앱\n카메라로 약을 찍으면 AI가 복용 스케줄을 자동으로 만들어 줍니다.'),
        SizedBox(height: 8),
        Text('기술 스택: Flutter · Gemini API · SQLite', style: TextStyle(color: Colors.grey, fontSize: 12)),
        Text('팀: PillNova | 앱 프로그래밍 응용', style: TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  // 개발자 정보
  void _showDeveloperInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('개발자 정보'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoRow(label: '개발자', value: '문학철'),
            _InfoRow(label: '팀', value: 'PillNova'),
            _InfoRow(label: '과목', value: '앱 프로그래밍 응용'),
            _InfoRow(label: '프레임워크', value: 'Flutter (Dart)'),
            _InfoRow(label: 'AI', value: 'Gemini API (Vision)'),
            _InfoRow(label: 'DB', value: 'SQLite (sqflite)'),
            _InfoRow(label: '개발 도구', value: 'Claude Code'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('닫기')),
        ],
      ),
    );
  }

  // 모든 데이터 초기화
  void _resetAllData(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('데이터 초기화', style: TextStyle(color: Colors.redAccent)),
        content: const Text('등록된 약, 복용 스케줄, 복용 기록이\n모두 삭제됩니다.\n\n이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('초기화', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (ok == true) {
      final medicines = await DbService().getMedicines();
      for (final m in medicines) {
        await DbService().deleteMedicine(m.id!);
      }
      await NotificationService().cancelAll();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모든 데이터가 초기화됐습니다')),
      );
    }
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
