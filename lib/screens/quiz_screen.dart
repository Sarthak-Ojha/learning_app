import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/lesson.dart';
import '../providers/user_provider_simple.dart';
import 'lesson_screen.dart';

class QuizScreen extends StatefulWidget {
  final Lesson lesson;

  const QuizScreen({super.key, required this.lesson});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with SingleTickerProviderStateMixin {
  int _currentQuestionIndex = 0;
  int _score = 0;
  List<String?> _selectedAnswers = [];
  bool _showResult = false;

  late AnimationController _animCtrl;
  late Animation<double> _scaleAnim;

  final List<String> _matchedPairs = [];
  String? _currentlySelectedLeft;

  // ── App theme colours ──────────────────────────────────────────────────────
  static const Color _primary = Color(0xFF1976D2);
  static const Color _primaryLight = Color(0xFF81D4FA);
  static const Color _darkText = Color(0xFF1A237E);
  static const Color _success = Color(0xFF2E7D32);
  static const Color _successBg = Color(0xFFE8F5E9);
  static const Color _errorBg = Color(0xFFFFEBEE);

  bool get _isNepali => widget.lesson.subject == Subject.Nepali;

  // ── Localized strings ──────────────────────────────────────────────────────
  String get _lblQuestion =>
      _isNepali ? 'प्रश्न' : 'Question';
  String get _lblCorrect =>
      _isNepali ? 'सही' : 'Correct';
  String get _lblCheckAnswer =>
      _isNepali ? 'जवाफ जाँच्नुहोस्' : 'Check Answer';
  String get _lblNext =>
      _isNepali ? 'अर्को प्रश्न' : 'Next Question';
  String get _lblFinish =>
      _isNepali ? 'परिणाम हेर्नुहोस्' : 'Finish Quiz';
  String get _lblNoQuiz =>
      _isNepali ? 'यस पाठमा कुनै प्रश्न छैन।' : 'No quiz available for this lesson.';

  @override
  void initState() {
    super.initState();
    if (widget.lesson.quiz != null) {
      _selectedAnswers = List.filled(
        widget.lesson.quiz!.questions.length,
        null,
      );
    }
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _scaleAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutBack);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _nextQuestion() {
    _animCtrl.reset();
    _animCtrl.forward();
    setState(() {
      _currentQuestionIndex++;
      _showResult = false;
      _matchedPairs.clear();
      _currentlySelectedLeft = null;
    });
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (widget.lesson.quiz == null) {
      return Scaffold(body: Center(child: Text(_lblNoQuiz)));
    }

    final questions = widget.lesson.quiz!.questions;
    final currentQuestion = questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / questions.length;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          '${widget.lesson.title} — ${_isNepali ? "प्रश्नोत्तर" : "Quiz"}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: Colors.white,
          ),
        ),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ── Progress Header ────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$_lblQuestion ${_currentQuestionIndex + 1} / ${questions.length}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: _darkText,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              color: Color(0xFFFFAB00), size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '$_score $_lblCorrect',
                            style: TextStyle(
                              color: _primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.shade200,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Color(0xFF1976D2)),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),

          // ── Question + Options ─────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Question card
                  ScaleTransition(
                    scale: _scaleAnim,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: _primary.withValues(alpha: 0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Type chip
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: _primaryLight.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _getQuestionTypeLabel(currentQuestion.type),
                              style: TextStyle(
                                color: _primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          // Question text
                          currentQuestion.type == 'fill_blank'
                              ? _buildFillInBlankText(currentQuestion)
                              : Text(
                                  currentQuestion.question,
                                  style: const TextStyle(
                                    fontSize: 21,
                                    fontWeight: FontWeight.bold,
                                    color: _darkText,
                                    height: 1.45,
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Options
                  Expanded(child: _buildAnswerOptions(currentQuestion)),

                  // Explanation after checking
                  if (_showResult &&
                      currentQuestion.type != 'translation_match') ...[
                    const SizedBox(height: 12),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: (_selectedAnswers[_currentQuestionIndex] ==
                                currentQuestion.correctAnswer)
                            ? _successBg
                            : _errorBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: (_selectedAnswers[_currentQuestionIndex] ==
                                  currentQuestion.correctAnswer)
                              ? Colors.green.shade300
                              : Colors.red.shade300,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            (_selectedAnswers[_currentQuestionIndex] ==
                                    currentQuestion.correctAnswer)
                                ? Icons.check_circle_rounded
                                : Icons.cancel_rounded,
                            color:
                                (_selectedAnswers[_currentQuestionIndex] ==
                                        currentQuestion.correctAnswer)
                                    ? _success
                                    : Colors.red.shade600,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              currentQuestion.explanation.isNotEmpty
                                  ? currentQuestion.explanation
                                  : (_selectedAnswers[_currentQuestionIndex] ==
                                          currentQuestion.correctAnswer
                                      ? (_isNepali
                                          ? 'सही जवाफ! 🎉'
                                          : 'Correct! 🎉')
                                      : (_isNepali
                                          ? 'सही जवाफ: ${currentQuestion.correctAnswer}'
                                          : 'Correct answer: ${currentQuestion.correctAnswer}')),
                              style: TextStyle(
                                color:
                                    (_selectedAnswers[_currentQuestionIndex] ==
                                            currentQuestion.correctAnswer)
                                        ? _success
                                        : Colors.red.shade700,
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // ── Bottom CTA ──────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            color: Colors.white,
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isSubmitEnabled(currentQuestion)
                    ? () {
                        if (!_showResult &&
                            currentQuestion.type != 'translation_match') {
                          setState(() {
                            _showResult = true;
                            if (_selectedAnswers[_currentQuestionIndex] ==
                                currentQuestion.correctAnswer) {
                              _score++;
                            }
                          });
                        } else {
                          if (_currentQuestionIndex <
                              widget.lesson.quiz!.questions.length - 1) {
                            _nextQuestion();
                          } else {
                            _finishQuiz();
                          }
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: !_showResult ? _primary : _success,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      Colors.grey.shade200,
                  disabledForegroundColor: Colors.grey.shade400,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  !_showResult &&
                          currentQuestion.type != 'translation_match'
                      ? _lblCheckAnswer
                      : _currentQuestionIndex <
                              (widget.lesson.quiz?.questions.length ?? 0) - 1
                          ? _lblNext
                          : _lblFinish,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  String _getQuestionTypeLabel(String type) {
    if (_isNepali) {
      switch (type) {
        case 'fill_blank':
          return '✏️  खाली ठाउँ भर्नुहोस्';
        case 'image_identification':
          return '🖼️  चित्र चिन्नुहोस्';
        case 'translation_match':
          return '🔗  जोड्नुहोस्';
        default:
          return '❓  बहुविकल्प';
      }
    }
    switch (type) {
      case 'fill_blank':
        return '✏️  Fill in the Blank';
      case 'image_identification':
        return '🖼️  Identify This';
      case 'translation_match':
        return '🔗  Match Pairs';
      default:
        return '❓  Multiple Choice';
    }
  }

  bool _isSubmitEnabled(Question q) {
    if (q.type == 'translation_match') {
      return _matchedPairs.length == (q.answerPairs?.length ?? 0) * 2;
    }
    return _selectedAnswers[_currentQuestionIndex] != null || _showResult;
  }

  // ── Fill-in-the-blank ───────────────────────────────────────────────────────

  Widget _buildFillInBlankText(Question q) {
    final segments = q.question.split('___');
    final currentSelection = _selectedAnswers[_currentQuestionIndex];

    List<Widget> children = [];
    for (int i = 0; i < segments.length; i++) {
      children.add(
        Text(
          segments[i],
          style: const TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: _darkText),
        ),
      );
      if (i < segments.length - 1) {
        children.add(
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            margin: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: currentSelection == null
                  ? Colors.grey.shade100
                  : _primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: currentSelection == null
                    ? Colors.grey.shade400
                    : _primary,
                width: 2,
              ),
            ),
            child: Text(
              currentSelection ?? '?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color:
                    currentSelection == null ? Colors.grey.shade400 : _primary,
              ),
            ),
          ),
        );
      }
    }
    return Wrap(
        crossAxisAlignment: WrapCrossAlignment.center, children: children);
  }

  // ── Answer Options ──────────────────────────────────────────────────────────

  Widget _buildAnswerOptions(Question q) {
    if (q.type == 'translation_match' && q.answerPairs != null) {
      return _buildTranslationMatchGrid(q);
    }

    return ListView.builder(
      itemCount: q.options.length,
      itemBuilder: (context, index) {
        final option = q.options[index];
        final isSelected = _selectedAnswers[_currentQuestionIndex] == option;
        final isCorrect = option == q.correctAnswer;

        Color bg = Colors.white;
        Color border = Colors.grey.shade300;
        Color textCol = Colors.black87;
        IconData? trailingIcon;

        if (_showResult) {
          if (isCorrect) {
            bg = _successBg;
            border = Colors.green.shade400;
            textCol = _success;
            trailingIcon = Icons.check_circle_rounded;
          } else if (isSelected && !isCorrect) {
            bg = _errorBg;
            border = Colors.red.shade400;
            textCol = Colors.red.shade700;
            trailingIcon = Icons.cancel_rounded;
          }
        } else if (isSelected) {
          bg = _primary.withValues(alpha: 0.08);
          border = _primary;
          textCol = _primary;
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border, width: 2),
            boxShadow: isSelected && !_showResult
                ? [
                    BoxShadow(
                      color: _primary.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: _showResult
                  ? null
                  : () {
                      setState(() {
                        _selectedAnswers[_currentQuestionIndex] = option;
                      });
                    },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 18),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        option,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: isSelected || (_showResult && isCorrect)
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: textCol,
                        ),
                      ),
                    ),
                    if (trailingIcon != null)
                      Icon(trailingIcon, color: textCol, size: 22),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Translation Match ───────────────────────────────────────────────────────

  Widget _buildTranslationMatchGrid(Question q) {
    final pairs = q.answerPairs!;
    final leftItems = pairs.keys.toList();
    final rightItems = List<String>.from(pairs.values)..shuffle();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: leftItems
                .map((t) => _buildMatchCard(t, isLeft: true, pairs: pairs))
                .toList(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            children: rightItems
                .map((t) => _buildMatchCard(t, isLeft: false, pairs: pairs))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMatchCard(
    String text, {
    required bool isLeft,
    required Map<String, String> pairs,
  }) {
    final isMatched = _matchedPairs.contains(text);
    final isSelected = _currentlySelectedLeft == text;

    Color bg = Colors.white;
    Color border = Colors.grey.shade300;
    Color textCol = Colors.black87;

    if (isMatched) {
      bg = _successBg;
      border = Colors.green.shade400;
      textCol = _success;
    } else if (isSelected) {
      bg = _primary.withValues(alpha: 0.08);
      border = _primary;
      textCol = _primary;
    }

    return GestureDetector(
      onTap: isMatched
          ? null
          : () {
              setState(() {
                if (isLeft) {
                  _currentlySelectedLeft = text;
                } else {
                  if (_currentlySelectedLeft != null) {
                    if (pairs[_currentlySelectedLeft!] == text) {
                      _matchedPairs.add(_currentlySelectedLeft!);
                      _matchedPairs.add(text);
                      _score++;
                    }
                    _currentlySelectedLeft = null;
                  }
                }
              });
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border, width: 2),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: textCol,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  // ── Finish Quiz ─────────────────────────────────────────────────────────────

  void _finishQuiz() {
    final userProvider =
        Provider.of<UserProviderSimple>(context, listen: false);
    final totalQuestions = widget.lesson.quiz!.questions.length;
    final passThreshold = (totalQuestions / 2).ceil();
    final passed = _score >= passThreshold;

    if (passed) {
      userProvider.completeLesson(widget.lesson.id, widget.lesson.xpReward);
    }

    _showResultDialog(passed, totalQuestions);
  }

  void _showResultDialog(bool passed, int totalQuestions) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      transitionDuration: const Duration(milliseconds: 350),
      transitionBuilder: (context, anim, secondAnim, child) => ScaleTransition(
        scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
        child: child,
      ),
      pageBuilder: (context, anim, secondAnim) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.88,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: passed
                        ? Colors.green.withValues(alpha: 0.2)
                        : Colors.red.withValues(alpha: 0.15),
                    blurRadius: 40,
                    spreadRadius: 4,
                  ),
                ],
                border: Border.all(
                  color: passed
                      ? Colors.green.shade200
                      : Colors.red.shade200,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Emoji
                  Text(
                    passed ? '🏆' : '😔',
                    style: const TextStyle(fontSize: 64),
                  ),
                  const SizedBox(height: 12),

                  // Title
                  Text(
                    passed
                        ? (_isNepali ? 'उत्कृष्ट काम!' : 'Excellent Job!')
                        : (_isNepali
                            ? 'फेरि प्रयास गर्नुहोस्!'
                            : 'Try Again!'),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: passed ? _success : Colors.red.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Score
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star_rounded,
                            color: Color(0xFFFFAB00), size: 28),
                        const SizedBox(width: 10),
                        Text(
                          '$_score / $totalQuestions',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: _darkText,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isNepali ? 'सही' : 'Correct',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // XP / retry hint
                  Text(
                    passed
                        ? (_isNepali
                            ? '+${widget.lesson.xpReward} XP अर्जित! ✨'
                            : '+${widget.lesson.xpReward} XP Earned! ✨')
                        : (_isNepali
                            ? 'उत्तीर्ण हुन कम्तीमा ${(totalQuestions / 2).ceil()} सही चाहिन्छ।'
                            : 'Need at least ${(totalQuestions / 2).ceil()} correct to pass.'),
                    style: TextStyle(
                      fontSize: 14,
                      color: passed
                          ? const Color(0xFFFFAB00)
                          : Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),

                  // Action button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // close dialog
                        if (passed) {
                          Navigator.of(context).pop(); // quiz screen
                          Navigator.of(context).pop(); // lesson screen
                        } else {
                          Navigator.of(context).pop(); // quiz
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) =>
                                  LessonScreen(lesson: widget.lesson),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            passed ? _primary : Colors.red.shade500,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        passed
                            ? (_isNepali
                                ? 'अगाडि बढ्नुहोस् 🚀'
                                : 'Continue Learning 🚀')
                            : (_isNepali
                                ? 'फेरि पढ्नुहोस् 📖'
                                : 'Re-read Lesson 📖'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
}
