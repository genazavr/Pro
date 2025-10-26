import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'registration.dart';
import 'login.dart';

class MainAnimationPage extends StatefulWidget {
  const MainAnimationPage({super.key});

  @override
  State<MainAnimationPage> createState() => _MainAnimationPageState();
}

class _MainAnimationPageState extends State<MainAnimationPage>
    with TickerProviderStateMixin {
  late AnimationController _gradientController;
  late AnimationController _glowController;
  late AnimationController _flyInController;

  late Animation<Offset> _flyPath;
  late Animation<double> _scaleBounce;

  bool _showButtons = false;

  final List<Color> colors = [
    const Color(0xFF171D33), // глубокий синий
    const Color(0xFF5365E5), // голубой
    const Color(0xFFF6514C), // жёлтый
    const Color(0xFFFDB901), // оранжево-красный
  ];

  @override
  void initState() {
    super.initState();

    // 🌈 Градиент плавно «переливается»
    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat(reverse: true);

    // 💫 Пульсация и лёгкое движение звезды
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
      lowerBound: 0.85,
      upperBound: 1.15,
    )..repeat(reverse: true);

    // ⭐ Анимация прилёта звезды
    _flyInController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _showButtons = true;
        });
      }
    });

    // 🚀 Дуга полёта (плавная, слегка выгнутая вверх)
    _flyPath = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(-1.5, -1.4),
          end: const Offset(-0.4, -0.6),
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(-0.4, -0.6),
          end: const Offset(0.0, 0.0),
        ).chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 60,
      ),
    ]).animate(_flyInController);

    // 🎯 Мягкий подпрыгивающий масштаб
    _scaleBounce = Tween<double>(begin: 0.4, end: 1.0)
        .animate(CurvedAnimation(parent: _flyInController, curve: Curves.easeOutBack));

    _flyInController.forward();
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _glowController.dispose();
    _flyInController.dispose();
    super.dispose();
  }

  // Метод для создания анимированных кнопок в новом стиле
  Widget _buildAnimatedButton({
    required String text,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback onTap,
    bool hasBorder = false,
  }) {
    bool isPressed = false;

    return StatefulBuilder(
      builder: (context, setInnerState) {
        return GestureDetector(
          onTapDown: (_) => setInnerState(() => isPressed = true),
          onTapUp: (_) {
            Future.delayed(const Duration(milliseconds: 100),
                    () => setInnerState(() => isPressed = false));
            onTap();
          },
          onTapCancel: () => setInnerState(() => isPressed = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: double.infinity,
            height: 56,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            transform: Matrix4.identity()
              ..scale(isPressed ? 0.98 : 1.0, isPressed ? 0.98 : 1.0),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: hasBorder
                  ? Border.all(color: const Color(0xFF6C63FF), width: 2)
                  : null,
              boxShadow: isPressed
                  ? []
                  : [
                BoxShadow(
                  color: backgroundColor == const Color(0xFF6C63FF)
                      ? const Color(0xFF6C63FF).withOpacity(0.3)
                      : Colors.black.withOpacity(0.1),
                  offset: const Offset(0, 4),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Center(
              child: Text(
                text,
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: AnimatedBuilder(
        animation:
        Listenable.merge([_gradientController, _glowController, _flyInController]),
        builder: (_, __) {
          // движение фона (параллакс)
          final t = _gradientController.value;
          final begin = Alignment(-1.0 + 2 * t, -1.0);
          final end = Alignment(1.0 - 2 * t, 1.0);

          // лёгкое покачивание звезды после посадки
          final dx = 4 * sin(_gradientController.value * 2 * pi);
          final dy = 2 * cos(_gradientController.value * 2 * pi);

          return Container(
            width: size.width,
            height: size.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: begin,
                end: end,
                colors: colors,
                tileMode: TileMode.mirror,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(),

                    // 🌟 Название приложения и звезда
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Profaritashion",
                          style: GoogleFonts.nunito(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 10),

                        // ⭐ Плавный прилёт и мягкий пульс
                        Transform.translate(
                          offset: Offset(
                            _flyPath.value.dx * size.width * 0.4 + dx,
                            _flyPath.value.dy * size.height * 0.4 + dy,
                          ),
                          child: Transform.scale(
                            scale: _scaleBounce.value * _glowController.value,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.amber.withOpacity(0.8),
                                    blurRadius: 25 + 8 * _glowController.value,
                                    spreadRadius: 4,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.star_rounded,
                                color: Colors.amber,
                                size: 50,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    Text(
                      "Найди свой путь к успеху",
                      style: GoogleFonts.nunito(
                        fontSize: 18,
                        color: Colors.white,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const Spacer(),

                    // Кнопки регистрации и входа в новом стиле
                    if (_showButtons)
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Кнопка "Войти" (белая с фиолетовым текстом)
                          _buildAnimatedButton(
                            text: "Войти",
                            backgroundColor: Colors.white,
                            textColor: const Color(0xFF6C63FF),
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const LoginPage()),
                              );
                            },
                            hasBorder: false,
                          ),
                          const SizedBox(height: 16),

                          // Кнопка "Создать аккаунт" (фиолетовая с белым текстом)
                          _buildAnimatedButton(
                            text: "Создать аккаунт",
                            backgroundColor: const Color(0xFF6C63FF),
                            textColor: Colors.white,
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const RegistrationPage()),
                              );
                            },
                            hasBorder: false,
                          ),
                        ],
                      ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}