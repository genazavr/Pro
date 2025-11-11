import 'package:flutter/material.dart';
import 'choice_of_tests.dart';
import 'map_page.dart';

class HomeWithBottomNav extends StatefulWidget {
  final String userId;
  const HomeWithBottomNav({super.key, required this.userId});

  @override
  State<HomeWithBottomNav> createState() => _HomeWithBottomNavState();
}

class _HomeWithBottomNavState extends State<HomeWithBottomNav> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      ChoiceOfTestsPage(userId: widget.userId), // Тесты
      MapPage(userId: '',),                               // Вузы
      const Center(child: Text('Рейтинг (заглушка)')),
      const Center(child: Text('Профессии (заглушка)')),
      const Center(child: Text('Профиль (заглушка)')),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Тесты'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Вузы'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Рейтинг'),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Профессии'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
        ],
      ),
    );
  }
}
