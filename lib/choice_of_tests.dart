import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tests.dart';
import 'widgets/bottom_nav.dart';
import 'widgets/themed_page.dart';
import 'dart:math';

class ChoiceOfTestsPage extends StatefulWidget {
  final String userId;
  const ChoiceOfTestsPage({super.key, required this.userId});

  @override
  State<ChoiceOfTestsPage> createState() => _ChoiceOfTestsPageState();
}

class _ChoiceOfTestsPageState extends State<ChoiceOfTestsPage> {
  final int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  void _navigate(BuildContext context, int index) {
    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/map_page', arguments: widget.userId);
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/college_rating', arguments: widget.userId);
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/professions', arguments: widget.userId);
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/profile', arguments: widget.userId);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ThemedPage(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // Заголовок
              Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.all(16),
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
                child: Column(
                  children: [
                    Text(
                      "Выбор тестов",
                      style: GoogleFonts.nunito(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0A0F2D),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Выберите тип теста для проверки знаний",
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF6C63FF),
                      ),
                    ),
                  ],
                ),
              ),

              // Тесты
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: tests.length,
                    itemBuilder: (context, index) {
                      final test = tests[index];
                      return GestureDetector(
                        onTap: () {
                          if (test['route'] != null) {
                            Navigator.pushNamed(
                              context,
                              test['route'] as String,
                              arguments: widget.userId,
                            );
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: (test['color'] as Color).withOpacity(0.3),
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
                                  color: (test['color'] as Color).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  test['icon'] as IconData,
                                  size: 40,
                                  color: test['color'] as Color,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                test['title'] as String,
                                style: GoogleFonts.nunito(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF0A0F2D),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                test['description'] as String,
                                style: GoogleFonts.nunito(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNav(currentIndex: _currentIndex, onTap: _navigate),
      ),
    );
  }
}