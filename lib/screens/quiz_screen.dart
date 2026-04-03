import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/lesson.dart';
import '../providers/user_provider_simple.dart';

class QuizScreen extends StatefulWidget {
  final Lesson lesson;

  const QuizScreen({super.key, required this.lesson});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  List<String?> _selectedAnswers = [];
  bool _showResult = false;
  
  // Custom state for translation matching
  List<String> _matchedPairs = [];
  String? _currentlySelectedLeft;

  @override
  void initState() {
    super.initState();
    if (widget.lesson.quiz != null) {
      _selectedAnswers = List.filled(widget.lesson.quiz!.questions.length, null);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.lesson.quiz == null) {
      return const Scaffold(
        body: Center(
          child: Text('No quiz available for this lesson'),
        ),
      );
    }
    
    final currentQuestion = widget.lesson.quiz!.questions[_currentQuestionIndex];

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text('${widget.lesson.title} - Quiz'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Progress Header
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Question ${_currentQuestionIndex + 1}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Score: $_score',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (_currentQuestionIndex + 1) / widget.lesson.quiz!.questions.length,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red.shade600),
                  minHeight: 6,
                ),
              ],
            ),
          ),

          // Question Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getQuestionTypeLabel(currentQuestion.type),
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Question text rendering based on type
                    if (currentQuestion.type == 'fill_blank')
                      _buildFillInBlankText(currentQuestion)
                    else 
                      Text(
                        currentQuestion.question,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          height: 1.4,
                        ),
                      ),
                    
                    if (currentQuestion.nepaliQuestion != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Text(
                          currentQuestion.nepaliQuestion ?? '',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade800,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],

                    if (currentQuestion.type == 'image_identification' && currentQuestion.imageUrl != null) ...[
                      const SizedBox(height: 24),
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: (currentQuestion.imageUrl!.startsWith('http')) 
                            ? Image.network(
                                currentQuestion.imageUrl!,
                                height: 180,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  height: 180,
                                  width: double.infinity,
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.broken_image, size: 60, color: Colors.grey),
                                ),
                              )
                            : Container(
                                height: 180,
                                width: double.infinity,
                                color: Colors.blue.shade50,
                                child: Icon(Icons.image, size: 80, color: Colors.blue.shade200),
                              ), // Fallback for local assets if missing
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 24),
                    
                    // Answer Options based on type
                    Expanded(
                      child: _buildAnswerOptions(currentQuestion),
                    ),
                    
                    // Explanation
                    if (_showResult && currentQuestion.type != 'translation_match') ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.yellow.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.yellow.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.lightbulb, color: Colors.yellow.shade700, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Explanation',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.yellow.shade700),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              currentQuestion.explanation,
                              style: TextStyle(color: Colors.yellow.shade800, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // Bottom Navigation
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                if (_currentQuestionIndex > 0)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _currentQuestionIndex--;
                          _showResult = false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        foregroundColor: Colors.grey.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Previous'),
                    ),
                  ),
                if (_currentQuestionIndex > 0) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSubmitEnabled(currentQuestion)
                        ? () {
                            if (!_showResult && currentQuestion.type != 'translation_match') {
                              setState(() {
                                _showResult = true;
                                if (_selectedAnswers[_currentQuestionIndex] == currentQuestion.correctAnswer) {
                                  _score++;
                                }
                              });
                            } else {
                              if (_currentQuestionIndex < widget.lesson.quiz!.questions.length - 1) {
                                setState(() {
                                  _currentQuestionIndex++;
                                  _showResult = false;
                                  _matchedPairs.clear();
                                  _currentlySelectedLeft = null;
                                });
                              } else {
                                _finishQuiz();
                              }
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      !_showResult && currentQuestion.type != 'translation_match'
                          ? 'Check Answer'
                          : _currentQuestionIndex < (widget.lesson.quiz?.questions.length ?? 0) - 1
                              ? 'Next Question'
                              : 'Finish Quiz',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getQuestionTypeLabel(String type) {
    switch (type) {
      case 'fill_blank': return 'Fill In The Blank';
      case 'image_identification': return 'Identify This';
      case 'translation_match': return 'Match Pairs';
      default: return 'Multiple Choice';
    }
  }

  bool _isSubmitEnabled(Question q) {
    if (q.type == 'translation_match') {
      return _matchedPairs.length == (q.answerPairs?.length ?? 0);
    }
    return _selectedAnswers[_currentQuestionIndex] != null || _showResult;
  }

  Widget _buildFillInBlankText(Question q) {
    final segments = q.question.split('___');
    final currentSelection = _selectedAnswers[_currentQuestionIndex];
    
    List<Widget> children = [];
    for (int i = 0; i < segments.length; i++) {
      children.add(Text(segments[i], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)));
      if (i < segments.length - 1) {
        children.add(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: currentSelection == null ? Colors.grey.shade100 : Colors.blue.shade50,
              border: Border.all(
                color: currentSelection == null ? Colors.grey.shade400 : Colors.blue.shade400,
                width: 2,
                style: currentSelection == null ? BorderStyle.solid : BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              currentSelection ?? '?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: currentSelection == null ? Colors.grey.shade400 : Colors.blue.shade700,
              ),
            ),
          )
        );
      }
    }
    
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: children,
    );
  }

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
        final showFeedback = _showResult;
        
        Color backgroundColor = Colors.white;
        Color borderColor = Colors.grey.shade300;
        Color textColor = Colors.black87;
        
        if (showFeedback) {
          if (isCorrect) {
            backgroundColor = Colors.green.shade50;
            borderColor = Colors.green.shade500;
            textColor = Colors.green.shade800;
          } else if (isSelected && !isCorrect) {
            backgroundColor = Colors.red.shade50;
            borderColor = Colors.red.shade400;
            textColor = Colors.red.shade800;
          }
        } else if (isSelected) {
          backgroundColor = Colors.blue.shade50;
          borderColor = Colors.blue.shade400;
          textColor = Colors.blue.shade800;
        }
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: showFeedback ? null : () {
                setState(() {
                  _selectedAnswers[_currentQuestionIndex] = option;
                });
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor, width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: isSelected || (showFeedback && isCorrect) ? FontWeight.bold : FontWeight.w500,
                    color: textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTranslationMatchGrid(Question q) {
    final pairs = q.answerPairs!;
    final leftItems = pairs.keys.toList();
    final rightItems = pairs.values.toList();
    
    // Sort logic to randomize could be added here, but for now we list them directly
    return Row(
      children: [
        // Left Column (Eng/Concept)
        Expanded(
          child: ListView.builder(
            itemCount: leftItems.length,
            itemBuilder: (context, index) {
              final text = leftItems[index];
              return _buildMatchCard(text, isLeft: true, pairs: pairs);
            },
          ),
        ),
        const SizedBox(width: 16),
        // Right Column (Nepali/Translation)
        Expanded(
          child: ListView.builder(
            itemCount: rightItems.length,
            itemBuilder: (context, index) {
              final text = rightItems[index];
              return _buildMatchCard(text, isLeft: false, pairs: pairs);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMatchCard(String text, {required bool isLeft, required Map<String, String> pairs}) {
    final isMatched = _matchedPairs.contains(text);
    final isSelected = _currentlySelectedLeft == text;

    Color bg = Colors.white;
    Color border = Colors.grey.shade300;
    Color textCol = Colors.black87;

    if (isMatched) {
      bg = Colors.green.shade50;
      border = Colors.green.shade300;
      textCol = Colors.green.shade300;
    } else if (isSelected) {
      bg = Colors.blue.shade50;
      border = Colors.blue.shade400;
      textCol = Colors.blue.shade800;
    }

    return GestureDetector(
      onTap: isMatched ? null : () {
        setState(() {
          if (isLeft) {
            _currentlySelectedLeft = text;
          } else {
            // Right selected
            if (_currentlySelectedLeft != null) {
              // Check if they match
              if (pairs[_currentlySelectedLeft!] == text) {
                _matchedPairs.add(_currentlySelectedLeft!);
                _matchedPairs.add(text);
                _score++; // Mini point
              }
              _currentlySelectedLeft = null;
            }
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border, width: 2),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textCol,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  void _finishQuiz() {
    final userProvider = Provider.of<UserProviderSimple>(context, listen: false);
    
    // Calculate final score bounds
    int localScore = _score;
    // Cap score at actual questions plus any mini points. 
    // This is simple so we'll just award 5 XP per correct answer tracking.
    final xpEarned = localScore * 5; 
    
    userProvider.addXP(xpEarned);
    userProvider.completeLesson(widget.lesson.id);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Quiz Completed!', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.emoji_events, size: 80, color: Colors.orange.shade400),
            ),
            const SizedBox(height: 24),
            Text(
              'Excellent Job!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
            ),
            const SizedBox(height: 8),
            Text(
              'Earned $xpEarned XP!',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade700, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); 
                Navigator.of(context).pop(); 
                Navigator.of(context).pop(); 
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Continue Learning', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
