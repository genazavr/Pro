import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'main_animation.dart';
import 'registration.dart';
import 'login.dart';
import 'choice_of_tests.dart';
import 'map_page.dart';
import 'college_rating.dart';
import 'professions.dart';
import 'profile.dart';
import 'ege_screen.dart';
import 'oge_screen.dart';
import 'admission_chances_screen.dart';
import 'merch_shop_screen.dart';
// Если есть firebase_options.dart, раскомментировать:
// import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Инициализация Firebase
  await Firebase.initializeApp(
    // options: DefaultFirebaseOptions.currentPlatform, // если используешь flutterfire configure
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Профориентация',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const MainAnimationPage(),
        '/registration': (context) => const RegistrationPage(),
        '/login': (context) => const LoginPage(),
        '/choice_tests': (context) {
          final userId = ModalRoute.of(context)!.settings.arguments as String;
          return ChoiceOfTestsPage(userId: userId);
        },
        '/map_page': (context) {
          final userId = ModalRoute.of(context)!.settings.arguments as String;
          return MapPage(userId: userId);
        },
        '/college_rating': (context) {
          final userId = ModalRoute.of(context)!.settings.arguments as String;
          return CollegeRatingPage(userId: userId);
        },
        '/professions': (context) {
          final userId = ModalRoute.of(context)!.settings.arguments as String;
          return ProfessionsPage(userId: userId);
        },
        '/profile': (context) {
          final userId = ModalRoute.of(context)!.settings.arguments as String;
          return ProfilePage(userId: userId);
        },
        '/ege': (context) {
          final userId = ModalRoute.of(context)!.settings.arguments as String;
          return EGEScreen(userId: userId);
        },
        '/oge': (context) {
          final userId = ModalRoute.of(context)!.settings.arguments as String;
          return OGEScreen(userId: userId);
        },
        '/admission_chances': (context) {
          final userId = ModalRoute.of(context)!.settings.arguments as String;
          return AdmissionChancesScreen(userId: userId);
        },
        '/merch_shop': (context) {
          final userId = ModalRoute.of(context)!.settings.arguments as String;
          return MerchShopScreen(userId: userId);
        },
      },
    );
  }
}
