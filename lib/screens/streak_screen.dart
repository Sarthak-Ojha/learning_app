import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider_simple.dart';

class StreakScreen extends StatelessWidget {
  const StreakScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProviderSimple>(
      builder: (context, userProvider, child) {
        final streakCount = userProvider.user?.streak ?? 0;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: const Color(0xFF1976D2),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Streak', 
              style: TextStyle(
                color: Colors.white, 
                fontWeight: FontWeight.bold,
                fontSize: 22,
              )
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined, color: Colors.white),
                onPressed: () {},
              )
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Streak Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFFE3F2FD),
                          Colors.white,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1976D2).withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ],
                      border: Border.all(
                        color: const Color(0xFF1976D2).withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '$streakCount',
                              style: const TextStyle(
                                fontSize: 80,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1976D2),
                                height: 0.9,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.local_fire_department, color: Colors.orange, size: 36),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Streak Days',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1976D2),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          streakCount > 0 
                            ? "This is the longest Streak you've ever had!"
                            : "Start your learning journey to build a streak!",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Achievements
                  const Text(
                    'Achievements',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1976D2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildAchievementBadge(Icons.sentiment_satisfied, '7\ndays', streakCount >= 7),
                      _buildAchievementBadge(Icons.star, '14\ndays', streakCount >= 14),
                      _buildAchievementBadge(Icons.emoji_events, '30\ndays', streakCount >= 30),
                      _buildAchievementBadge(Icons.diamond, '100\ndays', streakCount >= 100),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Streak Calendar
                  const Text(
                    'Streak Calendar',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1976D2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Icon(Icons.chevron_left, color: Colors.grey),
                            Text(
                              _getMonthName(DateTime.now().month),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1976D2),
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: Colors.grey),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Days of week
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: const [
                            Text('Sun', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
                            Text('Mon', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
                            Text('Tue', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
                            Text('Wed', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
                            Text('Thu', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
                            Text('Fri', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
                            Text('Sat', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Dynamic Calendar Grid
                        _buildCalendarGrid(streakCount),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAchievementBadge(IconData icon, String label, bool isAchieved) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isAchieved ? const Color(0xFF1976D2).withValues(alpha: 0.1) : Colors.grey.shade100,
            border: Border.all(
              color: isAchieved ? const Color(0xFF1976D2) : Colors.grey.shade400,
              width: 2,
            ),
          ),
          child: Icon(
            icon,
            size: 32,
            color: isAchieved ? const Color(0xFF1976D2) : Colors.grey.shade400,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  Widget _buildCalendarGrid(int streakCount) {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    
    // In Dart, weekday is 1=Mon, ..., 7=Sun.
    // If week starts on Sunday (0=Sun, 1=Mon, ...), offset is `firstDayOfMonth.weekday % 7`.
    final firstDayOffset = firstDayOfMonth.weekday % 7; 

    List<Widget> rows = [];
    List<Widget> currentRow = [];

    // Add empty cells for offset
    for (int i = 0; i < firstDayOffset; i++) {
      currentRow.add(const SizedBox(width: 36, height: 36));
    }

    for (int day = 1; day <= daysInMonth; day++) {
      bool isToday = (day == now.day);
      // streak colors the past consecutive `streakCount` days including today, if the streak is active up to today.
      bool isStreakDay = false;
      if (day <= now.day && day > now.day - streakCount) {
        isStreakDay = true;
      }

      currentRow.add(_buildDayCell(day.toString(), isToday: isToday, isStreakDay: isStreakDay));

      if (currentRow.length == 7) {
        rows.add(Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: currentRow,
        ));
        rows.add(const SizedBox(height: 16));
        currentRow = [];
      }
    }

    // Add remaining empty cells for the last row
    if (currentRow.isNotEmpty) {
      while (currentRow.length < 7) {
        currentRow.add(const SizedBox(width: 36, height: 36));
      }
      rows.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: currentRow,
      ));
    }

    return Column(children: rows);
  }

  Widget _buildDayCell(String day, {bool isToday = false, bool isStreakDay = false}) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isStreakDay ? Colors.orange : Colors.transparent,
        shape: BoxShape.circle,
        border: isToday ? Border.all(color: const Color(0xFF1976D2), width: 2) : null,
      ),
      child: Center(
        child: Text(
          day,
          style: TextStyle(
            color: isStreakDay ? Colors.white : Colors.grey.shade700, 
            fontWeight: isStreakDay || isToday ? FontWeight.bold : FontWeight.w500, 
            fontSize: 16
          ),
        ),
      ),
    );
  }
}
