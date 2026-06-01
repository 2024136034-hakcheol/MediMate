import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../data/local/db_service.dart';
import '../../domain/entities/intake_log.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focused = DateTime.now();
  DateTime _selected = DateTime.now();
  Map<String, double> _compliance = {};
  List<IntakeLog> _selectedDayLogs = [];

  @override
  void initState() {
    super.initState();
    _loadMonth(_focused);
    _loadDay(_selected);
  }

  Future<void> _loadMonth(DateTime month) async {
    final data = await DbService().getMonthlyCompliance(month.year, month.month);
    if (mounted) setState(() => _compliance = data);
  }

  Future<void> _loadDay(DateTime day) async {
    final dateStr = '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
    final logs = await DbService().getIntakeLogsByDate(dateStr);
    if (mounted) setState(() => _selectedDayLogs = logs);
  }

  bool _hasDose(DateTime day) {
    final key = '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
    return (_compliance[key] ?? 0) > 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F4),
      appBar: AppBar(
        title: const Text('복용 기록'),
        backgroundColor: const Color(0xFF2e7d32),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        children: [
          Container(
            color: Colors.white,
            child: TableCalendar(
              firstDay: DateTime(2024),
              lastDay: DateTime(2030),
              focusedDay: _focused,
              selectedDayPredicate: (d) => isSameDay(d, _selected),
              calendarFormat: CalendarFormat.month,
              availableCalendarFormats: const {CalendarFormat.month: '월'},
              onDaySelected: (selected, focused) {
                setState(() { _selected = selected; _focused = focused; });
                _loadDay(selected);
              },
              onPageChanged: (focused) {
                _focused = focused;
                _loadMonth(focused);
              },
              calendarStyle: CalendarStyle(
                todayDecoration: const BoxDecoration(
                  color: Color(0xFFa5d6a7), shape: BoxShape.circle,
                ),
                selectedDecoration: const BoxDecoration(
                  color: Color(0xFF2e7d32), shape: BoxShape.circle,
                ),
                markerDecoration: const BoxDecoration(
                  color: Color(0xFF4CAF50), shape: BoxShape.circle,
                ),
                outsideDaysVisible: false,
              ),
              calendarBuilders: CalendarBuilders(
                markerBuilder: (ctx, day, events) {
                  if (_hasDose(day)) {
                    return Positioned(
                      bottom: 4,
                      child: Container(
                        width: 6, height: 6,
                        decoration: const BoxDecoration(color: Color(0xFF4CAF50), shape: BoxShape.circle),
                      ),
                    );
                  }
                  return null;
                },
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_selected.month}월 ${_selected.day}일 복용 기록',
                  style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                if (_selectedDayLogs.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                    child: const Center(child: Text('복용 기록 없음', style: TextStyle(color: Colors.grey))),
                  )
                else
                  ..._selectedDayLogs.map((log) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Color(0xFF4CAF50)),
                            const SizedBox(width: 10),
                            Text(
                              log.takenAt.substring(11, 16),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            Text('복용 완료', style: TextStyle(color: Colors.grey.shade600)),
                          ],
                        ),
                      )),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
