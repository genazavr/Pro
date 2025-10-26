import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'choice_of_tests.dart';
import 'registration.dart';
import 'dart:math';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final dbRef = FirebaseDatabase.instance.ref().child("users");
  final _login = TextEditingController();
  final _password = TextEditingController();
  bool remember = false;
  bool loading = false;
  String error = '';

  late AnimationController _starController;
  final List<Star> _stars = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _starController = AnimationController(
      duration: const Duration(seconds: 25),
      vsync: this,
    )..repeat();

    // Создаем звезды для звездопада
    _initializeStars();

    // Загружаем сохраненные данные
    _loadSavedCredentials();
  }

  void _initializeStars() {
    for (int i = 0; i < 80; i++) { // Увеличил до 80 звезд
      _stars.add(Star(
        x: _random.nextDouble(),
        y: _random.nextDouble() * 2 - 1,
        speed: 0.2 + _random.nextDouble() * 1.0, // Немного замедлил
        size: 2.0 + _random.nextDouble() * 5.0, // Разные размеры
        delay: _random.nextDouble() * 4.0, // Увеличил разброс задержек
        brightness: 0.5 + _random.nextDouble() * 0.5,
        color: _getRandomStarColor(),
      ));
    }
  }

  Color _getRandomStarColor() {
    final colors = [
      Colors.white,
      const Color(0xFFF8F9FA),
      const Color(0xFFE3F2FD),
      const Color(0xFFBBDEFB),
      const Color(0xFF90CAF9),
      const Color(0xFF64B5F6),
      const Color(0xFFE1F5FE),
    ];
    return colors[_random.nextInt(colors.length)];
  }

  // Загрузка сохраненных данных
  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLogin = prefs.getString('savedLogin');
    final savedPassword = prefs.getString('savedPassword');
    final savedRemember = prefs.getBool('rememberMe') ?? false;

    if (savedRemember && savedLogin != null && savedPassword != null) {
      setState(() {
        _login.text = savedLogin;
        _password.text = savedPassword;
        remember = savedRemember;
      });
    }
  }

  // Сохранение данных
  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (remember) {
      await prefs.setString('savedLogin', _login.text);
      await prefs.setString('savedPassword', _password.text);
      await prefs.setBool('rememberMe', true);
    } else {
      await prefs.remove('savedLogin');
      await prefs.remove('savedPassword');
      await prefs.setBool('rememberMe', false);
    }
  }

  Future<void> _loginUser() async {
    setState(() {
      loading = true;
      error = '';
    });

    try {
      final snapshot = await dbRef.get();
      if (snapshot.exists) {
        final users = snapshot.value as Map;
        bool found = false;
        String? loggedUserId;

        users.forEach((key, value) {
          if ((value['login'] == _login.text ||
              value['email'] == _login.text ||
              value['phone'] == _login.text) &&
              value['password'] == _password.text) {
            found = true;
            loggedUserId = key;
          }
        });

        if (found && loggedUserId != null) {
          // Сохраняем данные если выбрано "Запомнить меня"
          await _saveCredentials();

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => ChoiceOfTestsPage(userId: loggedUserId!)
            ),
          );
        } else {
          setState(() => error = "Неверный логин или пароль");
        }
      } else {
        setState(() => error = "Пользователь не найден");
      }
    } catch (e) {
      setState(() => error = "Ошибка подключения");
    }

    setState(() => loading = false);
  }

  Widget _buildStarBackground() {
    return AnimatedBuilder(
      animation: _starController,
      builder: (context, child) {
        return Stack(
          children: _stars.map((star) {
            final progress = (_starController.value * star.speed + star.delay) % 2.0;
            final y = progress - 0.5;
            final opacity = y > 0 && y < 1.0
                ? (1.0 - (y / 1.0).abs()) * star.brightness
                : 0.0;

            // Пульсация звезды
            final pulse = (sin(_starController.value * 4 * pi + star.delay * 10) + 1) / 2;
            final currentOpacity = opacity * (0.7 + 0.3 * pulse);

            return Positioned(
              left: star.x * MediaQuery.of(context).size.width,
              top: y * MediaQuery.of(context).size.height,
              child: Opacity(
                opacity: currentOpacity.clamp(0.0, 1.0),
                child: Container(
                  width: star.size,
                  height: star.size,
                  decoration: BoxDecoration(
                    color: star.color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      // Основное свечение
                      BoxShadow(
                        color: star.color.withOpacity(0.9),
                        blurRadius: star.size * 2,
                        spreadRadius: star.size * 0.5,
                      ),
                      // Внешнее свечение
                      BoxShadow(
                        color: star.color.withOpacity(0.4),
                        blurRadius: star.size * 4,
                        spreadRadius: star.size * 1.5,
                      ),
                      // Белое ядро
                      BoxShadow(
                        color: Colors.white.withOpacity(0.9),
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

  @override
  void dispose() {
    _starController.dispose();
    _login.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F2D),
      body: Stack(
        children: [
          // Звездный фон
          _buildStarBackground(),

          // Слабое градиентное затемнение чтобы текст был читаемым
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF0A0F2D).withOpacity(0.4),
                  const Color(0xFF1E3A8A).withOpacity(0.3),
                  const Color(0xFF0A0F2D).withOpacity(0.4),
                ],
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Заголовок
                  Center(
                    child: Text(
                      "Добро пожаловать",
                      style: GoogleFonts.nunito(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 10,
                            color: Colors.black.withOpacity(0.5),
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Center(
                    child: Text(
                      "Войдите в свой аккаунт",
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        shadows: [
                          Shadow(
                            blurRadius: 5,
                            color: Colors.black.withOpacity(0.5),
                            offset: const Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Карточка с формой
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueAccent.withOpacity(0.4),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Поле логина
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _login,
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                            decoration: InputDecoration(
                              labelText: "Логин, email или телефон",
                              labelStyle: GoogleFonts.nunito(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              prefixIcon: Icon(
                                Icons.person_outline,
                                color: Colors.blueAccent[400],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Поле пароля
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _password,
                            obscureText: true,
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                            decoration: InputDecoration(
                              labelText: "Пароль",
                              labelStyle: GoogleFonts.nunito(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: Colors.blueAccent[400],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Запомнить меня
                        Row(
                          children: [
                            Transform.scale(
                              scale: 0.9,
                              child: Checkbox(
                                value: remember,
                                onChanged: (v) {
                                  setState(() {
                                    remember = v!;
                                  });
                                  if (!remember) {
                                    _clearSavedCredentials();
                                  }
                                },
                                activeColor: Colors.blueAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                            Text(
                              "Запомнить меня",
                              style: GoogleFonts.nunito(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Функция восстановления пароля в разработке",
                                      style: GoogleFonts.nunito(),
                                    ),
                                    backgroundColor: Colors.blueAccent,
                                  ),
                                );
                              },
                              child: Text(
                                "",
                                style: GoogleFonts.nunito(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Сообщение об ошибке
                        if (error.isNotEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.red[200]!),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, color: Colors.red[400], size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    error,
                                    style: GoogleFonts.nunito(
                                      color: Colors.red[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 24),

                        // Кнопка входа
                        Container(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6C63FF),
                              foregroundColor: Colors.white,
                              elevation: 8,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              shadowColor: const Color(0xFF6C63FF).withOpacity(0.5),
                            ),
                            onPressed: loading ? null : _loginUser,
                            child: loading
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                                : Text(
                              "Войти",
                              style: GoogleFonts.nunito(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Разделитель
                        Row(
                          children: [
                            Expanded(
                              child: Divider(color: Colors.grey[300]),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                "или",
                                style: GoogleFonts.nunito(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(color: Colors.grey[300]),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Кнопка регистрации
                        Container(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF6C63FF),
                              side: const BorderSide(color: Color(0xFF6C63FF), width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: Colors.white,
                              elevation: 2,
                            ),
                            onPressed: () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const RegistrationPage()),
                            ),
                            child: Text(
                              "Создать аккаунт",
                              style: GoogleFonts.nunito(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Очистка сохраненных данных
  Future<void> _clearSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('savedLogin');
    await prefs.remove('savedPassword');
  }
}

class Star {
  final double x;
  final double y;
  final double speed;
  final double size;
  final double delay;
  final double brightness;
  final Color color;

  Star({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.delay,
    required this.brightness,
    required this.color,
  });
}