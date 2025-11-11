import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:math' as math;

class FoundryGame extends StatefulWidget {
  final String userId;
  
  const FoundryGame({super.key, required this.userId});

  @override
  State<FoundryGame> createState() => _FoundryGameState();
}

class _FoundryGameState extends State<FoundryGame> with TickerProviderStateMixin {
  final _db = FirebaseDatabase.instance.ref();
  int _currentStep = 0;
  int? _selectedMold;
  double _fillLevel = 0.0;
  Offset _ladlePosition = const Offset(0, 0);
  bool _isPouring = false;
  late AnimationController _pouringController;
  late AnimationController _resultController;
  
  final List<Map<String, dynamic>> _levels = [
    {
      'task': 'Выберите форму для отливки шестерни с зубьями',
      'correctMold': 0,
      'molds': ['Зубчатая', 'Круглая', 'Квадратная'],
      'icons': [Icons.settings, Icons.circle_outlined, Icons.crop_square],
    },
    {
      'task': 'Выберите форму для отливки круглого колеса',
      'correctMold': 1,
      'molds': ['Треугольная', 'Круглая', 'Звездочка'],
      'icons': [Icons.change_history, Icons.circle, Icons.star_border],
    },
    {
      'task': 'Выберите форму для отливки болта',
      'correctMold': 2,
      'molds': ['Звезда', 'Круг', 'Шестигранник'],
      'icons': [Icons.star, Icons.circle, Icons.hexagon_outlined],
    },
  ];
  
  int _currentLevel = 0;
  int _completedLevels = 0;

  @override
  void initState() {
    super.initState();
    _pouringController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..addListener(() {
      if (_isPouring) {
        setState(() {
          _fillLevel = _pouringController.value;
        });
      }
    });
    
    _resultController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  @override
  void dispose() {
    _pouringController.dispose();
    _resultController.dispose();
    super.dispose();
  }

  void _selectMold(int index) {
    setState(() => _selectedMold = index);
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_selectedMold == _levels[_currentLevel]['correctMold']) {
        setState(() {
          _currentStep = 1;
          _ladlePosition = const Offset(50, 50);
        });
      } else {
        _showError();
      }
    } else if (_currentStep == 1) {
      if (_fillLevel >= 0.95) {
        _completedLevels++;
        if (_currentLevel < _levels.length - 1) {
          setState(() {
            _currentLevel++;
            _currentStep = 0;
            _selectedMold = null;
            _fillLevel = 0.0;
            _pouringController.reset();
          });
        } else {
          setState(() => _currentStep = 2);
          _resultController.forward();
          _saveResult();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Заполните форму полностью!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showError() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 30),
            const SizedBox(width: 10),
            Text(
              'Неверно!',
              style: GoogleFonts.nunito(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0A0F2D),
              ),
            ),
          ],
        ),
        content: Text(
          'Попробуйте выбрать другую форму.',
          style: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0A0F2D),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Ок'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveResult() async {
    await _db.child('users/${widget.userId}/gameResults/foundry').set({
      'completedLevels': _completedLevels,
      'totalLevels': _levels.length,
      'timestamp': DateTime.now().toIso8601String(),
    });
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
              Expanded(
                child: _currentStep == 0
                    ? _buildMoldSelection()
                    : _currentStep == 1
                        ? _buildPouringStep()
                        : _buildResultStep(),
              ),
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
                  'Игра: Литейщик',
                  style: GoogleFonts.nunito(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0A0F2D),
                  ),
                ),
                Text(
                  'Уровень ${_currentLevel + 1}/${_levels.length}',
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

  Widget _buildMoldSelection() {
    final level = _levels[_currentLevel];
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            level['task'],
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0A0F2D),
            ),
          ),
        ),
        const SizedBox(height: 30),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
            ),
            itemCount: 3,
            itemBuilder: (context, index) {
              final isSelected = _selectedMold == index;
              return GestureDetector(
                onTap: () => _selectMold(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF6C63FF)
                        : Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF6C63FF) : Colors.transparent,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? const Color(0xFF6C63FF).withOpacity(0.5)
                            : Colors.black.withOpacity(0.1),
                        blurRadius: isSelected ? 20 : 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        level['icons'][index],
                        size: 50,
                        color: isSelected ? Colors.white : const Color(0xFF6C63FF),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        level['molds'][index],
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : const Color(0xFF0A0F2D),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _selectedMold != null ? _nextStep : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                disabledBackgroundColor: Colors.grey,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                'Далее',
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPouringStep() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Заполните форму расплавленным металлом',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0A0F2D),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                _ladlePosition = Offset(
                  (_ladlePosition.dx + details.delta.dx).clamp(0, MediaQuery.of(context).size.width - 100),
                  (_ladlePosition.dy + details.delta.dy).clamp(0, MediaQuery.of(context).size.height - 300),
                );
              });
            },
            child: Stack(
              children: [
                Center(
                  child: Container(
                    width: 200,
                    height: 250,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 100),
                          width: 200,
                          height: 250 * _fillLevel,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.orange[700]!,
                                Colors.red[700]!,
                              ],
                            ),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(17),
                              bottomRight: Radius.circular(17),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: _ladlePosition.dx,
                  top: _ladlePosition.dy,
                  child: GestureDetector(
                    onTapDown: (_) {
                      setState(() => _isPouring = true);
                      _pouringController.forward();
                    },
                    onTapUp: (_) {
                      setState(() => _isPouring = false);
                      _pouringController.stop();
                    },
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(30),
                              bottomRight: Radius.circular(30),
                            ),
                            border: Border.all(color: Colors.grey[700]!, width: 3),
                          ),
                          child: Container(
                            margin: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.orange[700]!, Colors.red[700]!],
                              ),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(25),
                                bottomRight: Radius.circular(25),
                              ),
                            ),
                          ),
                        ),
                        if (_isPouring)
                          CustomPaint(
                            size: const Size(10, 40),
                            painter: MetalStreamPainter(),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                'Заполнено: ${(_fillLevel * 100).toStringAsFixed(0)}%',
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    'Готово',
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
      ],
    );
  }

  Widget _buildResultStep() {
    return Center(
      child: AnimatedBuilder(
        animation: _resultController,
        builder: (context, child) {
          return Transform.scale(
            scale: _resultController.value,
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
                  const Icon(
                    Icons.emoji_events,
                    size: 100,
                    color: Color(0xFF6C63FF),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Отлично!',
                    style: GoogleFonts.nunito(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF0A0F2D),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Вы завершили все уровни!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0A0F2D),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Отлито уровней: $_completedLevels/${_levels.length}',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF6C63FF),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        'Завершить',
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
        },
      ),
    );
  }
}

class MetalStreamPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.orange[700]!, Colors.red[700]!],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
