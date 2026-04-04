import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/lesson.dart';
import '../services/multi_subject_service.dart';
import '../providers/user_provider_simple.dart';
import '../services/parental_control_service.dart';
import '../theme/class_theme.dart';
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
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  Timer? _sessionTimer;
  bool _hasUnlockedStartup = false;
  late AnimationController _bounceCtrl;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _startSessionAndWatch(forceStartupLock: true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sessionTimer?.cancel();
    _bounceCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _checkLock();
  }

  Future<void> _startSessionAndWatch({bool forceStartupLock = false}) async {
    if (forceStartupLock && !_hasUnlockedStartup) {
      final pinSet = await ParentalControlService.instance.isSetUp();
      if (pinSet && mounted) {
        await ParentalControlService.instance.lockApp();
        _pushLockScreen(isTimeLimitExpired: false);
        return;
      }
    }
    await ParentalControlService.instance.startSession();
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
        builder: (_) => ParentalLockScreen(isTimeLimitExpired: isTimeLimitExpired),
      ),
    );
    _hasUnlockedStartup = true;
    await _startSessionAndWatch(forceStartupLock: false);
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProviderSimple>(
      builder: (context, userProvider, child) {
        final classLevel = userProvider.user?.classLevel ?? 1;
        final childName = userProvider.user?.name ?? 'Student';
        final theme = ClassTheme(classLevel);

        final hour = DateTime.now().hour;
        final greeting = hour < 12
            ? 'Good Morning'
            : hour < 17
                ? 'Good Afternoon'
                : 'Good Evening';

        final pages = [
          _buildHomePage(context, classLevel, childName, greeting, theme, userProvider),
          const LeaderboardScreenSimple(isEmbedded: true),
          const SettingsScreen(),
        ];

        return Scaffold(
          backgroundColor: theme.scaffoldBackground,
          extendBodyBehindAppBar: _currentIndex == 0,
          appBar: _currentIndex == 0
              ? _buildAppBar(theme, classLevel, userProvider)
              : null,
          bottomNavigationBar: _buildBottomNav(theme),
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: KeyedSubtree(
              key: ValueKey(_currentIndex),
              child: pages[_currentIndex],
            ),
          ),
        );
      },
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(
      ClassTheme theme, int classLevel, UserProviderSimple userProvider) {
    return AppBar(
      leadingWidth: 80,
      leading: GestureDetector(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const StreakScreen()),
        ),
        child: Container(
          margin: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _bounceCtrl,
                builder: (_, __) => Transform.scale(
                  scale: theme.isPlayful ? 1.0 + _bounceCtrl.value * 0.15 : 1.0,
                  child: const Icon(Icons.local_fire_department_rounded,
                      color: Colors.orangeAccent, size: 20),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '${userProvider.user?.streak ?? 0}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
      title: Text(
        theme.classLabel,
        style: TextStyle(
          color: Colors.white,
          fontWeight: theme.titleWeight,
          fontSize: theme.appBarTitleFontSize,
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.stars_rounded, color: Colors.amber, size: 20),
              const SizedBox(width: 6),
              Text(
                '${userProvider.user?.xp ?? 0} XP',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Bottom Nav ─────────────────────────────────────────────────────────────

  Widget _buildBottomNav(ClassTheme theme) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: theme.primary.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          backgroundColor: Colors.white,
          selectedItemColor: theme.navSelectedColor,
          unselectedItemColor: Colors.grey.shade400,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: theme.isPlayful ? 13 : 12),
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: Icon(theme.isPlayful
                  ? Icons.home_rounded
                  : Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded,
                  color: theme.navSelectedColor),
              label: theme.isPlayful ? '🏠 Home' : 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(theme.isPlayful
                  ? Icons.emoji_events_rounded
                  : Icons.leaderboard_outlined),
              activeIcon: Icon(Icons.leaderboard_rounded,
                  color: theme.navSelectedColor),
              label: theme.isPlayful ? '🏆 Ranks' : 'Leaderboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(theme.isPlayful
                  ? Icons.settings_rounded
                  : Icons.settings_outlined),
              activeIcon: Icon(Icons.settings_rounded,
                  color: theme.navSelectedColor),
              label: theme.isPlayful ? '⚙️ Settings' : 'Settings',
            ),
          ],
        ),
      ),
    );
  }

  // ── Home Page ──────────────────────────────────────────────────────────────

  Widget _buildHomePage(
    BuildContext context,
    int classLevel,
    String childName,
    String greeting,
    ClassTheme theme,
    UserProviderSimple userProvider,
  ) {
    final completedCount = userProvider.user?.completedLessons.length ?? 0;
    final xp = userProvider.user?.xp ?? 0;
    final level = userProvider.user?.level ?? 1;

    return Container(
      decoration: BoxDecoration(gradient: theme.headerLinearGradient),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Greeting Header ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    theme.greetingPrefix(childName, greeting),
                    style: TextStyle(
                      fontSize: theme.titleFontSize,
                      fontWeight: theme.titleWeight,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    theme.subtitleCopy,
                    style: TextStyle(
                      fontSize: theme.subtitleFontSize,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Stats Row (adaptive per tier) ─────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: theme.isPlayful
                  ? _buildPlayfulStats(xp, completedCount, level, theme)
                  : theme.isAdventure
                      ? _buildAdventureStats(xp, completedCount, level, theme)
                      : _buildScholarStats(xp, completedCount, level, theme),
            ),

            const SizedBox(height: 20),

            // ── Subject Cards ─────────────────────────────────────────────
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: theme.scaffoldBackground,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                  children: [
                    if (theme.isPlayful) ...[
                      _buildSectionLabel('📚 Choose Your Subject!', theme),
                      const SizedBox(height: 12),
                    ],
                    _buildSubjectCard(context, Subject.Math, Icons.calculate_rounded,
                        'Mathematics', const Color(0xFF4CAF50), classLevel, theme),
                    const SizedBox(height: 14),
                    _buildSubjectCard(context, Subject.English, Icons.language_rounded,
                        'English', const Color(0xFF2196F3), classLevel, theme),
                    const SizedBox(height: 14),
                    _buildSubjectCard(context, Subject.Nepali, Icons.menu_book_rounded,
                        'Nepali', const Color(0xFFFF9800), classLevel, theme),
                    const SizedBox(height: 14),
                    _buildSubjectCard(context, Subject.GK, Icons.public_rounded,
                        'Gen. Knowledge', const Color(0xFF9C27B0), classLevel, theme),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Stats Variants ─────────────────────────────────────────────────────────

  /// Class 1–2: Big emoji bubbles
  Widget _buildPlayfulStats(int xp, int done, int level, ClassTheme theme) {
    return Row(
      children: [
        _playfulBubble('⭐', '$xp', 'Stars', const Color(0xFFFFB347)),
        const SizedBox(width: 10),
        _playfulBubble('✅', '$done', 'Done!', const Color(0xFF4CAF50)),
        const SizedBox(width: 10),
        _playfulBubble('🏅', 'Lv.$level', 'Level', const Color(0xFFFF6B9D)),
      ],
    );
  }

  Widget _playfulBubble(String emoji, String value, String label, Color color) =>
      Expanded(
        child: AnimatedBuilder(
          animation: _bounceCtrl,
          builder: (_, __) => Transform.translate(
            offset: Offset(0, -4 * _bounceCtrl.value),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1.5),
              ),
              child: Column(
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 22)),
                  const SizedBox(height: 2),
                  Text(value,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 16)),
                  Text(label,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 10)),
                ],
              ),
            ),
          ),
        ),
      );

  /// Class 3–4: Horizontal badge strip
  Widget _buildAdventureStats(int xp, int done, int level, ClassTheme theme) {
    return Row(
      children: [
        _adventureStat(Icons.stars_rounded, '$xp XP', Colors.amber),
        const SizedBox(width: 10),
        _adventureStat(Icons.check_circle_rounded, '$done Done', Colors.greenAccent),
        const SizedBox(width: 10),
        _adventureStat(Icons.military_tech_rounded, 'Lv.$level', Colors.lightBlueAccent),
      ],
    );
  }

  Widget _adventureStat(IconData icon, String label, Color color) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Flexible(
                child: Text(label,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
      );

  /// Class 5+: Clean compact row
  Widget _buildScholarStats(int xp, int done, int level, ClassTheme theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _scholarStat('$xp', 'XP Earned'),
          _vDivider(),
          _scholarStat('Lv.$level', 'Level'),
          _vDivider(),
          _scholarStat('$done', 'Completed'),
        ],
      ),
    );
  }

  Widget _scholarStat(String value, String label) => Column(
        children: [
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          Text(label,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75), fontSize: 11)),
        ],
      );

  Widget _vDivider() => Container(
      height: 30, width: 1, color: Colors.white.withValues(alpha: 0.3));

  Widget _buildSectionLabel(String text, ClassTheme theme) => Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: theme.primary,
        ),
      );

  // ── Subject Card ───────────────────────────────────────────────────────────

  Widget _buildSubjectCard(
    BuildContext context,
    Subject subject,
    IconData icon,
    String baseTitle,
    Color baseColor,
    int classLevel,
    ClassTheme theme,
  ) {
    final color = theme.subjectAccent(baseColor);
    final title = theme.subjectTitle(baseTitle);
    final lessons = MultiSubjectService.getLessonsForClass(classLevel, subject);
    final userProvider = context.read<UserProviderSimple>();
    final completedIds = userProvider.user?.completedLessons ?? [];
    final done = lessons.where((l) => completedIds.contains(l.id)).length;
    final total = lessons.length;
    final pct = total > 0 ? done / total : 0.0;

    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(
        '/subject_lessons',
        arguments: {'subject': subject, 'title': baseTitle, 'classLevel': classLevel},
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
            horizontal: 16, vertical: theme.subjectCardPadding),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: theme.subjectCardGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(theme.cardBorderRadius),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: theme.isPlayful ? 0.3 : 0.18),
              blurRadius: theme.isPlayful ? 14 : 10,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(
            color: color.withValues(alpha: theme.isPlayful ? 0.5 : 0.3),
            width: theme.isPlayful ? 2.5 : 1.5,
          ),
        ),
        child: Row(
          children: [
            // Icon bubble
            Container(
              width: theme.subjectIconSize + 16,
              height: theme.subjectIconSize + 16,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withValues(alpha: 0.15), color.withValues(alpha: 0.08)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: theme.isPlayful ? BoxShape.circle : BoxShape.rectangle,
                borderRadius: theme.isPlayful ? null : BorderRadius.circular(14),
              ),
              child: Center(
                child: Icon(icon, size: theme.subjectIconSize, color: color),
              ),
            ),

            const SizedBox(width: 16),

            // Text + progress
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: theme.subjectCardTitleSize,
                      fontWeight: theme.titleWeight,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    theme.isPlayful
                        ? '$done of $total lessons done! 🎯'
                        : '$done / $total lessons completed',
                    style: TextStyle(
                      fontSize: theme.isPlayful ? 12 : 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(theme.progressBarHeight),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: theme.progressBarHeight,
                      backgroundColor: color.withValues(alpha: 0.12),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Arrow / percentage
            theme.isScholar
                ? Text(
                    '${(pct * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: color.withValues(alpha: 0.7)),
                  )
                : Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: theme.isPlayful ? 22 : 18,
                    color: color.withValues(alpha: 0.5),
                  ),
          ],
        ),
      ),
    );
  }
}
