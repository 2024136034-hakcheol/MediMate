import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
        backgroundColor: const Color(0xFF2e7d32),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 12),
          _tile(context, Icons.notifications_outlined, '알림 설정', '복용 알림 시간 관리'),
          _tile(context, Icons.info_outline, '앱 정보', 'MediMate v1.0.0 · PillNova'),
          _tile(context, Icons.code, '개발자', '문학철 · Flutter + Gemini API'),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF2e7d32)),
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
    );
  }
}
