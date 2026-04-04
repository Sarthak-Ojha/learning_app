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
import 'screens/premium_upgrade_screen.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'models/lesson.dart';

import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase init error: $e");
  }
  Stripe.publishableKey = 'pk_test_51TIKFCRRKy7XzxCrBxLUWQNTbTfkAeHFdj1aria7z3aMk3IczyQZMNkESlYsqXN8QWD7A2QaRBi51H7AXKYIiIA700j99R5l9I';
  await Stripe.instance.applySettings();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final provider = UserProviderSimple();
        provider.checkCurrentUser();
        return provider;
      },
      child: Consumer<UserProviderSimple>(
        builder: (context, userProvider, _) {
          return MaterialApp(
            title: 'GyanYatra',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF1976D2),
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              fontFamily: 'Roboto',
            ),
            // Automatically show dashboard if authenticated, else show Splash/Auth
            home: userProvider.isAuthenticated
                ? const SubjectDashboardScreen()
                : const SplashScreen(),
            routes: {
              '/auth': (context) => const AuthScreen(),
              '/profile': (context) => const ChildProfileScreen(),
              '/class_selection': (context) => const ClassSelectionScreen(),
              '/home': (context) => const SubjectDashboardScreen(),
              '/subject_lessons': (context) => const SubjectLessonsScreen(),
              '/lesson': (context) {
                final args = ModalRoute.of(context)!.settings.arguments
                    as Map<String, dynamic>;
                final lesson = args['lesson'] as Lesson;
                return LessonScreen(lesson: lesson);
              },
              '/quiz': (context) {
                final args = ModalRoute.of(context)!.settings.arguments
                    as Map<String, dynamic>;
                final lesson = args['lesson'] as Lesson;
                return QuizScreen(lesson: lesson);
              },
              '/leaderboard': (context) => const LeaderboardScreenSimple(),
              '/premium_upgrade': (context) => const PremiumUpgradeScreen(),
            },
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
