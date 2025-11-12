import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:math' as math;

class StamperGame extends StatefulWidget {
  final String userId;
  
  const StamperGame({super.key, required this.userId});

  @override
  State<StamperGame> createState() => _StamperGameState();
}

class _StamperGameState extends State<StamperGame> with TickerProviderStateMixin {
  final _db = FirebaseDatabase.instance.ref();
  late AnimationController _indicatorController;
  late AnimationController _stampController;
  late AnimationController _resultController;
  
  bool _isGameActive = false;
  bool _hasPressed = false;
  double _accuracy = 0.0;
  int _currentRound = 0;
  int _currentLevel = 0;
  final int _totalRounds = 5;
  final List<double> _accuracyHistory = [];
  
  double _getIndicatorDuration() {
    final baseDuration = 21.0;
    final speedIncrease = _currentLevel * 0.5;
    return (baseDuration - speedIncrease).clamp(15.0, 21.0);
  }
  
  @override
  void initState() {
    super.initState();
    _updateIndicatorController();
    _indicatorController.addListener(() {
      if (_indicatorController.value == 1.0 && !_hasPressed) {
        _onMissed();
      }
    });
    
    _stampController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _resultController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  void _updateIndicatorController() {
    _indicatorController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (_getIndicatorDuration() * 1000).toInt()),
    );
  }

  @override
  void dispose() {
    _indicatorController.dispose();
    _stampController.dispose();
    _resultController.dispose();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _isGameActive = true;
      _currentRound = 0;
      _currentLevel = 0;
      _accuracyHistory.clear();
    });
    _startRound();
  }

  void _startRound() {
    if (_currentRound > 0 && _currentRound % 5 == 0) {
      setState(() => _currentLevel++);
      _indicatorController.dispose();
      _updateIndicatorController();
    }
    setState(() {
      _hasPressed = false;
      _accuracy = 0.0;
    });
    _indicatorController.reset();
    _indicatorController.forward();
  }

  void _onPress() {
    if (!_isGameActive || _hasPressed) return;
    
    setState(() => _hasPressed = true);
    _indicatorController.stop();
    
    final value = _indicatorController.value;
    final targetZone = (value - 0.5).abs();
    _accuracy = ((1.0 - targetZone * 2) * 100).clamp(0, 100);
    _accuracyHistory.add(_accuracy);
    
    _stampController.forward().then((_) {
      _stampController.reverse();
      Future.delayed(const Duration(milliseconds: 500), () {
        if (_currentRound < _totalRounds - 1) {
          setState(() => _currentRound++);
          _startRound();
        } else {
          _finishGame();
        }
      });
    });
  }

  void _onMissed() {
    if (!_isGameActive || _hasPressed) return;
    
    setState(() {
      _hasPressed = true;
      _accuracy = 0.0;
    });
    _accuracyHistory.add(0.0);
    
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_currentRound < _totalRounds - 1) {
        setState(() => _currentRound++);
        _startRound();
      } else {
        _finishGame();
      }
    });
  }

  void _finishGame() {
    setState(() => _isGameActive = false);
    _resultController.forward();
    _saveResult();
  }

  Future<void> _saveResult() async {
    final avgAccuracy = _accuracyHistory.isEmpty
        ? 0.0
        : _accuracyHistory.reduce((a, b) => a + b) / _accuracyHistory.length;
    
    await _db.child('users/${widget.userId}/gameResults/stamper').set({
      'averageAccuracy': avgAccuracy,
      'rounds': _totalRounds,
      'accuracyHistory': _accuracyHistory,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  double get _averageAccuracy {
    if (_accuracyHistory.isEmpty) return 0.0;
    return _accuracyHistory.reduce((a, b) => a + b) / _accuracyHistory.length;
  }

  Color _getAccuracyColor(double accuracy) {
    if (accuracy >= 80) return Colors.green;
    if (accuracy >= 60) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F2D),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF0A0F2D),
              const Color(0xFF1E3A8A).withOpacity(0.3),
              const Color(0xFF0A0F2D),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              if (!_isGameActive && _accuracyHistory.isEmpty)
                Expanded(child: _buildStartScreen())
              else if (!_isGameActive && _accuracyHistory.isNotEmpty)
                Expanded(child: _buildResultScreen())
              else
                Expanded(child: _buildGameScreen()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Material(
            color: const Color(0xFF6C63FF).withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => Navigator.pop(context),
              child: const SizedBox(
                height: 44,
                width: 44,
                child: Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0A0F2D)),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Игра: Штамповщик',
                  style: GoogleFonts.nunito(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0A0F2D),
                  ),
                ),
                if (_isGameActive)
                  Text(
                    'Раунд ${_currentRound + 1}/$_totalRounds',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6C63FF),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartScreen() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C63FF).withOpacity(0.3),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.touch_app,
              size: 100,
              color: Color(0xFF6C63FF),
            ),
            const SizedBox(height: 20),
            Text(
              'Как играть',
              style: GoogleFonts.nunito(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF0A0F2D),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Нажимайте кнопку "Штамп", когда индикатор окажется в зеленой зоне!',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0A0F2D),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Чем точнее попадание, тем выше результат.',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6C63FF),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _startGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  'Начать игру',
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: AnimatedBuilder(
            animation: _indicatorController,
            builder: (context, child) {
              return Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(27.5),
                    ),
                  ),
                  Positioned(
                    left: 5 + (_indicatorController.value * (MediaQuery.of(context).size.width - 90)),
                    top: 5,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6C63FF), Color(0xFF4A90E2)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6C63FF).withOpacity(0.5),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Center(
                      child: Container(
                        width: 80,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.green, width: 2),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 60),
        AnimatedBuilder(
          animation: _stampController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _stampController.value * 20),
              child: GestureDetector(
                onTap: _onPress,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF6C63FF),
                        const Color(0xFF4A90E2),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6C63FF).withOpacity(0.5),
                        blurRadius: 30,
                        offset: Offset(0, 10 + _stampController.value * 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.pan_tool,
                        size: 60,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'ШТАМП',
                        style: GoogleFonts.nunito(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 40),
        if (_hasPressed)
          AnimatedOpacity(
            opacity: _hasPressed ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              decoration: BoxDecoration(
                color: _getAccuracyColor(_accuracy).withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _getAccuracyColor(_accuracy),
                  width: 3,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    '${_accuracy.toStringAsFixed(0)}%',
                    style: GoogleFonts.nunito(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: _getAccuracyColor(_accuracy),
                    ),
                  ),
                  Text(
                    _accuracy >= 80
                        ? 'Отлично!'
                        : _accuracy >= 60
                            ? 'Хорошо!'
                            : 'Попробуй еще!',
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _getAccuracyColor(_accuracy),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildResultScreen() {
    return AnimatedBuilder(
      animation: _resultController,
      builder: (context, child) {
        return Transform.scale(
          scale: _resultController.value,
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6C63FF).withOpacity(0.5),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _averageAccuracy >= 80
                        ? Icons.emoji_events
                        : _averageAccuracy >= 60
                            ? Icons.thumb_up
                            : Icons.refresh,
                    size: 100,
                    color: _getAccuracyColor(_averageAccuracy),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _averageAccuracy >= 80
                        ? 'Превосходно!'
                        : _averageAccuracy >= 60
                            ? 'Хороший результат!'
                            : 'Можно лучше!',
                    style: GoogleFonts.nunito(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF0A0F2D),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Средняя точность',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0A0F2D),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${_averageAccuracy.toStringAsFixed(1)}%',
                    style: GoogleFonts.nunito(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: _getAccuracyColor(_averageAccuracy),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...List.generate(_accuracyHistory.length, (index) {
                    final accuracy = _accuracyHistory[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _getAccuracyColor(accuracy).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getAccuracyColor(accuracy).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Раунд ${index + 1}',
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF0A0F2D),
                            ),
                          ),
                          Text(
                            '${accuracy.toStringAsFixed(0)}%',
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _getAccuracyColor(accuracy),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _accuracyHistory.clear();
                                _resultController.reset();
                              });
                              _startGame();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6C63FF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              'Еще раз',
                              style: GoogleFonts.nunito(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF6C63FF), width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              'Выход',
                              style: GoogleFonts.nunito(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF6C63FF),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
