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
  String? _selectedCategory;
  
  IconData _getCategoryIcon(String categoryId) {
    switch (categoryId) {
      case 'Learning': return Icons.menu_book_rounded;
      case 'Fill-in-the-Blanks': return Icons.edit_note_rounded;
      case 'True-False': return Icons.checklist_rtl_rounded;
      case 'Counting': return Icons.exposure_rounded;
      case 'Matching': return Icons.compare_arrows_rounded;
      case 'Barnamala': return Icons.sort_by_alpha_rounded;
      case 'Numbers': return Icons.format_list_numbered_rounded;
      case 'Barakhari': return Icons.font_download_rounded;
      case 'Handwriting': return Icons.draw_rounded;
      case 'Byakaran': return Icons.rule_folder_rounded;
      case 'Flashcards': return Icons.style_rounded;
      case 'Addition': return Icons.add_circle_outline_rounded;
      case 'Alphabets': return Icons.abc_rounded;
      case 'Grammar': return Icons.spellcheck_rounded;
      case 'Nepal Basics': return Icons.location_on_rounded;
      default: return Icons.school_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final subject = args['subject'] as Subject;
    final title = args['title'] as String;
    final classLevel = args['classLevel'] as int;

    final allLessons = MultiSubjectService.getLessonsForClass(classLevel, subject);
    
    // Get unique categories present in these lessons
    final categories = allLessons.map((l) => l.category).toSet().toList();
    
    final lessons = allLessons.where((l) => l.category == _selectedCategory).toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          _selectedCategory == null ? title : '$_selectedCategory',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            _selectedCategory == null ? Icons.arrow_back_ios_new : Icons.close, 
            color: Colors.white, 
            size: 20
          ),
          onPressed: () {
            if (_selectedCategory == null) {
              Navigator.pop(context);
            } else {
              setState(() {
                _selectedCategory = null;
              });
            }
          },
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
              if (_selectedCategory == null) ...[
                // Stage 1: BIG Category Grid
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: 0.9, // Make them tall/square
                      ),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final catId = categories[index];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategory = catId;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                )
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1976D2).withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _getCategoryIcon(catId),
                                    size: 48,
                                    color: const Color(0xFF1976D2),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  catId.replaceAll('-', ' '),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Color(0xFF1976D2),
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ] else ...[
                // Stage 2: Level Path UI
                Expanded(
                  child: lessons.isEmpty 
                    ? Center(
                        child: Text(
                          "No activities in '$_selectedCategory' yet!",
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
        final isPremium = userProvider.user?.isPremium ?? false;
        
        bool isPremiumLocked = false;
        bool isLocked = false;
        if (!isCompleted) {
          if (lesson.level == 1) {
            isLocked = false; // Level 1 is always accessible
          } else {
            if (!isPremium) {
              isLocked = true; // Standard Freemium Paywall
              isPremiumLocked = true;
            } else {
              // Even if premium, user must complete previous level
              final bool meetsPrerequisites = lesson.prerequisites.isEmpty || 
                  lesson.prerequisites.every((reqId) => userProvider.user?.completedLessons.contains(reqId) ?? false);
              isLocked = !meetsPrerequisites;
            }
          }
        }
        
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
              onTap: () => _showLessonDetails(context, lesson, isLocked, isCompleted, isPremiumLocked),
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
                                child: Icon(isPremiumLocked ? Icons.star : Icons.lock, size: 14, color: isPremiumLocked ? Colors.amber.shade700 : Colors.grey.shade600),
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

  void _showLessonDetails(BuildContext context, Lesson lesson, bool isLocked, bool isCompleted, bool isPremiumLocked) {
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
                  onPressed: isPremiumLocked 
                    ? () {
                        Navigator.pop(context);
                        Navigator.of(context).pushNamed('/premium_upgrade');
                      }
                    : (isLocked ? null : () {
                        Navigator.pop(context); // Close sheet
                        Navigator.of(context).pushNamed(
                          '/lesson',
                          arguments: {'lesson': lesson},
                        );
                      }),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isPremiumLocked ? Colors.amber.shade600 : (isLocked ? Colors.grey.shade300 : const Color(0xFF1976D2)),
                    foregroundColor: isPremiumLocked || !isLocked ? Colors.white : Colors.grey.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    isPremiumLocked ? 'Unlock with Premium' : (isLocked ? 'Complete previous level' : (isCompleted ? 'Review Activity' : 'Start Activity')),
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
