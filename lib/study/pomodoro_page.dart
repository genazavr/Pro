import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../theme/theme_manager.dart';
import '../theme/app_theme.dart';

class PomodoroPage extends StatefulWidget {
  final String userId;
  const PomodoroPage({super.key, required this.userId});

  @override
  State<PomodoroPage> createState() => _PomodoroPageState();
}

class _PomodoroPageState extends State<PomodoroPage> with TickerProviderStateMixin {
  final _db = FirebaseDatabase.instance.ref();
  Timer? _timer;
  int _seconds = 25 * 60;
  bool _isRunning = false;
  bool _isWorkMode = true;
  int _completedPomodoros = 0;
  late AnimationController _pulseController;
  
  int _workDuration = 25;
  int _shortBreak = 5;
  int _longBreak = 15;
  int _pomodorosUntilLongBreak = 4;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _loadSettings();
    _loadStats();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final snap = await _db.child('users/${widget.userId}/pomodoro/settings').get();
    if (snap.exists) {
      final data = snap.value as Map;
      setState(() {
        _workDuration = data['workDuration'] ?? 25;
        _shortBreak = data['shortBreak'] ?? 5;
        _longBreak = data['longBreak'] ?? 15;
        _pomodorosUntilLongBreak = data['pomodorosUntilLongBreak'] ?? 4;
        _seconds = _workDuration * 60;
      });
    }
  }

  Future<void> _loadStats() async {
    final snap = await _db.child('users/${widget.userId}/pomodoro/stats/completed').get();
    if (snap.exists) {
      setState(() => _completedPomodoros = int.tryParse(snap.value.toString()) ?? 0);
    }
  }

  void _startStop() {
    setState(() {
      _isRunning = !_isRunning;
      if (_isRunning) {
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            if (_seconds > 0) {
              _seconds--;
            } else {
              _onTimerComplete();
            }
          });
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  void _onTimerComplete() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      if (_isWorkMode) {
        _completedPomodoros++;
        _db.child('users/${widget.userId}/pomodoro/stats/completed').set(_completedPomodoros);
        _db.child('users/${widget.userId}/pomodoro/history/${DateTime.now().millisecondsSinceEpoch}').set({
          'date': DateTime.now().toIso8601String(),
          'duration': _workDuration,
        });
        
        final isLongBreak = _completedPomodoros % _pomodorosUntilLongBreak == 0;
        _seconds = (isLongBreak ? _longBreak : _shortBreak) * 60;
        _isWorkMode = false;
      } else {
        _seconds = _workDuration * 60;
        _isWorkMode = true;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isWorkMode ? 'Перерыв окончен! Время работать 💪' : 'Помодоро завершено! Отдохните 🎉',
          style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
        ),
        backgroundColor: _isWorkMode ? Colors.green : Colors.blue,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _seconds = _workDuration * 60;
      _isWorkMode = true;
    });
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _buildSettingsSheet(),
    );
  }

  Widget _buildSettingsSheet() {
    int tempWork = _workDuration;
    int tempShort = _shortBreak;
    int tempLong = _longBreak;
    int tempPomodorosUntilLong = _pomodorosUntilLongBreak;

    return StatefulBuilder(
      builder: (context, setModalState) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Настройки таймера',
                style: GoogleFonts.nunito(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 24),
              _buildSliderSetting('Работа (мин)', tempWork, 15, 60, (val) {
                setModalState(() => tempWork = val);
              }),
              _buildSliderSetting('Короткий перерыв (мин)', tempShort, 3, 15, (val) {
                setModalState(() => tempShort = val);
              }),
              _buildSliderSetting('Длинный перерыв (мин)', tempLong, 10, 30, (val) {
                setModalState(() => tempLong = val);
              }),
              _buildSliderSetting('Помодоро до длинного перерыва', tempPomodorosUntilLong, 2, 8, (val) {
                setModalState(() => tempPomodorosUntilLong = val);
              }),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _workDuration = tempWork;
                    _shortBreak = tempShort;
                    _longBreak = tempLong;
                    _pomodorosUntilLongBreak = tempPomodorosUntilLong;
                    if (!_isRunning) _seconds = _workDuration * 60;
                  });
                  _db.child('users/${widget.userId}/pomodoro/settings').set({
                    'workDuration': tempWork,
                    'shortBreak': tempShort,
                    'longBreak': tempLong,
                    'pomodorosUntilLongBreak': tempPomodorosUntilLong,
                  });
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF3124),
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  'Сохранить',
                  style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSliderSetting(String label, int value, int min, int max, ValueChanged<int> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: $value',
          style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        Slider(
          value: value.toDouble(),
          min: min.toDouble(),
          max: max.toDouble(),
          divisions: max - min,
          activeColor: const Color(0xFFEF3124),
          onChanged: (val) => onChanged(val.toInt()),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeManager>().currentTheme;
    final minutes = _seconds ~/ 60;
    final seconds = _seconds % 60;

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(theme),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.getPrimaryColor(theme)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Pomodoro Таймер',
          style: GoogleFonts.nunito(
            color: AppTheme.getPrimaryColor(theme),
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: AppTheme.getPrimaryColor(theme)),
            onPressed: _showSettings,
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _isWorkMode ? 'Время работать 📚' : 'Время отдохнуть ☕',
                style: GoogleFonts.nunito(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.getPrimaryColor(theme),
                ),
              ),
              const SizedBox(height: 40),
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final scale = _isRunning ? 1.0 + (_pulseController.value * 0.05) : 1.0;
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: (_isWorkMode ? const Color(0xFFEF3124) : Colors.blue).withOpacity(0.3),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                          style: GoogleFonts.nunito(
                            fontSize: 64,
                            fontWeight: FontWeight.w900,
                            color: _isWorkMode ? const Color(0xFFEF3124) : Colors.blue,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildControlButton(
                    icon: _isRunning ? Icons.pause : Icons.play_arrow,
                    onTap: _startStop,
                    color: _isWorkMode ? const Color(0xFFEF3124) : Colors.blue,
                  ),
                  const SizedBox(width: 20),
                  _buildControlButton(
                    icon: Icons.stop,
                    onTap: _reset,
                    color: Colors.grey[700]!,
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.getPrimaryColor(theme).withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(Icons.emoji_events, size: 48, color: Colors.amber[700]),
                    const SizedBox(height: 12),
                    Text(
                      'Завершено помодоро',
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$_completedPomodoros',
                      style: GoogleFonts.nunito(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.getPrimaryColor(theme),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({required IconData icon, required VoidCallback onTap, required Color color}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 36),
      ),
    );
  }
}
