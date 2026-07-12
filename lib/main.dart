import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'services/theme.dart';
import 'screens/schedule_screen.dart';
import 'screens/challenges_screen.dart';
import 'screens/analysis_screen.dart';
import 'screens/focus_screen.dart';
import 'screens/notes_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  await NotificationService.init();
  await StorageService.rolloverStreakIfNeeded();
  runApp(const PlannerApp());
}

class PlannerApp extends StatefulWidget {
  const PlannerApp({Key? key}) : super(key: key);

  @override
  State<PlannerApp> createState() => _PlannerAppState();
}

class _PlannerAppState extends State<PlannerApp> {
  bool _isFarsi = true;

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  void _loadLanguage() async {
    final lang = await StorageService.loadLanguage();
    setState(() {
      _isFarsi = lang;
    });
  }

  void _toggleLanguage() async {
    setState(() {
      _isFarsi = !_isFarsi;
    });
    await StorageService.saveLanguage(_isFarsi);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _isFarsi ? 'برنامه‌ریز زندگی' : 'Life Planner',
      theme: AppTheme.lightTheme,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fa', 'IR'),
        Locale('en', 'US'),
      ],
      locale: _isFarsi ? const Locale('fa', 'IR') : const Locale('en', 'US'),
      home: MainScreen(
        isFarsi: _isFarsi,
        onLanguageChanged: _toggleLanguage,
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  final bool isFarsi;
  final VoidCallback onLanguageChanged;

  const MainScreen({
    Key? key,
    required this.isFarsi,
    required this.onLanguageChanged,
  }) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const ScheduleScreen(),
      const ChallengesScreen(),
      const AnalysisScreen(),
      const FocusScreen(),
      const NotesScreen(),
      SettingsScreen(onLanguageChanged: widget.onLanguageChanged),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final labels = widget.isFarsi
        ? ['برنامه', 'چالش', 'آنالیز', 'تمرکز', 'یادداشت', 'تنظیمات']
        : ['Schedule', 'Challenges', 'Analysis', 'Focus', 'Notes', 'Settings'];

    final icons = [
      Icons.calendar_today,
      Icons.emoji_events,
      Icons.bar_chart,
      Icons.psychology,
      Icons.note,
      Icons.settings,
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTheme.surface,
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: AppTheme.textSecondary,
        items: List.generate(
          _screens.length,
          (index) => BottomNavigationBarItem(
            icon: Icon(icons[index]),
            label: labels[index],
          ),
        ),
      ),
    );
  }
}
