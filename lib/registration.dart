import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_with_bottom_nav.dart';
import 'login.dart'; // Добавляем импорт страницы входа
import 'dart:math';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});
  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> with SingleTickerProviderStateMixin {
  final _login = TextEditingController();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool agree = false;
  bool loading = false;
  String error = '';

  final dbRef = FirebaseDatabase.instance.ref().child("users");

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

    _initializeStars();
  }

  void _initializeStars() {
    for (int i = 0; i < 80; i++) { // 80 звезд
      _stars.add(Star(
        x: _random.nextDouble(),
        y: _random.nextDouble() * 2 - 1,
        speed: 0.2 + _random.nextDouble() * 1.0,
        size: 2.0 + _random.nextDouble() * 5.0,
        delay: _random.nextDouble() * 4.0,
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
                      BoxShadow(
                        color: star.color.withOpacity(0.9),
                        blurRadius: star.size * 2,
                        spreadRadius: star.size * 0.5,
                      ),
                      BoxShadow(
                        color: star.color.withOpacity(0.4),
                        blurRadius: star.size * 4,
                        spreadRadius: star.size * 1.5,
                      ),
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

  void _register() async {
    if (!agree) {
      setState(() => error = "Необходимо согласие с обработкой данных");
      return;
    }

    if (_password.text != _confirm.text) {
      setState(() => error = "Пароли не совпадают");
      return;
    }

    if (_login.text.isEmpty || _name.text.isEmpty || _email.text.isEmpty) {
      setState(() => error = "Заполните все обязательные поля");
      return;
    }

    setState(() {
      loading = true;
      error = '';
    });

    try {
      // Проверяем уникальность логина
      final snapshot = await dbRef.get();
      if (snapshot.exists) {
        final users = snapshot.value as Map;
        for (var value in users.values) {
          if (value['login'] == _login.text) {
            setState(() => error = "Логин уже занят");
            setState(() => loading = false);
            return;
          }
          if (value['email'] == _email.text) {
            setState(() => error = "Email уже используется");
            setState(() => loading = false);
            return;
          }
        }
      }

      final newUser = {
        'login': _login.text,
        'name': _name.text,
        'phone': _phone.text,
        'email': _email.text,
        'password': _password.text,
        'createdAt': DateTime.now().toIso8601String(),
      };

      final ref = dbRef.push();
      await ref.set(newUser);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeWithBottomNav(userId: ref.key!)),
      );
    } catch (e) {
      setState(() => error = "Ошибка регистрации: $e");
      setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    _starController.dispose();
    _login.dispose();
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
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

          // Градиентный оверлей
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
                  // Кнопка назад
                  IconButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    },
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Заголовок
                  Center(
                    child: Text(
                      "Создать аккаунт",
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
                      "Заполните форму для регистрации",
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
                        _buildTextField(
                          controller: _login,
                          label: "Логин",
                          icon: Icons.person_outline,
                          isRequired: true,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _name,
                          label: "ФИО",
                          icon: Icons.badge_outlined,
                          isRequired: true,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _phone,
                          label: "Номер телефона",
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _email,
                          label: "Почта",
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          isRequired: true,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _password,
                          label: "Пароль",
                          icon: Icons.lock_outline,
                          isPassword: true,
                          isRequired: true,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _confirm,
                          label: "Подтверждение пароля",
                          icon: Icons.lock_reset_outlined,
                          isPassword: true,
                          isRequired: true,
                        ),

                        const SizedBox(height: 16),

                        // Соглашение
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              Transform.scale(
                                scale: 0.9,
                                child: Checkbox(
                                  value: agree,
                                  onChanged: (v) => setState(() => agree = v!),
                                  activeColor: Colors.blueAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 16),
                                  child: Text(
                                    "Согласен с обработкой персональных данных",
                                    style: GoogleFonts.nunito(
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 2,
                                  ),
                                ),
                              ),
                            ],
                          ),
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

                        // Кнопка регистрации
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
                            onPressed: loading ? null : _register,
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
                              "Зарегистрироваться",
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

                        // Кнопка "Вернуться ко входу"
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
                              MaterialPageRoute(builder: (_) => const LoginPage()),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.arrow_back_rounded, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  "Вернуться ко входу",
                                  style: GoogleFonts.nunito(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
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
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        style: GoogleFonts.nunito(
          fontSize: 16,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          labelText: isRequired ? "$label *" : label,
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
            icon,
            color: Colors.blueAccent[400],
          ),
        ),
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