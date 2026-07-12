import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../services/theme.dart';
import '../l10n/app_strings.dart';
import '../widgets/activity_tile.dart';
import 'activity_editor.dart';
import 'package:uuid/uuid.dart';

class ScheduleScreen extends StatefulWidget {
  final bool isPersian;
  const ScheduleScreen({super.key, required this.isPersian});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  List<Activity> _weekdayActivities = [];
  List<Activity> _weekendActivities = [];
  Map<String, DailyRecord> _records = {};
  int _dayOffset = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final wd = await StorageService.loadActivities(DayType.weekday);
    final we = await StorageService.loadActivities(DayType.weekend);
    final rec = await StorageService.loadRecords();
    setState(() {
      _weekdayActivities = wd;
      _weekendActivities = we;
      _records = rec;
      _loading = false;
    });
  }

  String get _todayKey {
    final d = DateTime.now().add(Duration(days: _dayOffset));
    return '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';
  }

  bool _isWeekend(int offset) {
    final d = DateTime.now().add(Duration(days: offset));
    // Friday=5, Thursday=4 in Dart weekday (1=Mon...7=Sun)
    // Persian weekend: Thursday & Friday => weekday 4 & 5
    return d.weekday == 4 || d.weekday == 5;
  }

  List<Activity> get _currentActivities =>
      _isWeekend(_dayOffset) ? _weekendActivities : _weekdayActivities;

  DailyRecord get _currentRecord =>
      _records[_todayKey] ??
      DailyRecord(date: _todayKey, completedActivities: {});

  AppStrings get s => widget.isPersian ? AppStrings.fa : AppStrings.en;

  String _dayLabel(int offset) {
    if (offset == 0) return s.today;
    if (offset == -1) return s.yesterday;
    if (offset == 1) return s.tomorrow;
    final d = DateTime.now().add(Duration(days: offset));
    final names = s.dayNames;
    // weekday: 1=Mon, 2=Tue, 3=Wed, 4=Thu, 5=Fri, 6=Sat, 7=Sun
    // Persian order: Sat=6,Sun=7,Mon=1,Tue=2,Wed=3,Thu=4,Fri=5
    final idx = [6, 0, 1, 2, 3, 4, 5][d.weekday - 1];
    return names[idx];
  }

  Future<void> _toggleActivity(String activityId) async {
    final record = _currentRecord;
    record.completedActivities[activityId] =
        !(record.completedActivities[activityId] ?? false);
    _records[_todayKey] = record;
    await StorageService.saveRecords(_records);
    setState(() {});
  }

  Future<void> _openEditor({Activity? activity, required DayType dayType}) async {
    final result = await Navigator.push<Activity?>(
      context,
      MaterialPageRoute(
        builder: (_) => ActivityEditorScreen(
          activity: activity,
          dayType: dayType,
          isPersian: widget.isPersian,
        ),
      ),
    );
    if (result != null) {
      setState(() {
        if (dayType == DayType.weekday) {
          final idx = _weekdayActivities.indexWhere((a) => a.id == result.id);
          if (idx >= 0) {
            _weekdayActivities[idx] = result;
          } else {
            _weekdayActivities.add(result);
          }
          _weekdayActivities.sort((a, b) =>
              (a.startTime.hour * 60 + a.startTime.minute)
                  .compareTo(b.startTime.hour * 60 + b.startTime.minute));
          StorageService.saveActivities(_weekdayActivities, DayType.weekday);
        } else {
          final idx = _weekendActivities.indexWhere((a) => a.id == result.id);
          if (idx >= 0) {
            _weekendActivities[idx] = result;
          } else {
            _weekendActivities.add(result);
          }
          _weekendActivities.sort((a, b) =>
              (a.startTime.hour * 60 + a.startTime.minute)
                  .compareTo(b.startTime.hour * 60 + b.startTime.minute));
          StorageService.saveActivities(_weekendActivities, DayType.weekend);
        }
      });
      NotificationService.scheduleActivityNotifications(
          _currentActivities, s.notificationTitle);
    }
  }

  Future<void> _deleteActivity(String id, DayType dayType) async {
    setState(() {
      if (dayType == DayType.weekday) {
        _weekdayActivities.removeWhere((a) => a.id == id);
        StorageService.saveActivities(_weekdayActivities, DayType.weekday);
      } else {
        _weekendActivities.removeWhere((a) => a.id == id);
        StorageService.saveActivities(_weekendActivities, DayType.weekend);
      }
    });
  }

  double get _completionRate {
    final activities = _currentActivities;
    if (activities.isEmpty) return 0;
    final done = activities
        .where((a) => _currentRecord.completedActivities[a.id] == true)
        .length;
    return done / activities.length;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final isRtl = widget.isPersian;

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: Column(
          children: [
            _buildDaySelector(),
            _buildProgressBar(),
            _buildDayTypeIndicator(),
            Expanded(child: _buildActivityList()),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _openEditor(
            dayType: _isWeekend(_dayOffset) ? DayType.weekend : DayType.weekday,
          ),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildDaySelector() {
    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => setState(() => _dayOffset--),
            icon: const Icon(Icons.chevron_left),
          ),
          Column(
            children: [
              Text(
                _dayLabel(_dayOffset),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                _todayKey,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () => setState(() => _dayOffset++),
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final rate = _completionRate;
    final done = _currentActivities
        .where((a) => _currentRecord.completedActivities[a.id] == true)
        .length;
    final total = _currentActivities.length;

    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$done ${s.of} $total ${s.completed}',
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: rate,
              minHeight: 6,
              backgroundColor: const Color(0xFFE0E0E0),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppTheme.secondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayTypeIndicator() {
    final isWeekend = _isWeekend(_dayOffset);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isWeekend
            ? const Color(0xFFE8F5E9)
            : const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isWeekend ? Icons.weekend_outlined : Icons.work_outline,
            size: 16,
            color: isWeekend
                ? const Color(0xFF2E7D32)
                : const Color(0xFF1565C0),
          ),
          const SizedBox(width: 6),
          Text(
            isWeekend
                ? (widget.isPersian ? 'پنجشنبه / جمعه' : 'Weekend')
                : (widget.isPersian ? 'روز کاری' : 'Weekday'),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isWeekend
                  ? const Color(0xFF2E7D32)
                  : const Color(0xFF1565C0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityList() {
    final activities = _currentActivities;
    if (activities.isEmpty) {
      return Center(
        child: Text(s.noActivities,
            style: const TextStyle(color: AppTheme.textSecondary)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      itemCount: activities.length,
      itemBuilder: (_, i) {
        final a = activities[i];
        final isDone = _currentRecord.completedActivities[a.id] == true;
        return ActivityTile(
          activity: a,
          isDone: isDone,
          isPersian: widget.isPersian,
          onTap: () => _toggleActivity(a.id),
          onEdit: () => _openEditor(
              activity: a,
              dayType: _isWeekend(_dayOffset)
                  ? DayType.weekend
                  : DayType.weekday),
          onDelete: () => _deleteActivity(
              a.id,
              _isWeekend(_dayOffset) ? DayType.weekend : DayType.weekday),
        );
      },
    );
  }
}
