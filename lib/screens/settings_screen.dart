import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/theme.dart';
import '../l10n/app_strings.dart';

class SettingsScreen extends StatefulWidget {
  final bool isPersian;
  final ValueChanged<bool> onLanguageChanged;

  const SettingsScreen({
    super.key,
    required this.isPersian,
    required this.onLanguageChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _shortGoalCtrl;
  late TextEditingController _longGoalCtrl;
  bool _loading = true;

  AppStrings get s => widget.isPersian ? AppStrings.fa : AppStrings.en;

  @override
  void initState() {
    super.initState();
    _shortGoalCtrl = TextEditingController();
    _longGoalCtrl = TextEditingController();
    _load();
  }

  Future<void> _load() async {
    final short = await StorageService.loadShortGoal();
    final long = await StorageService.loadLongGoal();
    setState(() {
      _shortGoalCtrl.text = short;
      _longGoalCtrl.text = long;
      _loading = false;
    });
  }

  Future<void> _saveGoals() async {
    await StorageService.saveGoals(
        _shortGoalCtrl.text, _longGoalCtrl.text);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isPersian ? 'ذخیره شد' : 'Saved'),
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
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSection(
                    s.language,
                    Icons.language,
                    [
                      Row(
                        children: [
                          Expanded(
                            child: _langBtn(
                              s.persian,
                              widget.isPersian,
                              () {
                                widget.onLanguageChanged(true);
                                StorageService.saveLanguage(true);
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _langBtn(
                              s.english,
                              !widget.isPersian,
                              () {
                                widget.onLanguageChanged(false);
                                StorageService.saveLanguage(false);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    s.myGoals,
                    Icons.flag_outlined,
                    [
                      Text(s.shortTermGoal,
                          style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _shortGoalCtrl,
                        decoration: InputDecoration(
                          hintText: s.goalPlaceholderShort,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      Text(s.longTermGoal,
                          style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _longGoalCtrl,
                        decoration: InputDecoration(
                          hintText: s.goalPlaceholderLong,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saveGoals,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text(s.save),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildGoalsDisplay(),
                ],
              ),
      ),
    );
  }

  Widget _buildGoalsDisplay() {
    final short = _shortGoalCtrl.text;
    final long = _longGoalCtrl.text;
    if (short.isEmpty && long.isEmpty) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.secondary.withOpacity(0.1),
            AppTheme.primary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppTheme.primary.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.visibility_outlined,
                  size: 18, color: AppTheme.primary),
              const SizedBox(width: 8),
              Text(
                widget.isPersian ? 'اهداف من' : 'My Goals',
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary),
              ),
            ],
          ),
          if (short.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              widget.isPersian ? '🎯 کوتاه‌مدت' : '🎯 Short-term',
              style: const TextStyle(
                  fontSize: 12, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 4),
            Text(short,
                style: const TextStyle(
                    fontSize: 14, color: AppTheme.textPrimary)),
          ],
          if (long.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              widget.isPersian ? '🚀 بلندمدت' : '🚀 Long-term',
              style: const TextStyle(
                  fontSize: 12, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 4),
            Text(long,
                style: const TextStyle(
                    fontSize: 14, color: AppTheme.textPrimary)),
          ],
        ],
      ),
    );
  }

  Widget _buildSection(
      String title, IconData icon, List<Widget> children) {
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
          Row(
            children: [
              Icon(icon, size: 18, color: AppTheme.primary),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary)),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _langBtn(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppTheme.primary : const Color(0xFFE0E0E0),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}
