import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/storage_service.dart';
import '../services/theme.dart';
import '../l10n/app_strings.dart';

class ChallengesScreen extends StatefulWidget {
  final bool isPersian;
  const ChallengesScreen({super.key, required this.isPersian});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  List<Challenge> _challenges = [];
  Map<String, bool> _completed = {};
  int _points = 0;
  int _streak = 0;
  String _todayKey = '';

  AppStrings get s => widget.isPersian ? AppStrings.fa : AppStrings.en;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _todayKey =
        '${now.year}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}';
    _load();
  }

  Future<void> _load() async {
    final challenges = getDailyChallenges(widget.isPersian);
    final completed = await StorageService.loadChallenges(_todayKey);
    final points = await StorageService.loadPoints();
    final streak = await StorageService.loadStreak();
    setState(() {
      _challenges = challenges;
      _completed = completed;
      _points = points;
      _streak = streak;
    });
  }

  Future<void> _toggle(Challenge ch) async {
    final wasCompleted = _completed[ch.id] ?? false;
    setState(() {
      _completed[ch.id] = !wasCompleted;
      if (!wasCompleted) {
        _points += ch.points;
      } else {
        _points = (_points - ch.points).clamp(0, 99999);
      }
    });
    await StorageService.saveChallenges(_todayKey, _completed);
    await StorageService.savePoints(_points);
  }

  int get _level => (_points / 200).floor() + 1;
  int get _levelProgress => _points % 200;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: widget.isPersian ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildStatsRow(),
            const SizedBox(height: 16),
            _buildLevelCard(),
            const SizedBox(height: 16),
            Text(
              s.challenges,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            ..._challenges.map((ch) => _buildChallengeTile(ch)),
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
                '$_points', s.points, Icons.stars_outlined, Colors.amber)),
        const SizedBox(width: 12),
        Expanded(
            child: _statCard(
                '$_streak', s.streak, Icons.local_fire_department_outlined,
                Colors.deepOrange)),
      ],
    );
  }

  Widget _statCard(
      String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 0.5),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary)),
              Text(label,
                  style: const TextStyle(
                      fontSize: 12, color: AppTheme.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLevelCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary.withOpacity(0.8),
            AppTheme.primary,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${s.level} $_level',
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _levelProgress / 200,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$_levelProgress / 200 ${s.points}',
            style: TextStyle(
                fontSize: 12, color: Colors.white.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeTile(Challenge ch) {
    final done = _completed[ch.id] ?? false;
    return GestureDetector(
      onTap: () => _toggle(ch),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: done
              ? const Color(0xFFE8F5E9)
              : AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: done
                ? AppTheme.secondary
                : const Color(0xFFE0E0E0),
            width: done ? 1 : 0.5,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done ? AppTheme.secondary : Colors.transparent,
                border: Border.all(
                  color: done ? AppTheme.secondary : const Color(0xFFBDBDBD),
                  width: 1.5,
                ),
              ),
              child: done
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.isPersian ? ch.titleFa : ch.titleEn,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                  decoration: done ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '+${ch.points} ${s.points}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.amber,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
