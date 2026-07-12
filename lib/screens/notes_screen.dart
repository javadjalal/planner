import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/storage_service.dart';
import '../services/theme.dart';
import '../l10n/app_strings.dart';

class NotesScreen extends StatefulWidget {
  final bool isPersian;
  const NotesScreen({super.key, required this.isPersian});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  Map<String, DailyRecord> _records = {};
  late TextEditingController _ctrl;
  String _todayKey = '';
  bool _loading = true;

  AppStrings get s => widget.isPersian ? AppStrings.fa : AppStrings.en;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController();
    final now = DateTime.now();
    _todayKey =
        '${now.year}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}';
    _load();
  }

  Future<void> _load() async {
    final records = await StorageService.loadRecords();
    setState(() {
      _records = records;
      _ctrl.text = records[_todayKey]?.note ?? '';
      _loading = false;
    });
  }

  Future<void> _save() async {
    final record = _records[_todayKey] ??
        DailyRecord(date: _todayKey, completedActivities: {});
    record.note = _ctrl.text;
    _records[_todayKey] = record;
    await StorageService.saveRecords(_records);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isPersian ? 'یادداشت ذخیره شد' : 'Note saved'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: widget.isPersian ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.dailyNote,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _todayKey,
                      style: const TextStyle(
                          fontSize: 13, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: const Color(0xFFE0E0E0), width: 0.5),
                        ),
                        child: TextField(
                          controller: _ctrl,
                          maxLines: null,
                          expands: true,
                          textAlign: widget.isPersian
                              ? TextAlign.right
                              : TextAlign.left,
                          decoration: InputDecoration(
                            hintText: s.writeNote,
                            border: InputBorder.none,
                            hintStyle: const TextStyle(
                                color: AppTheme.textSecondary),
                          ),
                          style: const TextStyle(
                              fontSize: 15,
                              color: AppTheme.textPrimary,
                              height: 1.6),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _save,
                        icon: const Icon(Icons.save_outlined),
                        label: Text(s.save),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_records.isNotEmpty) _buildPastNotes(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildPastNotes() {
    final past = _records.entries
        .where((e) => e.key != _todayKey && e.value.note.isNotEmpty)
        .toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    if (past.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.isPersian ? 'یادداشت‌های قبلی' : 'Past Notes',
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: past.take(5).length,
            itemBuilder: (_, i) {
              final entry = past[i];
              return Container(
                width: 180,
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: const Color(0xFFE0E0E0), width: 0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      entry.value.note,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.textPrimary),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
