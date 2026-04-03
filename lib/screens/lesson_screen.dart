import 'package:flutter/material.dart';
import '../models/lesson.dart';
import 'quiz_screen.dart';

class LessonScreen extends StatefulWidget {
  final Lesson lesson;

  const LessonScreen({super.key, required this.lesson});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  int _currentContentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(widget.lesson.title),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Progress Indicator
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Progress',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (_currentContentIndex + 1) / widget.lesson.content.length,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red.shade600),
                  minHeight: 6,
                ),
                const SizedBox(height: 8),
                Text(
                  '${_currentContentIndex + 1} of ${widget.lesson.content.length}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Content Area
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Content Icon
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        _getContentIcon(),
                        size: 60,
                        color: Colors.red.shade600,
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Main Content
                    Text(
                      widget.lesson.content[_currentContentIndex].content,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    if (widget.lesson.content[_currentContentIndex].nepaliTranslation != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Text(
                          widget.lesson.content[_currentContentIndex].nepaliTranslation!,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.blue.shade800,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // Navigation Buttons
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                if (_currentContentIndex > 0)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _currentContentIndex--;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        foregroundColor: Colors.grey.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Previous'),
                    ),
                  ),
                if (_currentContentIndex > 0) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentContentIndex < widget.lesson.content.length - 1) {
                        setState(() {
                          _currentContentIndex++;
                        });
                      } else {
                        // Start quiz
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuizScreen(lesson: widget.lesson),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _currentContentIndex < widget.lesson.content.length - 1
                          ? 'Next'
                          : 'Start Quiz',
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

  IconData _getContentIcon() {
    switch (widget.lesson.content[_currentContentIndex].type) {
      case 'text':
        return Icons.menu_book;
      case 'example':
        return Icons.lightbulb;
      case 'image':
        return Icons.image;
      default:
        return Icons.school;
    }
  }
}
