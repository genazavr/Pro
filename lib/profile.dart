import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'widgets/bottom_nav.dart';
import 'dart:math';
import 'ege_screen.dart';
import 'oge_screen.dart';
import 'admission_chances_screen.dart';
import 'merch_shop_screen.dart';
import 'theme/theme_manager.dart';
import 'theme/app_theme.dart';
import 'theme/particle_painters.dart';
import 'settings/theme_settings_page.dart';

class ProfilePage extends StatefulWidget {
  final String userId;
  const ProfilePage({super.key, required this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  final _db = FirebaseDatabase.instance.ref();
  String name = '';
  String email = '';
  String phone = '';
  List<String> favoriteColleges = [];
  List<String> favoriteProfessions = [];
  int _currentIndex = 4;
  late AnimationController _starController;
  final List<Star> _stars = [];
  final Random _random = Random();
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _starController = AnimationController(
      duration: const Duration(seconds: 25),
      vsync: this,
    )..repeat();

    _initializeStars();
    _loadProfile();
    _loadFavorites();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ThemeManager>().initialize(widget.userId);
    });
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

  Future<void> _loadProfile() async {
    final snap = await _db.child('users/${widget.userId}').get();
    if (snap.exists && snap.value != null) {
      final data = snap.value as Map<dynamic, dynamic>;
      setState(() {
        name = data['name']?.toString() ?? 'Пользователь';
        email = data['email']?.toString() ?? 'email@example.com';
        phone = data['phone']?.toString() ?? '+7 XXX XXX XX XX';
      });
    }
  }

  Future<void> _loadFavorites() async {
    final colSnap = await _db.child('users/${widget.userId}/favoriteColleges').get();
    if (colSnap.exists && colSnap.value != null) {
      final data = colSnap.value as Map<dynamic, dynamic>;
      setState(() => favoriteColleges = data.keys.map((e) => e.toString()).toList());
    }

    final profSnap = await _db.child('users/${widget.userId}/favoriteProfessions').get();
    if (profSnap.exists && profSnap.value != null) {
      final data = profSnap.value as Map<dynamic, dynamic>;
      setState(() => favoriteProfessions = data.keys.map((e) => e.toString()).toList());
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        setState(() {
          _profileImage = File(image.path);
        });

        // Показываем уведомление об успешной загрузке
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Фото профиля обновлено',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Ошибка при выборе фото: $e',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Widget _buildInfoCard(IconData icon, String title, String subtitle, SeasonTheme theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getPrimaryColor(theme).withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.getPrimaryColor(theme).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.getPrimaryColor(theme), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    color: AppTheme.getPrimaryColor(theme),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteSection(String title, List<String> items, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.star,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0A0F2D),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  items.length.toString(),
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            Text(
              'Пока ничего нет',
              style: GoogleFonts.nunito(
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
            )
          else
            ...items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.circle, size: 6, color: color),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item,
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: const Color(0xFF0A0F2D),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            )),
        ],
      ),
    );
  }

  void _navigate(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/choice_tests', arguments: widget.userId);
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/map_page', arguments: widget.userId);
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/chat', arguments: widget.userId);
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/professions', arguments: widget.userId);
        break;
      case 4:
        break;
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Выход из аккаунта',
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0A0F2D),
            ),
          ),
          content: Text(
            'Вы уверены, что хотите выйти из аккаунта?',
            style: GoogleFonts.nunito(
              color: const Color(0xFF0A0F2D),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Отмена',
                style: GoogleFonts.nunito(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Закрыть диалог
                Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/',
                        (route) => false // Очистить всю навигационную историю
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Выйти',
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFeatureButton(String title, String subtitle, IconData icon, VoidCallback onTap, SeasonTheme theme) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.getPrimaryColor(theme).withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.getPrimaryColor(theme).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.getPrimaryColor(theme), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      color: AppTheme.getPrimaryColor(theme),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeasonalBackground(SeasonTheme theme) {
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

            Color particleColor;
            Widget particleShape;

            switch (theme) {
              case SeasonTheme.autumn:
                particleColor = [
                  const Color(0xFFFF8A65),
                  const Color(0xFFFFAB91),
                  const Color(0xFFFFCCBC),
                  const Color(0xFFD7CCC8),
                ][_random.nextInt(4)];
                particleShape = CustomPaint(
                  size: Size(star.size, star.size),
                  painter: LeafPainter(particleColor),
                );
                break;
              case SeasonTheme.winter:
                particleColor = Colors.white;
                particleShape = CustomPaint(
                  size: Size(star.size, star.size),
                  painter: SnowflakePainter(particleColor),
                );
                break;
              case SeasonTheme.spring:
                particleColor = const Color(0xFF81C784);
                particleShape = CustomPaint(
                  size: Size(star.size, star.size),
                  painter: RaindropPainter(particleColor),
                );
                break;
              default:
                particleColor = const Color(0xFFFFD54F);
                particleShape = Container(
                  width: star.size,
                  height: star.size,
                  decoration: BoxDecoration(
                    color: particleColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: particleColor.withValues(alpha: 0.6),
                        blurRadius: star.size / 2,
                      ),
                    ],
                  ),
                );
            }

            return Positioned(
              left: x * MediaQuery.of(context).size.width,
              top: y * MediaQuery.of(context).size.height,
              child: Transform.rotate(
                angle: _starController.value * 2 * pi,
                child: Opacity(
                  opacity: currentOpacity.clamp(0.0, 1.0),
                  child: particleShape,
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        return Scaffold(
          backgroundColor: AppTheme.getBackgroundColor(themeManager.currentTheme),
          body: Stack(
            children: [
              // Анимированный фон в зависимости от темы
              if (themeManager.currentTheme != SeasonTheme.summer)
                _buildSeasonalBackground(themeManager.currentTheme)
              else
                _buildStarBackground(),

              // Градиентный оверлей
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppTheme.getBackgroundColor(themeManager.currentTheme).withOpacity(0.6),
                      AppTheme.getPrimaryColor(themeManager.currentTheme).withOpacity(0.4),
                      AppTheme.getBackgroundColor(themeManager.currentTheme).withOpacity(0.6),
                    ],
                  ),
                ),
              ),

              SafeArea(
                child: Column(
                  children: [
                    // Заголовок страницы
                    Container(
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.getPrimaryColor(themeManager.currentTheme).withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            "Мой профиль",
                            style: GoogleFonts.nunito(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.getPrimaryColor(themeManager.currentTheme),
                            ),
                          ),
                          Text(
                            "Управление вашими данными",
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.getPrimaryColor(themeManager.currentTheme).withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: ListView(
                        children: [
                          // Аватар и основная информация
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.getPrimaryColor(themeManager.currentTheme).withOpacity(0.2),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Исправленная кнопка выбора фото
                                GestureDetector(
                                  onTap: _pickImage,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        width: 120,
                                        height: 120,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              AppTheme.getPrimaryColor(themeManager.currentTheme),
                                              AppTheme.getPrimaryColor(themeManager.currentTheme).withOpacity(0.7),
                                            ],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppTheme.getPrimaryColor(themeManager.currentTheme).withOpacity(0.4),
                                              blurRadius: 20,
                                              offset: const Offset(0, 10),
                                            ),
                                          ],
                                        ),
                                        child: _profileImage != null
                                            ? ClipOval(
                                          child: Image.file(
                                            _profileImage!,
                                            width: 120,
                                            height: 120,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                            : Icon(
                                          Icons.person,
                                          size: 60,
                                          color: Colors.white.withOpacity(0.9),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.2),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Icon(
                                            Icons.camera_alt,
                                            color: AppTheme.getPrimaryColor(themeManager.currentTheme),
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  name,
                                  style: GoogleFonts.nunito(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.getPrimaryColor(themeManager.currentTheme),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'ID: ${widget.userId}',
                                  style: GoogleFonts.nunito(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Контактная информация
                          _buildInfoCard(Icons.email, 'Электронная почта', email, themeManager.currentTheme),
                          _buildInfoCard(Icons.phone, 'Телефон', phone, themeManager.currentTheme),

                          // Избранные колледжи
                          _buildFavoriteSection(
                              'Избранные колледжи',
                              favoriteColleges,
                              Colors.blueAccent
                          ),

                          // Избранные профессии
                          _buildFavoriteSection(
                              'Избранные профессии',
                              favoriteProfessions,
                              Colors.green
                          ),

                          const SizedBox(height: 20),

                          // Новые фишки профиля
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Text(
                              'Подготовка к экзаменам',
                              style: GoogleFonts.nunito(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          _buildFeatureButton(
                            'ЕГЭ',
                            'Подготовка к единому гос. экзамену',
                            Icons.school,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => EGEScreen(userId: widget.userId)),
                            ),
                            themeManager.currentTheme,
                          ),

                          _buildFeatureButton(
                            'ОГЭ',
                            'Подготовка к основному гос. экзамену',
                            Icons.school_outlined,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => OGEScreen(userId: widget.userId)),
                            ),
                            themeManager.currentTheme,
                          ),

                          const SizedBox(height: 20),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Text(
                              'Организация подготовки',
                              style: GoogleFonts.nunito(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          _buildFeatureButton(
                            'Pomodoro таймер',
                            'Планируйте циклы работы и отдыха',
                            Icons.timer,
                            () => Navigator.pushNamed(
                              context,
                              '/pomodoro',
                              arguments: widget.userId,
                            ),
                            themeManager.currentTheme,
                          ),

                          _buildFeatureButton(
                            'Календарь подготовки',
                            'Расписывайте занятия по дням',
                            Icons.calendar_today,
                            () => Navigator.pushNamed(
                              context,
                              '/schedule',
                              arguments: widget.userId,
                            ),
                            themeManager.currentTheme,
                          ),

                          _buildFeatureButton(
                            'Заметки',
                            'Храните идеи и списки задач',
                            Icons.note_alt,
                            () => Navigator.pushNamed(
                              context,
                              '/notes',
                              arguments: widget.userId,
                            ),
                            themeManager.currentTheme,
                          ),

                          const SizedBox(height: 20),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Text(
                              'Карьерная ориентация',
                              style: GoogleFonts.nunito(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          _buildFeatureButton(
                            'Шансы поступления',
                            'Рассчитайте свои шансы на профессию',
                            Icons.trending_up,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => AdmissionChancesScreen(userId: widget.userId)),
                            ),
                            themeManager.currentTheme,
                          ),

                          const SizedBox(height: 20),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Text(
                              'Магазин',
                              style: GoogleFonts.nunito(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          _buildFeatureButton(
                            'Магазин мерча',
                            'Купите мерч на баллы',
                            Icons.shopping_bag,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => MerchShopScreen(userId: widget.userId)),
                            ),
                            themeManager.currentTheme,
                          ),

                          const SizedBox(height: 20),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Text(
                              'Настройки',
                              style: GoogleFonts.nunito(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          _buildFeatureButton(
                            'Тема приложения',
                            'Выберите тему оформления',
                            Icons.palette,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ThemeSettingsPage(userId: widget.userId),
                              ),
                            ),
                            themeManager.currentTheme,
                          ),

                          const SizedBox(height: 20),

                          // Кнопка выхода (исправленная)
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            child: ElevatedButton.icon(
                              onPressed: _logout, // Используем исправленный метод
                              icon: const Icon(Icons.logout, size: 20),
                              label: Text(
                                'Выйти из аккаунта',
                                style: GoogleFonts.nunito(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 56),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 8,
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: BottomNav(currentIndex: _currentIndex, onTap: _navigate, userId: widget.userId),
        );
      },
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