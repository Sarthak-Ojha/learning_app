import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/lesson.dart';
import '../services/multi_subject_service.dart';
import '../providers/user_provider_simple.dart';

class SubjectLessonsScreen extends StatefulWidget {
  const SubjectLessonsScreen({super.key});

  @override
  State<SubjectLessonsScreen> createState() => _SubjectLessonsScreenState();
}

class _SubjectLessonsScreenState extends State<SubjectLessonsScreen> {
  String _selectedCategory = 'Learning';
  
  final List<Map<String, dynamic>> _categories = [
    {'id': 'Learning', 'name': 'Learn', 'icon': Icons.menu_book_rounded},
    {'id': 'Fill-in-the-Blanks', 'name': 'Fill Blanks', 'icon': Icons.edit_note_rounded},
    {'id': 'True-False', 'name': 'True/False', 'icon': Icons.checklist_rtl_rounded},
    {'id': 'Counting', 'name': 'Counting', 'icon': Icons.exposure_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final subject = args['subject'] as Subject;
    final title = args['title'] as String;
    final classLevel = args['classLevel'] as int;

    final allLessons = MultiSubjectService.getLessonsForClass(classLevel, subject);
    final lessons = allLessons.where((l) => l.category == _selectedCategory).toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF81D4FA),
              Color(0xFF1976D2),
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Category Selector
              Container(
                height: 60,
                margin: const EdgeInsets.symmetric(vertical: 16),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected = _selectedCategory == cat['id'];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = cat['id'];
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: isSelected ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ] : [],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              cat['icon'],
                              size: 20,
                              color: isSelected ? const Color(0xFF1976D2) : Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              cat['name'],
                              style: TextStyle(
                                color: isSelected ? const Color(0xFF1976D2) : Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Path UI
              Expanded(
                child: lessons.isEmpty 
                  ? Center(
                      child: Text(
                        "No lessons in '$_selectedCategory' yet!",
                        style: const TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 24, bottom: 64),
                      itemCount: lessons.length,
                      itemBuilder: (context, index) {
                        final lesson = lessons[index];
                        return _buildPathNode(context, lesson, index);
                      },
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPathNode(BuildContext context, Lesson lesson, int index) {
    return Consumer<UserProviderSimple>(
      builder: (context, userProvider, child) {
        final isCompleted = userProvider.user?.completedLessons.contains(lesson.id) ?? false;
        final isLocked = lesson.isLocked && !isCompleted && lesson.category == 'Learning'; // Only lock standard path
        
        // Create an alternating winding pattern
        final offsets = [0.0, 60.0, 100.0, 60.0, 0.0, -60.0, -100.0, -60.0];
        final offset = offsets[index % offsets.length];

        return Center(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: 40, // Spacing between nodes
              left: offset > 0 ? offset : 0, 
              right: offset < 0 ? -offset : 0
            ),
            child: GestureDetector(
              onTap: () => _showLessonDetails(context, lesson, isLocked, isCompleted),
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // 3D Shadow
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: isLocked ? Colors.grey.shade400 : const Color(0xFF0D47A1), 
                      shape: BoxShape.circle,
                    ),
                  ),
                  // Main Top Face
                  Positioned(
                    bottom: 6,
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: isLocked ? Colors.grey.shade300 : const Color(0xFF4FC3F7),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Center(
                            child: Text(
                              lesson.level.toString(),
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                color: isLocked ? Colors.grey.shade500 : Colors.white,
                              ),
                            ),
                          ),
                          if (isLocked)
                            Positioned(
                              bottom: 8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                child: Icon(Icons.lock, size: 14, color: Colors.grey.shade600),
                              ),
                            ),
                          if (isCompleted)
                            Positioned(
                              bottom: 8,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                child: const Icon(Icons.check_circle, size: 16, color: Color(0xFF4CAF50)),
                              ),
                            ),
                        ],
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

  void _showLessonDetails(BuildContext context, Lesson lesson, bool isLocked, bool isCompleted) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(32),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1976D2).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${lesson.category} - Level ${lesson.level}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1976D2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                lesson.title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1976D2),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                lesson.description,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isLocked ? null : () {
                    Navigator.pop(context); // Close sheet
                    Navigator.of(context).pushNamed(
                      '/lesson',
                      arguments: {'lesson': lesson},
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isLocked ? Colors.grey.shade300 : const Color(0xFF1976D2),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    isLocked ? 'Locked' : (isCompleted ? 'Review Activity' : 'Start Activity'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      }
    );
  }
}
