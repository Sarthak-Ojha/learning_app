import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/lesson.dart';
import '../services/multi_subject_service.dart';
import '../providers/user_provider_simple.dart';
import '../services/parental_control_service.dart';
import 'streak_screen.dart';
import 'settings_screen.dart';
import 'parental_lock_screen.dart';
import 'leaderboard_screen_simple.dart';

class SubjectDashboardScreen extends StatefulWidget {
  const SubjectDashboardScreen({super.key});

  @override
  State<SubjectDashboardScreen> createState() => _SubjectDashboardScreenState();
}

class _SubjectDashboardScreenState extends State<SubjectDashboardScreen>
    with WidgetsBindingObserver {
  int _currentIndex = 0;
  Timer? _sessionTimer;
  bool _hasUnlockedStartup = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startSessionAndWatch(forceStartupLock: true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sessionTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkLock();
    }
  }

  Future<void> _startSessionAndWatch({bool forceStartupLock = false}) async {
    // 🛡️ SECURITY: Force lock on cold start, but only ONCE
    if (forceStartupLock && !_hasUnlockedStartup) {
      final pinSet = await ParentalControlService.instance.isSetUp();
      if (pinSet && mounted) {
        await ParentalControlService.instance.lockApp();
        _pushLockScreen(isTimeLimitExpired: false);
        return;
      }
    }

    // Normal session logic
    await ParentalControlService.instance.startSession();

    // Poll every 30 seconds to check time limit
    _sessionTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      await _checkLock();
    });
  }

  Future<void> _checkLock() async {
    final expired = await ParentalControlService.instance.checkSessionExpired();
    final alreadyLocked = await ParentalControlService.instance.isLocked();
    if ((expired || alreadyLocked) && mounted) {
      await ParentalControlService.instance.lockApp();
      _pushLockScreen(isTimeLimitExpired: expired);
    }
  }

  Future<void> _pushLockScreen({required bool isTimeLimitExpired}) async {
    _sessionTimer?.cancel();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            ParentalLockScreen(isTimeLimitExpired: isTimeLimitExpired),
      ),
    );
    
    // Mark as unlocked so we don't loop
    _hasUnlockedStartup = true;
    
    // Re-start session after unlock (without forcing the startup lock)
    await _startSessionAndWatch(forceStartupLock: false);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProviderSimple>(
      builder: (context, userProvider, child) {
        final childClass = userProvider.user?.classLevel ?? 1;
        final childName = userProvider.user?.name ?? 'Student';

        final hour = DateTime.now().hour;
        String greeting;
        if (hour < 12) {
          greeting = 'Good Morning';
        } else if (hour < 17) {
          greeting = 'Good Afternoon';
        } else {
          greeting = 'Good Evening';
        }

        // Pages indexed by bottom nav
        final pages = [
          _buildHomePage(context, childClass, childName, greeting),
          const LeaderboardScreenSimple(isEmbedded: true),
          const SettingsScreen(),
        ];

        return Scaffold(
          extendBodyBehindAppBar: _currentIndex == 0,
          appBar: _currentIndex == 0
              ? AppBar(
                  leadingWidth: 80,
                  leading: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => const StreakScreen()),
                      );
                    },
                    child: Container(
                      margin:
                          const EdgeInsets.only(left: 16, top: 8, bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.local_fire_department_rounded,
                              color: Colors.orangeAccent, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            '${userProvider.user?.streak ?? 0}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  title: Text(
                    'Class $childClass',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  centerTitle: true,
                  iconTheme: const IconThemeData(color: Colors.white),
                  actions: [
                    Container(
                      margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.stars_rounded, color: Colors.amber, size: 20),
                          const SizedBox(width: 6),
                          Text(
                            '${userProvider.user?.xp ?? 0} pts',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : null,
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              child: BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                backgroundColor: Colors.white,
                selectedItemColor: const Color(0xFF1976D2),
                unselectedItemColor: Colors.grey.shade400,
                showSelectedLabels: true,
                showUnselectedLabels: false,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_rounded),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.leaderboard_rounded),
                    label: 'Leaderboard',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.settings_rounded),
                    label: 'Settings',
                  ),
                ],
              ),
            ),
          ),
          body: pages[_currentIndex],
        );
      },
    );
  }

  // ── Home Page ─────────────────────────────────────────────────────────────

  Widget _buildHomePage(
      BuildContext context, int childClass, String childName, String greeting) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF81D4FA),
            Color(0xFF1976D2),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  text: 'Welcome! ',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  children: [
                    TextSpan(
                      text: '$greeting, $childName',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Subject Cards List
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 24),
                  children: [
                    _buildSubjectCard(
                      context,
                      Subject.Math,
                      Icons.calculate,
                      'Mathematics',
                      const Color(0xFF4CAF50),
                      childClass,
                    ),
                    const SizedBox(height: 16),
                    _buildSubjectCard(
                      context,
                      Subject.English,
                      Icons.language,
                      'English',
                      const Color(0xFF2196F3),
                      childClass,
                    ),
                    const SizedBox(height: 16),
                    _buildSubjectCard(
                      context,
                      Subject.Nepali,
                      Icons.menu_book,
                      'Nepali',
                      const Color(0xFFFF9800),
                      childClass,
                    ),
                    const SizedBox(height: 16),
                    _buildSubjectCard(
                      context,
                      Subject.GK,
                      Icons.public,
                      'Gen. Knowledge',
                      const Color(0xFF9C27B0),
                      childClass,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectCard(
    BuildContext context,
    Subject subject,
    IconData icon,
    String title,
    Color color,
    int childClass,
  ) {
    final lessons =
        MultiSubjectService.getLessonsForClass(childClass, subject);
    final unlockedLessons =
        lessons.where((lesson) => !lesson.isLocked).length;
    final totalLessons = lessons.length;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          '/subject_lessons',
          arguments: {
            'subject': subject,
            'title': title,
            'classLevel': childClass,
          },
        );
      },
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$unlockedLessons / $totalLessons lessons',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: totalLessons > 0
                          ? unlockedLessons / totalLessons
                          : 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Icon(Icons.arrow_forward_ios,
                size: 20, color: color.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }
}


