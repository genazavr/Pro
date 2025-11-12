import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/bottom_nav.dart';
import 'perspective_professions_screen.dart';
import 'dart:math';

class ProfessionsPage extends StatefulWidget {
  final String userId;
  const ProfessionsPage({super.key, required this.userId});

  @override
  State<ProfessionsPage> createState() => _ProfessionsPageState();
}

class _ProfessionsPageState extends State<ProfessionsPage> with SingleTickerProviderStateMixin {
  final _db = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> professions = [];
  List<String> favoriteProfessions = [];
  List<String> filteredProfessions = [];
  List<String> testResults = [];
  String _selectedFilter = 'Все профессии';
  int _currentIndex = 3;
  late AnimationController _starController;
  final List<Star> _stars = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _starController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();

    _initializeStars();
    _loadProfessions();
    _loadFavorites();
    _loadTestResults();
  }

  void _initializeStars() {
    for (int i = 0; i < 150; i++) { // 150 звезд
      _stars.add(Star(
        x: _random.nextDouble() * 1.5 - 0.5,
        y: _random.nextDouble() * 2 - 1,
        speed: 0.2 + _random.nextDouble() * 0.8,
        size: 1.0 + _random.nextDouble() * 3.0,
        delay: _random.nextDouble() * 4.0,
        brightness: 0.4 + _random.nextDouble() * 0.6,
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

            final pulse = (sin(_starController.value * 6 * pi + star.delay * 12) + 1) / 2;
            final currentOpacity = opacity * (0.7 + 0.3 * pulse);

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
                        color: Colors.yellow.withOpacity(0.8),
                        blurRadius: star.size * 2,
                        spreadRadius: star.size * 0.5,
                      ),
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.4),
                        blurRadius: star.size * 4,
                        spreadRadius: star.size * 1.5,
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

  void _loadProfessions() {
    professions = [
      // ВСТАВЬТЕ СВОИ ПРОФЕССИИ ЗДЕСЬ
      {
        'name': 'Автомеханик',
        'type': 'реалистический',
        'duration': '2 года 10 месяцев',
        'salary': '35 000–80 000 ₽',
        'description': 'Диагностика, ремонт и техническое обслуживание автомобилей.',
        'colleges': ['Ижевский автотранспортный техникум', 'Сарапульский многопрофильный колледж']
      },
      {
        'name': 'Электромонтажник',
        'type': 'реалистический',
        'duration': '2 года 10 месяцев',
        'salary': '40 000–90 000 ₽',
        'description': 'Монтаж, наладка и обслуживание электрооборудования.',
        'colleges': ['Ижевский политехнический колледж', 'Воткинский машиностроительный техникум']
      },
      {
        'name': 'Слесарь-механик',
        'type': 'реалистический',
        'duration': '2 года 10 месяцев',
        'salary': '30 000–70 000 ₽',
        'description': 'Ремонт и обслуживание промышленного оборудования.',
        'colleges': ['Глазовский политехнический колледж', 'Ижевский индустриальный техникум']
      },
      {
        'name': 'Строитель',
        'type': 'реалистический',
        'duration': '2 года 10 месяцев',
        'salary': '35 000–85 000 ₽',
        'description': 'Строительство зданий и сооружений, выполнение строительно-монтажных работ.',
        'colleges': ['Строительный техникум', 'Ижевский агростроительный техникум']
      },

      // Интеллектуальный тип (Тест Голланда + Методика "Профиль")
      {
        'name': 'Программист',
        'type': 'интеллектуальный',
        'duration': '3 года 10 месяцев',
        'salary': '50 000–150 000 ₽',
        'description': 'Разработка программного обеспечения, создание веб-сайтов и мобильных приложений.',
        'colleges': ['Техникум радиоэлектроники и информационных технологий', 'Ижевский политехнический колледж']
      },
      {
        'name': 'Техник-программист',
        'type': 'интеллектуальный',
        'duration': '2 года 10 месяцев',
        'salary': '40 000–100 000 ₽',
        'description': 'Сопровождение программных продуктов, настройка программного обеспечения.',
        'colleges': ['Техникум радиоэлектроники и информационных технологий']
      },
      {
        'name': 'Системный администратор',
        'type': 'интеллектуальный',
        'duration': '2 года 10 месяцев',
        'salary': '45 000–110 000 ₽',
        'description': 'Настройка и обслуживание компьютерных сетей и серверов.',
        'colleges': ['Техникум радиоэлектроники и информационных технологий']
      },

      // Социальный тип (Тест Голланда)
      {
        'name': 'Воспитатель детского сада',
        'type': 'социальный',
        'duration': '3 года 10 месяцев',
        'salary': '25 000–45 000 ₽',
        'description': 'Воспитание и развитие детей дошкольного возраста.',
        'colleges': ['Можгинский педагогический колледж', 'Удмуртский республиканский социально-педагогический колледж']
      },
      {
        'name': 'Учитель начальных классов',
        'type': 'социальный',
        'duration': '3 года 10 месяцев',
        'salary': '30 000–50 000 ₽',
        'description': 'Обучение детей младшего школьного возраста.',
        'colleges': ['Можгинский педагогический колледж', 'Удмуртский республиканский социально-педагогический колледж']
      },
      {
        'name': 'Социальный работник',
        'type': 'социальный',
        'duration': '2 года 10 месяцев',
        'salary': '25 000–40 000 ₽',
        'description': 'Помощь социально незащищенным слоям населения.',
        'colleges': ['Удмуртский республиканский социально-педагогический колледж']
      },

      // Конвенциальный тип (Тест Голланда)
      {
        'name': 'Бухгалтер',
        'type': 'конвенциальный',
        'duration': '2 года 10 месяцев',
        'salary': '30 000–60 000 ₽',
        'description': 'Ведение бухгалтерского учета, составление отчетности.',
        'colleges': ['Ижевский торгово-экономический техникум', 'Экономико-технологический колледж']
      },
      {
        'name': 'Менеджер по продажам',
        'type': 'конвенциальный',
        'duration': '2 года 10 месяцев',
        'salary': '35 000–80 000 ₽',
        'description': 'Продажа товаров и услуг, работа с клиентами.',
        'colleges': ['Ижевский торгово-экономический техникум', 'Экономико-технологический колледж']
      },
      {
        'name': 'Офис-менеджер',
        'type': 'конвенциальный',
        'duration': '2 года 10 месяцев',
        'salary': '25 000–45 000 ₽',
        'description': 'Организация работы офиса, документооборот.',
        'colleges': ['Экономико-технологический колледж']
      },

      // Предпринимательский тип (Тест Голланда)
      {
        'name': 'Предприниматель',
        'type': 'предпринимательский',
        'duration': '2 года 10 месяцев',
        'salary': '50 000–200 000 ₽',
        'description': 'Ведение собственного бизнеса, организация предпринимательской деятельности.',
        'colleges': ['Ижевский торгово-экономический техникум', 'Экономико-технологический колледж']
      },
      {
        'name': 'Торговый представитель',
        'type': 'предпринимательский',
        'duration': '2 года 10 месяцев',
        'salary': '40 000–100 000 ₽',
        'description': 'Продвижение товаров на рынке, работа с клиентами.',
        'colleges': ['Ижевский торгово-экономический техникум']
      },

      // Артистический тип (Тест Голланда)
      {
        'name': 'Дизайнер',
        'type': 'артистический',
        'duration': '3 года 10 месяцев',
        'salary': '35 000–90 000 ₽',
        'description': 'Создание дизайна интерьеров, графики, веб-дизайна.',
        'colleges': ['Воткинский музыкально-педагогический техникум']
      },
      {
        'name': 'Музыкальный работник',
        'type': 'артистический',
        'duration': '3 года 10 месяцев',
        'salary': '25 000–50 000 ₽',
        'description': 'Преподавание музыки, организация культурно-массовых мероприятий.',
        'colleges': ['Воткинский музыкально-педагогический техникум']
      },

      // Технический тип (Выбор профессии для подростков)
      {
        'name': 'Инженер-механик',
        'type': 'технический',
        'duration': '3 года 10 месяцев',
        'salary': '45 000–120 000 ₽',
        'description': 'Проектирование и эксплуатация механических систем.',
        'colleges': ['Ижевский политехнический колледж', 'Глазовский политехнический колледж']
      },
      {
        'name': 'Техник-энергетик',
        'type': 'технический',
        'duration': '2 года 10 месяцев',
        'salary': '40 000–90 000 ₽',
        'description': 'Обслуживание энергетических систем и оборудования.',
        'colleges': ['Топливно-энергетический колледж']
      },
      {
        'name': 'Радиотехник',
        'type': 'технический',
        'duration': '2 года 10 месяцев',
        'salary': '35 000–80 000 ₽',
        'description': 'Обслуживание радиоэлектронного оборудования.',
        'colleges': ['Радиомеханический техникум']
      },

      // Гуманитарный тип (Выбор профессии для подростков)
      {
        'name': 'Журналист',
        'type': 'гуманитарный',
        'duration': '3 года 10 месяцев',
        'salary': '30 000–70 000 ₽',
        'description': 'Создание журналистских материалов, работа в СМИ.',
        'colleges': ['Удмуртский республиканский социально-педагогический колледж']
      },
      {
        'name': 'Переводчик',
        'type': 'гуманитарный',
        'duration': '2 года 10 месяцев',
        'salary': '35 000–80 000 ₽',
        'description': 'Перевод документов, сопровождение переговоров.',
        'colleges': ['Удмуртский республиканский социально-педагогический колледж']
      },

      // Творческий тип (Выбор профессии для подростков)
      {
        'name': 'Художник-оформитель',
        'type': 'творческий',
        'duration': '2 года 10 месяцев',
        'salary': '30 000–65 000 ₽',
        'description': 'Создание художественного оформления мероприятий и пространств.',
        'colleges': ['Воткинский музыкально-педагогический техникум']
      },

      // Спортивный тип (Выбор профессии для подростков)
      {
        'name': 'Тренер-преподаватель',
        'type': 'спортивный',
        'duration': '3 года 10 месяцев',
        'salary': '25 000–55 000 ₽',
        'description': 'Проведение спортивных тренировок и занятий.',
        'colleges': ['Сарапульский колледж социально-педагогических технологий']
      },

      // Организатор (Методика "Профиль")
      {
        'name': 'Менеджер проекта',
        'type': 'организатор',
        'duration': '2 года 10 месяцев',
        'salary': '40 000–100 000 ₽',
        'description': 'Планирование и координация выполнения проектов.',
        'colleges': ['Ижевский промышленно-экономический колледж']
      },
      {
        'name': 'Администратор',
        'type': 'организатор',
        'duration': '2 года 10 месяцев',
        'salary': '30 000–55 000 ₽',
        'description': 'Организация работы подразделения, координация процессов.',
        'colleges': ['Экономико-технологический колледж']
      },

      // Практик (Методика "Профиль")
      {
        'name': 'Мастер производственного обучения',
        'type': 'практик',
        'duration': '2 года 10 месяцев',
        'salary': '35 000–60 000 ₽',
        'description': 'Обучение практическим навыкам по рабочим профессиям.',
        'colleges': ['Глазовский технический колледж', 'Сарапульский политехнический колледж']
      },

      // Коммуникатор (Методика "Профиль")
      {
        'name': 'Психолог',
        'type': 'коммуникатор',
        'duration': '3 года 10 месяцев',
        'salary': '30 000–65 000 ₽',
        'description': 'Психологическое консультирование и помощь людям.',
        'colleges': ['Удмуртский республиканский социально-педагогический колледж']
      },
      {
        'name': 'Специалист по работе с молодежью',
        'type': 'коммуникатор',
        'duration': '2 года 10 месяцев',
        'salary': '25 000–45 000 ₽',
        'description': 'Организация досуга и работы с молодежью.',
        'colleges': ['Сарапульский колледж социально-педагогических технологий']
      },

      // Контролер (Методика "Профиль")
      {
        'name': 'Контролер-кассир',
        'type': 'контролер',
        'duration': '2 года 10 месяцев',
        'salary': '25 000–45 000 ₽',
        'description': 'Работа с денежными средствами, контроль кассовых операций.',
        'colleges': ['Ижевский торгово-экономический техникум']
      },

      // Креативщик (Методика "Профиль")
      {
        'name': 'Специалист по рекламе',
        'type': 'креативщик',
        'duration': '2 года 10 месяцев',
        'salary': '30 000–70 000 ₽',
        'description': 'Создание рекламных кампаний и продвижение товаров.',
        'colleges': ['Экономико-технологический колледж']
      },
      // Перспективные профессии для Удмуртии
      {
        'name': 'Технический контролер',
        'type': 'контролер',
        'duration': '2 года 10 месяцев',
        'salary': '45 000–85 000 ₽',
        'description': 'Контроль качества продукции, проверка соответствия техническим требованиям и стандартам.',
        'colleges': ['Ижевский индустриальный техникум', 'Воткинский машиностроительный техникум', 'Глазовский политехнический колледж'],
        'isPerspective': true
      },
      {
        'name': 'Литейщик',
        'type': 'реалистический',
        'duration': '2 года 10 месяцев',
        'salary': '50 000–95 000 ₽',
        'description': 'Изготовление отливок из металла, работа с литейным оборудованием и формами.',
        'colleges': ['Ижевский машиностроительный колледж', 'Воткинский машиностроительный техникум'],
        'isPerspective': true
      },
      {
        'name': 'Штамповщик',
        'type': 'реалистический',
        'duration': '2 года 10 месяцев',
        'salary': '42 000–80 000 ₽',
        'description': 'Обработка металлов давлением, работа на штамповочном оборудовании.',
        'colleges': ['Ижевский индустриальный техникум', 'Сарапульский политехнический колледж'],
        'isPerspective': true
      },
      {
        'name': 'Оператор станков с ЧПУ',
        'type': 'технический',
        'duration': '2 года 10 месяцев',
        'salary': '48 000–100 000 ₽',
        'description': 'Управление и наладка металлообрабатывающих станков с числовым программным управлением.',
        'colleges': ['Ижевский индустриальный техникум', 'Сарапульский политехнический колледж', 'Глазовский политехнический колледж'],
        'isPerspective': true
      },
      {
        'name': 'Инженер по робототехнике',
        'type': 'интеллектуальный',
        'duration': '4 года',
        'salary': '60 000–140 000 ₽',
        'description': 'Разработка, внедрение и обслуживание роботизированных систем на производстве.',
        'colleges': ['Ижевский государственный технический университет', 'Техникум радиоэлектроники и информационных технологий'],
        'isPerspective': true
      },
      // ... остальные профессии
    ];
    setState(() {
      filteredProfessions = professions.map((p) => p['name'] as String).toList();
    });
  }

  Future<void> _loadFavorites() async {
    final snap = await _db.child('users/${widget.userId}/favoriteProfessions').get();
    if (snap.exists && snap.value != null) {
      final Map data = snap.value as Map;
      favoriteProfessions = data.keys.map((e) => e.toString()).toList();
      setState(() {});
    }
  }

  Future<void> _loadTestResults() async {
    final snap = await _db.child('users/${widget.userId}/results').get();
    if (snap.exists && snap.value != null) {
      final Map resultsData = snap.value as Map;
      testResults = resultsData.keys.map((e) => e.toString()).toList();
      setState(() {});
    }
  }

  Future<void> _toggleFavorite(String name) async {
    final ref = _db.child('users/${widget.userId}/favoriteProfessions/$name');
    final isFav = favoriteProfessions.contains(name);
    setState(() => isFav ? favoriteProfessions.remove(name) : favoriteProfessions.add(name));
    isFav ? await ref.remove() : await ref.set(true);
  }

  void _applyFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      if (filter == 'Все профессии') {
        filteredProfessions = professions.map((p) => p['name'] as String).toList();
      } else {
        filteredProfessions = professions
            .where((p) => p['type'] == filter)
            .map((p) => p['name'] as String)
            .toList();
      }
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
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/profile', arguments: widget.userId);
        break;
    }
  }

  Color _getTypeColor(String type) {
    final colors = {
      'реалистический': Colors.blueAccent,
      'интеллектуальный': Colors.purple,
      'социальный': Colors.green,
      'конвенциальный': Colors.orange,
      'предпринимательский': Colors.red,
      'артистический': Colors.pink,
      'технический': Colors.blue,
      'гуманитарный': Colors.teal,
      'творческий': Colors.deepPurple,
      'спортивный': Colors.amber,
      'организатор': Colors.indigo,
      'практик': Colors.cyan,
      'коммуникатор': Colors.lightGreen,
      'контролер': Colors.brown,
      'креативщик': Colors.deepOrange,
    };
    return colors[type] ?? const Color(0xFF6C63FF);
  }

  @override
  void dispose() {
    _starController.dispose();
    super.dispose();
  }

  void _showPerspectiveProfessions(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PerspectiveProfessionsScreen(
          perspectiveProfessions: professions.where((p) => p['isPerspective'] == true).toList(),
          userId: widget.userId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final availableTypes = [
      'Все профессии',
      'реалистический',
      'интеллектуальный',
      'социальный',
      'конвенциальный',
      'предпринимательский',
      'артистический',
      'технический',
      'гуманитарный',
      'творческий',
      'спортивный',
      'организатор',
      'практик',
      'коммуникатор',
      'контролер',
      'креативщик'
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F2D),
      body: Stack(
        children: [
          // Звездный фон с 150 звездами
          _buildStarBackground(),

          // Градиентный оверлей
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF0A0F2D).withOpacity(0.7),
                  const Color(0xFF1E3A8A).withOpacity(0.5),
                  const Color(0xFF0A0F2D).withOpacity(0.7),
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
                        "Каталог профессий",
                        style: GoogleFonts.nunito(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0A0F2D),
                        ),
                      ),
                      Text(
                        "Найдите свою будущую профессию",
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF6C63FF),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Кнопка перспективных профессий
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: Material(
                    borderRadius: BorderRadius.circular(16),
                    elevation: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF6C63FF),
                            Color(0xFF4A90E2),
                          ],
                        ),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _showPerspectiveProfessions(context),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.trending_up, color: Colors.white, size: 24),
                              const SizedBox(width: 12),
                              Text(
                                'Самые перспективные профессии',
                                style: GoogleFonts.nunito(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Фильтр
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
                      value: _selectedFilter,
                      isExpanded: true,
                      underline: const SizedBox(),
                      icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF6C63FF)),
                      items: availableTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(
                            type == 'Все профессии' ? type : type[0].toUpperCase() + type.substring(1),
                            style: GoogleFonts.nunito(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF0A0F2D),
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) => _applyFilter(value!),
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
                            filteredProfessions.length.toString(),
                            style: GoogleFonts.nunito(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF6C63FF),
                            ),
                          ),
                          Text(
                            'Профессий',
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
                            professions.length.toString(),
                            style: GoogleFonts.nunito(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.blueAccent,
                            ),
                          ),
                          Text(
                            'Всего',
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
                            favoriteProfessions.length.toString(),
                            style: GoogleFonts.nunito(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.amber,
                            ),
                          ),
                          Text(
                            'В избранном',
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

                // Список профессий
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredProfessions.length,
                    itemBuilder: (context, i) {
                      final professionName = filteredProfessions[i];
                      final p = professions.firstWhere((prof) => prof['name'] == professionName);
                      final fav = favoriteProfessions.contains(p['name']);
                      final typeColor = _getTypeColor(p['type']);

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
                                  typeColor.withOpacity(0.1),
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
                                      child: Text(
                                        p['name'],
                                        style: GoogleFonts.nunito(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 18,
                                          color: const Color(0xFF0A0F2D),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.star,
                                        color: fav ? Colors.amber : Colors.grey[400],
                                        size: 24,
                                      ),
                                      onPressed: () => _toggleFavorite(p['name']),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 8),

                                // Тип профессии
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: typeColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: typeColor.withOpacity(0.3)),
                                  ),
                                  child: Text(
                                    'Тип: ${p['type'][0].toUpperCase() + p['type'].substring(1)}',
                                    style: GoogleFonts.nunito(
                                      fontSize: 12,
                                      color: typeColor,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 12),

                                // Информация
                                Row(
                                  children: [
                                    _buildInfoItem(Icons.schedule, p['duration'], Colors.blueAccent),
                                    const SizedBox(width: 12),
                                    _buildInfoItem(Icons.attach_money, p['salary'], Colors.green),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                // Описание
                                Text(
                                  p['description'],
                                  style: GoogleFonts.nunito(
                                    fontSize: 14,
                                    color: const Color(0xFF0A0F2D),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),

                                const SizedBox(height: 12),

                                // Колледжи
                                Text(
                                  'Колледжи:',
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
                                  children: (p['colleges'] as List).map<Widget>((college) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF6C63FF).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.3)),
                                      ),
                                      child: Text(
                                        college,
                                        style: GoogleFonts.nunito(
                                          fontSize: 11,
                                          color: const Color(0xFF6C63FF),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    );
                                  }).toList(),
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
      bottomNavigationBar: BottomNav(currentIndex: _currentIndex, onTap: _navigate, userId: widget.userId),
    );
  }

  Widget _buildInfoItem(IconData icon, String text, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
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

  Star({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.delay,
    required this.brightness,
  });
}