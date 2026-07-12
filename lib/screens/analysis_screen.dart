import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/models.dart';
import '../services/storage_service.dart';
import '../services/theme.dart';
import '../l10n/app_strings.dart';

class AnalysisScreen extends StatefulWidget {
  final bool isPersian;
  const AnalysisScreen({super.key, required this.isPersian});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  Map<String, DailyRecord> _records = {};
  List<Activity> _weekdayActivities = [];
  List<Activity> _weekendActivities = [];
  bool _loading = true;

  AppStrings get s => widget.isPersian ? AppStrings.fa : AppStrings.en;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final records = await StorageService.loadRecords();
    final wd = await StorageService.loadActivities(DayType.weekday);
    final we = await StorageService.loadActivities(DayType.weekend);
    setState(() {
      _records = records;
      _weekdayActivities = wd;
      _weekendActivities = we;
      _loading = false;
    });
  }

  List<Activity> _activitiesFor(DateTime d) {
    final isWeekend = d.weekday == 4 || d.weekday == 5;
    return isWeekend ? _weekendActivities : _weekdayActivities;
  }

  List<MapEntry<String, double>> _weeklyData() {
    final now = DateTime.now();
    final result = <MapEntry<String, double>>[];
    for (int i = 6; i >= 0; i--) {
      final d = now.subtract(Duration(days: i));
      final key =
          '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';
      final record = _records[key];
      final dayActivities = _activitiesFor(d);
      double rate = 0;
      if (record != null && dayActivities.isNotEmpty) {
        final done = dayActivities
            .where((a) => record.completedActivities[a.id] == true)
            .length;
        rate = done / dayActivities.length;
      }
      final dayIdx = [6, 0, 1, 2, 3, 4, 5][d.weekday - 1];
      result.add(MapEntry(s.dayNames[dayIdx], rate));
    }
    return result;
  }

  double get _avgCompletion {
    final data = _weeklyData();
    if (data.isEmpty) return 0;
    final sum = data.fold<double>(0, (a, b) => a + b.value);
    return sum / data.length;
  }

  String get _bestDay {
    final data = _weeklyData();
    if (data.isEmpty) return '-';
    data.sort((a, b) => b.value.compareTo(a.value));
    return data.first.key;
  }

  int get _totalDone {
    return _records.values.fold<int>(
        0,
        (sum, r) =>
            sum + r.completedActivities.values.where((v) => v).length);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final weekData = _weeklyData();

    return Directionality(
      textDirection: widget.isPersian ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              s.weeklyAnalysis,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 16),
            _buildStatsRow(),
            const SizedBox(height: 16),
            _buildChartCard(weekData),
            const SizedBox(height: 16),
            _buildTypeBreakdown(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
            child: _statCard(
                '${(_avgCompletion * 100).round()}%',
                s.completionRate,
                Icons.pie_chart_outline,
                AppTheme.primary)),
        const SizedBox(width: 8),
        Expanded(
            child: _statCard(
                _bestDay, s.bestDay, Icons.emoji_events_outlined, Colors.amber)),
        const SizedBox(width: 8),
        Expanded(
            child: _statCard('$_totalDone', s.totalDone,
                Icons.check_circle_outline, AppTheme.secondary)),
      ],
    );
  }

  Widget _statCard(
      String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 0.5),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary)),
          Text(label,
              style: const TextStyle(
                  fontSize: 10, color: AppTheme.textSecondary),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildChartCard(List<MapEntry<String, double>> data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.isPersian ? '۷ روز اخیر' : 'Last 7 Days',
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary)),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                maxY: 1,
                barGroups: data.asMap().entries.map((e) {
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: e.value.value,
                        color: AppTheme.primary,
                        width: 24,
                        borderRadius: BorderRadius.circular(4),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: 1,
                          color: const Color(0xFFF5F5F5),
                        ),
                      ),
                    ],
                  );
                }).toList(),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, meta) {
                        final idx = val.toInt();
                        if (idx < 0 || idx >= data.length)
                          return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            data[idx].key,
                            style: const TextStyle(
                                fontSize: 10,
                                color: AppTheme.textSecondary),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (val, meta) => Text(
                        '${(val * 100).round()}%',
                        style: const TextStyle(
                            fontSize: 10, color: AppTheme.textSecondary),
                      ),
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 0.25,
                  getDrawingHorizontalLine: (val) => const FlLine(
                      color: Color(0xFFEEEEEE), strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeBreakdown() {
    final combined = [..._weekdayActivities, ..._weekendActivities];
    final typeCounts = <ActivityType, int>{};
    for (final r in _records.values) {
      for (final entry in r.completedActivities.entries) {
        if (entry.value) {
          final activity =
              combined.firstWhere((a) => a.id == entry.key, orElse: () {
            return Activity(
              id: '',
              name: '',
              startTime: const TimeOfDaySimple(0, 0),
              endTime: const TimeOfDaySimple(0, 0),
              type: ActivityType.other,
            );
          });
          if (activity.id.isNotEmpty) {
            typeCounts[activity.type] =
                (typeCounts[activity.type] ?? 0) + 1;
          }
        }
      }
    }

    if (typeCounts.isEmpty) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.isPersian ? 'تفکیک بر اساس نوع' : 'By Activity Type',
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 12),
          ...typeCounts.entries.map((e) {
            final color = AppTheme.activityColor(e.key);
            final total =
                typeCounts.values.fold<int>(0, (a, b) => a + b);
            final pct = total > 0 ? e.value / total : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                          color: color, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 8,
                        backgroundColor: const Color(0xFFF0F0F0),
                        valueColor:
                            AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${(pct * 100).round()}%',
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.textSecondary)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
