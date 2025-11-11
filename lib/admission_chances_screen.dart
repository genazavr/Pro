import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

class AdmissionChancesScreen extends StatefulWidget {
  final String userId;
  const AdmissionChancesScreen({super.key, required this.userId});

  @override
  State<AdmissionChancesScreen> createState() => _AdmissionChancesScreenState();
}

class _AdmissionChancesScreenState extends State<AdmissionChancesScreen> with SingleTickerProviderStateMixin {
  final _db = FirebaseDatabase.instance.ref();
  late AnimationController _starController;
  final List<Star> _stars = [];
  final Random _random = Random();
  
  final TextEditingController _scoreController = TextEditingController();
  List<Map<String, dynamic>> professions = [];
  List<Map<String, dynamic>> chances = [];
  bool _calculated = false;

  @override
  void initState() {
    super.initState();
    _starController = AnimationController(
      duration: const Duration(seconds: 25),
      vsync: this,
    )..repeat();
    _initializeStars();
    _loadProfessions();
  }

  void _initializeStars() {
    for (int i = 0; i < 80; i++) {
      _stars.add(Star(
        x: _random.nextDouble() * 1.5 - 0.5,
        y: _random.nextDouble() * 2 - 1,
        speed: 0.3 + _random.nextDouble() * 0.7,
        size: 2.0 + _random.nextDouble() * 4.0,
        delay: _random.nextDouble() * 3.0,
        brightness: 0.6 + _random.nextDouble() * 0.4,
      ));
    }
  }

  Widget _buildStarBackground() {
    return AnimatedBuilder(
      animation: _starController,
      builder: (context, child) {
        return Stack(
          children: _stars.map((star) {
            final progress = (_starController.value * star.speed + star.delay) % 2.0;
            final x = star.x + progress * 1.5;
            final y = star.y + progress * 1.5;
            final opacity = x > 0 && x < 1.5 && y > -0.5 && y < 1.5
                ? (1.0 - (progress / 2.0).abs()) * star.brightness
                : 0.0;

            final pulse = (sin(_starController.value * 5 * pi + star.delay * 8) + 1) / 2;
            final currentOpacity = opacity * (0.8 + 0.2 * pulse);

            return Positioned(
              left: x * MediaQuery.of(context).size.width,
              top: y * MediaQuery.of(context).size.height,
              child: Opacity(
                opacity: currentOpacity.clamp(0.0, 1.0),
                child: Container(
                  width: star.size,
                  height: star.size,
                  decoration: BoxDecoration(
                    color: Colors.yellow,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.yellow.withOpacity(0.9),
                        blurRadius: star.size * 3,
                        spreadRadius: star.size * 0.8,
                      ),
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.6),
                        blurRadius: star.size * 6,
                        spreadRadius: star.size * 2,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Future<void> _loadProfessions() async {
    try {
      final snap = await _db.child('professions').get();
      if (snap.exists && snap.value != null) {
        final data = snap.value as Map<dynamic, dynamic>;
        setState(() {
          professions = data.entries.map((e) {
            final prof = e.value as Map<dynamic, dynamic>;
            return {
              'name': prof['name']?.toString() ?? 'Профессия',
              'difficulty': (prof['difficulty'] ?? 5).toString(),
            };
          }).toList();
        });
      }
    } catch (e) {
      debugPrint('Error loading professions: $e');
    }
  }

  void _calculateChances() {
    final score = int.tryParse(_scoreController.text);
    if (score == null || score < 0 || score > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Введите балл от 0 до 100',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      chances = professions.map((prof) {
        final difficulty = int.tryParse(prof['difficulty'] ?? '5') ?? 5;
        final baseChance = (100 - (difficulty * 10)).clamp(10, 100);
        final chance = ((score / 100) * baseChance).toInt().clamp(10, 100);
        return {
          ...prof,
          'chance': chance,
          'color': chance >= 80 ? Colors.green : chance >= 50 ? Colors.orange : Colors.red,
        };
      }).toList();
      _calculated = true;
    });
  }

  @override
  void dispose() {
    _starController.dispose();
    _scoreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F2D),
      body: Stack(
        children: [
          _buildStarBackground(),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF0A0F2D).withOpacity(0.6),
                  const Color(0xFF1E3A8A).withOpacity(0.4),
                  const Color(0xFF0A0F2D).withOpacity(0.6),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      Expanded(
                        child: Text(
                          'Шансы поступления',
                          style: GoogleFonts.nunito(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (!_calculated) ...[
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6C63FF).withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Введите ваш балл аттестата',
                                style: GoogleFonts.nunito(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF0A0F2D),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _scoreController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: 'Балл (0-100)',
                                  hintStyle: GoogleFonts.nunito(color: Colors.grey[400]),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFF6C63FF)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _calculateChances,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF6C63FF),
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(double.infinity, 50),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    'Рассчитать',
                                    style: GoogleFonts.nunito(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        ...chances.map((chance) {
                          final chancePercent = chance['chance'] as int;
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: (chance['color'] as Color).withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        chance['name'] as String,
                                        style: GoogleFonts.nunito(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF0A0F2D),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: (chance['color'] as Color).withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '$chancePercent%',
                                        style: GoogleFonts.nunito(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: chance['color'] as Color,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: LinearProgressIndicator(
                                    value: chancePercent / 100,
                                    minHeight: 8,
                                    backgroundColor: Colors.grey[300],
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      chance['color'] as Color,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() => _calculated = false);
                              _scoreController.clear();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[600],
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Рассчитать заново',
                              style: GoogleFonts.nunito(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Star {
  final double x;
  final double y;
  final double speed;
  final double size;
  final double delay;
  final double brightness;

  Star({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.delay,
    required this.brightness,
  });
}
