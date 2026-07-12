import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../services/theme.dart';
import '../l10n/app_strings.dart';

class ActivityEditorScreen extends StatefulWidget {
  final Activity? activity;
  final DayType dayType;
  final bool isPersian;

  const ActivityEditorScreen({
    super.key,
    this.activity,
    required this.dayType,
    required this.isPersian,
  });

  @override
  State<ActivityEditorScreen> createState() => _ActivityEditorScreenState();
}

class _ActivityEditorScreenState extends State<ActivityEditorScreen> {
  late TextEditingController _nameCtrl;
  late TimeOfDaySimple _startTime;
  late TimeOfDaySimple _endTime;
  late ActivityType _type;
  late bool _alarmEnabled;
  late DayType _dayType;

  AppStrings get s => widget.isPersian ? AppStrings.fa : AppStrings.en;

  @override
  void initState() {
    super.initState();
    final a = widget.activity;
    _nameCtrl = TextEditingController(text: a?.name ?? '');
    _startTime = a?.startTime ?? const TimeOfDaySimple(8, 0);
    _endTime = a?.endTime ?? const TimeOfDaySimple(9, 0);
    _type = a?.type ?? ActivityType.other;
    _alarmEnabled = a?.alarmEnabled ?? true;
    _dayType = a?.dayType ?? widget.dayType;
  }

  Future<void> _pickTime(bool isStart) async {
    final current = isStart ? _startTime : _endTime;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current.hour, minute: current.minute),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = TimeOfDaySimple(picked.hour, picked.minute);
        } else {
          _endTime = TimeOfDaySimple(picked.hour, picked.minute);
        }
      });
    }
  }

  void _save() {
    if (_nameCtrl.text.trim().isEmpty) return;
    final activity = Activity(
      id: widget.activity?.id ?? const Uuid().v4(),
      name: _nameCtrl.text.trim(),
      startTime: _startTime,
      endTime: _endTime,
      type: _type,
      alarmEnabled: _alarmEnabled,
      dayType: _dayType,
    );
    Navigator.pop(context, activity);
  }

  String _typeName(ActivityType t) {
    switch (t) {
      case ActivityType.work:
        return s.typeWork;
      case ActivityType.study:
        return s.typeStudy;
      case ActivityType.gym:
        return s.typeGym;
      case ActivityType.rest:
        return s.typeRest;
      case ActivityType.review:
        return s.typeReview;
      case ActivityType.other:
        return s.typeOther;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          widget.isPersian ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.activity == null ? s.addActivity : s.editActivity),
          actions: [
            TextButton(
              onPressed: _save,
              child: Text(s.save,
                  style: const TextStyle(color: AppTheme.primary)),
            )
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildCard([
              TextField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  labelText: s.activityName,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            _buildCard([
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(s.startTime),
                trailing: TextButton(
                  onPressed: () => _pickTime(true),
                  child: Text(_startTime.format(),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(s.endTime),
                trailing: TextButton(
                  onPressed: () => _pickTime(false),
                  child: Text(_endTime.format(),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            _buildCard([
              Text(s.activityType,
                  style: const TextStyle(
                      fontSize: 14, color: AppTheme.textSecondary)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ActivityType.values.map((t) {
                  final selected = t == _type;
                  final color = AppTheme.activityColor(t);
                  return GestureDetector(
                    onTap: () => setState(() => _type = t),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color:
                            selected ? color : color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: color,
                            width: selected ? 0 : 1),
                      ),
                      child: Text(
                        _typeName(t),
                        style: TextStyle(
                          fontSize: 13,
                          color: selected ? Colors.white : color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ]),
            const SizedBox(height: 12),
            _buildCard([
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(s.enableAlarm),
                value: _alarmEnabled,
                onChanged: (v) => setState(() => _alarmEnabled = v),
                activeColor: AppTheme.primary,
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 0.5),
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }
}
