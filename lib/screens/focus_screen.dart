import 'dart:async';
import 'package:flutter/material.dart';
import '../services/theme.dart';
import '../services/notification_service.dart';
import '../l10n/app_strings.dart';

class FocusScreen extends StatefulWidget {
  final bool isPersian;
  const FocusScreen({super.key, required this.isPersian});

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> {
  Timer? _timer;
  int _secondsLeft = 25 * 60;
  bool _isRunning = false;
  bool _isBreak = false;
  int _sessions = 0;
  int _workMinutes = 25;
  int _breakMinutes = 5;

  AppStrings get s => widget.isPersian ? AppStrings.fa : AppStrings.en;

  void _start() {
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        _timer?.cancel();
        setState(() {
          _isRunning = false;
          if (!_isBreak) {
            _sessions++;
            _isBreak = true;
            _secondsLeft = _breakMinutes * 60;
            NotificationService.showInstant(
                s.notificationTitle, s.pomodoroBreak);
          } else {
            _isBreak = false;
            _secondsLeft = _workMinutes * 60;
            NotificationService.showInstant(
                s.notificationTitle, s.pomodoroWork);
          }
        });
      }
    });
  }

  void _pause() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isBreak = false;
      _secondsLeft = _workMinutes * 60;
    });
  }

  String get _timeDisplay {
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  double get _progress {
    final total = (_isBreak ? _breakMinutes : _workMinutes) * 60;
    return 1 - (_secondsLeft / total);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = _isBreak ? AppTheme.secondary : AppTheme.primary;

    return Directionality(
      textDirection: widget.isPersian ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text(
                _isBreak ? s.pomodoroBreak : s.pomodoroWork,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: color),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 220,
                height: 220,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 220,
                      height: 220,
                      child: CircularProgressIndicator(
                        value: _progress,
                        strokeWidth: 10,
                        backgroundColor: const Color(0xFFEEEEEE),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _timeDisplay,
                          style: TextStyle(
                              fontSize: 52,
                              fontWeight: FontWeight.w300,
                              color: color,
                              fontFeatures: const [
                                FontFeature.tabularFigures()
                              ]),
                        ),
                        Text(
                          '$_sessions ${s.sessions}',
                          style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!_isRunning)
                    _actionBtn(s.start, Icons.play_arrow_rounded, color,
                        _start)
                  else
                    _actionBtn(s.pause, Icons.pause_rounded, color, _pause),
                  const SizedBox(width: 16),
                  _actionBtn(s.reset, Icons.refresh_rounded,
                      AppTheme.textSecondary, _reset),
                ],
              ),
              const SizedBox(height: 40),
              _buildSettings(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionBtn(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildSettings() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 0.5),
      ),
      child: Column(
        children: [
          _sliderRow(s.workTime, _workMinutes, 10, 60, (v) {
            setState(() {
              _workMinutes = v.round();
              if (!_isRunning && !_isBreak) {
                _secondsLeft = _workMinutes * 60;
              }
            });
          }),
          _sliderRow(s.breakTime, _breakMinutes, 1, 30, (v) {
            setState(() {
              _breakMinutes = v.round();
              if (!_isRunning && _isBreak) {
                _secondsLeft = _breakMinutes * 60;
              }
            });
          }),
        ],
      ),
    );
  }

  Widget _sliderRow(
      String label, int value, int min, int max, ValueChanged<double> onChanged) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(label,
              style: const TextStyle(
                  fontSize: 13, color: AppTheme.textSecondary)),
        ),
        Expanded(
          child: Slider(
            value: value.toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: max - min,
            onChanged: onChanged,
            activeColor: AppTheme.primary,
          ),
        ),
        Text('$value ${s.minutes}',
            style: const TextStyle(
                fontSize: 13, color: AppTheme.textPrimary)),
      ],
    );
  }
}
