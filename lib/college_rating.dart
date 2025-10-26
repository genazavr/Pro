import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/bottom_nav.dart';
import 'dart:math';

class CollegeRatingPage extends StatefulWidget {
  final String userId;
  const CollegeRatingPage({super.key, required this.userId});

  @override
  State<CollegeRatingPage> createState() => _CollegeRatingPageState();
}

class _CollegeRatingPageState extends State<CollegeRatingPage> with SingleTickerProviderStateMixin {
  final _db = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> colleges = [];
  List<String> favoriteColleges = [];
  int _currentIndex = 2;
  String _selectedCity = 'Все города';
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
    _loadColleges();
    _loadFavorites();
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

  void _loadColleges() {
    colleges = [
      // ВСТАВЬТЕ СВОИ КОЛЛЕДЖИ ЗДЕСЬ
      {
        'name': 'Сарапульский многопрофильный колледж',
        'budget': 25,
        'passScore': 165,
        'paid': 20,
        'price': 45.0,
        'city': 'Сарапул',
        'specialties': ['Автомеханик', 'Электромонтажник', 'Слесарь-механик', 'Сварщик'],
        'url': 'https://ciur.ru/sit',
        'type': 'БПОУ УР'
      },
      {
        'name': 'Ижевский торгово-экономический техникум',
        'budget': 40,
        'passScore': 180,
        'paid': 30,
        'price': 55.0,
        'city': 'Ижевск',
        'specialties': ['Бухгалтер', 'Менеджер по продажам', 'Торговый представитель', 'Продавец'],
        'url': 'https://ciur.ru/itet',
        'type': 'БПОУ УР'
      },
      {
        'name': 'Глазовский аграрно-промышленный техникум',
        'budget': 30,
        'passScore': 160,
        'paid': 15,
        'price': 40.0,
        'city': 'Глазов',
        'specialties': ['Агроном', 'Механизатор', 'Зоотехник', 'Электромонтажник'],
        'url': 'https://ciur.ru/gapt',
        'type': 'АПОУ УР'
      },
      {
        'name': 'Сарапульский политехнический колледж',
        'budget': 35,
        'passScore': 170,
        'paid': 25,
        'price': 48.0,
        'city': 'Сарапул',
        'specialties': ['Инженер-механик', 'Техник-механик', 'Электромонтажник', 'Слесарь'],
        'url': 'https://ciur.ru/sptk',
        'type': 'БПОУ УР'
      },
      {
        'name': 'Ижевский промышленно-экономический колледж',
        'budget': 45,
        'passScore': 175,
        'paid': 35,
        'price': 52.0,
        'city': 'Ижевск',
        'specialties': ['Менеджер проекта', 'Экономист', 'Бухгалтер', 'Делопроизводитель'],
        'url': 'https://ciur.ru/ipek',
        'type': 'АПОУ УР'
      },
      {
        'name': 'Строительный техникум',
        'budget': 25,
        'passScore': 165,
        'paid': 20,
        'price': 42.0,
        'city': 'Ижевск',
        'specialties': ['Строитель', 'Мастер строительных работ', 'Каменщик', 'Штукатур'],
        'url': 'https://ciur.ru/st',
        'type': 'АПОУ УР'
      },
      {
        'name': 'Глазовский технический колледж',
        'budget': 40,
        'passScore': 170,
        'paid': 30,
        'price': 50.0,
        'city': 'Глазов',
        'specialties': ['Мастер производственного обучения', 'Слесарь-механик', 'Электромонтажник'],
        'url': 'https://ciur.ru/gtk',
        'type': 'БПОУ УР'
      },
      {
        'name': 'Воткинский машиностроительный техникум имени В.Г. Садовникова',
        'budget': 35,
        'passScore': 168,
        'paid': 28,
        'price': 48.0,
        'city': 'Воткинск',
        'specialties': ['Токарь', 'Фрезеровщик', 'Электромонтажник', 'Автомеханик'],
        'url': 'https://ciur.ru/vmt',
        'type': 'БПОУ УР'
      },
      {
        'name': 'Игринский политехнический техникум',
        'budget': 20,
        'passScore': 155,
        'paid': 15,
        'price': 35.0,
        'city': 'Игринск',
        'specialties': ['Тракторист-машинист', 'Механизатор', 'Сварщик', 'Электромонтажник'],
        'url': 'https://ciur.ru/ipt',
        'type': 'БПОУ УР'
      },
      {
        'name': 'Ижевский техникум индустрии питания',
        'budget': 25,
        'passScore': 160,
        'paid': 20,
        'price': 40.0,
        'city': 'Ижевск',
        'specialties': ['Повар', 'Кондитер', 'Официант', 'Бармен'],
        'url': 'https://ciur.ru/itip',
        'type': 'БПОУ УР'
      },
      {
        'name': 'Можгинский агропромышленный колледж имени Г.Г. Оревкова',
        'budget': 35,
        'passScore': 165,
        'paid': 25,
        'price': 45.0,
        'city': 'Можга',
        'specialties': ['Агроном', 'Зоотехник', 'Механизатор', 'Ветеринар'],
        'url': 'https://ciur.ru/magk',
        'type': 'БПОУ УР'
      },
      {
        'name': 'Можгинский педагогический колледж имени Т.К. Борисова',
        'budget': 50,
        'passScore': 175,
        'paid': 40,
        'price': 60.0,
        'city': 'Можга',
        'specialties': ['Воспитатель детского сада', 'Учитель начальных классов', 'Педагог-психолог'],
        'url': 'https://ciur.ru/mpk',
        'type': 'БПОУ УР'
      },
      {
        'name': 'Ижевский монтажный техникум',
        'budget': 30,
        'passScore': 165,
        'paid': 22,
        'price': 45.0,
        'city': 'Ижевск',
        'specialties': ['Монтажник', 'Электромонтажник', 'Слесарь-ремонтник'],
        'url': 'https://ciur.ru/imt',
        'type': 'БПОУ УР'
      },
      {
        'name': 'Дебёсский политехникум',
        'budget': 15,
        'passScore': 150,
        'paid': 10,
        'price': 30.0,
        'city': 'Дебёсы',
        'specialties': ['Тракторист-машинист', 'Сварщик', 'Электромонтажник'],
        'url': 'https://ciur.ru/dpt',
        'type': 'БПОУ УР'
      },
      {
        'name': 'Экономико-технологический колледж',
        'budget': 40,
        'passScore': 172,
        'paid': 32,
        'price': 55.0,
        'city': 'Ижевск',
        'specialties': ['Бухгалтер', 'Менеджер по продажам', 'Администратор', 'Специалист по рекламе'],
        'url': 'https://ciur.ru/etk',
        'type': 'АПОУ УР'
      },
      {
        'name': 'Асановский аграрно-технический техникум',
        'budget': 20,
        'passScore': 158,
        'paid': 15,
        'price': 38.0,
        'city': 'Асаново',
        'specialties': ['Механизатор', 'Агроном', 'Тракторист-машинист'],
        'url': 'https://ciur.ru/aat',
        'type': 'БПОУ УР'
      },
      {
        'name': 'Техникум радиоэлектроники и информационных технологий имени А.В. Воскресенского',
        'budget': 35,
        'passScore': 180,
        'paid': 30,
        'price': 65.0,
        'city': 'Ижевск',
        'specialties': ['Программист', 'Техник-программист', 'Системный администратор', 'Радиотехник'],
        'url': 'https://ciur.ru/trit',
        'type': 'АПОУ УР'
      },
      {
        'name': 'Ижевский политехнический колледж',
        'budget': 45,
        'passScore': 175,
        'paid': 35,
        'price': 58.0,
        'city': 'Ижевск',
        'specialties': ['Инженер-механик', 'Техник-механик', 'Электромонтажник', 'Автомеханик'],
        'url': 'https://ciur.ru/ipk',
        'type': 'АПОУ УР'
      },
      {
        'name': 'Сюмсинский техникум лесного и сельского хозяйства',
        'budget': 20,
        'passScore': 152,
        'paid': 12,
        'price': 32.0,
        'city': 'Сюмси',
        'specialties': ['Лесник', 'Мастер лесного хозяйства', 'Тракторист-машинист'],
        'url': 'https://ciur.ru/stlsh',
        'type': 'БПОУ УР'
      },
      {
        'name': 'Топливно-энергетический колледж',
        'budget': 30,
        'passScore': 170,
        'paid': 25,
        'price': 52.0,
        'city': 'Ижевск',
        'specialties': ['Техник-энергетик', 'Электромонтажник', 'Электромонтер'],
        'url': 'https://ciur.ru/tek',
        'type': 'АПОУ УР'
      },
      {
        'name': 'Сарапульский колледж социально-педагогических технологий',
        'budget': 40,
        'passScore': 168,
        'paid': 30,
        'price': 50.0,
        'city': 'Сарапул',
        'specialties': ['Тренер-преподаватель', 'Специалист по работе с молодежью', 'Психолог'],
        'url': 'https://ciur.ru/skspt',
        'type': 'БПОУ УР'
      },
      {
        'name': 'Удмуртский республиканский социально-педагогический колледж',
        'budget': 60,
        'passScore': 175,
        'paid': 45,
        'price': 62.0,
        'city': 'Ижевск',
        'specialties': ['Воспитатель детского сада', 'Учитель начальных классов', 'Психолог', 'Журналист', 'Переводчик'],
        'url': 'https://ciur.ru/urspt',
        'type': 'БПОУ УР'
      },
      {
        'name': 'Воткинский промышленный техникум',
        'budget': 25,
        'passScore': 165,
        'paid': 20,
        'price': 42.0,
        'city': 'Воткинск',
        'specialties': ['Токарь', 'Фрезеровщик', 'Слесарь-механик', 'Автомеханик'],
        'url': 'https://ciur.ru/vpt',
        'type': 'БПОУ УР'
      },
      {
        'name': 'Ижевский индустриальный техникум имени Е.Ф. Драгунова',
        'budget': 35,
        'passScore': 170,
        'paid': 28,
        'price': 48.0,
        'city': 'Ижевск',
        'specialties': ['Слесарь-механик', 'Токарь', 'Фрезеровщик', 'Электромонтажник'],
        'url': 'https://ciur.ru/iitd',
        'type': 'БПОУ УР'
      },
      {
        'name': 'Ижевский агростроительный техникум',
        'budget': 30,
        'passScore': 168,
        'paid': 25,
        'price': 45.0,
        'city': 'Ижевск',
        'specialties': ['Строитель', 'Мастер строительных работ', 'Тракторист-машинист'],
        'url': 'https://ciur.ru/iat',
        'type': 'БПОУ УР'
      },
      {
        'name': 'Радиомеханический техникум имени В.А. Шутова',
        'budget': 30,
        'passScore': 172,
        'paid': 25,
        'price': 55.0,
        'city': 'Сарапул',
        'specialties': ['Радиотехник', 'Электромонтажник', 'Системный администратор'],
        'url': 'https://ciur.ru/rmt',
        'type': 'БПОУ УР'
      },
      {
        'name': 'Воткинский музыкально-педагогический техникум имени П.И. Чайковского',
        'budget': 40,
        'passScore': 175,
        'paid': 35,
        'price': 58.0,
        'city': 'Воткинск',
        'specialties': ['Музыкальный работник', 'Дизайнер', 'Художник-оформитель', 'Преподаватель музыки'],
        'url': 'https://ciur.ru/vmpt',
        'type': 'БПОУ УР'
      },
      {
        'name': 'Ижевский машиностроительный техникум имени С.Н. Борина',
        'budget': 35,
        'passScore': 170,
        'paid': 30,
        'price': 50.0,
        'city': 'Ижевск',
        'specialties': ['Автомеханик', 'Токарь', 'Фрезеровщик', 'Слесарь-механик'],
        'url': 'https://ciur.ru/imt',
        'type': 'БПОУ УР'
      },
      {
        'name': 'Глазовский политехнический колледж',
        'budget': 40,
        'passScore': 172,
        'paid': 32,
        'price': 52.0,
        'city': 'Глазов',
        'specialties': ['Инженер-механик', 'Техник-механик', 'Слесарь-механик', 'Электромонтажник'],
        'url': 'https://ciur.ru/gpk',
        'type': 'БПОУ УР'
      },
      {
        'name': 'Увинский профессиональный колледж',
        'budget': 25,
        'passScore': 158,
        'paid': 18,
        'price': 35.0,
        'city': 'Ува',
        'specialties': ['Тракторист-машинист', 'Механизатор', 'Сварщик', 'Электромонтажник'],
        'url': 'https://ciur.ru/upk',
        'type': 'БПОУ УР'
      },
      {
        'name': 'Ярский политехникум',
        'budget': 15,
        'passScore': 150,
        'paid': 12,
        'price': 28.0,
        'city': 'Яр',
        'specialties': ['Тракторист-машинист', 'Механизатор', 'Электромонтажник'],
        'url': 'https://ciur.ru/yp',
        'type': 'БПОУ УР'
      },
      {
        'name': 'Ижевский автотранспортный техникум',
        'budget': 30,
        'passScore': 165,
        'paid': 25,
        'price': 45.0,
        'city': 'Ижевск',
        'specialties': ['Автомеханик', 'Автослесарь', 'Электромонтажник'],
        'url': 'https://ciur.ru/iatk',
        'type': 'БПОУ УР'
      },
      {
        'name': 'Сарапульский техникум машиностроения и информационных технологий',
        'budget': 35,
        'passScore': 170,
        'paid': 28,
        'price': 48.0,
        'city': 'Сарапул',
        'specialties': ['Токарь', 'Фрезеровщик', 'Программист', 'Техник-программист'],
        'url': 'https://ciur.ru/stmi',
        'type': 'БПОУ УР'
      }
      // ... остальные колледжи
    ];
    setState(() {});
  }

  Future<void> _loadFavorites() async {
    final snap = await _db.child('users/${widget.userId}/favoriteColleges').get();
    if (snap.exists && snap.value != null) {
      final Map data = snap.value as Map;
      favoriteColleges = data.keys.map((e) => e.toString()).toList();
      setState(() {});
    }
  }

  Future<void> _toggleFavorite(String name) async {
    final ref = _db.child('users/${widget.userId}/favoriteColleges/$name');
    final isFav = favoriteColleges.contains(name);
    setState(() => isFav ? favoriteColleges.remove(name) : favoriteColleges.add(name));
    isFav ? await ref.remove() : await ref.set(true);
  }

  Future<void> _launchURL(String url) async {
    try {
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Не удалось открыть сайт'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _applyCityFilter(String city) {
    setState(() {
      _selectedCity = city;
    });
  }

  void _navigate(int i) {
    switch (i) {
      case 0:
        Navigator.pushReplacementNamed(context, '/choice_tests', arguments: widget.userId);
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/map_page', arguments: widget.userId);
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/professions', arguments: widget.userId);
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/profile', arguments: widget.userId);
        break;
      default:
        break;
    }
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 10,
                color: color.withOpacity(0.8),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _starController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final availableCities = ['Все города'] + colleges.map((c) => c['city'] as String).toSet().toList();
    final filteredColleges = _selectedCity == 'Все города'
        ? colleges
        : colleges.where((c) => c['city'] == _selectedCity).toList();

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
                // Заголовок
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
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
                        "Рейтинг колледжей",
                        style: GoogleFonts.nunito(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0A0F2D),
                        ),
                      ),
                      Text(
                        "Удмуртская Республика",
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF6C63FF),
                        ),
                      ),
                    ],
                  ),
                ),

                // Фильтр по городам
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: DropdownButton<String>(
                      value: _selectedCity,
                      isExpanded: true,
                      underline: const SizedBox(),
                      icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF6C63FF)),
                      items: availableCities.map((city) {
                        return DropdownMenuItem(
                          value: city,
                          child: Text(
                            city,
                            style: GoogleFonts.nunito(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF0A0F2D),
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) => _applyCityFilter(value!),
                    ),
                  ),
                ),

                // Статистика
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueAccent.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            filteredColleges.length.toString(),
                            style: GoogleFonts.nunito(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF6C63FF),
                            ),
                          ),
                          Text(
                            'Колледжей',
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF0A0F2D),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            filteredColleges.fold(0, (sum, c) => sum + (c['budget'] as int)).toString(),
                            style: GoogleFonts.nunito(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.blueAccent,
                            ),
                          ),
                          Text(
                            'Бюджетных мест',
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF0A0F2D),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            filteredColleges.fold(0, (sum, c) => sum + (c['paid'] as int)).toString(),
                            style: GoogleFonts.nunito(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.green,
                            ),
                          ),
                          Text(
                            'Платных мест',
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF0A0F2D),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Список колледжей
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredColleges.length,
                    itemBuilder: (context, i) {
                      final c = filteredColleges[i];
                      final fav = favoriteColleges.contains(c['name']);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Material(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white.withOpacity(0.95),
                          elevation: 8,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white,
                                  const Color(0xFFE3F2FD).withOpacity(0.5),
                                ],
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Заголовок и избранное
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            c['name'],
                                            style: GoogleFonts.nunito(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 16,
                                              color: const Color(0xFF0A0F2D),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(Icons.location_city, size: 14, color: Colors.grey[600]),
                                              const SizedBox(width: 4),
                                              Text(
                                                c['city'],
                                                style: GoogleFonts.nunito(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF6C63FF).withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  c['type'],
                                                  style: GoogleFonts.nunito(
                                                    fontSize: 10,
                                                    color: const Color(0xFF6C63FF),
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.star,
                                        color: fav ? Colors.amber : Colors.grey[400],
                                        size: 24,
                                      ),
                                      onPressed: () => _toggleFavorite(c['name']),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                // Статистика
                                Row(
                                  children: [
                                    _buildStatCard('Бюджет', c['budget'].toString(), Colors.blueAccent),
                                    const SizedBox(width: 4),
                                    _buildStatCard('Проходной\nбалл', c['passScore'].toString(), Colors.orange),
                                    const SizedBox(width: 4),
                                    _buildStatCard('Платных', c['paid'].toString(), Colors.green),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                // Оплата
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6C63FF).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.attach_money, size: 16, color: const Color(0xFF6C63FF)),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Оплата в год: ${c['price']} тыс. руб.',
                                        style: GoogleFonts.nunito(
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF0A0F2D),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 12),

                                // Специальности
                                Text(
                                  'Специальности:',
                                  style: GoogleFonts.nunito(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: const Color(0xFF0A0F2D),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: (c['specialties'] as List).map<Widget>((specialty) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.blueAccent.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
                                      ),
                                      child: Text(
                                        specialty,
                                        style: GoogleFonts.nunito(
                                          fontSize: 11,
                                          color: Colors.blueAccent,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),

                                const SizedBox(height: 12),

                                // Кнопка сайта
                                Container(
                                  width: double.infinity,
                                  height: 44,
                                  child: ElevatedButton.icon(
                                    onPressed: () => _launchURL(c['url']),
                                    icon: const Icon(Icons.link, size: 18),
                                    label: Text(
                                      'Перейти на сайт',
                                      style: GoogleFonts.nunito(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF6C63FF),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
      bottomNavigationBar: BottomNav(currentIndex: _currentIndex, onTap: _navigate),
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