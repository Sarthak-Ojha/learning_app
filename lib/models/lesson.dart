// ignore_for_file: constant_identifier_names

enum Subject { Math, English, Nepali, GK }

class Lesson {
  final String id;
  final String title;
  final String description;
  final Subject subject;
  final int classLevel; // 1-5
  final int level; // 1, 2, 3...
  final String category; // 'Learning', 'Fill in the blanks', 'True/False', 'Counting', etc.
  final List<LessonContent> content;
  final List<String> prerequisites;
  final bool isLocked;
  final int xpReward;
  final Duration estimatedDuration;
  final Quiz? quiz; // Optional quiz for this lesson

  Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.classLevel,
    required this.level,
    this.category = 'Learning',
    required this.content,
    this.prerequisites = const [],
    this.isLocked = true,
    this.xpReward = 50,
    this.estimatedDuration = const Duration(minutes: 15),
    this.quiz,
  });

  // Unlock logic
  bool canBeUnlocked(List<String> completedLessons) {
    if (prerequisites.isEmpty) return true;
    return prerequisites.every((lessonId) => completedLessons.contains(lessonId));
  }
}

class LessonContent {
  final String type; // 'text', 'image', 'video', 'interactive'
  final Map<String, dynamic> data;
  final int order;
  final String content;
  final String? nepaliTranslation;

  LessonContent({
    required this.type,
    this.data = const {},
    this.order = 0,
    this.content = '',
    this.nepaliTranslation,
  });
}

class Quiz {
  final String id;
  final String lessonId;
  final List<Question> questions;
  final int passingScore;
  final Duration timeLimit;
  final Subject subject;
  final int classLevel;

  Quiz({
    this.id = '',
    this.lessonId = '',
    required this.questions,
    this.passingScore = 70,
    this.timeLimit = const Duration(minutes: 10),
    this.subject = Subject.Math,
    this.classLevel = 1,
  });
}

class Question {
  final String id;
  final String type; // 'multiple_choice', 'fill_blank', 'true_false', 'image_identification', 'translation_match'
  final String question;
  final String? nepaliQuestion; // Nepali translation of the question
  final List<String> options; // For multiple choice
  final String? correctAnswer;
  final String explanation;
  final int difficulty; // 1-5
  final String? imageUrl; // For image_identification
  final Map<String, String>? answerPairs; // For translation_match

  Question({
    required this.id,
    this.type = 'multiple_choice',
    required this.question,
    this.difficulty = 1,
    this.options = const [],
    this.correctAnswer,
    this.explanation = '',
    this.nepaliQuestion,
    this.imageUrl,
    this.answerPairs,
  });
}

// Grammar Exercise for Fill-in-the-Blanks
class GrammarExercise {
  final String id;
  final Subject subject; // English or Nepali
  final int classLevel;
  final String sentence; // "The cat ___ on the mat."
  final String answer; // "sits"
  final List<String> options; // ["sits", "sit", "sitting"]
  final String explanation; // Learning explanation
  final String hint; // Optional hint for students

  GrammarExercise({
    required this.id,
    required this.subject,
    required this.classLevel,
    required this.sentence,
    required this.answer,
    required this.options,
    this.explanation = '',
    this.hint = '',
  });
}

// Game Models
class ColorGame {
  final String id;
  final String displayedColor; // Changed from MaterialColor to String
  final List<String> options;
  final int difficulty; // Based on class/age
  final String nepalContext; // Nepal-specific description

  ColorGame({
    required this.id,
    required this.displayedColor,
    required this.options,
    required this.difficulty,
    this.nepalContext = '',
  });
}

class MemoryCard {
  final String id;
  final String content; // Letter, color, animal, Nepali text
  final String type; // 'letter', 'color', 'animal', 'nepali_text'
  final String? matchingId; // For pairing

  MemoryCard({
    required this.id,
    required this.content,
    required this.type,
    this.matchingId,
  });
}

class MemoryGame {
  final String id;
  final List<MemoryCard> cards;
  final int gridSize; // 4x4 to 8x8
  final int classLevel;
  final Subject? subject; // Optional subject filter

  MemoryGame({
    required this.id,
    required this.cards,
    required this.gridSize,
    required this.classLevel,
    this.subject,
  });
}

class BrainGame {
  final String id;
  final String leftBrainTask; // Visual/logical pattern
  final String rightBrainTask; // Language/spatial creative
  final int classLevel;
  final Map<String, dynamic> gameData;

  BrainGame({
    required this.id,
    required this.leftBrainTask,
    required this.rightBrainTask,
    required this.classLevel,
    this.gameData = const {},
  });
}
