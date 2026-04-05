import '../models/lesson.dart';

class MultiSubjectService {
  // Get all lessons for a specific class and subject
  static List<Lesson> getLessonsForClass(int classLevel, Subject subject) {
    List<Lesson> rawLessons;
    switch (subject) {
      case Subject.Math:
        rawLessons = _getMathLessons(classLevel);
        break;
      case Subject.English:
        rawLessons = _getEnglishLessons(classLevel);
        break;
      case Subject.Nepali:
        rawLessons = _getNepaliLessons(classLevel);
        break;
      case Subject.GK:
        rawLessons = _getGKLessons(classLevel);
        break;
    }
    return _enforceThreeLevels(rawLessons, classLevel, subject);
  }

  static List<Lesson> _enforceThreeLevels(
    List<Lesson> lessons,
    int classLevel,
    Subject subject,
  ) {
    List<Lesson> result = [];
    Map<String, List<Lesson>> byCategory = {};

    for (var l in lessons) {
      byCategory.putIfAbsent(l.category, () => []).add(l);
    }

    if (byCategory.isEmpty) {
      byCategory['Learning'] = [];
    }

    for (var category in byCategory.keys) {
      var catLessons = List<Lesson>.from(byCategory[category]!);
      catLessons.sort((a, b) => a.level.compareTo(b.level));

      String? previousNodeId; // Tracks the actual ID of the previous node

      for (int i = 1; i <= 4; i++) {
        bool isLearnNode = i % 2 != 0; // Odd = Learn, Even = Play
        String stepType = isLearnNode ? 'Learn' : 'Play';
        bool isLocked = i > 1;

        String generatedId =
            '${subject.name.toLowerCase()}_${classLevel}_${category.toLowerCase().replaceAll(' ', '_')}_$i';

        Lesson node;

        if (i <= catLessons.length) {
          // Use the real lesson data
          var orig = catLessons[i - 1];
          node = Lesson(
            id: orig.id,
            title: orig.title,
            description: orig.description,
            subject: orig.subject,
            classLevel: orig.classLevel,
            level: i,
            category: orig.category,
            content: orig.content,
            prerequisites: previousNodeId != null ? [previousNodeId] : [],
            isLocked: isLocked,
            xpReward: orig.xpReward,
            estimatedDuration: orig.estimatedDuration,
            quiz: orig.quiz,
          );
        } else {
          // Generate a placeholder node
          var baseLesson = catLessons.isNotEmpty ? catLessons.first : null;
          node = Lesson(
            id: generatedId,
            title: baseLesson != null
                ? '${baseLesson.title} ($stepType Pt.${(i / 2).ceil()})'
                : '$category $stepType $i',
            description: 'Level $i of $category',
            subject: subject,
            classLevel: classLevel,
            level: i,
            category: category,
            content: baseLesson != null
                ? baseLesson.content
                : [
                    LessonContent(
                      type: 'text',
                      content: 'Keep exploring $category!',
                    ),
                  ],
            prerequisites: previousNodeId != null ? [previousNodeId] : [],
            isLocked: isLocked,
            xpReward: 50 * i,
            quiz: !isLearnNode
                ? Quiz(
                    questions: [
                      Question(
                        id: 'q_$generatedId',
                        type: 'multiple_choice',
                        question: 'What did you learn in $category?',
                        options: [
                          'A lot!',
                          'Something',
                          'Not much',
                          'Everything',
                        ],
                        correctAnswer: 'A lot!',
                      ),
                    ],
                  )
                : null,
          );
        }

        previousNodeId = node.id; // Store this node's ID for the next iteration
        result.add(node);
      }
    }
    return result;
  }

  // Math Lessons by Class
  static List<Lesson> _getMathLessons(int classLevel) {
    List<Lesson> lessons = [];

    if (classLevel == 1) {
      // Class 1 Numbers Path
      lessons.addAll([
        Lesson(
          id: 'math_1_numbers_1',
          title: 'Numbers (1-10)',
          description: 'Learn numbers then complete the task to earn XP!',
          subject: Subject.Math,
          classLevel: 1,
          level: 1,
          category: 'Numbers',
          content: [
            LessonContent(
              type: 'text',
              content: '🔢 Let\'s learn numbers from 1 to 10!',
              order: 1,
            ),
            LessonContent(
              type: 'text',
              content:
                  '1 = One (एक)\n2 = Two (दुई)\n3 = Three (तीन)\n4 = Four (चार)\n5 = Five (पाँच)',
              order: 2,
            ),
            LessonContent(
              type: 'text',
              content:
                  '6 = Six (छ)\n7 = Seven (सात)\n8 = Eight (आठ)\n9 = Nine (नौ)\n10 = Ten (दश)',
              order: 3,
            ),
            LessonContent(
              type: 'text',
              content:
                  '💡 Tip: Use your fingers to count!\n\nHold up 3 fingers → that is 3.\nHold up 7 fingers → that is 7.',
              order: 4,
            ),
          ],
          xpReward: 50,
          quiz: Quiz(
            questions: [
              Question(
                id: 'q_math_1_num_1',
                type: 'multiple_choice',
                question: 'Which number is "Five"?',
                options: ['3', '5', '7', '1'],
                correctAnswer: '5',
                explanation: 'Five is written as 5. Count: 1, 2, 3, 4, 5!',
              ),
              Question(
                id: 'q_math_1_num_2',
                type: 'multiple_choice',
                question: 'Count the stars: ★ ★ ★',
                options: ['2', '3', '4', '5'],
                correctAnswer: '3',
                explanation:
                    'Count them one by one: 1, 2, 3. There are 3 stars!',
              ),
              Question(
                id: 'q_math_1_num_3',
                type: 'fill_blank',
                question: 'What comes after 4? \n4, ___',
                options: ['3', '5', '6', '2'],
                correctAnswer: '5',
                explanation: '4 comes before 5. The order is: 3, 4, 5.',
              ),
              Question(
                id: 'q_math_1_num_4',
                type: 'multiple_choice',
                question: 'How many fingers on ONE hand?',
                options: ['4', '5', '6', '10'],
                correctAnswer: '5',
                explanation: 'One hand has 5 fingers!',
              ),
            ],
          ),
        ),
      ]);

      // Class 1 Addition Path
      lessons.addAll([
        Lesson(
          id: 'math_1_addition_1',
          title: 'Addition',
          description: 'Learn addition then complete the task to earn XP!',
          subject: Subject.Math,
          classLevel: 1,
          level: 1,
          category: 'Addition',
          content: [
            LessonContent(
              type: 'text',
              content:
                  '➕ Addition means joining things together to find the total!',
              order: 1,
            ),
            LessonContent(
              type: 'text',
              content: 'Example:\n🍎 + 🍎 = 2 apples\n\n1 + 1 = 2',
              order: 2,
            ),
            LessonContent(
              type: 'text',
              content:
                  'We use the "+" sign to add.\nWe use the "=" sign for the answer.\n\nExample: 2 + 3 = 5',
              order: 3,
            ),
            LessonContent(
              type: 'text',
              content:
                  '📝 Practice:\n1 + 1 = 2\n2 + 1 = 3\n3 + 2 = 5\n4 + 1 = 5',
              order: 4,
            ),
          ],
          xpReward: 60,
          quiz: Quiz(
            questions: [
              Question(
                id: 'q_math_1_add_1',
                type: 'fill_blank',
                question: '1 + 2 = ___',
                options: ['1', '2', '3', '4'],
                correctAnswer: '3',
                explanation: '1 + 2 = 3. Start at 1, count 2 more: 2, 3!',
              ),
              Question(
                id: 'q_math_1_add_2',
                type: 'multiple_choice',
                question: '2 + 2 = ?',
                options: ['3', '4', '5', '6'],
                correctAnswer: '4',
                explanation:
                    '2 + 2 = 4. Hold 2 fingers, then 2 more = 4 fingers!',
              ),
              Question(
                id: 'q_math_1_add_3',
                type: 'multiple_choice',
                question: '3 + 1 = ?',
                options: ['2', '3', '4', '5'],
                correctAnswer: '4',
                explanation: '3 + 1 = 4.',
              ),
            ],
          ),
        ),
      ]);
    } else if (classLevel == 2) {
      lessons.addAll([
        Lesson(
          id: 'math_2_placevalue_1',
          title: 'Tens and Ones',
          description: 'Learn about place value, then complete the task to earn XP!',
          subject: Subject.Math,
          classLevel: 2,
          level: 1,
          category: 'Numbers',
          content: [
            LessonContent(type: 'text', content: '🔢 Every number is made of Tens and Ones!', order: 1),
            LessonContent(type: 'text', content: 'Example: 24 = 2 Tens (20) + 4 Ones (4)', order: 2),
            LessonContent(type: 'text', content: 'Example: 37 = 3 Tens (30) + 7 Ones (7)', order: 3),
            LessonContent(type: 'text', content: '💡 Think of Tens as a bundle of 10 sticks tied together!', order: 4),
          ],
          xpReward: 60,
          quiz: Quiz(
            questions: [
              Question(
                id: 'q_math_2_pv_1',
                type: 'multiple_choice',
                question: 'In 37, how many Tens are there?',
                options: ['3', '7', '30', '1'],
                correctAnswer: '3',
                explanation: '37 = 3 Tens and 7 Ones.',
              ),
              Question(
                id: 'q_math_2_pv_2',
                type: 'multiple_choice',
                question: 'In 45, how many Ones are there?',
                options: ['4', '5', '40', '9'],
                correctAnswer: '5',
                explanation: '45 = 4 Tens + 5 Ones.',
              ),
              Question(
                id: 'q_math_2_pv_3',
                type: 'fill_blank',
                question: '52 = ___ Tens + 2 Ones',
                options: ['3', '5', '2', '52'],
                correctAnswer: '5',
                explanation: '52 = 5 Tens + 2 Ones.',
              ),
            ],
          ),
        ),
        Lesson(
          id: 'math_2_addition_1',
          title: 'Two-Digit Addition',
          description: 'Add bigger numbers, then complete the task to earn XP!',
          subject: Subject.Math,
          classLevel: 2,
          level: 1,
          category: 'Addition',
          content: [
            LessonContent(type: 'text', content: '➕ Now we add bigger numbers!', order: 1),
            LessonContent(type: 'text', content: 'Add the Ones first, then the Tens.\n\nExample: 13 + 24\nOnes: 3 + 4 = 7\nTens: 1 + 2 = 3\nAnswer: 37 ✅', order: 2),
            LessonContent(type: 'text', content: '📝 Try: 21 + 15 = ?\nOnes: 1+5=6, Tens: 2+1=3 → Answer: 36', order: 3),
          ],
          xpReward: 60,
          quiz: Quiz(
            questions: [
              Question(
                id: 'q_math_2_add_1',
                type: 'fill_blank',
                question: '13 + 24 = ___',
                options: ['36', '37', '38', '27'],
                correctAnswer: '37',
                explanation: 'Ones: 3+4=7, Tens: 1+2=3 → 37!',
              ),
              Question(
                id: 'q_math_2_add_2',
                type: 'multiple_choice',
                question: '21 + 15 = ?',
                options: ['35', '36', '26', '46'],
                correctAnswer: '36',
                explanation: 'Ones: 1+5=6, Tens: 2+1=3 → 36!',
              ),
            ],
          ),
        ),
      ]);
    } else if (classLevel == 3) {
      lessons.addAll([
        Lesson(
          id: 'math_3_mult_1',
          title: 'Multiplication Basics',
          description: 'Learn multiplication, then complete the task to earn XP!',
          subject: Subject.Math,
          classLevel: 3,
          level: 1,
          category: 'Multiplication',
          content: [
            LessonContent(type: 'text', content: '✖️ Multiplication is fast repeated addition!', order: 1),
            LessonContent(type: 'text', content: '2 × 3 means: add 2 three times\n2 + 2 + 2 = 6\nSo 2 × 3 = 6!', order: 2),
            LessonContent(type: 'text', content: '5 × 4 means: add 5 four times\n5+5+5+5 = 20\nSo 5 × 4 = 20!', order: 3),
            LessonContent(type: 'text', content: '💡 Times Tables:\n2×1=2, 2×2=4, 2×3=6, 2×4=8, 2×5=10', order: 4),
          ],
          xpReward: 70,
          quiz: Quiz(
            questions: [
              Question(
                id: 'q_math_3_mult_1',
                type: 'multiple_choice',
                question: 'What is 3 × 3?',
                options: ['6', '9', '12', '3'],
                correctAnswer: '9',
                explanation: '3 + 3 + 3 = 9.',
              ),
              Question(
                id: 'q_math_3_mult_2',
                type: 'multiple_choice',
                question: 'What is 5 × 2?',
                options: ['7', '8', '10', '52'],
                correctAnswer: '10',
                explanation: '5 + 5 = 10.',
              ),
              Question(
                id: 'q_math_3_mult_3',
                type: 'fill_blank',
                question: '4 × 3 = ___',
                options: ['9', '12', '7', '43'],
                correctAnswer: '12',
                explanation: '4+4+4 = 12.',
              ),
            ],
          ),
        ),
        Lesson(
          id: 'math_3_division_1',
          title: 'Intro to Division',
          description: 'Learn to share equally, then complete the task to earn XP!',
          subject: Subject.Math,
          classLevel: 3,
          level: 1,
          category: 'Division',
          content: [
            LessonContent(type: 'text', content: '➗ Division means splitting into equal groups!', order: 1),
            LessonContent(type: 'text', content: '6 ÷ 2 = 3\nShare 6 apples between 2 people → 3 each!', order: 2),
            LessonContent(type: 'text', content: '10 ÷ 5 = 2\nShare 10 sweets between 5 kids → 2 each!', order: 3),
          ],
          xpReward: 70,
          quiz: Quiz(
            questions: [
              Question(
                id: 'q_math_3_div_1',
                type: 'multiple_choice',
                question: '8 ÷ 2 = ?',
                options: ['2', '4', '6', '3'],
                correctAnswer: '4',
                explanation: '8 shared equally between 2 = 4 each.',
              ),
              Question(
                id: 'q_math_3_div_2',
                type: 'fill_blank',
                question: '9 ÷ 3 = ___',
                options: ['2', '3', '4', '6'],
                correctAnswer: '3',
                explanation: '9 ÷ 3 = 3.',
              ),
            ],
          ),
        ),
      ]);
    } else if (classLevel == 4) {
      lessons.addAll([
        Lesson(
          id: 'math_4_carry_1',
          title: 'Addition with Carrying',
          description: 'Add big numbers using carrying, then complete the task!',
          subject: Subject.Math,
          classLevel: 4,
          level: 1,
          category: 'Addition',
          content: [
            LessonContent(type: 'text', content: '➕ When a column adds up to 10 or more, we "carry" to the next column!', order: 1),
            LessonContent(type: 'text', content: 'Example: 18 + 5\n  Step 1: 8 + 5 = 13\n  Write 3, carry the 1\n  Step 2: 1 + 1(carried) = 2\n  Answer: 23 ✅', order: 2),
            LessonContent(type: 'text', content: 'Example: 47 + 36\n  Ones: 7+6=13 → write 3, carry 1\n  Tens: 4+3+1=8\n  Answer: 83 ✅', order: 3),
          ],
          xpReward: 80,
          quiz: Quiz(
            questions: [
              Question(
                id: 'q_math_4_add_1',
                type: 'multiple_choice',
                question: 'What is 18 + 5?',
                options: ['22', '23', '24', '13'],
                correctAnswer: '23',
                explanation: '8+5=13: write 3, carry 1. 1+1=2. Answer: 23.',
              ),
              Question(
                id: 'q_math_4_add_2',
                type: 'fill_blank',
                question: '47 + 36 = ___',
                options: ['82', '83', '84', '73'],
                correctAnswer: '83',
                explanation: '7+6=13 (carry 1), 4+3+1=8. Answer: 83.',
              ),
            ],
          ),
        ),
        Lesson(
          id: 'math_4_mult_1',
          title: 'Multiplication Tables (6-10)',
          description: 'Master higher times tables, then complete the task!',
          subject: Subject.Math,
          classLevel: 4,
          level: 1,
          category: 'Multiplication',
          content: [
            LessonContent(type: 'text', content: '✖️ You know 2-5 tables. Now let\'s go further!', order: 1),
            LessonContent(type: 'text', content: '6 × table:\n6×1=6, 6×2=12, 6×3=18,\n6×4=24, 6×5=30', order: 2),
            LessonContent(type: 'text', content: '7 × table:\n7×1=7, 7×2=14, 7×3=21,\n7×4=28, 7×5=35', order: 3),
          ],
          xpReward: 80,
          quiz: Quiz(
            questions: [
              Question(
                id: 'q_math_4_mul_1',
                type: 'multiple_choice',
                question: 'What is 6 × 4?',
                options: ['20', '22', '24', '26'],
                correctAnswer: '24',
                explanation: '6 × 4 = 24.',
              ),
              Question(
                id: 'q_math_4_mul_2',
                type: 'multiple_choice',
                question: 'What is 7 × 3?',
                options: ['18', '21', '24', '28'],
                correctAnswer: '21',
                explanation: '7 × 3 = 21.',
              ),
            ],
          ),
        ),
      ]);
    } else if (classLevel == 5) {
      lessons.addAll([
        Lesson(
          id: 'math_5_fractions_1',
          title: 'Understanding Fractions',
          description: 'Learn fractions, then complete the task to earn XP!',
          subject: Subject.Math,
          classLevel: 5,
          level: 1,
          category: 'Fractions',
          content: [
            LessonContent(type: 'text', content: '🍕 A fraction shows a PART of a whole!', order: 1),
            LessonContent(type: 'text', content: 'The TOP number = Numerator (parts we have)\nThe BOTTOM number = Denominator (total parts)\n\nExample: 3/4 → we have 3 out of 4 parts', order: 2),
            LessonContent(type: 'text', content: 'Common fractions:\n1/2 = Half (pizza cut in 2, take 1)\n1/4 = Quarter (cut in 4, take 1)\n3/4 = Three quarters', order: 3),
            LessonContent(type: 'text', content: '💡 Equivalent fractions: 1/2 = 2/4 = 4/8\nThey all mean the same amount!', order: 4),
          ],
          xpReward: 100,
          quiz: Quiz(
            questions: [
              Question(
                id: 'q_math_5_frac_1',
                type: 'multiple_choice',
                question: 'In 5/8, what is the Numerator?',
                options: ['5', '8', '3', '13'],
                correctAnswer: '5',
                explanation: 'The TOP number is the Numerator. It\'s 5.',
              ),
              Question(
                id: 'q_math_5_frac_2',
                type: 'multiple_choice',
                question: 'Which fraction is the same as 1/2?',
                options: ['2/4', '1/3', '3/5', '4/9'],
                correctAnswer: '2/4',
                explanation: '2/4 simplifies to 1/2. Both mean half!',
              ),
              Question(
                id: 'q_math_5_frac_3',
                type: 'fill_blank',
                question: 'In 3/4, the Denominator is ___',
                options: ['3', '4', '7', '1'],
                correctAnswer: '4',
                explanation: 'The BOTTOM number (4) is the Denominator.',
              ),
            ],
          ),
        ),
        Lesson(
          id: 'math_5_decimals_1',
          title: 'Introduction to Decimals',
          description: 'Learn decimals, then complete the task to earn XP!',
          subject: Subject.Math,
          classLevel: 5,
          level: 1,
          category: 'Decimals',
          content: [
            LessonContent(type: 'text', content: '🔢 Decimals are fractions written with a dot!', order: 1),
            LessonContent(type: 'text', content: '1/2 = 0.5\n1/4 = 0.25\n3/4 = 0.75', order: 2),
            LessonContent(type: 'text', content: 'The dot (.) separates the whole number from the part.\n3.5 means "3 and a half"', order: 3),
          ],
          xpReward: 100,
          quiz: Quiz(
            questions: [
              Question(
                id: 'q_math_5_dec_1',
                type: 'multiple_choice',
                question: 'What is 1/2 as a decimal?',
                options: ['0.25', '0.5', '0.75', '1.2'],
                correctAnswer: '0.5',
                explanation: '1/2 = 0.5 (half).',
              ),
              Question(
                id: 'q_math_5_dec_2',
                type: 'multiple_choice',
                question: '3.5 means?',
                options: ['35 whole', '3 and a half', '3 and a quarter', '0.35'],
                correctAnswer: '3 and a half',
                explanation: '3.5 = 3 + 0.5 = 3 and a half.',
              ),
            ],
          ),
        ),
      ]);
    } else if (classLevel == 6) {
      lessons.addAll([
        Lesson(
          id: 'math_6_algebra_1',
          title: 'Introduction to Algebra',
          description: 'Learn about variables and constants',
          subject: Subject.Math,
          classLevel: 6,
          level: 1,
          category: 'Algebra',
          content: [
            LessonContent(
              type: 'text',
              content: 'Algebra uses letters to stand for unknown numbers!',
              order: 1,
            ),
            LessonContent(
              type: 'text',
              content:
                  'A variable is a letter whose value we don\'t know.\nExample: x, y, z',
              order: 2,
            ),
            LessonContent(
              type: 'text',
              content:
                  'A constant is a fixed number.\nExample: 5, 10, or 100 never change.',
              order: 3,
            ),
            LessonContent(
              type: 'text',
              content:
                  'Solving an equation:\nIf x + 2 = 5\nThen x = 5 - 2 = 3 ✓',
              order: 4,
            ),
          ],
          xpReward: 120,
        ),
        Lesson(
          id: 'math_6_algebra_2',
          title: 'Algebra Quiz',
          description: 'Solve for x',
          subject: Subject.Math,
          classLevel: 6,
          level: 2,
          category: 'Algebra',
          content: [
            LessonContent(
              type: 'text',
              content: 'Find the value of the variable!',
              order: 1,
            ),
          ],
          xpReward: 150,
          quiz: Quiz(
            questions: [
              Question(
                id: 'q_math_6_alg_1',
                type: 'fill_blank',
                question: 'If x + 5 = 10, then x = ___',
                options: ['2', '5', '10', '15'],
                correctAnswer: '5',
                explanation: 'x = 10 - 5 = 5',
              ),
              Question(
                id: 'q_math_6_alg_2',
                type: 'multiple_choice',
                question: 'Which letter is a "variable"?',
                options: ['5', 'x', '100', '0'],
                correctAnswer: 'x',
                explanation:
                    'x is a letter (variable). Numbers like 5 or 100 are constants.',
              ),
            ],
          ),
        ),
      ]);
    } else {
      // Default for other classes (3, 4, 7-10)
      lessons.addAll([
        Lesson(
          id: 'math_${classLevel}_gen_1',
          title: 'Mathematics Class $classLevel',
          description: 'Core concepts for Class $classLevel',
          subject: Subject.Math,
          classLevel: classLevel,
          level: 1,
          category: 'Mathematics',
          content: [
            LessonContent(
              type: 'text',
              content: 'Welcome to Class $classLevel Mathematics!',
              order: 1,
            ),
            LessonContent(
              type: 'text',
              content:
                  'In this class you will learn:\n• Number operations\n• Geometry\n• Measurement\n• Problem solving',
              order: 2,
            ),
          ],
          xpReward: 50,
        ),
      ]);
    }

    return lessons;
  }

  // English Lessons by Class
  static List<Lesson> _getEnglishLessons(int classLevel) {
    List<Lesson> lessons = [];

    if (classLevel == 1) {
      // Alphabets: Step 1 - Learn
      lessons.add(
        Lesson(
          id: 'eng_alphabets_1_1',
          title: 'Learn Alphabets A to E',
          description: 'Explore letters A to E with sounds and pictures!',
          subject: Subject.English,
          classLevel: 1,
          level: 1,
          category: 'Alphabets',
          content: [
            LessonContent(type: 'text', content: '🔤 Every letter has a sound. Let\'s learn A to E!', order: 1),
            LessonContent(type: 'text', content: 'A says "Ah" → Apple 🍎\nB says "Buh" → Ball ⚽\nC says "Cuh" → Cat 🐱', order: 2),
            LessonContent(type: 'text', content: 'D says "Duh" → Dog 🐶\nE says "Eh" → Egg 🥚', order: 3),
            LessonContent(type: 'text', content: '💡 Repeat aloud: A, B, C, D, E!', order: 4),
          ],
          xpReward: 50,
          quiz: Quiz(
            questions: [
              Question(
                id: 'q_eng_1_alpha_1',
                type: 'multiple_choice',
                question: 'Which letter makes the "Ah" sound?',
                options: ['B', 'A', 'C', 'D'],
                correctAnswer: 'A',
                explanation: 'A says "Ah" like in Apple!',
              ),
              Question(
                id: 'q_eng_1_alpha_2',
                type: 'fill_blank',
                question: 'A, B, ___, D, E',
                options: ['A', 'C', 'F', 'Z'],
                correctAnswer: 'C',
                explanation: 'The order is A, B, C, D, E.',
              ),
            ],
          ),
        ),
      );

      // Grammar: 3-Letter Words (combined learn + quiz)
      lessons.add(
        Lesson(
          id: 'eng_words_1_1',
          title: '3-Letter Words',
          description: 'Learn to build words, then complete the task to earn XP!',
          subject: Subject.English,
          classLevel: 1,
          level: 1,
          category: 'Grammar',
          content: [
            LessonContent(type: 'text', content: '📝 Let\'s build short words!', order: 1),
            LessonContent(type: 'text', content: 'C + A + T = CAT 🐱\nB + A + T = BAT 🏏\nM + A + T = MAT 🪆', order: 2),
            LessonContent(type: 'text', content: 'D + O + G = DOG 🐶\nC + U + P = CUP ☕', order: 3),
            LessonContent(type: 'text', content: '💡 CAT, BAT, MAT all rhyme — they end with "-AT"!', order: 4),
          ],
          xpReward: 60,
          quiz: Quiz(
            questions: [
              Question(
                id: 'q_eng_1_word_1',
                type: 'multiple_choice',
                question: 'What does C + A + T spell?',
                options: ['BAT', 'CAT', 'MAT', 'DOG'],
                correctAnswer: 'CAT',
                explanation: 'C + A + T = CAT 🐱',
              ),
              Question(
                id: 'q_eng_1_word_2',
                type: 'multiple_choice',
                question: 'Which word rhymes with CAT?',
                options: ['DOG', 'CUP', 'BAT', 'EGG'],
                correctAnswer: 'BAT',
                explanation: 'CAT and BAT both end with -AT!',
              ),
            ],
          ),
        ),
      );
    } else if (classLevel == 2) {
      lessons.addAll([
        Lesson(
          id: 'eng_phonics_2_1',
          title: 'Phonics: Letter Sounds (A-M)',
          description: 'Learn letter sounds, then complete the task to earn XP!',
          subject: Subject.English,
          classLevel: 2,
          level: 1,
          category: 'Alphabets',
          content: [
            LessonContent(type: 'text', content: '🔤 Let\'s review letter sounds A to M!', order: 1),
            LessonContent(type: 'text', content: 'A-Apple, B-Ball, C-Cat, D-Dog, E-Egg', order: 2),
            LessonContent(type: 'text', content: 'F-Fish 🐟, G-Goat 🐐, H-Hat 🎩, I-Ink 🖊️, J-Jar 🫙', order: 3),
            LessonContent(type: 'text', content: 'K-Kite 🪁, L-Lion 🦁, M-Mango 🥭', order: 4),
          ],
          xpReward: 60,
          quiz: Quiz(
            questions: [
              Question(
                id: 'q_eng_2_alpha_1',
                type: 'multiple_choice',
                question: 'F is for ___?',
                options: ['Goat', 'Fish', 'Hat', 'Ink'],
                correctAnswer: 'Fish',
                explanation: 'F is for Fish 🐟',
              ),
              Question(
                id: 'q_eng_2_alpha_2',
                type: 'multiple_choice',
                question: 'Which letter comes after J?',
                options: ['I', 'K', 'L', 'H'],
                correctAnswer: 'K',
                explanation: 'J, K, L... K comes after J!',
              ),
            ],
          ),
        ),
        Lesson(
          id: 'eng_words_2_1',
          title: 'Building Words',
          description: 'Learn to spell words, then complete the task!',
          subject: Subject.English,
          classLevel: 2,
          level: 1,
          category: 'Grammar',
          content: [
            LessonContent(type: 'text', content: '📝 Let\'s spell words using letters!', order: 1),
            LessonContent(type: 'text', content: 'C+A+T = CAT 🐱\nB+A+T = BAT 🏏\nM+A+T = MAT 🪆', order: 2),
            LessonContent(type: 'text', content: 'CAT, BAT, MAT all rhyme — they end with "-AT"!', order: 3),
          ],
          xpReward: 60,
          quiz: Quiz(
            questions: [
              Question(
                id: 'q_eng_2_word_1',
                type: 'multiple_choice',
                question: 'Which word rhymes with CAT?',
                options: ['DOG', 'CUP', 'BAT', 'EGG'],
                correctAnswer: 'BAT',
                explanation: 'CAT and BAT both end with -AT!',
              ),
            ],
          ),
        ),
      ]);
    } else if (classLevel == 3 || classLevel == 4) {
      lessons.addAll([
        Lesson(
          id: 'eng_grammar_${classLevel}_1',
          title: 'Nouns and Verbs',
          description: 'Learn parts of speech, then complete the task!',
          subject: Subject.English,
          classLevel: classLevel,
          level: 1,
          category: 'Grammar',
          content: [
            LessonContent(type: 'text', content: '📚 English sentences have Parts of Speech!', order: 1),
            LessonContent(type: 'text', content: 'Nouns = naming words (person, place, thing)\nExamples: Dog 🐶, Kathmandu 🏔️, Book 📖', order: 2),
            LessonContent(type: 'text', content: 'Verbs = action words (things you do)\nExamples: Run 🏃, Eat 🍽️, Read 📖', order: 3),
            LessonContent(type: 'text', content: '💡 Every sentence needs a Noun AND a Verb!\n"The dog runs" — dog=Noun, runs=Verb', order: 4),
          ],
          xpReward: 70,
          quiz: Quiz(
            questions: [
              Question(
                id: 'q_eng_${classLevel}_noun_1',
                type: 'multiple_choice',
                question: 'Which word is a Noun?',
                options: ['Run', 'Apple', 'Jump', 'Fast'],
                correctAnswer: 'Apple',
                explanation: 'Apple is a thing — so it\'s a Noun!',
              ),
              Question(
                id: 'q_eng_${classLevel}_verb_1',
                type: 'multiple_choice',
                question: 'Which word is a Verb (action)?',
                options: ['Table', 'Happy', 'Jump', 'Blue'],
                correctAnswer: 'Jump',
                explanation: '"Jump" is an action — you can do it!',
              ),
            ],
          ),
        ),
      ]);
    } else if (classLevel == 5 || classLevel == 6) {
      lessons.addAll([
        Lesson(
          id: 'eng_grammar_${classLevel}_1',
          title: 'Advanced Grammar: Nouns, Verbs & Adjectives',
          description: 'Master parts of speech, then complete the task!',
          subject: Subject.English,
          classLevel: classLevel,
          level: 1,
          category: 'Grammar',
          content: [
            LessonContent(type: 'text', content: '📚 A Noun names a person, place, or thing. (Student, Nepal, Pen)', order: 1),
            LessonContent(type: 'text', content: 'A Verb is an action or state of being. (Run, Think, Is)', order: 2),
            LessonContent(type: 'text', content: 'An Adjective describes a Noun. (Big, Smart, Red)', order: 3),
            LessonContent(type: "text", content: "✅ Example: The smart student reads books. Nouns: student, books | Verb: reads | Adjective: smart", order: 4),
          ],
          xpReward: 100,
          quiz: Quiz(
            questions: [
              Question(
                id: 'q_eng_gv_1_$classLevel',
                type: 'multiple_choice',
                question: 'In "The student studies hard", which word is the Verb?',
                options: ['The', 'student', 'studies', 'hard'],
                correctAnswer: 'studies',
                explanation: '"Studies" is the action — it\'s the Verb!',
              ),
              Question(
                id: 'q_eng_adj_1_$classLevel',
                type: 'multiple_choice',
                question: 'In "The red ball", which word is the Adjective?',
                options: ['The', 'red', 'ball', 'a'],
                correctAnswer: 'red',
                explanation: '"Red" describes the ball — it\'s an Adjective!',
              ),
            ],
          ),
        ),
      ]);
    }

    if (lessons.isEmpty) {
      lessons.add(
        Lesson(
          id: 'english_${classLevel}_gen_1',
          title: 'Class $classLevel English',
          description: 'Read and complete the task to earn XP!',
          subject: Subject.English,
          classLevel: classLevel,
          level: 1,
          category: 'Grammar',
          content: [
            LessonContent(
              type: 'text',
              content: 'Welcome to Class $classLevel English!',
              order: 1,
            ),
            LessonContent(
              type: 'text',
              content: 'We will learn to read, write and speak in English.',
              order: 2,
            ),
          ],
          xpReward: 50,
        ),
      );
    }

    return lessons;
  }

  // Nepali Lessons by Class
  static List<Lesson> _getNepaliLessons(int classLevel) {
    List<Lesson> lessons = [];

    if (classLevel == 1) {
      // ── स्वर वर्ण (Vowels) ─────────────────────────────────────────────
      lessons.add(
        Lesson(
          id: 'nep_swar_1_1',
          title: 'नेपाली स्वर वर्ण (अ–ऊ)',
          description: 'स्वर वर्णहरू सिक्नुहोस् र प्रश्न गर्नुहोस्!',
          subject: Subject.Nepali,
          classLevel: 1,
          level: 1,
          category: 'Barnamala',
          content: [
            LessonContent(type: 'text', content: '🔤 आउनुहोस् स्वर वर्णमाला सिकौं!', order: 1),
            LessonContent(type: 'text', content: 'अ – अनार 🍎\nआ – आमा 👩\nइ – इनार 🪣', order: 2),
            LessonContent(type: 'text', content: 'ई – ईश्वर 🙏\nउ – उँट 🐫\nऊ – ऊन 🧶', order: 3),
            LessonContent(type: 'text', content: '�� जोरले पढ्नुहोस्: अ, आ, इ, ई, उ, ऊ!', order: 4),
          ],
          xpReward: 50,
          quiz: Quiz(
            questions: [
              Question(
                id: 'q_nep_1_swar_1',
                type: 'multiple_choice',
                question: 'नेपाली स्वर वर्णमालाको पहिलो अक्षर कुन हो?',
                options: ['इ', 'आ', 'अ', 'ई'],
                correctAnswer: 'अ',
                explanation: 'अ नेपाली वर्णमालाको पहिलो स्वर अक्षर हो।',
              ),
              Question(
                id: 'q_nep_1_swar_2',
                type: 'fill_blank',
                question: 'अ, ___, इ, ई, उ, ऊ',
                options: ['ए', 'ओ', 'आ', 'अ'],
                correctAnswer: 'आ',
                explanation: 'सही क्रम: अ, आ, इ, ई, उ, ऊ।',
              ),
            ],
          ),
        ),
      );

      // ── नेपाली अंक (Numbers 1–5) ──────────────────────────────────────
      lessons.add(
        Lesson(
          id: 'nep_ank_1_1',
          title: 'नेपाली अंक (१–५)',
          description: 'नेपाली अंक सिक्नुहोस् र प्रश्न गर्नुहोस्!',
          subject: Subject.Nepali,
          classLevel: 1,
          level: 1,
          category: 'Numbers',
          content: [
            LessonContent(type: 'text', content: '🔢 आउनुहोस् नेपाली अंक सिकौं!', order: 1),
            LessonContent(type: 'text', content: '१ = एक 🥇\n२ = दुई ✌️\n३ = तीन 🔱', order: 2),
            LessonContent(type: 'text', content: '४ = चार 🍀\n५ = पाँच 🖐️', order: 3),
            LessonContent(type: 'text', content: '💡 दोहोर्याउनुहोस्: एक, दुई, तीन, चार, पाँच!', order: 4),
          ],
          xpReward: 50,
          quiz: Quiz(
            questions: [
              Question(
                id: 'q_nep_1_ank_1',
                type: 'multiple_choice',
                question: '"तीन" लाई नेपाली अंकमा कसरी लेख्छन्?',
                options: ['१', '२', '३', '४'],
                correctAnswer: '३',
                explanation: '३ भनेको तीन हो।',
              ),
              Question(
                id: 'q_nep_1_ank_2',
                type: 'fill_blank',
                question: 'एक, दुई, ___, चार, पाँच',
                options: ['दुई', 'तीन', 'छ', 'सात'],
                correctAnswer: 'तीन',
                explanation: 'सही क्रम: एक, दुई, तीन, चार, पाँच।',
              ),
            ],
          ),
        ),
      );

      // ── जनावरका नाम (Animals) ─────────────────────────────────────────
      lessons.add(
        Lesson(
          id: 'nep_janavar_1_1',
          title: 'जनावरका नाम',
          description: 'जनावरका नाम सिक्नुहोस् र प्रश्न गर्नुहोस्!',
          subject: Subject.Nepali,
          classLevel: 1,
          level: 1,
          category: 'Flashcards',
          content: [
            LessonContent(type: 'text', content: '🐾 आउनुहोस् जनावरका नाम सिकौं!', order: 1),
            LessonContent(type: 'text', content: 'सिंह 🦁\nहात्ती 🐘\nगाई 🐄', order: 2),
            LessonContent(type: 'text', content: 'कुकुर ��\nबिरालो 🐱\nचरा 🐦', order: 3),
            LessonContent(type: 'text', content: '💡 जोरले भन्नुहोस्: सिंह, हात्ती, गाई, कुकुर, बिरालो!', order: 4),
          ],
          xpReward: 50,
          quiz: Quiz(
            questions: [
              Question(
                id: 'q_nep_1_jan_1',
                type: 'multiple_choice',
                question: '🦁 यो कुन जनावर हो?',
                options: ['हात्ती', 'सिंह', 'गाई', 'कुकुर'],
                correctAnswer: 'सिंह',
                explanation: '🦁 यो सिंह हो।',
              ),
              Question(
                id: 'q_nep_1_jan_2',
                type: 'multiple_choice',
                question: '🐶 यो कुन जनावर हो?',
                options: ['बिरालो', 'चरा', 'कुकुर', 'सिंह'],
                correctAnswer: 'कुकुर',
                explanation: '🐶 यो कुकुर हो।',
              ),
              Question(
                id: 'q_nep_1_jan_3',
                type: 'fill_blank',
                question: '🐘 यो ___ हो।',
                options: ['गाई', 'हात्ती', 'बिरालो', 'चरा'],
                correctAnswer: 'हात्ती',
                explanation: '🐘 यो हात्ती हो।',
              ),
            ],
          ),
        ),
      );

      // ── Game (Flip & Pair) ───────────────────────────────────────────
      lessons.add(
        Lesson(
          id: 'nep_game_1_flip',
          title: 'Nepali Flip & Pair Game',
          description: 'Match the identical Nepali letters! 🎮',
          subject: Subject.Nepali,
          classLevel: 1,
          level: 1,
          category: 'Games',
          content: [
            LessonContent(type: 'text', content: 'Let\'s play a matching game!', order: 1),
          ],
          xpReward: 30,
        ),
      );

    } else if (classLevel == 2) {
      // ── व्यञ्जन वर्ण (Consonants क–ङ) ──────────────────────────────────
      lessons.add(
        Lesson(
          id: 'nep_byanjan_2_1',
          title: 'नेपाली व्यञ्जन (क–ङ)',
          description: 'व्यञ्जन वर्णहरू सिक्नुहोस् र प्रश्न गर्नुहोस्!',
          subject: Subject.Nepali,
          classLevel: 2,
          level: 1,
          category: 'Barnamala',
          content: [
            LessonContent(type: 'text', content: '🔤 आउनुहोस् व्यञ्जन वर्ण सिकौं!', order: 1),
            LessonContent(type: 'text', content: 'क – कपाल 💇\nख – खरायो 🐇\nग – गाई 🐄', order: 2),
            LessonContent(type: 'text', content: 'घ – घर 🏠\nङ – ङ्याउरो 🐱', order: 3),
            LessonContent(type: 'text', content: '💡 दोहोर्याउनुहोस्: क, ख, ग, घ, ङ!', order: 4),
          ],
          xpReward: 60,
          quiz: Quiz(
            questions: [
              Question(
                id: 'q_nep_2_bya_1',
                type: 'multiple_choice',
                question: '"खरायो" कुन अक्षरबाट सुरु हुन्छ?',
                options: ['क', 'ख', 'ग', 'घ'],
                correctAnswer: 'ख',
                explanation: 'खरायो "ख" बाट सुरु हुन्छ।',
              ),
              Question(
                id: 'q_nep_2_bya_2',
                type: 'fill_blank',
                question: 'क, ख, ___, घ, ङ',
                options: ['च', 'ग', 'ज', 'ट'],
                correctAnswer: 'ग',
                explanation: 'सही क्रम: क, ख, ग, घ, ङ।',
              ),
            ],
          ),
        ),
      );

      // ── फलफूलका नाम (Fruits) ─────────────────────────────────────────
      lessons.add(
        Lesson(
          id: 'nep_phal_2_1',
          title: 'फलफूलका नाम',
          description: 'फलफूलका नाम सिक्नुहोस् र प्रश्न गर्नुहोस्!',
          subject: Subject.Nepali,
          classLevel: 2,
          level: 1,
          category: 'Flashcards',
          content: [
            LessonContent(type: 'text', content: '🍎 आउनुहोस् फलफूलका नाम सिकौं!', order: 1),
            LessonContent(type: 'text', content: 'स्याउ 🍎\nकेरा 🍌\nआँप 🥭', order: 2),
            LessonContent(type: 'text', content: 'सुन्तला 🍊\nअंगुर 🍇\nखरबुजा 🍈', order: 3),
            LessonContent(type: 'text', content: '💡 मनपर्ने फल छान्नुहोस्!', order: 4),
          ],
          xpReward: 60,
          quiz: Quiz(
            questions: [
              Question(
                id: 'q_nep_2_phal_1',
                type: 'multiple_choice',
                question: '🍌 यो कुन फल हो?',
                options: ['आँप', 'स्याउ', 'केरा', 'सुन्तला'],
                correctAnswer: 'केरा',
                explanation: '🍌 यो केरा हो।',
              ),
              Question(
                id: 'q_nep_2_phal_2',
                type: 'fill_blank',
                question: '🍊 यो ___ हो।',
                options: ['आँप', 'अंगुर', 'सुन्तला', 'केरा'],
                correctAnswer: 'सुन्तला',
                explanation: '🍊 यो सुन्तला हो।',
              ),
            ],
          ),
        ),
      );

      // ── Game (Flip & Pair) ───────────────────────────────────────────
      lessons.add(
        Lesson(
          id: 'nep_game_2_flip',
          title: 'Nepali Flip & Pair Game',
          description: 'Match the identical Nepali letters! 🎮',
          subject: Subject.Nepali,
          classLevel: 2,
          level: 1,
          category: 'Games',
          content: [
            LessonContent(type: 'text', content: 'Let\'s play a matching game!', order: 1),
          ],
          xpReward: 30,
        ),
      );

    } else if (classLevel == 3) {
      // ── नाम र सर्वनाम ─────────────────────────────────────────────────
      lessons.add(
        Lesson(
          id: 'nep_nam_3_1',
          title: 'नाम र सर्वनाम',
          description: 'नाम र सर्वनाम सिक्नुहोस् र प्रश्न गर्नुहोस्!',
          subject: Subject.Nepali,
          classLevel: 3,
          level: 1,
          category: 'Byakaran',
          content: [
            LessonContent(type: 'text', content: '📚 नाम र सर्वनाम के हो?', order: 1),
            LessonContent(type: 'text', content: 'नाम: कुनै व्यक्ति वा वस्तुको नाम।\nजस्तै: राम, कलम, काठमाडौं', order: 2),
            LessonContent(type: 'text', content: 'सर्वनाम: नामको सट्टा प्रयोग हुने शब्द।\nजस्तै: ऊ, तिमी, हामी', order: 3),
            LessonContent(type: 'text', content: '💡 उदाहरण: "राम स्कुल जान्छ।" → "ऊ स्कुल जान्छ।"', order: 4),
          ],
          xpReward: 70,
          quiz: Quiz(
            questions: [
              Question(
                id: 'q_nep_3_nam_1',
                type: 'multiple_choice',
                question: '"राम" कस्तो शब्द हो?',
                options: ['नाम', 'सर्वनाम', 'क्रियापद', 'विशेषण'],
                correctAnswer: 'नाम',
                explanation: '"राम" एक व्यक्तिको नाम हो — त्यसैले यो नाम हो।',
              ),
              Question(
                id: 'q_nep_3_nam_2',
                type: 'multiple_choice',
                question: '"तिमी" कस्तो शब्द हो?',
                options: ['नाम', 'सर्वनाम', 'क्रियापद', 'विशेषण'],
                correctAnswer: 'सर्वनाम',
                explanation: '"तिमी" नामको सट्टा प्रयोग हुन्छ — त्यसैले यो सर्वनाम हो।',
              ),
            ],
          ),
        ),
      );

      // ── क्रियापद (Verbs) ──────────────────────────────────────────────
      lessons.add(
        Lesson(
          id: 'nep_kriya_3_1',
          title: 'क्रियापद (कामजनाउने शब्द)',
          description: 'क्रियापद सिक्नुहोस् र प्रश्न गर्नुहोस्!',
          subject: Subject.Nepali,
          classLevel: 3,
          level: 1,
          category: 'Byakaran',
          content: [
            LessonContent(type: 'text', content: '📚 क्रियापद भनेको के हो?', order: 1),
            LessonContent(type: 'text', content: 'क्रियापद: काम जनाउने शब्द।\nजस्तै: खान्छ, पढ्छ, दौडन्छ', order: 2),
            LessonContent(type: 'text', content: 'उदाहरण:\nराम खान्छ। 🍽️\nसीता पढ्छे। 📖\nहरि दौडन्छ। 🏃', order: 3),
            LessonContent(type: 'text', content: '💡 हरेक वाक्यमा एउटा क्रियापद हुन्छ!', order: 4),
          ],
          xpReward: 70,
          quiz: Quiz(
            questions: [
              Question(
                id: 'q_nep_3_kriya_1',
                type: 'multiple_choice',
                question: '"सीता पढ्छे" — यस वाक्यमा क्रियापद कुन हो?',
                options: ['सीता', 'पढ्छे', 'यो', 'त्यो'],
                correctAnswer: 'पढ्छे',
                explanation: '"पढ्छे" काम जनाउँछ — त्यसैले यो क्रियापद हो।',
              ),
              Question(
                id: 'q_nep_3_kriya_2',
                type: 'multiple_choice',
                question: 'निम्न मध्ये कुन क्रियापद हो?',
                options: ['राम', 'राम्रो', 'खान्छ', 'काठमाडौं'],
                correctAnswer: 'खान्छ',
                explanation: '"खान्छ" एउटा काम जनाउँछ — यो क्रियापद हो।',
              ),
            ],
          ),
        ),
      );

    } else if (classLevel == 4) {
      // ── विशेषण (Adjectives) ───────────────────────────────────────────
      lessons.add(
        Lesson(
          id: 'nep_visheshan_4_1',
          title: 'विशेषण (गुण जनाउने शब्द)',
          description: 'विशेषण सिक्नुहोस् र प्रश्न गर्नुहोस्!',
          subject: Subject.Nepali,
          classLevel: 4,
          level: 1,
          category: 'Byakaran',
          content: [
            LessonContent(type: 'text', content: '📚 विशेषण भनेको के हो?', order: 1),
            LessonContent(type: 'text', content: 'विशेषण: नामको गुण, संख्या वा अवस्था बताउने शब्द।', order: 2),
            LessonContent(type: 'text', content: 'उदाहरण:\nरातो फूल 🌹 (रातो = विशेषण)\nसानो बालक 👦 (सानो = विशेषण)', order: 3),
            LessonContent(type: 'text', content: '💡 विशेषणले नामलाई थप स्पष्ट बनाउँछ!', order: 4),
          ],
          xpReward: 80,
          quiz: Quiz(
            questions: [
              Question(
                id: 'q_nep_4_vis_1',
                type: 'multiple_choice',
                question: '"रातो फूल" — यस वाक्यमा विशेषण कुन हो?',
                options: ['फूल', 'रातो', 'र', 'यो'],
                correctAnswer: 'रातो',
                explanation: '"रातो" फूलको गुण बताउँछ — त्यसैले यो विशेषण हो।',
              ),
              Question(
                id: 'q_nep_4_vis_2',
                type: 'multiple_choice',
                question: 'निम्न मध्ये कुन विशेषण हो?',
                options: ['दौडन्छ', 'राम', 'सुन्दर', 'काठमाडौं'],
                correctAnswer: 'सुन्दर',
                explanation: '"सुन्दर" गुण बताउँछ — यो विशेषण हो।',
              ),
            ],
          ),
        ),
      );

      // ── वाक्य रचना (Sentence Structure) ──────────────────────────────
      lessons.add(
        Lesson(
          id: 'nep_vakya_4_1',
          title: 'वाक्य रचना',
          description: 'नेपाली वाक्य कसरी बन्छ सिक्नुहोस् र प्रश्न गर्नुहोस्!',
          subject: Subject.Nepali,
          classLevel: 4,
          level: 1,
          category: 'Byakaran',
          content: [
            LessonContent(type: 'text', content: '📚 नेपाली वाक्यको रचना!', order: 1),
            LessonContent(type: 'text', content: 'नेपाली वाक्यमा सामान्यतः:\nकर्ता + कर्म + क्रियापद', order: 2),
            LessonContent(type: 'text', content: 'उदाहरण:\nराम (कर्ता) स्याउ (कर्म) खान्छ (क्रियापद)।', order: 3),
            LessonContent(type: 'text', content: '💡 कर्ता काम गर्छ, कर्म कामको वस्तु हो!', order: 4),
          ],
          xpReward: 80,
          quiz: Quiz(
            questions: [
              Question(
                id: 'q_nep_4_vak_1',
                type: 'multiple_choice',
                question: '"राम स्याउ खान्छ" — कर्ता कुन हो?',
                options: ['स्याउ', 'खान्छ', 'राम', 'र'],
                correctAnswer: 'राम',
                explanation: '"राम" काम गर्छ — त्यसैले यो कर्ता हो।',
              ),
              Question(
                id: 'q_nep_4_vak_2',
                type: 'multiple_choice',
                question: 'नेपाली वाक्यमा क्रियापद कहाँ आउँछ?',
                options: ['सुरुमा', 'बीचमा', 'अन्तमा', 'जहाँ भए पनि'],
                correctAnswer: 'अन्तमा',
                explanation: 'नेपाली वाक्यमा क्रियापद प्रायः अन्तमा आउँछ।',
              ),
            ],
          ),
        ),
      );

    } else if (classLevel == 5) {
      // ── उच्च व्याकरण (Advanced Grammar) ──────────────────────────────
      lessons.add(
        Lesson(
          id: 'nep_uchha_5_1',
          title: 'उच्च व्याकरण — कारक',
          description: 'कारक सिक्नुहोस् र प्रश्न गर्नुहोस्!',
          subject: Subject.Nepali,
          classLevel: 5,
          level: 1,
          category: 'Byakaran',
          content: [
            LessonContent(type: 'text', content: '📚 कारक भनेको के हो?', order: 1),
            LessonContent(type: 'text', content: 'कारक: वाक्यमा नाम वा सर्वनामको भूमिका बताउने तत्त्व।', order: 2),
            LessonContent(type: 'text', content: 'मुख्य कारकहरू:\nकर्ता कारक – काम गर्नेले\nकर्म कारक – कामको वस्तु\nकरण कारक – जसद्वारा काम हुन्छ', order: 3),
            LessonContent(type: 'text', content: '💡 उदाहरण:\nरामले (कर्ता) कलमले (करण) चिठ्ठी (कर्म) लेख्छ।', order: 4),
          ],
          xpReward: 100,
          quiz: Quiz(
            questions: [
              Question(
                id: 'q_nep_5_kar_1',
                type: 'multiple_choice',
                question: '"रामले स्याउ खायो" — "रामले" कुन कारक हो?',
                options: ['कर्म कारक', 'कर्ता कारक', 'करण कारक', 'सम्प्रदान कारक'],
                correctAnswer: 'कर्ता कारक',
                explanation: '"रामले" काम गर्नेलाई जनाउँछ — त्यसैले यो कर्ता कारक हो।',
              ),
              Question(
                id: 'q_nep_5_kar_2',
                type: 'multiple_choice',
                question: '"कलमले लेख्छ" — "कलमले" कुन कारक हो?',
                options: ['कर्ता कारक', 'कर्म कारक', 'करण कारक', 'बिभक्ति कारक'],
                correctAnswer: 'करण कारक',
                explanation: '"कलमले" साधन जनाउँछ — त्यसैले यो करण कारक हो।',
              ),
            ],
          ),
        ),
      );

      // ── लोककथा र कविता (Folk Tales & Poetry) ────────────────────────
      lessons.add(
        Lesson(
          id: 'nep_lokatha_5_1',
          title: 'नेपाली लोककथा र कविता',
          description: 'लोककथा र कविता सिक्नुहोस् र प्रश्न गर्नुहोस्!',
          subject: Subject.Nepali,
          classLevel: 5,
          level: 1,
          category: 'Sahitya',
          content: [
            LessonContent(type: 'text', content: '📖 नेपाली साहित्यको परिचय!', order: 1),
            LessonContent(type: 'text', content: 'लोककथा: पुरानो समयदेखि चल्दै आएको कथा।\nजस्तै: "भालु र बाँदर", "खरायो र कछुवा"', order: 2),
            LessonContent(type: 'text', content: 'कविता: लयमा लेखिएको साहित्य।\nजस्तै: "मेरो प्यारो देश नेपाल"', order: 3),
            LessonContent(type: 'text', content: '💡 लोककथाले नैतिक शिक्षा दिन्छ!', order: 4),
          ],
          xpReward: 100,
          quiz: Quiz(
            questions: [
              Question(
                id: 'q_nep_5_lok_1',
                type: 'multiple_choice',
                question: 'लोककथा भनेको के हो?',
                options: ['नयाँ कथा', 'पुरानो चल्दै आएको कथा', 'विज्ञानको पुस्तक', 'गणितको पुस्तक'],
                correctAnswer: 'पुरानो चल्दै आएको कथा',
                explanation: 'लोककथा पुरानो समयदेखि चल्दै आएको परम्परागत कथा हो।',
              ),
              Question(
                id: 'q_nep_5_lok_2',
                type: 'multiple_choice',
                question: 'कविता कस्तो साहित्य हो?',
                options: ['गद्यमा लेखिएको', 'लयमा लेखिएको', 'नाटकको रूप', 'विज्ञानको विषय'],
                correctAnswer: 'लयमा लेखिएको',
                explanation: 'कविता लय र तालमा लेखिएको साहित्य हो।',
              ),
            ],
          ),
        ),
      );
    }

    return lessons;
  }

  // GK Lessons by Class
  static List<Lesson> _getGKLessons(int classLevel) {
    List<Lesson> lessons = [];

    // Class-specific content depth
    final isAdvanced = classLevel >= 4;

    lessons.add(
      Lesson(
        id: 'gk_nepal_${classLevel}_1',
        title: classLevel <= 2 ? 'Our Country Nepal 🇳🇵' : 'Nepal: Geography & Heritage',
        description: 'Nepal को बारेमा सिक्नुहोस् र प्रश्न गर्नुहोस्!',
        subject: Subject.GK,
        classLevel: classLevel,
        level: 1,
        category: 'Nepal Basics',
        content: [
          LessonContent(type: 'text', content: '🇳🇵 Nepal is our beautiful country in South Asia!', order: 1),
          LessonContent(
            type: 'text',
            content: classLevel <= 2
              ? 'Capital: Kathmandu ��️\nCurrency: Nepali Rupee 💰\nFlag: Two triangles 🔺🔺'
              : 'Federal Democratic Republic of Nepal\nCapital: Kathmandu\n7 Provinces, 77 Districts',
            order: 2,
          ),
          LessonContent(type: 'text', content: 'Mount Everest (8,848m) 🏔️ is the tallest peak in the world!', order: 3),
          LessonContent(
            type: 'text',
            content: isAdvanced
              ? '💡 National flower: Laligurans 🌺  National bird: Danfe 🦜\nNational animal: Cow 🐄'
              : '💡 Nepal flag is the only non-rectangular national flag in the world!',
            order: 4,
          ),
        ],
        xpReward: classLevel <= 2 ? 50 : 80,
        quiz: Quiz(
          questions: [
            Question(
              id: 'q_gk_nep_1_$classLevel',
              type: 'multiple_choice',
              question: 'What is the capital of Nepal?',
              options: ['Kathmandu', 'Pokhara', 'Lumbini', 'Janakpur'],
              correctAnswer: 'Kathmandu',
              explanation: 'Kathmandu is the capital city of Nepal.',
            ),
            Question(
              id: 'q_gk_nep_2_$classLevel',
              type: 'multiple_choice',
              question: classLevel <= 2
                ? 'What shape is Nepal\'s flag?'
                : 'How many provinces does Nepal have?',
              options: classLevel <= 2
                ? ['Rectangle', 'Two triangles', 'Circle', 'Star']
                : ['5', '6', '7', '8'],
              correctAnswer: classLevel <= 2 ? 'Two triangles' : '7',
              explanation: classLevel <= 2
                ? 'Nepal\'s flag has two triangular shapes — unique in the world!'
                : 'Nepal has 7 Provinces since the 2015 Constitution.',
            ),
            if (isAdvanced)
              Question(
                id: 'q_gk_nep_3_$classLevel',
                type: 'multiple_choice',
                question: 'What is Nepal\'s national flower?',
                options: ['Rose', 'Laligurans', 'Lotus', 'Sunflower'],
                correctAnswer: 'Laligurans',
                explanation: 'Laligurans (Rhododendron) is the national flower of Nepal.',
              ),
          ],
        ),
      ),
    );

    // Second lesson — world / science GK
    lessons.add(
      Lesson(
        id: 'gk_world_${classLevel}_1',
        title: classLevel <= 2 ? 'The World Around Us 🌍' : 'World & Science GK',
        description: 'सामान्य ज्ञान सिक्नुहोस् र प्रश्न गर्नुहोस्!',
        subject: Subject.GK,
        classLevel: classLevel,
        level: 1,
        category: 'World GK',
        content: [
          LessonContent(type: 'text', content: '🌍 Let\'s explore the world!', order: 1),
          LessonContent(
            type: 'text',
            content: classLevel <= 2
              ? 'Sun ☀️ gives us light and heat.\nMoon 🌙 shines at night.\nStars ⭐ are far away suns.'
              : 'The Solar System has 8 planets.\nEarth is the 3rd planet from the Sun.\nWater covers 71% of Earth.',
            order: 2,
          ),
          LessonContent(
            type: 'text',
            content: classLevel <= 3
              ? 'There are 7 continents and 5 oceans on Earth.'
              : 'Largest continent: Asia 🌏\nSmallest continent: Australia/Oceania\nDeepest ocean: Pacific Ocean',
            order: 3,
          ),
          LessonContent(type: 'text', content: '💡 Curiosity leads to discovery! 🔭', order: 4),
        ],
        xpReward: classLevel <= 2 ? 50 : 80,
        quiz: Quiz(
          questions: [
            Question(
              id: 'q_gk_world_1_$classLevel',
              type: 'multiple_choice',
              question: classLevel <= 2
                ? 'What gives us light and heat?'
                : 'How many planets are in our Solar System?',
              options: classLevel <= 2
                ? ['Moon', 'Star', 'Sun', 'Cloud']
                : ['7', '8', '9', '10'],
              correctAnswer: classLevel <= 2 ? 'Sun' : '8',
              explanation: classLevel <= 2
                ? 'The Sun ☀️ gives us light and heat!'
                : 'Our Solar System has 8 planets (Pluto is now a dwarf planet).',
            ),
            Question(
              id: 'q_gk_world_2_$classLevel',
              type: 'multiple_choice',
              question: 'How many continents are there on Earth?',
              options: ['5', '6', '7', '8'],
              correctAnswer: '7',
              explanation: 'Earth has 7 continents: Asia, Africa, Europe, N.America, S.America, Australia, Antarctica.',
            ),
          ],
        ),
      ),
    );

    return lessons;
  }

  // Get grammar exercises for a subject and class
  static List<GrammarExercise> getGrammarExercises(
    Subject subject,
    int classLevel,
  ) {
    switch (subject) {
      case Subject.English:
        return _getEnglishGrammarExercises(classLevel);
      case Subject.Nepali:
        return _getNepaliGrammarExercises(classLevel);
      default:
        return [];
    }
  }

  static List<GrammarExercise> _getEnglishGrammarExercises(int classLevel) {
    switch (classLevel) {
      case 1:
        return [
          GrammarExercise(
            id: 'eng_grammar_1_1',
            subject: Subject.English,
            classLevel: 1,
            sentence: 'The cat ___ on the mat.',
            answer: 'sits',
            options: ['sits', 'sit', 'sitting'],
            explanation: 'The cat sits on the mat. Cats like to rest on mats.',
          ),
          GrammarExercise(
            id: 'eng_grammar_1_2',
            subject: Subject.English,
            classLevel: 1,
            sentence: 'I ___ to school every day.',
            answer: 'go',
            options: ['go', 'goes', 'going'],
            explanation: 'I go to school every day. Present tense of "go".',
          ),
        ];
      case 2:
        return [
          GrammarExercise(
            id: 'eng_grammar_2_1',
            subject: Subject.English,
            classLevel: 2,
            sentence: 'She ___ apples to the market.',
            answer: 'takes',
            options: ['takes', 'took', 'taking'],
            explanation:
                'She takes apples to the market. Past tense of "take".',
          ),
        ];
      case 3:
        return [
          GrammarExercise(
            id: 'eng_grammar_3_1',
            subject: Subject.English,
            classLevel: 3,
            sentence: 'They ___ playing football now.',
            answer: 'are',
            options: ['are', 'is', 'am'],
            explanation:
                'They are playing football now. Present continuous tense.',
          ),
        ];
    }
    return [];
  }

  static List<GrammarExercise> _getNepaliGrammarExercises(int classLevel) {
    switch (classLevel) {
      case 1:
        return [
          GrammarExercise(
            id: 'nep_grammar_1_1',
            subject: Subject.Nepali,
            classLevel: 1,
            sentence: 'बाघले ___ खान्छ।',
            answer: 'खान्छ',
            options: ['खान्छ', 'खान्द', 'खान्छ'],
            explanation: 'बाघले खान्छ। (The tiger roars.)',
          ),
          GrammarExercise(
            id: 'nep_grammar_1_2',
            subject: Subject.Nepali,
            classLevel: 1,
            sentence: 'म ___ विद्यालयाँ जान्छ।',
            answer: 'घर',
            options: ['घर', 'गएर', 'गएँ'],
            explanation: 'म घर विद्यालयाँ जान्छ। (I go to school.)',
          ),
        ];
      case 2:
        return [
          GrammarExercise(
            id: 'nep_grammar_2_1',
            subject: Subject.Nepali,
            classLevel: 2,
            sentence: 'उसले ___ पानी खान्छ।',
            answer: 'पानी',
            options: ['पानी', 'पानो', 'पानि'],
            explanation: 'उसले पानी खान्छ। (He ate bread.)',
          ),
        ];
    }
    return [];
  }

  // Get color games for a class level
  static List<ColorGame> getColorGames(int classLevel) {
    switch (classLevel) {
      case 1:
        return [
          ColorGame(
            id: 'color_1_1',
            displayedColor: '#000000', // Black
            options: ['Black', 'Red', 'Blue', 'Green', 'Yellow'],
            difficulty: 1,
            nepalContext: 'Basic colors like Nepal flag',
          ),
          ColorGame(
            id: 'color_1_2',
            displayedColor: '#FF0000', // Red
            options: ['Red', 'Blue', 'Green', 'Yellow', 'Orange'],
            difficulty: 1,
            nepalContext: 'Like rhododendron flowers',
          ),
        ];
      case 2:
        return [
          ColorGame(
            id: 'color_2_1',
            displayedColor: '#800080', // Brown
            options: ['Brown', 'Gray', 'Pink', 'Purple'],
            difficulty: 2,
            nepalContext: 'Mountain colors',
          ),
        ];
      case 3:
        return [
          ColorGame(
            id: 'color_3_1',
            displayedColor: '#008080', // Navy
            options: ['Navy', 'Teal', 'Maroon', 'Gold'],
            difficulty: 3,
            nepalContext: 'Advanced colors',
          ),
        ];
      case 4:
        return [
          ColorGame(
            id: 'color_4_1',
            displayedColor: '#4B0082', // Indigo
            options: ['Indigo', 'Violet', 'turquoise', 'magenta'],
            difficulty: 4,
            nepalContext: 'Complex colors',
          ),
        ];
      case 5:
        return [
          ColorGame(
            id: 'color_5_1',
            displayedColor: '#2F4F4F', // Dark Gray
            options: ['Silver', 'Gold', 'Bronze', 'Copper'],
            difficulty: 5,
            nepalContext: 'Metallic colors',
          ),
        ];
    }
    return [];
  }
}
