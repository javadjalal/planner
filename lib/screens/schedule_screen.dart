import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../services/theme.dart';
import '../models/activity.dart';
import '../widgets/activity_tile.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({Key? key}) : super(key: key);

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  List<Activity> _weekdayActivities = [];
  List<Activity> _weekendActivities = [];
  bool _isWeekday = true;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  void _loadActivities() async {
    final wd = await StorageService.loadActivities(DayType.weekday);
    final we = await StorageService.loadActivities(DayType.weekend);
    setState(() {
      _weekdayActivities = wd;
      _weekendActivities = we;
    });
  }

  void _saveActivities() async {
    await StorageService.saveActivities(_weekdayActivities, DayType.weekday);
    await StorageService.saveActivities(_weekendActivities, DayType.weekend);
    await NotificationService.scheduleActivityNotifications(_weekdayActivities);
  }

  void _addActivity() {
    final nameController = TextEditingController();
    final timeController = TextEditingController();
    String selectedCategory = 'study';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Activity'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Activity Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: timeController,
              decoration: const InputDecoration(labelText: 'Time (HH:MM)'),
            ),
            const SizedBox(height: 12),
            DropdownButton<String>(
              value: selectedCategory,
              onChanged: (value) {
                selectedCategory = value ?? 'study';
              },
              items: ['study', 'exercise', 'work', 'rest', 'meditation', 'reading']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                final activity = Activity(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  category: selectedCategory,
                  startTime: timeController.text.isEmpty ? null : timeController.text,
                );
                setState(() {
                  if (_isWeekday) {
                    _weekdayActivities.add(activity);
                  } else {
                    _weekendActivities.add(activity);
                  }
                });
                _saveActivities();
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _toggleActivity(int index, bool value) {
    setState(() {
      final activity = _isWeekday ? _weekdayActivities[index] : _weekendActivities[index];
      final updated = activity.copyWith(completed: value);
      if (_isWeekday) {
        _weekdayActivities[index] = updated;
      } else {
        _weekendActivities[index] = updated;
      }
    });
    _saveActivities();
  }

  void _deleteActivity(int index) {
    setState(() {
      if (_isWeekday) {
        _weekdayActivities.removeAt(index);
      } else {
        _weekendActivities.removeAt(index);
      }
    });
    _saveActivities();
  }

  @override
  Widget build(BuildContext context) {
    final activities = _isWeekday ? _weekdayActivities : _weekendActivities;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule'),
        backgroundColor: AppTheme.surface,
      ),
      body: Column(
        children: [
          Container(
            color: AppTheme.surface,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isWeekday = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _isWeekday ? AppTheme.primary : AppTheme.background,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Weekday',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _isWeekday ? Colors.white : AppTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isWeekday = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !_isWeekday ? AppTheme.primary : AppTheme.background,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Weekend',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: !_isWeekday ? Colors.white : AppTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: activities.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_today,
                            size: 64, color: AppTheme.textSecondary),
                        const SizedBox(height: 16),
                        Text(
                          'No activities yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: activities.length,
                    itemBuilder: (context, index) {
                      final activity = activities[index];
                      return ActivityTile(
                        activity: activity,
                        onTap: () {},
                        onDelete: () => _deleteActivity(index),
                        onCompleted: (value) =>
                            _toggleActivity(index, value ?? false),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addActivity,
        child: const Icon(Icons.add),
      ),
    );
  }
}
