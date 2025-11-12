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
  final int _currentIndex = 2;
  String _selectedCity = 'Все города';
  late AnimationController _starController;
  final List<Star> _stars = [];
  final Random _random = Random();
  late final PageController _trendPageController;
  List<SpecialtyTrend> specialtyTrends = [];
  bool _isLoadingColleges = true;
  bool _isLoadingTrends = true;
  int _currentTrendIndex = 0;

  @override
  void initState() {
    super.initState();
    _trendPageController = PageController(viewportFraction: 0.88);
    _starController = AnimationController(
      duration: const Duration(seconds: 25),
      vsync: this,
    )..repeat();

    _initializeStars();
    _loadColleges();
    _loadLaborTrends();
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
                        color: Colors.yellow.withValues(alpha: 0.9),
                        blurRadius: star.size * 3,
                        spreadRadius: star.size * 0.8,
                      ),
                      BoxShadow(
                        color: Colors.orange.withValues(alpha: 0.6),
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

  Future<void> _loadColleges() async {
    List<Map<String, dynamic>> parsed = [];
    try {
      final snap = await _db.child('udmurtCollegeRatings').get();
      if (snap.exists && snap.value != null) {
        parsed = _parseCollegeSnapshot(snap.value);
      }
    } catch (e) {
      debugPrint('Не удалось загрузить рейтинг колледжей: $e');
    }

    if (parsed.isEmpty) {
      parsed = _buildFallbackColleges();
    }

    if (!mounted) return;
    setState(() {
      colleges = parsed;
      _isLoadingColleges = false;
    });
  }

  List<Map<String, dynamic>> _buildFallbackColleges() {
    return [
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
  }

  List<Map<String, dynamic>> _parseCollegeSnapshot(dynamic raw) {
    final List<Map<String, dynamic>> result = [];
    if (raw is Map) {
      raw.forEach((_, value) {
        final map = _normalizeCollegeMap(value);
        if (map != null) {
          result.add(map);
        }
      });
    } else if (raw is List) {
      for (final value in raw) {
        final map = _normalizeCollegeMap(value);
        if (map != null) {
          result.add(map);
        }
      }
    }
    return result;
  }

  Map<String, dynamic>? _normalizeCollegeMap(dynamic raw) {
    if (raw is! Map) return null;
    final map = raw.map((key, value) => MapEntry(key.toString(), value));

    int? parseInt(dynamic value) {
      if (value is int) return value;
      if (value is double) return value.round();
      if (value is String) {
        final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
        return int.tryParse(digits);
      }
      return null;
    }

    double? parseDouble(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) {
        final normalized = value.replaceAll(' ', '').replaceAll(',', '.');
        return double.tryParse(normalized);
      }
      return null;
    }

    final name = map['name']?.toString().trim();
    if (name == null || name.isEmpty) {
      return null;
    }

    final rawSpecialties = map['specialties'];
    final List<String> specialties = [];
    if (rawSpecialties is List) {
      for (final item in rawSpecialties) {
        final text = item?.toString().trim();
        if (text != null && text.isNotEmpty) {
          specialties.add(text);
        }
      }
    }

    return {
      'name': name,
      'budget': parseInt(map['budget']) ?? 0,
      'passScore': parseInt(map['passScore']) ?? 0,
      'paid': parseInt(map['paid']) ?? 0,
      'price': parseDouble(map['price']) ?? 0,
      'city': map['city']?.toString().trim() ?? '',
      'specialties': specialties,
      'url': map['url']?.toString().trim() ?? '',
      'type': map['type']?.toString().trim() ?? 'Колледж',
      'rating': parseDouble(map['rating']),
      'demandIndex': parseDouble(map['demandIndex']),
    };
  }

  Future<void> _loadLaborTrends() async {
    List<SpecialtyTrend> trends = [];
    try {
      final snap = await _db.child('udmurtSpecialtyTrends').get();
      if (snap.exists && snap.value != null) {
        trends = _parseSpecialtyTrends(snap.value);
      }
    } catch (e) {
      debugPrint('Не удалось загрузить тенденции по специальностям: $e');
    }

    if (trends.isEmpty) {
      trends = _buildFallbackTrends();
    }

    if (!mounted) return;
    setState(() {
      specialtyTrends = trends;
      _isLoadingTrends = false;
    });
  }

  List<SpecialtyTrend> _parseSpecialtyTrends(dynamic raw) {
    final List<SpecialtyTrend> result = [];
    if (raw is Map) {
      raw.forEach((key, value) {
        if (value is Map) {
          result.add(SpecialtyTrend.fromMap(
            value.map((k, v) => MapEntry(k.toString(), v)),
            id: key.toString(),
          ));
        }
      });
    } else if (raw is List) {
      for (final value in raw) {
        if (value is Map) {
          result.add(SpecialtyTrend.fromMap(
            value.map((k, v) => MapEntry(k.toString(), v)),
          ));
        }
      }
    }
    result.sort((a, b) => b.priority.compareTo(a.priority));
    return result;
  }

  List<SpecialtyTrend> _buildFallbackTrends() {
    return _fallbackSpecialtyTrendData
        .map((item) => SpecialtyTrend.fromMap(item))
        .toList();
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
      if (!mounted) return;
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
      case 2:
        Navigator.pushReplacementNamed(context, '/chat', arguments: widget.userId);
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
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: GoogleFonts.nunito(
                  fontSize: 10,
                  color: color.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _starController.dispose();
    _trendPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final availableCities = ['Все города'] + colleges.map((c) => c['city'] as String).toSet().toList();
    final filteredColleges = _selectedCity == 'Все города'
        ? colleges
        : colleges.where((c) => c['city'] == _selectedCity).toList();
    final rankedColleges = List<Map<String, dynamic>>.from(filteredColleges)
      ..sort((a, b) => _computeCollegeScore(b).compareTo(_computeCollegeScore(a)));

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
                  const Color(0xFF0A0F2D).withValues(alpha: 0.6),
                  const Color(0xFF1E3A8A).withValues(alpha: 0.4),
                  const Color(0xFF0A0F2D).withValues(alpha: 0.6),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueAccent.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          "Рейтинг колледжей",
                          style: GoogleFonts.nunito(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0A0F2D),
                          ),
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          "Удмуртская Республика",
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF6C63FF),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
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
                const SizedBox(height: 6),
                _buildTrendCarousel(),
                const SizedBox(height: 10),
                _buildStatsSummary(filteredColleges, rankedColleges),
                const SizedBox(height: 8),
                Expanded(
                  child: _buildCollegeList(rankedColleges),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNav(currentIndex: _currentIndex, onTap: _navigate, userId: widget.userId),
    );
  }

  Widget _buildTrendCarousel() {
    if (_isLoadingTrends) {
      return Container(
        height: 230,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
          ),
        ),
      );
    }

    if (specialtyTrends.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'Данные о трендах появятся совсем скоро',
          style: GoogleFonts.nunito(
            color: Colors.white70,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Wrap(
            spacing: 12,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Лидеры рынка труда после 9 класса',
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Firebase realtime',
                  style: GoogleFonts.nunito(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 260,
          child: PageView.builder(
            controller: _trendPageController,
            itemCount: specialtyTrends.length,
            onPageChanged: (index) {
              if (_currentTrendIndex != index) {
                setState(() => _currentTrendIndex = index);
              }
            },
            itemBuilder: (context, index) {
              return _buildTrendCard(specialtyTrends[index], index);
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            specialtyTrends.length,
            (index) => _buildTrendIndicator(index),
          ),
        ),
      ],
    );
  }

  Widget _buildTrendCard(SpecialtyTrend trend, int index) {
    final isActive = index == _currentTrendIndex;
    final margin = EdgeInsets.only(
      left: index == 0 ? 20 : 12,
      right: index == specialtyTrends.length - 1 ? 20 : 12,
      top: isActive ? 0 : 12,
      bottom: 16,
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      margin: margin,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF6C63FF).withValues(alpha: isActive ? 0.96 : 0.78),
            const Color(0xFF4A90E2).withValues(alpha: isActive ? 0.92 : 0.72),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A90E2).withValues(alpha: isActive ? 0.35 : 0.18),
            blurRadius: isActive ? 28 : 18,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRankingBadge(index),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trend.name,
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          trend.focus,
                          style: GoogleFonts.nunito(
                            color: Colors.white.withValues(alpha: 0.88),
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.auto_graph_rounded,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: trend.colleges.map((college) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    college,
                    style: GoogleFonts.nunito(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            _buildTrendMetricsRow(trend),
            const SizedBox(height: 16),
            _buildTrendCharts(trend),
          ],
        ),
      ),
    );
  }

  Row _buildTrendMetricsRow(SpecialtyTrend trend) {
    return Row(
      children: [
        Expanded(
          child: _buildTrendMetricChip(
            label: 'Рост спроса',
            value: trend.demandGrowthLabel,
            subtitle: '${_formatNumber(trend.latestDemand)} вакансий',
            icon: Icons.trending_up_rounded,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildTrendMetricChip(
            label: 'Средняя з/п',
            value: _formatCurrency(trend.latestSalary),
            subtitle: trend.salaryGrowthLabel,
            icon: Icons.payments_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildTrendMetricChip({
    required String label,
    required String value,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.82), size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.nunito(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.nunito(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.nunito(
              color: Colors.white60,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendCharts(SpecialtyTrend trend) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Спрос на специалистов',
            style: GoogleFonts.nunito(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 90,
            child: AnimatedLineChart(
              points: trend.demandTrend,
              color: const Color(0xFF4BE1EC),
              fill: true,
            ),
          ),
          const SizedBox(height: 6),
          _buildTrendAxis(trend.demandTrend),
          const SizedBox(height: 14),
          Text(
            'Средняя зарплата, ₽',
            style: GoogleFonts.nunito(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 90,
            child: AnimatedLineChart(
              points: trend.salaryTrend,
              color: const Color(0xFFFFD166),
            ),
          ),
          const SizedBox(height: 6),
          _buildTrendAxis(trend.salaryTrend, isCurrency: true),
        ],
      ),
    );
  }

  Widget _buildTrendAxis(List<TrendPoint> points, {bool isCurrency = false}) {
    if (points.isEmpty) {
      return const SizedBox.shrink();
    }

    final first = points.first;
    final last = points.last;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${first.year}',
          style: GoogleFonts.nunito(color: Colors.white70, fontSize: 12),
        ),
        Text(
          isCurrency ? _formatCurrency(last.value) : _formatNumber(last.value),
          style: GoogleFonts.nunito(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
        Text(
          '${last.year}',
          style: GoogleFonts.nunito(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildTrendIndicator(int index) {
    final isActive = index == _currentTrendIndex;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 6,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF6C63FF) : Colors.white.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildStatsSummary(List<Map<String, dynamic>> filtered, List<Map<String, dynamic>> ranked) {
    if (_isLoadingColleges) {
      return Container(
        height: 120,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
          ),
        ),
      );
    }

    if (filtered.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          'В выбранном городе пока нет колледжей в базе',
          style: GoogleFonts.nunito(
            color: Colors.white70,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    final totalBudget = filtered.fold<int>(0, (sum, item) => sum + ((item['budget'] as int?) ?? 0));
    final totalPaid = filtered.fold<int>(0, (sum, item) => sum + ((item['paid'] as int?) ?? 0));
    final avgPass = filtered.fold<double>(0, (sum, item) => sum + ((item['passScore'] as num?)?.toDouble() ?? 0)) / filtered.length;
    final leaderName = ranked.isNotEmpty ? ranked.first['name'] as String : null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildStatCard('Колледжей', filtered.length.toString(), const Color(0xFF6C63FF)),
              const SizedBox(width: 6),
              _buildStatCard('Бюджетных\nмест', totalBudget.toString(), Colors.blueAccent),
              const SizedBox(width: 6),
              _buildStatCard('Платных\nмест', totalPaid.toString(), Colors.green),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  height: 38,
                  width: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.workspace_premium_rounded, color: Colors.white70),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Средний проходной балл: ${avgPass.round()}',
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (leaderName != null)
                        Text(
                          'Лидер рейтинга: $leaderName',
                          style: GoogleFonts.nunito(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
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

  Widget _buildCollegeList(List<Map<String, dynamic>> ranked) {
    if (_isLoadingColleges) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
        ),
      );
    }

    if (ranked.isEmpty) {
      return Center(
        child: Text(
          'Пока нет данных по колледжам',
          style: GoogleFonts.nunito(
            color: Colors.white70,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: ranked.length,
      itemBuilder: (context, index) {
        return _buildCollegeCard(ranked[index], index);
      },
    );
  }

  Widget _buildCollegeCard(Map<String, dynamic> college, int index) {
    final isFavorite = favoriteColleges.contains(college['name']);
    final double rating = _computeCollegeScore(college);
    final price = ((college['price'] as num?) ?? 0).toDouble();
    final List<String> specialties = List<String>.from(college['specialties'] as List);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.white.withValues(alpha: 0.96),
        elevation: 8,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                const Color(0xFFE8F1FF),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRankingBadge(index),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          college['name'],
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0A0F2D),
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.location_city, size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text(
                                  college['city'],
                                  style: GoogleFonts.nunito(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                college['type'],
                                style: GoogleFonts.nunito(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF6C63FF),
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
                      Icons.star_rounded,
                      color: isFavorite ? Colors.amber : Colors.grey[300],
                      size: 26,
                    ),
                    onPressed: () => _toggleFavorite(college['name'] as String),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _buildScoreChip(rating),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Индекс востребованности',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF6C63FF),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 350) {
                    return Column(
                      children: [
                        Row(
                          children: [
                            _buildStatInfoChip('Бюджет', '${college['budget']} мест', Colors.blueAccent),
                            const SizedBox(width: 8),
                            _buildStatInfoChip('Платных', '${college['paid']}', Colors.green),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildStatInfoChip('Проходной балл', '${college['passScore']}', Colors.deepOrangeAccent),
                      ],
                    );
                  }
                  return Row(
                    children: [
                      _buildStatInfoChip('Бюджет', '${college['budget']} мест', Colors.blueAccent),
                      const SizedBox(width: 8),
                      _buildStatInfoChip('Проходной балл', '${college['passScore']}', Colors.deepOrangeAccent),
                      const SizedBox(width: 8),
                      _buildStatInfoChip('Платных', '${college['paid']}', Colors.green),
                    ],
                  );
                },
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.attach_money, size: 18, color: Color(0xFF6C63FF)),
                    const SizedBox(width: 8),
                    Text(
                      'Оплата в год: ${price.toStringAsFixed(1)} тыс. ₽',
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0A0F2D),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Направления подготовки',
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0A0F2D),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: specialties.map((specialty) {
                  final isTrend = _isTrendingSpecialty(specialty);
                  final color = isTrend ? const Color(0xFF6C63FF) : Colors.blueAccent;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: color.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isTrend)
                          Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Icon(Icons.whatshot, size: 14, color: color),
                          ),
                        Text(
                          specialty,
                          style: GoogleFonts.nunito(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: () => _launchURL(college['url']),
                  icon: const Icon(Icons.link, size: 18),
                  label: Flexible(
                    child: Text(
                      'Перейти на сайт колледжа',
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
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
  }

  Widget _buildStatInfoChip(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: GoogleFonts.nunito(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color.withValues(alpha: 0.85),
                ),
              ),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankingBadge(int index) {
    final colors = [
      const Color(0xFFFFD700),
      const Color(0xFFC0C0C0),
      const Color(0xFFCD7F32),
    ];
    final baseColor = index < colors.length ? colors[index] : const Color(0xFF6C63FF);

    return Container(
      height: 48,
      width: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            baseColor,
            baseColor.withValues(alpha: 0.75),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: baseColor.withValues(alpha: 0.45),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '#${index + 1}',
          style: GoogleFonts.nunito(
            color: index < 3 ? Colors.black87 : Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _buildScoreChip(double rating) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF4A90E2)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: Colors.white, size: 18),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: GoogleFonts.nunito(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  bool _isTrendingSpecialty(String specialty) {
    return specialtyTrends.any((trend) => trend.name.toLowerCase() == specialty.toLowerCase());
  }

  double _computeCollegeScore(Map<String, dynamic> college) {
    final rating = college['rating'];
    if (rating is num) {
      return rating.toDouble().clamp(3.5, 5.0);
    }

    final budget = (college['budget'] as num?)?.toDouble() ?? 0;
    final passScore = (college['passScore'] as num?)?.toDouble() ?? 0;
    final paid = (college['paid'] as num?)?.toDouble() ?? 0;
    final price = (college['price'] as num?)?.toDouble() ?? 0;
    final demandIndex = (college['demandIndex'] as num?)?.toDouble() ?? 0;

    final totalSeats = budget + paid;
    final availability = totalSeats == 0 ? 0.5 : (budget / totalSeats).clamp(0.0, 1.0);
    final normalizedPass = (passScore / 200).clamp(0.0, 1.0);
    final normalizedBudget = (budget / 60).clamp(0.0, 1.0);
    final affordability = price <= 0 ? 1.0 : (1 - (price / 80).clamp(0.0, 1.0));
    final demand = demandIndex.clamp(0.0, 1.0);

    final score = 3.3
        + normalizedPass * 1.1
        + normalizedBudget * 0.6
        + availability * 0.5
        + affordability * 0.4
        + demand * 0.6;
    return score.clamp(3.5, 5.0);
  }

  String _formatNumber(num value) {
    final intValue = value.round();
    final digits = intValue.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      final reverseIndex = digits.length - i;
      buffer.write(digits[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write(' ');
      }
    }
    return buffer.toString();
  }

  String _formatCurrency(num value) {
    return '${_formatNumber(value)} ₽';
  }

}

const List<Map<String, dynamic>> _fallbackSpecialtyTrendData = [
  {
    'id': 'programmer',
    'name': 'Программист',
    'focus': 'IT и цифровые технологии',
    'colleges': [
      'ТРИТ им. А.В. Воскресенского',
      'Ижевский политехнический колледж',
      'Сарапульский техникум машиностроения и ИТ',
    ],
    'description': 'Создание и поддержка цифровых решений для предприятий региона.',
    'demandTrend': [
      {'year': 2021, 'value': 95},
      {'year': 2022, 'value': 130},
      {'year': 2023, 'value': 170},
      {'year': 2024, 'value': 215},
    ],
    'salaryTrend': [
      {'year': 2021, 'value': 48000},
      {'year': 2022, 'value': 56000},
      {'year': 2023, 'value': 65000},
      {'year': 2024, 'value': 74000},
    ],
  },
  {
    'id': 'electrician',
    'name': 'Электромонтажник',
    'focus': 'Промышленность и энергетика',
    'colleges': [
      'Ижевский политехнический колледж',
      'Воткинский машиностроительный техникум',
      'Глазовский технический колледж',
    ],
    'description': 'Монтаж и обслуживание электрических сетей, автоматики и оборудования.',
    'demandTrend': [
      {'year': 2021, 'value': 110},
      {'year': 2022, 'value': 138},
      {'year': 2023, 'value': 176},
      {'year': 2024, 'value': 228},
    ],
    'salaryTrend': [
      {'year': 2021, 'value': 42000},
      {'year': 2022, 'value': 47000},
      {'year': 2023, 'value': 52000},
      {'year': 2024, 'value': 59000},
    ],
  },
  {
    'id': 'avtomechanic',
    'name': 'Автомеханик',
    'focus': 'Транспорт и сервис',
    'colleges': [
      'Ижевский автотранспортный техникум',
      'Сарапульский многопрофильный колледж',
      'Воткинский промышленный техникум',
    ],
    'description': 'Диагностика, ремонт и обслуживание транспорта в автопарках Удмуртии.',
    'demandTrend': [
      {'year': 2021, 'value': 92},
      {'year': 2022, 'value': 118},
      {'year': 2023, 'value': 149},
      {'year': 2024, 'value': 188},
    ],
    'salaryTrend': [
      {'year': 2021, 'value': 38000},
      {'year': 2022, 'value': 42000},
      {'year': 2023, 'value': 47000},
      {'year': 2024, 'value': 53000},
    ],
  },
  {
    'id': 'energy-tech',
    'name': 'Техник-энергетик',
    'focus': 'Энергетическая инфраструктура',
    'colleges': [
      'Топливно-энергетический колледж',
      'Глазовский политехнический колледж',
    ],
    'description': 'Эксплуатация и настройка энергетического оборудования, работа на ТЭЦ и предприятиях.',
    'demandTrend': [
      {'year': 2021, 'value': 74},
      {'year': 2022, 'value': 98},
      {'year': 2023, 'value': 124},
      {'year': 2024, 'value': 162},
    ],
    'salaryTrend': [
      {'year': 2021, 'value': 40000},
      {'year': 2022, 'value': 44500},
      {'year': 2023, 'value': 50500},
      {'year': 2024, 'value': 57000},
    ],
  },
  {
    'id': 'chef-tech',
    'name': 'Повар-технолог',
    'focus': 'Сфера услуг и HoReCa',
    'colleges': [
      'Ижевский техникум индустрии питания',
      'Сарапульский колледж социально-педагогических технологий',
    ],
    'description': 'Организация технологических процессов на кухне, работа с локальными продуктами.',
    'demandTrend': [
      {'year': 2021, 'value': 88},
      {'year': 2022, 'value': 112},
      {'year': 2023, 'value': 138},
      {'year': 2024, 'value': 172},
    ],
    'salaryTrend': [
      {'year': 2021, 'value': 33000},
      {'year': 2022, 'value': 36500},
      {'year': 2023, 'value': 41000},
      {'year': 2024, 'value': 45500},
    ],
  },
];

class TrendPoint {
  final int year;
  final double value;

  const TrendPoint({required this.year, required this.value});

  factory TrendPoint.fromMap(Map<String, dynamic> map) {
    final year = (map['year'] as num?)?.toInt() ?? 0;
    final value = (map['value'] as num?)?.toDouble() ?? 0;
    return TrendPoint(year: year, value: value);
  }
}

class SpecialtyTrend {
  final String id;
  final String name;
  final String focus;
  final List<String> colleges;
  final List<TrendPoint> demandTrend;
  final List<TrendPoint> salaryTrend;
  final String? description;

  SpecialtyTrend({
    required this.id,
    required this.name,
    required this.focus,
    required this.colleges,
    required this.demandTrend,
    required this.salaryTrend,
    this.description,
  });

  factory SpecialtyTrend.fromMap(Map<String, dynamic> map, {String? id}) {
    final demand = <TrendPoint>[];
    final rawDemand = map['demandTrend'];
    if (rawDemand is List) {
      for (final item in rawDemand) {
        if (item is Map) {
          demand.add(TrendPoint.fromMap(item.map((k, v) => MapEntry(k.toString(), v))));
        }
      }
    }

    final salary = <TrendPoint>[];
    final rawSalary = map['salaryTrend'];
    if (rawSalary is List) {
      for (final item in rawSalary) {
        if (item is Map) {
          salary.add(TrendPoint.fromMap(item.map((k, v) => MapEntry(k.toString(), v))));
        }
      }
    }

    demand.sort((a, b) => a.year.compareTo(b.year));
    salary.sort((a, b) => a.year.compareTo(b.year));

    final collegesRaw = map['colleges'];
    final colleges = collegesRaw is List
        ? collegesRaw.map((e) => e.toString()).where((element) => element.isNotEmpty).toList()
        : <String>[];

    return SpecialtyTrend(
      id: id ?? map['id']?.toString() ?? map['name']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      focus: map['focus']?.toString() ?? '',
      colleges: colleges,
      demandTrend: demand,
      salaryTrend: salary,
      description: map['description']?.toString(),
    );
  }

  double get latestDemand => demandTrend.isNotEmpty ? demandTrend.last.value : 0;
  double get latestSalary => salaryTrend.isNotEmpty ? salaryTrend.last.value : 0;

  double get _demandDelta => demandTrend.length < 2 ? 0 : latestDemand - demandTrend.first.value;
  double get _salaryDelta => salaryTrend.length < 2 ? 0 : latestSalary - salaryTrend.first.value;

  double get demandGrowthPercent {
    final base = demandTrend.isNotEmpty ? demandTrend.first.value : 0;
    if (base == 0) {
      return _demandDelta > 0 ? 1 : 0;
    }
    return _demandDelta / base;
  }

  double get salaryGrowthPercent {
    final base = salaryTrend.isNotEmpty ? salaryTrend.first.value : 0;
    if (base == 0) {
      return _salaryDelta > 0 ? 1 : 0;
    }
    return _salaryDelta / base;
  }

  String get demandGrowthLabel {
    final percent = demandGrowthPercent * 100;
    if (percent == 0) return 'стабильно';
    final sign = percent > 0 ? '+' : '';
    return '$sign${percent.round()}%';
  }

  String get salaryGrowthLabel {
    final percent = salaryGrowthPercent * 100;
    if (percent == 0) return 'стабильно';
    final sign = percent > 0 ? '+' : '';
    return '$sign${percent.round()}% за 3 года';
  }

  double get priority {
    final demandScore = demandGrowthPercent.clamp(-0.2, 0.8) * 0.6;
    final salaryScore = salaryGrowthPercent.clamp(-0.15, 0.6) * 0.3;
    final scale = (latestDemand / 220).clamp(0.0, 0.2);
    return demandScore + salaryScore + scale;
  }
}

class AnimatedLineChart extends StatelessWidget {
  const AnimatedLineChart({
    super.key,
    required this.points,
    required this.color,
    this.fill = false,
  });

  final List<TrendPoint> points;
  final Color color;
  final bool fill;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      tween: Tween(begin: 0, end: 1),
      builder: (context, value, child) {
        return CustomPaint(
          painter: _TrendChartPainter(
            points: points,
            color: color,
            progress: value,
            fill: fill,
          ),
        );
      },
    );
  }
}

class _TrendChartPainter extends CustomPainter {
  _TrendChartPainter({
    required this.points,
    required this.color,
    required this.progress,
    this.fill = false,
  });

  final List<TrendPoint> points;
  final Color color;
  final double progress;
  final bool fill;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final horizontalPadding = 12.0;
    final verticalPadding = 14.0;
    final usableWidth = size.width - horizontalPadding * 2;
    final usableHeight = size.height - verticalPadding * 2;

    double minY = points.map((e) => e.value).reduce((a, b) => a < b ? a : b);
    double maxY = points.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    if (minY == maxY) {
      if (minY == 0) {
        maxY = 1;
      } else {
        minY = minY * 0.85;
        maxY = maxY * 1.05;
      }
    }

    final range = (maxY - minY).abs();

    final offsets = <Offset>[];
    for (int i = 0; i < points.length; i++) {
      final ratioX = i / (points.length - 1);
      final ratioY = (points[i].value - minY) / range;
      final dx = horizontalPadding + ratioX * usableWidth;
      final dy = verticalPadding + (1 - ratioY) * usableHeight;
      offsets.add(Offset(dx, dy));
    }

    final gridPaint = Paint()
      ..color = color.withValues(alpha: 0.08)
      ..strokeWidth = 1;

    for (int i = 0; i <= 3; i++) {
      final y = verticalPadding + (usableHeight / 3) * i;
      canvas.drawLine(
        Offset(horizontalPadding, y),
        Offset(size.width - horizontalPadding, y),
        gridPaint,
      );
    }

    final linePath = Path()..moveTo(offsets.first.dx, offsets.first.dy);
    for (final offset in offsets.skip(1)) {
      linePath.lineTo(offset.dx, offset.dy);
    }

    final metrics = linePath.computeMetrics().isEmpty ? null : linePath.computeMetrics().first;
    if (metrics == null) return;

    final length = metrics.length * progress.clamp(0.0, 1.0);
    final animatedPath = metrics.extractPath(0, length);

    if (fill) {
      final tangent = metrics.getTangentForOffset(length);
      final lastPoint = tangent?.position ?? offsets.last;
      final areaPath = Path.from(animatedPath)
        ..lineTo(lastPoint.dx, verticalPadding + usableHeight)
        ..lineTo(offsets.first.dx, verticalPadding + usableHeight)
        ..close();

      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0.28),
            color.withValues(alpha: 0.05),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
        ..style = PaintingStyle.fill;

      canvas.drawPath(areaPath, fillPaint);
    }

    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(animatedPath, linePaint);

    final tangent = metrics.getTangentForOffset(length);
    if (tangent != null) {
      canvas.drawCircle(tangent.position, 4.5, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(covariant _TrendChartPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.points != points || oldDelegate.color != color;
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
