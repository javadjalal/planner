import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/theme.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onLanguageChanged;

  const SettingsScreen({Key? key, required this.onLanguageChanged})
      : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _shortGoalController;
  late TextEditingController _longGoalController;
  bool _isFarsi = true;

  @override
  void initState() {
    super.initState();
    _shortGoalController = TextEditingController();
    _longGoalController = TextEditingController();
    _loadSettings();
  }

  void _loadSettings() async {
    final shortGoal = await StorageService.loadShortGoal();
    final longGoal = await StorageService.loadLongGoal();
    final lang = await StorageService.loadLanguage();

    setState(() {
      _shortGoalController.text = shortGoal;
      _longGoalController.text = longGoal;
      _isFarsi = lang;
    });
  }

  void _saveGoals() async {
    await StorageService.saveGoals(
      _shortGoalController.text,
      _longGoalController.text,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Goals saved')),
    );
  }

  void _toggleLanguage(bool value) async {
    setState(() {
      _isFarsi = value;
    });
    await StorageService.saveLanguage(value);
    widget.onLanguageChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppTheme.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Language Setting
            Text(
              'Language',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppTheme.primary.withOpacity(0.2),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Farsi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Use Farsi language',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isFarsi,
                    onChanged: _toggleLanguage,
                    activeColor: AppTheme.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'English',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              value: !_isFarsi,
              onChanged: (value) => _toggleLanguage(!value),
              title: const Text('Use English language'),
              activeColor: AppTheme.primary,
            ),
            const SizedBox(height: 32),
            // Goals
            Text(
              'Goals',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _shortGoalController,
              decoration: InputDecoration(
                labelText: 'Short-term Goal',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: AppTheme.surfaceVariant,
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _longGoalController,
              decoration: InputDecoration(
                labelText: 'Long-term Goal',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: AppTheme.surfaceVariant,
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveGoals,
                child: const Text('Save Goals'),
              ),
            ),
            const SizedBox(height: 32),
            // About
            Text(
              'About',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Life Planner',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'A comprehensive app for scheduling, tracking challenges, and maintaining focus.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _shortGoalController.dispose();
    _longGoalController.dispose();
    super.dispose();
  }
}
