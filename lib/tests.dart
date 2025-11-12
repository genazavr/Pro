import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:profaritashion/test_questions.dart';
import 'choice_of_tests.dart';
import 'dart:math';

class TestPage extends StatefulWidget {
  final String testName;
  final String userId;
  const TestPage({super.key, required this.testName, required this.userId});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> with SingleTickerProviderStateMixin {
  final dbRef = FirebaseDatabase.instance.ref().child("users");
  late List<Map<String, dynamic>> questions;
  int current = 0;
  Map<String, int> scores = {};
  int? selectedOption;
  bool _isLoading = true;

  // Анимация звезд
  late AnimationController _starController;
  final List<Star> _stars = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    // Инициализация звездной анимации
    _starController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _initializeStars();
    _loadTest();
  }

  void _initializeStars() {
    for (int i = 0; i < 150; i++) {
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
                      BoxShadow(
                        color: Colors.white.withOpacity(0.95),
                        blurRadius: 1,
                        spreadRadius: 0.5,
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

  void _loadTest() {
    setState(() {
      _isLoading = true;
    });

    switch (widget.testName) {
      case 'Дифференциально-диагностический опросник':
        questions = getDifferentialDiagnosticQuestions();
        break;
      case 'Тест Голланда':
        questions = getHollandTestQuestions();
        break;
      case 'Выбор профессии для подростков':
        questions = getProfessionChoiceQuestions();
        break;
      case 'Методика "Профиль"':
        questions = getProfileMethodQuestions();
        break;
      default:
        questions = [];
    }
    _initializeScores();

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  void _initializeScores() {
    if (widget.testName == 'Дифференциально-диагностический опросник') {
      scores = {
        'гипертимический': 0,
        'тревожный': 0,
        'педантичный': 0,
        'лабильный': 0,
        'темпераментный': 0,
        'циклотимнийный': 0,
      };
    } else if (widget.testName == 'Тест Голланда') {
      scores = {
        'реалистический': 0,
        'интеллектуальный': 0,
        'социальный': 0,
        'конвенциальный': 0,
        'предпринимательский': 0,
        'артистический': 0,
      };
    } else if (widget.testName == 'Выбор профессии для подростков') {
      scores = {
        'технический': 0,
        'гуманитарный': 0,
        'творческий': 0,
        'социальный': 0,
        'предпринимательский': 0,
        'спортивный': 0,
      };
    } else if (widget.testName == 'Методика "Профиль"') {
      scores = {
        'организатор': 0,
        'интеллектуал': 0,
        'практик': 0,
        'коммуникатор': 0,
        'контролер': 0,
        'креативщик': 0,
      };
    } else {
      scores = {};
    }
  }

  void _next() {
    if (selectedOption == null) return;

    if (questions[current]['types'] != null && selectedOption! < questions[current]['types'].length) {
      final selectedType = questions[current]['types'][selectedOption];
      if (selectedType != null && scores.containsKey(selectedType)) {
        scores[selectedType] = scores[selectedType]! + 1;
      }
    }

    setState(() {
      current++;
      selectedOption = null;
    });

    if (current >= questions.length) {
      _finishTest();
    }
  }

  void _previous() {
    if (current > 0) {
      setState(() {
        current--;
        selectedOption = null;
      });
    }
  }

  Future<void> _finishTest() async {
    try {
      await dbRef.child(widget.userId).child("results").child(_getTestKey()).set({
        'profile': scores,
        'total': questions.length,
        'date': DateTime.now().toIso8601String(),
      });

      _showResultsDialog();
    } catch (e) {
      debugPrint("Ошибка сохранения результатов: $e");
      _showErrorDialog();
    }
  }

  String _getTestKey() {
    switch (widget.testName) {
      case 'Дифференциально-диагностический опросник':
        return 'differential_diagnostic_test';
      case 'Тест Голланда':
        return 'holland_test';
      case 'Выбор профессии для подростков':
        return 'profession_choice_test';
      case 'Методика "Профиль"':
        return 'profile_method';
      default:
        return 'unknown_test';
    }
  }

  void _showResultsDialog() {
    final topResults = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topThree = topResults.take(3).map((e) => _getTypeName(e.key)).join(', ');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E3A8A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Тест завершен!",
            style: GoogleFonts.nunito(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.yellow,
            )
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Ваши ведущие типы:",
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                )
            ),
            const SizedBox(height: 10),
            Text(topThree,
                style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.yellow
                )
            ),
            const SizedBox(height: 10),
            Text("Детальные результаты сохранены в профиле",
                style: GoogleFonts.nunito(
                    fontSize: 14,
                    color: Colors.white70
                )
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                current = 0;
                selectedOption = null;
                _initializeScores();
              });
            },
            child: Text("Пройти заново",
                style: GoogleFonts.nunito(
                    color: Colors.yellow,
                    fontWeight: FontWeight.bold
                )
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => ChoiceOfTestsPage(userId: widget.userId)),
                    (route) => false,
              );
            },
            child: Text("К выбору тестов",
                style: GoogleFonts.nunito(
                    color: Colors.yellow,
                    fontWeight: FontWeight.bold
                )
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E3A8A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Ошибка",
            style: GoogleFonts.nunito(
                color: Colors.yellow,
                fontWeight: FontWeight.bold
            )
        ),
        content: Text("Произошла ошибка при сохранении результатов. Пожалуйста, попробуйте еще раз.",
            style: GoogleFonts.nunito(
                color: Colors.white
            )
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text("OK",
                style: GoogleFonts.nunito(
                    color: Colors.yellow,
                    fontWeight: FontWeight.bold
                )
            ),
          ),
        ],
      ),
    );
  }

  String _getTypeName(String type) {
    final typeNames = {
      'гипертимический': 'Гипертимический',
      'тревожный': 'Тревожный',
      'педантичный': 'Педантичный',
      'лабильный': 'Лабильный',
      'темпераментный': 'Темпераментный',
      'циклотимнийный': 'Циклотимный',
      'реалистический': 'Реалистический',
      'интеллектуальный': 'Интеллектуальный',
      'социальный': 'Социальный',
      'конвенциальный': 'Конвенциальный',
      'предпринимательский': 'Предпринимательский',
      'артистический': 'Артистический',
      'технический': 'Технический',
      'гуманитарный': 'Гуманитарный',
      'творческий': 'Творческий',
      'спортивный': 'Спортивный',
      'организатор': 'Организатор',
      'интеллектуал': 'Интеллектуал',
      'практик': 'Практик',
      'коммуникатор': 'Коммуникатор',
      'контролер': 'Контролер',
      'креативщик': 'Креативщик',
    };

    return typeNames[type] ?? type;
  }

  @override
  void dispose() {
    _starController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || questions.isEmpty) {
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
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Colors.yellow),
                  const SizedBox(height: 20),
                  Text("Загрузка теста...",
                      style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontSize: 16
                      )
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (current >= questions.length) {
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
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Colors.yellow),
                  const SizedBox(height: 20),
                  Text("Обработка результатов...",
                      style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontSize: 16
                      )
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final q = questions[current];
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F2D),
      body: Stack(
        children: [
          // Звездный фон
          _buildStarBackground(),

          // Градиентный оверлей
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
                // Заголовок и прогресс
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () {
                              if (current > 0) {
                                _previous();
                              } else {
                                Navigator.pop(context);
                              }
                            },
                          ),
                          Expanded(
                            child: Text(
                              widget.testName,
                              style: GoogleFonts.nunito(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(width: 48), // Для балансировки
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Прогресс бар
                      LinearProgressIndicator(
                        value: (current + 1) / questions.length,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.yellow),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      const SizedBox(height: 10),

                      // Счетчик вопросов
                      Text(
                        "Вопрос ${current + 1} из ${questions.length}",
                        style: GoogleFonts.nunito(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        // Вопрос
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            q['question'],
                            style: GoogleFonts.nunito(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0A0F2D),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        // Варианты ответов
                        Expanded(
                          child: ListView.builder(
                            itemCount: q['options'].length,
                            itemBuilder: (context, index) {
                              final selected = selectedOption == index;
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: Material(
                                  borderRadius: BorderRadius.circular(16),
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: () => setState(() => selectedOption = index),
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: selected
                                              ? [Colors.yellow, Colors.orange]
                                              : [Colors.white.withOpacity(0.9), Colors.white.withOpacity(0.7)],
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        border: selected
                                            ? Border.all(color: Colors.orange, width: 2)
                                            : null,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.2),
                                            blurRadius: 6,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                                            color: selected ? Colors.deepPurple : Colors.grey.shade600,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              q['options'][index],
                                              style: GoogleFonts.nunito(
                                                fontSize: 16,
                                                color: selected ? Colors.deepPurple : const Color(0xFF0A0F2D),
                                                fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Кнопка продолжить
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 20),
                          child: Material(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: selectedOption == null ? null : _next,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: selectedOption != null
                                      ? const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [Colors.yellow, Colors.orange],
                                  )
                                      : LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [Colors.grey.shade400, Colors.grey.shade600],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: selectedOption != null
                                      ? [
                                    BoxShadow(
                                      color: Colors.orange.withOpacity(0.5),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                      : null,
                                ),
                                child: Text(
                                  current == questions.length - 1 ? "Завершить тест" : "Продолжить",
                                  style: GoogleFonts.nunito(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: selectedOption != null ? const Color(0xFF0A0F2D) : Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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