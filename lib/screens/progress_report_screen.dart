import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/user_provider_simple.dart';
import '../services/multi_subject_service.dart';
import '../models/lesson.dart';

class ProgressReportScreen extends StatelessWidget {
  const ProgressReportScreen({super.key});

  static const _primary = Color(0xFF1976D2);
  static const _darkText = Color(0xFF1A237E);

  // Per-subject colour palette
  static const _subjectColors = {
    Subject.Math: Color(0xFF4CAF50),
    Subject.English: Color(0xFF2196F3),
    Subject.Nepali: Color(0xFFFF9800),
    Subject.GK: Color(0xFF9C27B0),
  };

  static const _subjectLabels = {
    Subject.Math: 'Math',
    Subject.English: 'English',
    Subject.Nepali: 'Nepali',
    Subject.GK: 'GK',
  };

  static const _subjectIcons = {
    Subject.Math: Icons.calculate_rounded,
    Subject.English: Icons.language_rounded,
    Subject.Nepali: Icons.menu_book_rounded,
    Subject.GK: Icons.public_rounded,
  };

  /// Returns 0.0–1.0 completion fraction for a subject.
  double _subjectProgress(
      List<String> completed, int classLevel, Subject subject) {
    final lessons = MultiSubjectService.getLessonsForClass(classLevel, subject);
    if (lessons.isEmpty) return 0;
    final done = lessons.where((l) => completed.contains(l.id)).length;
    return done / lessons.length;
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProviderSimple>();
    final user = userProvider.user;
    final completed = user?.completedLessons ?? [];
    final classLevel = user?.classLevel ?? 1;

    final subjects = [
      Subject.Math,
      Subject.English,
      Subject.Nepali,
      Subject.GK,
    ];

    final progressMap = {
      for (final s in subjects)
        s: _subjectProgress(completed, classLevel, s),
    };

    final totalLessons = subjects.fold<int>(0, (sum, s) {
      return sum +
          MultiSubjectService.getLessonsForClass(classLevel, s).length;
    });
    final totalCompleted = completed.length;
    final overallPct =
        totalLessons > 0 ? (totalCompleted / totalLessons).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      appBar: AppBar(
        title: const Text(
          'Progress Report',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
        ),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Class banner ──────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF81D4FA), Color(0xFF1976D2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.emoji_events_rounded,
                      color: Colors.amber, size: 40),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'Student',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Class $classLevel  •  ${(overallPct * 100).toStringAsFixed(0)}% overall',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Overall ring
                  _MiniRing(value: overallPct, color: Colors.amber),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Radar chart card ──────────────────────────────────────────
            _sectionHeader('📊  Subject Radar'),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _primary.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 260,
                    child: _RadarChart(progressMap: progressMap),
                  ),
                  const SizedBox(height: 12),
                  // Legend row
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 16,
                    runSpacing: 8,
                    children: subjects.map((s) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _subjectColors[s],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _subjectLabels[s]!,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black54),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Per-subject breakdown ─────────────────────────────────────
            _sectionHeader('📚  Subject Breakdown'),
            ...subjects.map((s) {
              final pct = progressMap[s]!;
              final color = _subjectColors[s]!;
              final all =
                  MultiSubjectService.getLessonsForClass(classLevel, s);
              final done = all.where((l) => completed.contains(l.id)).length;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border:
                      Border.all(color: color.withValues(alpha: 0.25), width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(_subjectIcons[s], color: color, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _subjectLabels[s]!,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                '$done / ${all.length} lessons completed',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.black45),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${(pct * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 8,
                        backgroundColor: color.withValues(alpha: 0.12),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 24),

            // ── XP Summary ───────────────────────────────────────────────
            _sectionHeader('⭐  XP & Level'),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                    color: Colors.amber.withValues(alpha: 0.35), width: 1.5),
              ),
              child: Row(
                children: [
                  _xpStat('⭐ XP', '${user?.xp ?? 0}', Colors.amber),
                  _vDivider(),
                  _xpStat('🏅 Level', '${user?.level ?? 1}', _primary),
                  _vDivider(),
                  _xpStat('✅ Done', '$totalCompleted', const Color(0xFF4CAF50)),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _darkText,
          ),
        ),
      );

  Widget _xpStat(String label, String value, Color color) => Expanded(
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(fontSize: 11, color: Colors.black45)),
          ],
        ),
      );

  Widget _vDivider() => Container(
        height: 40,
        width: 1,
        color: Colors.grey.shade200,
      );
}

// ── Radar Chart Widget ────────────────────────────────────────────────────────

class _RadarChart extends StatelessWidget {
  final Map<Subject, double> progressMap;

  const _RadarChart({required this.progressMap});

  @override
  Widget build(BuildContext context) {
    // Subjects in clockwise order: Math, English, Nepali, GK
    final subjects = [Subject.Math, Subject.English, Subject.Nepali, Subject.GK];
    final values = subjects.map((s) => progressMap[s]! * 5).toList(); // Scale 0-5

    return RadarChart(
      RadarChartData(
        radarShape: RadarShape.polygon,
        tickCount: 5,
        ticksTextStyle:
            const TextStyle(color: Colors.transparent, fontSize: 10),
        radarBorderData: BorderSide(
          color: Colors.grey.shade300,
          width: 1,
        ),
        gridBorderData: BorderSide(
          color: Colors.grey.shade200,
          width: 1,
        ),
        tickBorderData: BorderSide(
          color: Colors.grey.shade200,
          width: 1,
        ),
        getTitle: (index, angle) {
          const labels = ['Math', 'English', 'Nepali', 'GK'];
          final icons = ['➕', '🔤', '📖', '🌍'];
          return RadarChartTitle(
            text: '${icons[index]} ${labels[index]}',
            angle: 0,
          );
        },
        titleTextStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A237E),
        ),
        titlePositionPercentageOffset: 0.15,
        dataSets: [
          // Filled data set
          RadarDataSet(
            fillColor: const Color(0xFF1976D2).withValues(alpha: 0.18),
            borderColor: const Color(0xFF1976D2),
            borderWidth: 2,
            entryRadius: 5,
            dataEntries: values
                .map((v) => RadarEntry(value: v))
                .toList(),
          ),
          // Max boundary (transparent — just to keep scale)
          RadarDataSet(
            fillColor: Colors.transparent,
            borderColor: Colors.transparent,
            borderWidth: 0,
            entryRadius: 0,
            dataEntries: List.generate(4, (_) => const RadarEntry(value: 5)),
          ),
        ],
      ),
    );
  }
}

// ── Mini circular progress ring ───────────────────────────────────────────────

class _MiniRing extends StatelessWidget {
  final double value;
  final Color color;

  const _MiniRing({required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: value,
            strokeWidth: 5,
            backgroundColor: Colors.white.withValues(alpha: 0.3),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          Text(
            '${(value * 100).toStringAsFixed(0)}%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
