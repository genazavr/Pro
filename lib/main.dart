import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import 'theme/theme_manager.dart';
import 'theme/app_theme.dart';
import 'main_animation.dart';
import 'registration.dart';
import 'login.dart';
import 'choice_of_tests.dart';
import 'map_page.dart';
import 'college_rating.dart';
import 'professions.dart';
import 'profile.dart';
import 'chat_page.dart';
import 'ege_screen.dart';
import 'oge_screen.dart';
import 'admission_chances_screen.dart';
import 'merch_shop_screen.dart';
import 'study/pomodoro_page.dart';
import 'study/schedule_calendar_page.dart';
import 'study/notes_page.dart';
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
    return ChangeNotifierProvider(
      create: (context) => ThemeManager(),
      child: Consumer<ThemeManager>(
        builder: (context, themeManager, child) {
          return MaterialApp(
            title: 'Профориентация',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.getThemeData(themeManager.currentTheme),
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
              '/chat': (context) {
                final userId = ModalRoute.of(context)!.settings.arguments as String;
                return ChatPage(userId: userId);
              },
              '/profile': (context) {
                final userId = ModalRoute.of(context)!.settings.arguments as String;
                return ProfilePage(userId: userId);
              },
              '/pomodoro': (context) {
                final userId = ModalRoute.of(context)!.settings.arguments as String;
                return PomodoroPage(userId: userId);
              },
              '/schedule': (context) {
                final userId = ModalRoute.of(context)!.settings.arguments as String;
                return ScheduleCalendarPage(userId: userId);
              },
              '/notes': (context) {
                final userId = ModalRoute.of(context)!.settings.arguments as String;
                return NotesPage(userId: userId);
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
        },
      ),
    );
  }
}
