import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'services/theme.dart';
import 'l10n/app_strings.dart';
import 'screens/schedule_screen.dart';
import 'screens/challenges_screen.dart';
import 'screens/analysis_screen.dart';
import 'screens/focus_screen.dart';
import 'screens/notes_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  await StorageService.rolloverStreakIfNeeded();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const PlannerApp());
}

class PlannerApp extends StatefulWidget {
  const PlannerApp({super.key});

  @override
  State<PlannerApp> createState() => _PlannerAppState();
}

class _PlannerAppState extends State<PlannerApp> {
  bool _isPersian = true;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadLang();
  }

  Future<void> _loadLang() async {
    final lang = await StorageService.loadLanguage();
    setState(() {
      _isPersian = lang;
      _loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }
    return MaterialApp(
      title: _isPersian ? AppStrings.fa.appName : AppStrings.en.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: MainScreen(
        isPersian: _isPersian,
        onLanguageChanged: (v) => setState(() => _isPersian = v),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  final bool isPersian;
  final ValueChanged<bool> onLanguageChanged;

  const MainScreen({
    super.key,
    required this.isPersian,
    required this.onLanguageChanged,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  AppStrings get s => widget.isPersian ? AppStrings.fa : AppStrings.en;

  @override
  Widget build(BuildContext context) {
    final screens = [
      ScheduleScreen(isPersian: widget.isPersian),
      ChallengesScreen(isPersian: widget.isPersian),
      FocusScreen(isPersian: widget.isPersian),
      NotesScreen(isPersian: widget.isPersian),
      AnalysisScreen(isPersian: widget.isPersian),
      SettingsScreen(
        isPersian: widget.isPersian,
        onLanguageChanged: widget.onLanguageChanged,
      ),
    ];

    final items = [
      BottomNavigationBarItem(
          icon: const Icon(Icons.calendar_today_outlined),
          activeIcon: const Icon(Icons.calendar_today),
          label: s.schedule),
      BottomNavigationBarItem(
          icon: const Icon(Icons.emoji_events_outlined),
          activeIcon: const Icon(Icons.emoji_events),
          label: s.tasks),
      BottomNavigationBarItem(
          icon: const Icon(Icons.timer_outlined),
          activeIcon: const Icon(Icons.timer),
          label: s.pomodoro),
      BottomNavigationBarItem(
          icon: const Icon(Icons.edit_note_outlined),
          activeIcon: const Icon(Icons.edit_note),
          label: s.notes),
      BottomNavigationBarItem(
          icon: const Icon(Icons.bar_chart_outlined),
          activeIcon: const Icon(Icons.bar_chart),
          label: s.analysis),
      BottomNavigationBarItem(
          icon: const Icon(Icons.settings_outlined),
          activeIcon: const Icon(Icons.settings),
          label: s.settings),
    ];

    return Directionality(
      textDirection:
          widget.isPersian ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(s.appName),
          centerTitle: true,
        ),
        body: IndexedStack(
          index: _currentIndex,
          children: screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppTheme.primary,
          unselectedItemColor: AppTheme.textSecondary,
          backgroundColor: AppTheme.surface,
          selectedLabelStyle:
              const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          elevation: 8,
          items: items,
        ),
      ),
    );
  }
}
