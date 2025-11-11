import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:math' as math;

class QCGame extends StatefulWidget {
  final String userId;
  
  const QCGame({super.key, required this.userId});

  @override
  State<QCGame> createState() => _QCGameState();
}

class _QCGameState extends State<QCGame> with TickerProviderStateMixin {
  final _db = FirebaseDatabase.instance.ref();
  int _currentLevel = 0;
  int _foundDifferences = 0;
  Set<int> _clickedDifferences = {};
  late AnimationController _shakeController;
  late AnimationController _successController;
  
  final List<Map<String, dynamic>> _levels = [
    {
      'title': 'Найдите 3 отличия',
      'totalDifferences': 3,
      'differences': [
        {'position': const Offset(0.3, 0.2), 'size': 40.0},
        {'position': const Offset(0.6, 0.5), 'size': 40.0},
        {'position': const Offset(0.4, 0.7), 'size': 40.0},
      ],
    },
    {
      'title': 'Найдите 4 отличия',
      'totalDifferences': 4,
      'differences': [
        {'position': const Offset(0.2, 0.25), 'size': 35.0},
        {'position': const Offset(0.5, 0.3), 'size': 35.0},
        {'position': const Offset(0.7, 0.6), 'size': 35.0},
        {'position': const Offset(0.35, 0.75), 'size': 35.0},
      ],
    },
    {
      'title': 'Найдите 5 отличий',
      'totalDifferences': 5,
      'differences': [
        {'position': const Offset(0.15, 0.2), 'size': 30.0},
        {'position': const Offset(0.4, 0.25), 'size': 30.0},
        {'position': const Offset(0.65, 0.35), 'size': 30.0},
        {'position': const Offset(0.3, 0.6), 'size': 30.0},
        {'position': const Offset(0.7, 0.75), 'size': 30.0},
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _successController.dispose();
    super.dispose();
  }

  void _checkDifference(Offset tapPosition, Size containerSize) {
    final level = _levels[_currentLevel];
    final differences = level['differences'] as List;
    
    for (int i = 0; i < differences.length; i++) {
      if (_clickedDifferences.contains(i)) continue;
      
      final diff = differences[i];
      final diffPosition = diff['position'] as Offset;
      final diffSize = diff['size'] as double;
      
      final actualX = diffPosition.dx * containerSize.width;
      final actualY = diffPosition.dy * containerSize.height;
      
      final distance = math.sqrt(
        math.pow(tapPosition.dx - actualX, 2) + 
        math.pow(tapPosition.dy - actualY, 2)
      );
      
      if (distance < diffSize) {
        setState(() {
          _clickedDifferences.add(i);
          _foundDifferences++;
        });
        _successController.forward().then((_) => _successController.reverse());
        
        if (_foundDifferences >= level['totalDifferences']) {
          _levelComplete();
        }
        return;
      }
    }
    
    _shakeController.forward().then((_) => _shakeController.reverse());
  }

  void _levelComplete() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_currentLevel < _levels.length - 1) {
        setState(() {
          _currentLevel++;
          _foundDifferences = 0;
          _clickedDifferences.clear();
        });
      } else {
        _saveResult();
        _showCompletionDialog();
      }
    });
  }

  Future<void> _saveResult() async {
    await _db.child('users/${widget.userId}/gameResults/qc').set({
      'completedLevels': _currentLevel + 1,
      'totalLevels': _levels.length,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.verified, size: 80, color: Color(0xFF6C63FF)),
            const SizedBox(height: 20),
            Text(
              'Поздравляем!',
              style: GoogleFonts.nunito(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF0A0F2D),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Вы успешно завершили все уровни контроля качества!',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0A0F2D),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
  }

  @override
  Widget build(BuildContext context) {
    final level = _levels[_currentLevel];
    
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
              const SizedBox(height: 20),
              _buildProgress(),
              const SizedBox(height: 20),
              Expanded(child: _buildGameArea()),
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
                  'Игра: Контролер качества',
                  style: GoogleFonts.nunito(
                    fontSize: 18,
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

  Widget _buildProgress() {
    final level = _levels[_currentLevel];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            level['title'],
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0A0F2D),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              level['totalDifferences'],
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: index < _foundDifferences
                      ? const Color(0xFF6C63FF)
                      : Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                child: index < _foundDifferences
                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameArea() {
    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        final shake = math.sin(_shakeController.value * math.pi * 4) * 10;
        return Transform.translate(
          offset: Offset(shake, 0),
          child: child,
        );
      },
      child: Row(
        children: [
          Expanded(child: _buildDetailPanel(true)),
          Expanded(child: _buildDetailPanel(false)),
        ],
      ),
    );
  }

  Widget _buildDetailPanel(bool isLeft) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return GestureDetector(
            onTapDown: (details) {
              if (isLeft) {
                _checkDifference(details.localPosition, constraints.biggest);
              }
            },
            child: AnimatedBuilder(
              animation: _successController,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isLeft
                          ? Color.lerp(const Color(0xFF6C63FF), Colors.green, _successController.value)!
                          : const Color(0xFF6C63FF),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      _buildDetailContent(isLeft, constraints.biggest),
                      if (isLeft) _buildFoundMarkers(constraints.biggest),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailContent(bool showDifferences, Size size) {
    final level = _levels[_currentLevel];
    final differences = level['differences'] as List;
    
    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.precision_manufacturing,
                size: 100,
                color: const Color(0xFF0A0F2D).withOpacity(0.3),
              ),
              const SizedBox(height: 20),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: CustomPaint(
                  painter: DetailPainter(showDifferences ? differences : [], showDifferences),
                ),
              ),
            ],
          ),
        ),
        if (showDifferences)
          ...List.generate(differences.length, (index) {
            if (_clickedDifferences.contains(index)) return const SizedBox.shrink();
            
            final diff = differences[index];
            final position = diff['position'] as Offset;
            final diffSize = diff['size'] as double;
            
            return Positioned(
              left: position.dx * size.width - diffSize / 2,
              top: position.dy * size.height - diffSize / 2,
              child: Container(
                width: diffSize,
                height: diffSize,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.3),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.red.withOpacity(0.5), width: 2),
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildFoundMarkers(Size size) {
    final level = _levels[_currentLevel];
    final differences = level['differences'] as List;
    
    return Stack(
      children: _clickedDifferences.map((index) {
        final diff = differences[index];
        final position = diff['position'] as Offset;
        final diffSize = diff['size'] as double;
        
        return Positioned(
          left: position.dx * size.width - diffSize / 2,
          top: position.dy * size.height - diffSize / 2,
          child: Container(
            width: diffSize,
            height: diffSize,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 20),
          ),
        );
      }).toList(),
    );
  }
}

class DetailPainter extends CustomPainter {
  final List differences;
  final bool showDifferences;

  DetailPainter(this.differences, this.showDifferences);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0A0F2D)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    canvas.drawRect(
      Rect.fromLTWH(20, 20, size.width - 40, size.height - 40),
      paint,
    );
    
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      20,
      paint,
    );

    if (!showDifferences) {
      final missingPaint = Paint()
        ..color = const Color(0xFF6C63FF)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(size.width * 0.3, size.height * 0.3),
        5,
        missingPaint,
      );
      
      canvas.drawCircle(
        Offset(size.width * 0.7, size.height * 0.7),
        5,
        missingPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
