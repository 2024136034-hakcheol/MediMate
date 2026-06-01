import 'package:flutter/material.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('복용 기록'),
        backgroundColor: const Color(0xFF2e7d32),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_month, size: 72, color: Colors.grey),
            SizedBox(height: 16),
            Text('복용 기록 달력', style: TextStyle(fontSize: 18, color: Colors.grey)),
            SizedBox(height: 8),
            Text('13주차에 구현 예정', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
