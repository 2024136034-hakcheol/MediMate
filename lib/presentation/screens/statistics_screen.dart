import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/local/db_service.dart';

const _green = Color(0xFF0f766e);
const _lightGreen = Color(0xFF0d9488);
const _bg = Color(0xFFF4F7F4);

const _weekdayLabels = ['월', '화', '수', '목', '금', '토', '일'];

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  List<Map<String, dynamic>> _weekly = [];
  List<Map<String, dynamic>> _medicineCounts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = DbService();
    final weekly = await db.getWeeklyAdherence();
    final medicineCounts = await db.getMedicineIntakeCounts();
    if (mounted) {
      setState(() {
        _weekly = weekly;
        _medicineCounts = medicineCounts;
        _isLoading = false;
      });
    }
  }

  int get _scheduledTotal =>
      _weekly.fold(0, (sum, d) => sum + (d['scheduled'] as int));
  int get _takenTotal =>
      _weekly.fold(0, (sum, d) => sum + (d['taken'] as int));
  double get _adherenceRate =>
      _scheduledTotal == 0 ? 0 : _takenTotal / _scheduledTotal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text('복용 통계'),
        backgroundColor: _green,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _green))
          : RefreshIndicator(
              color: _green,
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _rateCard(),
                  const SizedBox(height: 20),
                  _weeklyChartCard(),
                  const SizedBox(height: 20),
                  _medicineRankingCard(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _card({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _rateCard() {
    final percent = (_adherenceRate * 100).round();
    return _card(
      title: '최근 7일 복용률',
      child: Row(
        children: [
          SizedBox(
            width: 84,
            height: 84,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 84,
                  height: 84,
                  child: CircularProgressIndicator(
                    value: _adherenceRate,
                    strokeWidth: 8,
                    backgroundColor: const Color(0xFFe0e0e0),
                    valueColor: const AlwaysStoppedAnimation(_lightGreen),
                  ),
                ),
                Text('$percent%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: _green)),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '예정 $_scheduledTotal회 중 $_takenTotal회 복용',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Text(
                  _scheduledTotal == 0
                      ? '아직 등록된 복용 일정이 없습니다'
                      : _adherenceRate >= 0.8
                          ? '꾸준히 잘 챙겨 먹고 있어요 👍'
                          : '알림을 확인하고 꾸준히 복용해 보세요',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _weeklyChartCard() {
    final maxScheduled = _weekly.fold<int>(1, (m, d) => (d['scheduled'] as int) > m ? d['scheduled'] as int : m);
    final double maxY = maxScheduled.toDouble() + 1;

    return _card(
      title: '일자별 복용 현황',
      child: SizedBox(
        height: 180,
        child: _weekly.isEmpty
            ? const Center(child: Text('데이터가 없습니다', style: TextStyle(color: Colors.grey)))
            : BarChart(
                BarChartData(
                  maxY: maxY,
                  alignment: BarChartAlignment.spaceAround,
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final i = value.toInt();
                          if (i < 0 || i >= _weekly.length) return const SizedBox.shrink();
                          final weekday = _weekly[i]['weekday'] as int;
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(_weekdayLabels[weekday - 1],
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: List.generate(_weekly.length, (i) {
                    final d = _weekly[i];
                    final scheduled = (d['scheduled'] as int).toDouble();
                    final taken = (d['taken'] as int).toDouble();
                    return BarChartGroupData(x: i, barRods: [
                      BarChartRodData(
                        toY: scheduled,
                        width: 16,
                        borderRadius: BorderRadius.circular(4),
                        color: const Color(0xFFe0e0e0),
                      ),
                      BarChartRodData(
                        toY: taken,
                        width: 16,
                        borderRadius: BorderRadius.circular(4),
                        color: _lightGreen,
                      ),
                    ], barsSpace: 4);
                  }),
                ),
              ),
      ),
    );
  }

  Widget _medicineRankingCard() {
    return _card(
      title: '약별 누적 복용 횟수',
      child: _medicineCounts.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('등록된 약이 없습니다', style: TextStyle(color: Colors.grey)),
            )
          : Column(
              children: _medicineCounts.map((m) {
                final maxCount = _medicineCounts.first['taken_count'] as int;
                final count = m['taken_count'] as int;
                final ratio = maxCount == 0 ? 0.0 : count / maxCount;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 70,
                        child: Text(m['medicine_name'] as String,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: ratio,
                            minHeight: 10,
                            backgroundColor: const Color(0xFFf0fdfa),
                            valueColor: const AlwaysStoppedAnimation(_lightGreen),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text('$count회', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }
}
