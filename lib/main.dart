import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider_simple.dart';
import 'screens/splash_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/login_screen.dart';
import 'screens/class_selection_screen.dart';
import 'screens/subject_dashboard_screen.dart';
import 'screens/subject_lessons_screen.dart';
import 'screens/lesson_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/leaderboard_screen_simple.dart';
import 'models/lesson.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserProviderSimple(),
      child: MaterialApp(
        title: 'Nepal Learning Quest',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFFFD700), // Sunny Yellow
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/auth': (context) => const AuthScreen(),
          '/profile': (context) => const ChildProfileScreen(),
          '/class_selection': (context) => const ClassSelectionScreen(),
          '/home': (context) => const SubjectDashboardScreen(),
          '/subject_lessons': (context) => const SubjectLessonsScreen(),
          '/lesson': (context) => LessonScreen(lesson: Lesson(
            id: 'temp',
            title: 'Temporary',
            description: 'Temporary lesson',
            subject: Subject.Math,
            classLevel: 1,
            level: 1,
            content: [],
          )),
          '/quiz': (context) => QuizScreen(lesson: Lesson(
            id: 'temp',
            title: 'Temporary',
            description: 'Temporary lesson',
            subject: Subject.Math,
            classLevel: 1,
            level: 1,
            content: [],
          )),
          '/leaderboard': (context) => const LeaderboardScreenSimple(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
