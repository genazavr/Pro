import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math';

class OGEScreen extends StatefulWidget {
  final String userId;
  const OGEScreen({super.key, required this.userId});

  @override
  State<OGEScreen> createState() => _OGEScreenState();
}

class _OGEScreenState extends State<OGEScreen> with SingleTickerProviderStateMixin {
  late AnimationController _starController;
  final List<Star> _stars = [];
  final Random _random = Random();

  final List<Map<String, String>> ogeSubjects = [
    {'name': 'Русский язык', 'url': 'https://oge.sdamgia.ru/'},
    {'name': 'Математика', 'url': 'https://oge.sdamgia.ru/'},
    {'name': 'Физика', 'url': 'https://oge.sdamgia.ru/'},
    {'name': 'Химия', 'url': 'https://oge.sdamgia.ru/'},
    {'name': 'Биология', 'url': 'https://oge.sdamgia.ru/'},
    {'name': 'История', 'url': 'https://oge.sdamgia.ru/'},
    {'name': 'Обществознание', 'url': 'https://oge.sdamgia.ru/'},
    {'name': 'Литература', 'url': 'https://oge.sdamgia.ru/'},
    {'name': 'География', 'url': 'https://oge.sdamgia.ru/'},
    {'name': 'Информатика', 'url': 'https://oge.sdamgia.ru/'},
    {'name': 'Английский язык', 'url': 'https://oge.sdamgia.ru/'},
    {'name': 'Немецкий язык', 'url': 'https://oge.sdamgia.ru/'},
  ];

  @override
  void initState() {
    super.initState();
    _starController = AnimationController(
      duration: const Duration(seconds: 25),
      vsync: this,
    )..repeat();
    _initializeStars();
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

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  void dispose() {
    _starController.dispose();
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
                          'Предметы ОГЭ',
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
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.9,
                    ),
                    itemCount: ogeSubjects.length,
                    itemBuilder: (context, index) {
                      final subject = ogeSubjects[index];
                      return GestureDetector(
                        onTap: () => _launchUrl(subject['url']!),
                        child: Container(
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
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6C63FF).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.school,
                                  color: const Color(0xFF6C63FF),
                                  size: 32,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                subject['name']!,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.nunito(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF0A0F2D),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6C63FF).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Решу ОГЭ',
                                  style: GoogleFonts.nunito(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF6C63FF),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
