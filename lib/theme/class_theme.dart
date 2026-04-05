import 'package:flutter/material.dart';

/// Age-appropriate UI theme based on class level.
///
///  Class 1–2  → Playful / Cartoon  (ages 5–7)
///  Class 3–4  → Adventure / Badge  (ages 8–10)
///  Class 5+   → Scholar / Pro      (ages 11+)
class ClassTheme {
  final int classLevel;

  const ClassTheme(this.classLevel);

  // ── Tier ──────────────────────────────────────────────────────────────────

  /// 1 = Playful, 2 = Adventure, 3 = Scholar
  int get tier {
    if (classLevel <= 2) return 1;
    if (classLevel <= 4) return 2;
    return 3;
  }

  bool get isPlayful => tier == 1;
  bool get isAdventure => tier == 2;
  bool get isScholar => tier == 3;

  // ── Gradient ───────────────────────────────────────────────────────────────

  List<Color> get headerGradient {
    switch (tier) {
      case 1:
        return const [Color(0xFF7C4DFF), Color(0xFF448AFF)]; // Soft violet → blue (friendly)
      case 2:
        return const [Color(0xFF00897B), Color(0xFF26C6DA)]; // Teal → cyan (energetic)
      case 3:
      default:
        return const [Color(0xFF1A237E), Color(0xFF1976D2)]; // Navy → Blue (scholar)
    }
  }

  LinearGradient get headerLinearGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: headerGradient,
      );

  // ── Primary Accent ─────────────────────────────────────────────────────────

  Color get primary {
    switch (tier) {
      case 1:
        return const Color(0xFF7C4DFF); // Soft violet
      case 2:
        return const Color(0xFF00897B); // Teal
      case 3:
      default:
        return const Color(0xFF1976D2);
    }
  }

  Color get primaryLight {
    switch (tier) {
      case 1:
        return const Color(0xFF448AFF); // Soft blue
      case 2:
        return const Color(0xFF26C6DA); // Cyan
      case 3:
      default:
        return const Color(0xFF64B5F6);
    }
  }

  // ── Background ─────────────────────────────────────────────────────────────

  Color get scaffoldBackground {
    switch (tier) {
      case 1:
        return const Color(0xFFF3F0FF); // Soft lavender-white
      case 2:
        return const Color(0xFFEFFAFB); // Light cyan-white
      case 3:
      default:
        return const Color(0xFFF5F7FF); // Cool white-blue
    }
  }

  // ── Subject Card Colors ────────────────────────────────────────────────────

  List<Color> get subjectCardGradient {
    switch (tier) {
      case 1:
        return [Colors.white, const Color(0xFFFFF8F0)];
      case 2:
        return [Colors.white, const Color(0xFFF0FFF8)];
      case 3:
      default:
        return [Colors.white, const Color(0xFFF8FAFF)];
    }
  }

  // ── Typography ─────────────────────────────────────────────────────────────

  double get titleFontSize {
    switch (tier) {
      case 1:
        return 26; // Big & bold for small kids
      case 2:
        return 22;
      case 3:
      default:
        return 20;
    }
  }

  double get subtitleFontSize {
    switch (tier) {
      case 1:
        return 16;
      case 2:
        return 14;
      case 3:
      default:
        return 13;
    }
  }

  double get subjectCardTitleSize {
    switch (tier) {
      case 1:
        return 20;
      case 2:
        return 17;
      case 3:
      default:
        return 16;
    }
  }

  String get fontFamily {
    switch (tier) {
      case 1:
        return 'Roboto'; // Round & friendly
      case 2:
        return 'Roboto';
      case 3:
      default:
        return 'Roboto';
    }
  }

  FontWeight get titleWeight {
    switch (tier) {
      case 1:
        return FontWeight.w900; // Extra black for kids
      case 2:
        return FontWeight.bold;
      case 3:
      default:
        return FontWeight.w700;
    }
  }

  // ── Icon sizes ─────────────────────────────────────────────────────────────

  double get subjectIconSize {
    switch (tier) {
      case 1:
        return 40;
      case 2:
        return 32;
      case 3:
      default:
        return 28;
    }
  }

  double get subjectCardPadding {
    switch (tier) {
      case 1:
        return 20;
      case 2:
        return 18;
      case 3:
      default:
        return 16;
    }
  }

  double get cardBorderRadius {
    switch (tier) {
      case 1:
        return 28; // Very rounded for kids
      case 2:
        return 20;
      case 3:
      default:
        return 16;
    }
  }

  // ── Greeting / Copy ────────────────────────────────────────────────────────

  String greetingPrefix(String name, String timeGreeting) {
    switch (tier) {
      case 1:
        return '👋 Hi $name!';
      case 2:
        return '$timeGreeting, $name!';
      case 3:
      default:
        return '$timeGreeting, $name';
    }
  }

  String get classLabel {
    switch (tier) {
      case 1:
        return '🌟 Class $classLevel Explorer';
      case 2:
        return '🏆 Class $classLevel Achiever';
      case 3:
      default:
        return 'Class $classLevel';
    }
  }

  String get subtitleCopy {
    switch (tier) {
      case 1:
        return 'What do you want to learn today? 🎉';
      case 2:
        return 'Complete your lessons and earn XP! ⚡';
      case 3:
      default:
        return 'Master your subjects — one lesson at a time.';
    }
  }

  // ── Subject labels ─────────────────────────────────────────────────────────

  String subjectTitle(String base) {
    if (base == 'Nepali') return 'नेपाली - Nepali';
    switch (tier) {
      case 1:
        switch (base) {
          case 'Mathematics':
            return '🔢 Maths Fun';
          case 'English':
            return '🔤 English Play';
          case 'Nepali':
            return '📖 नेपाली - Nepali Paath';
          case 'Gen. Knowledge':
            return '🌍 Cool Facts';
        }
      case 2:
        switch (base) {
          case 'Mathematics':
            return 'Mathematics ➕';
          case 'English':
            return 'English 🔤';
          case 'Nepali':
            return 'नेपाली - Nepali 📖';
          case 'Gen. Knowledge':
            return 'General Knowledge 🌏';
        }
    }
    return base;
  }

  // ── Bottom nav accent ──────────────────────────────────────────────────────

  Color get navSelectedColor => primary;

  // ── Progress bar ───────────────────────────────────────────────────────────

  double get progressBarHeight {
    switch (tier) {
      case 1:
        return 10; // Fat & visible for young kids
      case 2:
        return 8;
      case 3:
      default:
        return 6;
    }
  }

  // ── AppBar style ──────────────────────────────────────────────────────────

  double get appBarTitleFontSize {
    switch (tier) {
      case 1:
        return 22;
      case 2:
        return 20;
      case 3:
      default:
        return 18;
    }
  }

  // ── Decoration overlay (fun background shapes for young kids) ──────────────

  bool get showFunBackground => tier == 1;
  bool get showBadgeStyle => tier == 2;

  // ── Subject card decoration ────────────────────────────────────────────────

  /// Returns subject-specific colors that match the tier mood
  Color subjectAccent(Color base) {
    // Keep all tier colors as-is — no neon boosting
    return base;
  }
}
