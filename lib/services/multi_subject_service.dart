import '../models/lesson.dart';

class MultiSubjectService {
  // Get all lessons for a specific class and subject
  static List<Lesson> getLessonsForClass(int classLevel, Subject subject) {
    List<Lesson> rawLessons;
    switch (subject) {
      case Subject.Math:
        rawLessons = _getMathLessons(classLevel); break;
      case Subject.English:
        rawLessons = _getEnglishLessons(classLevel); break;
      case Subject.Nepali:
        rawLessons = _getNepaliLessons(classLevel); break;
      case Subject.GK:
        rawLessons = _getGKLessons(classLevel); break;
    }
    return _enforceThreeLevels(rawLessons, classLevel, subject);
  }

  static List<Lesson> _enforceThreeLevels(List<Lesson> lessons, int classLevel, Subject subject) {
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

        String generatedId = '${subject.name.toLowerCase()}_${classLevel}_${category.toLowerCase().replaceAll(' ', '_')}_$i';

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
                : [LessonContent(type: 'text', content: 'Keep exploring $category!')],
            prerequisites: previousNodeId != null ? [previousNodeId] : [],
            isLocked: isLocked,
            xpReward: 50 * i,
            quiz: !isLearnNode
                ? Quiz(questions: [
                    Question(
                      id: 'q_$generatedId',
                      type: 'multiple_choice',
                      question: 'What did you learn in $category?',
                      options: ['A lot!', 'Something', 'Not much', 'Everything'],
                      correctAnswer: 'A lot!',
                    )
                  ])
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
            LessonContent(type: 'text', content: '🔢 Let\'s learn numbers from 1 to 10!', order: 1),
            LessonContent(type: 'text', content: '1 = One (एक)\n2 = Two (दुई)\n3 = Three (तीन)\n4 = Four (चार)\n5 = Five (पाँच)', order: 2),
            LessonContent(type: 'text', content: '6 = Six (छ)\n7 = Seven (सात)\n8 = Eight (आठ)\n9 = Nine (नौ)\n10 = Ten (दश)', order: 3),
            LessonContent(type: 'text', content: '💡 Tip: Use your fingers to count!\n\nHold up 3 fingers → that is 3.\nHold up 7 fingers → that is 7.', order: 4),
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
                explanation: 'Count them one by one: 1, 2, 3. There are 3 stars!',
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
            ]
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
            LessonContent(type: 'text', content: '➕ Addition means joining things together to find the total!', order: 1),
            LessonContent(type: 'text', content: 'Example:\n🍎 + 🍎 = 2 apples\n\n1 + 1 = 2', order: 2),
            LessonContent(type: 'text', content: 'We use the "+" sign to add.\nWe use the "=" sign for the answer.\n\nExample: 2 + 3 = 5', order: 3),
            LessonContent(type: 'text', content: '📝 Practice:\n1 + 1 = 2\n2 + 1 = 3\n3 + 2 = 5\n4 + 1 = 5', order: 4),
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
                explanation: '2 + 2 = 4. Hold 2 fingers, then 2 more = 4 fingers!',
              ),
              Question(
                id: 'q_math_1_add_3',
                type: 'multiple_choice',
                question: '3 + 1 = ?',
                options: ['2', '3', '4', '5'],
                correctAnswer: '4',
                explanation: '3 + 1 = 4.',
              ),
            ]
          ),
        ),
      ]);
    } else if (classLevel == 2) {
      lessons.addAll([
        Lesson(
          id: 'math_2_placevalue_1',
          title: 'Place Value: Tens and Ones',
          description: 'Learn about Tens and Ones',
          subject: Subject.Math,
          classLevel: 2,
          level: 1,
          category: 'Numbers',
          content: [
            LessonContent(type: 'text', content: 'Every number is made of Tens and Ones.', order: 1),
            LessonContent(type: 'text', content: 'Example: The number 15\n→ 1 Ten and 5 Ones', order: 2),
            LessonContent(type: 'text', content: 'Example: The number 24\n→ 2 Tens and 4 Ones', order: 3),
            LessonContent(type: 'text', content: 'Think of Tens as a bundle of 10 sticks!', order: 4),
          ],
          xpReward: 40,
        ),
        Lesson(
          id: 'math_2_placevalue_2',
          title: 'Place Value Quiz',
          description: 'Test your place value skills',
          subject: Subject.Math,
          classLevel: 2,
          level: 2,
          category: 'Numbers',
          content: [LessonContent(type: 'text', content: 'How many Tens and Ones?', order: 1)],
          xpReward: 60,
          quiz: Quiz(
            questions: [
              Question(
                id: 'q_math_2_pv_1',
                type: 'multiple_choice',
                question: 'In the number 24, how many Tens are there?',
                options: ['2', '4', '20', '6'],
                correctAnswer: '2',
                explanation: '24 = 2 Tens + 4 Ones.',
              ),
              Question(
                id: 'q_math_2_pv_2',
                type: 'multiple_choice',
                question: 'In the number 37, how many Ones are there?',
                options: ['3', '7', '37', '10'],
                correctAnswer: '7',
                explanation: '37 = 3 Tens + 7 Ones.',
              ),
            ]
          )
        ),
        Lesson(
          id: 'math_2_addition_1',
          title: 'Two-Digit Addition',
          description: 'Adding numbers up to 99',
          subject: Subject.Math,
          classLevel: 2,
          level: 1,
          category: 'Addition',
          content: [
            LessonContent(type: 'text', content: 'Now we add bigger numbers!', order: 1),
            LessonContent(type: 'text', content: 'Add the Ones first, then the Tens.\n\nExample: 12 + 21\nOnes: 2 + 1 = 3\nTens: 1 + 2 = 3\nAnswer: 33', order: 2),
            LessonContent(type: 'text', content: 'Practice: 14 + 25 = 39', order: 3),
          ],
          xpReward: 50,
        ),
      ]);
    } else if (classLevel == 5) {
      lessons.addAll([
        Lesson(
          id: 'math_5_fractions_1',
          title: 'Introduction to Fractions',
          description: 'Learn about numerator and denominator',
          subject: Subject.Math,
          classLevel: 5,
          level: 1,
          category: 'Fractions',
          content: [
            LessonContent(type: 'text', content: 'A fraction shows a part of a whole.', order: 1),
            LessonContent(type: 'text', content: 'A fraction looks like this: 1/2\n\nNumerator (top) = parts we have\nDenominator (bottom) = total parts', order: 2),
            LessonContent(type: 'text', content: 'Example: A pizza cut into 4 slices.\nIf you eat 1 slice, you ate 1/4 of the pizza.', order: 3),
            LessonContent(type: 'text', content: 'Common fractions:\n1/2 = Half\n1/4 = Quarter\n3/4 = Three quarters', order: 4),
          ],
          xpReward: 100,
        ),
        Lesson(
          id: 'math_5_fractions_2',
          title: 'Fraction Quiz',
          description: 'Test your understanding of fractions',
          subject: Subject.Math,
          classLevel: 5,
          level: 2,
          category: 'Fractions',
          content: [LessonContent(type: 'text', content: 'Identify the parts of a fraction!', order: 1)],
          xpReward: 120,
          quiz: Quiz(
            questions: [
              Question(
                id: 'q_math_5_frac_1',
                type: 'multiple_choice',
                question: 'In the fraction 3/4, what is the numerator?',
                options: ['3', '4', '7', '1'],
                correctAnswer: '3',
                explanation: 'The numerator is the TOP number. Here it is 3.',
              ),
              Question(
                id: 'q_math_5_frac_2',
                type: 'multiple_choice',
                question: 'What fraction means "half"?',
                options: ['1/4', '2/3', '1/2', '3/4'],
                correctAnswer: '1/2',
                explanation: '1/2 means one part out of two equal parts = half.',
              ),
            ]
          )
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
            LessonContent(type: 'text', content: 'Algebra uses letters to stand for unknown numbers!', order: 1),
            LessonContent(type: 'text', content: 'A variable is a letter whose value we don\'t know.\nExample: x, y, z', order: 2),
            LessonContent(type: 'text', content: 'A constant is a fixed number.\nExample: 5, 10, or 100 never change.', order: 3),
            LessonContent(type: 'text', content: 'Solving an equation:\nIf x + 2 = 5\nThen x = 5 - 2 = 3 ✓', order: 4),
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
          content: [LessonContent(type: 'text', content: 'Find the value of the variable!', order: 1)],
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
                explanation: 'x is a letter (variable). Numbers like 5 or 100 are constants.',
              ),
            ]
          )
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
            LessonContent(type: 'text', content: 'Welcome to Class $classLevel Mathematics!', order: 1),
            LessonContent(type: 'text', content: 'In this class you will learn:\n• Number operations\n• Geometry\n• Measurement\n• Problem solving', order: 2),
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
      // Alphabets: Learn letters + quiz in one level
      lessons.add(Lesson(
        id: 'eng_alphabets_1_1',
        title: 'Alphabets A to E',
        description: 'Learn letter sounds then complete the task to earn XP!',
        subject: Subject.English,
        classLevel: 1,
        level: 1,
        category: 'Alphabets',
        content: [
          LessonContent(type: 'text', content: '🔤 Every letter has a sound. Let\'s learn A to E!', order: 1),
          LessonContent(type: 'text', content: 'A says "Ah" → Apple 🍎\nB says "Buh" → Ball ⚽\nC says "Cuh" → Cat 🐱', order: 2),
          LessonContent(type: 'text', content: 'D says "Duh" → Dog 🐶\nE says "Eh" → Egg 🥚', order: 3),
          LessonContent(type: 'text', content: '💡 Repeat aloud:\nA, B, C, D, E!\nA... B... C... D... E...', order: 4),
        ],
        xpReward: 40,
        quiz: Quiz(questions: [
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
          Question(
            id: 'q_eng_1_alpha_3',
            type: 'multiple_choice',
            question: 'B is for ___?',
            options: ['Apple', 'Cat', 'Ball', 'Egg'],
            correctAnswer: 'Ball',
            explanation: 'B says "Buh" like in Ball!',
          ),
        ]),
      ));

      // Grammar: Simple words - Learn + quiz
      lessons.add(Lesson(
        id: 'eng_words_1_1',
        title: 'Simple 3-Letter Words',
        description: 'Build words and complete the task to earn XP!',
        subject: Subject.English,
        classLevel: 1,
        level: 1,
        category: 'Grammar',
        content: [
          LessonContent(type: 'text', content: '📝 Let\'s build short words!', order: 1),
          LessonContent(type: 'text', content: 'C + A + T = CAT 🐱\nB + A + T = BAT 🏏\nM + A + T = MAT 🪆', order: 2),
          LessonContent(type: 'text', content: 'D + O + G = DOG 🐶\nC + U + P = CUP ☕', order: 3),
          LessonContent(type: 'text', content: '💡 CAT, BAT, MAT all rhyme!\nThey all end with "-AT"', order: 4),
        ],
        xpReward: 50,
        quiz: Quiz(questions: [
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
          Question(
            id: 'q_eng_1_word_3',
            type: 'fill_blank',
            question: 'D + O + G = ___',
            options: ['CAT', 'DOG', 'BAT', 'CUP'],
            correctAnswer: 'DOG',
            explanation: 'D + O + G = DOG 🐶',
          ),
        ]),
      ));
    } else if (classLevel == 2) {
      lessons.addAll([
        Lesson(
          id: 'eng_phonics_2_1',
          title: 'Letter Sounds (A-M)',
          description: 'Learn letter sounds then complete the task!',
          subject: Subject.English,
          classLevel: 2,
          level: 1,
          category: 'Alphabets',
          content: [
            LessonContent(type: 'text', content: 'Let\'s review letter sounds A to M!', order: 1),
            LessonContent(type: 'text', content: 'A-Apple, B-Ball, C-Cat, D-Dog, E-Egg', order: 2),
            LessonContent(type: 'text', content: 'F-Fish, G-Goat, H-Hat, I-Ink, J-Jar', order: 3),
            LessonContent(type: 'text', content: 'K-Kite, L-Lion, M-Mango', order: 4),
          ],
          xpReward: 40,
          quiz: Quiz(questions: [
            Question(
              id: 'q_eng_2_alpha_1',
              type: 'multiple_choice',
              question: 'F is for ___?',
              options: ['Goat', 'Fish', 'Hat', 'Ink'],
              correctAnswer: 'Fish',
              explanation: 'F is for Fish 🐟',
            ),
          ]),
        ),
        Lesson(
          id: 'eng_words_2_1',
          title: 'Three Letter Words',
          description: 'Learn and practise CVC words',
          subject: Subject.English,
          classLevel: 2,
          level: 1,
          category: 'Grammar',
          content: [
            LessonContent(type: 'text', content: 'Let\'s build words!', order: 1),
            LessonContent(type: 'text', content: 'C + A + T = CAT\nB + A + T = BAT\nM + A + T = MAT', order: 2),
            LessonContent(type: 'text', content: 'CAT, BAT, MAT all rhyme! They end with -AT.', order: 3),
          ],
          xpReward: 40,
          quiz: Quiz(questions: [
            Question(
              id: 'q_eng_2_word_1',
              type: 'multiple_choice',
              question: 'Which word rhymes with CAT?',
              options: ['DOG', 'CUP', 'BAT', 'EGG'],
              correctAnswer: 'BAT',
              explanation: 'CAT and BAT both end with -AT!',
            ),
          ]),
        ),
      ]);
    } else if (classLevel == 5 || classLevel == 6) {
      lessons.addAll([
        Lesson(
          id: 'eng_grammar_${classLevel}_1',
          title: 'Nouns and Verbs',
          description: 'Learn parts of speech then complete the task!',
          subject: Subject.English,
          classLevel: classLevel,
          level: 1,
          category: 'Grammar',
          content: [
            LessonContent(type: 'text', content: 'Nouns are naming words.\nExample: Dog, Kathmandu, Joy', order: 1),
            LessonContent(type: 'text', content: 'Verbs are action words.\nExample: Run, Sleep, Play', order: 2),
            LessonContent(type: 'text', content: 'Every sentence needs a verb!', order: 3),
          ],
          xpReward: 80,
          quiz: Quiz(questions: [
            Question(
              id: 'q_eng_gv_1_$classLevel',
              type: 'multiple_choice',
              question: 'Which word is a Verb (Action)?',
              options: ['Apple', 'Jump', 'Smart', 'Table'],
              correctAnswer: 'Jump',
              explanation: '"Jump" is an action — you can do it!',
            ),
            Question(
              id: 'q_eng_gv_2_$classLevel',
              type: 'multiple_choice',
              question: 'Which word is a Noun (Name)?',
              options: ['Run', 'Fast', 'Kathmandu', 'Jump'],
              correctAnswer: 'Kathmandu',
              explanation: 'Kathmandu is a place — a naming word (Noun).',
            ),
          ]),
        ),
        Lesson(
          id: 'eng_writing_${classLevel}_1',
          title: 'Sentence Structure (SVO)',
          description: 'Build sentences then complete the task!',
          subject: Subject.English,
          classLevel: classLevel,
          level: 1,
          category: 'Alphabets',
          content: [
            LessonContent(type: 'text', content: 'A sentence follows S → V → O order.', order: 1),
            LessonContent(type: 'text', content: 'Subject: Who? (The boy)\nVerb: Does what? (eats)\nObject: What? (an apple)', order: 2),
            LessonContent(type: 'text', content: '✅ "The boy eats an apple."\nSubject=boy, Verb=eats, Object=apple', order: 3),
          ],
          xpReward: 90,
          quiz: Quiz(questions: [
            Question(
              id: 'q_eng_svo_1_$classLevel',
              type: 'multiple_choice',
              question: 'In "The girl reads a book", what is the Verb?',
              options: ['girl', 'reads', 'book', 'the'],
              correctAnswer: 'reads',
              explanation: '"reads" is the action (Verb) in this sentence.',
            ),
          ]),
        ),
      ]);
    }

    if (lessons.isEmpty) {
      lessons.add(Lesson(
        id: 'english_${classLevel}_gen_1',
        title: 'Class $classLevel English',
        description: 'Read and complete the task to earn XP!',
        subject: Subject.English,
        classLevel: classLevel,
        level: 1,
        category: 'Grammar',
        content: [
          LessonContent(type: 'text', content: 'Welcome to Class $classLevel English!', order: 1),
          LessonContent(type: 'text', content: 'We will learn to read, write and speak in English.', order: 2),
        ],
        xpReward: 50,
      ));
    }

    return lessons;
  }

  // Nepali Lessons by Class
  static List<Lesson> _getNepaliLessons(int classLevel) {
    List<Lesson> lessons = [];

    if (classLevel == 1) {
      // Barnamala: Vowels - Learn + Quiz in one level
      lessons.add(Lesson(
        id: 'nep_barnamala_1_1',
        title: 'Nepali Vowels (स्वर)',
        description: 'Learn vowels then complete the task to earn XP!',
        subject: Subject.Nepali,
        classLevel: 1,
        level: 1,
        category: 'Barnamala',
        content: [
          LessonContent(type: 'text', content: '🔤 Let\'s learn Nepali Vowels (स्वर वर्णमाला)!', order: 1),
          LessonContent(type: 'text', content: 'अ → Aa (like in Apple)\nआ → Aa (like in Father)\nइ → I (like in Ink)', order: 2),
          LessonContent(type: 'text', content: 'ई → Ee (like in Eat)\nउ → U (like in Up)\nऊ → Oo (like in Food)', order: 3),
          LessonContent(type: 'text', content: '💡 Practice saying aloud:\nअ, आ, इ, ई, उ, ऊ...', order: 4),
        ],
        xpReward: 40,
        quiz: Quiz(questions: [
          Question(
            id: 'q_nep_1_barna_1',
            type: 'multiple_choice',
            question: 'Which is the Nepali vowel for "Aa"?',
            options: ['अ', 'आ', 'इ', 'ई'],
            correctAnswer: 'आ',
            explanation: 'आ makes the long "Aa" sound like in Father.',
          ),
          Question(
            id: 'q_nep_1_barna_2',
            type: 'multiple_choice',
            question: 'How many vowels did we learn today?',
            options: ['4', '5', '6', '7'],
            correctAnswer: '6',
            explanation: 'We learned: अ, आ, इ, ई, उ, ऊ — that is 6 vowels!',
          ),
          Question(
            id: 'q_nep_1_barna_3',
            type: 'multiple_choice',
            question: 'What is the FIRST vowel in Nepali?',
            options: ['इ', 'आ', 'अ', 'ई'],
            correctAnswer: 'अ',
            explanation: 'अ is the very first vowel in Nepali!',
          ),
        ]),
      ));

      // Numbers - Learn + Quiz
      lessons.add(Lesson(
        id: 'nep_numbers_1_1',
        title: 'Nepali Numbers (१-५)',
        description: 'Learn to count in Nepali then complete the task!',
        subject: Subject.Nepali,
        classLevel: 1,
        level: 1,
        category: 'Numbers',
        content: [
          LessonContent(type: 'text', content: '🔢 Let\'s count in Nepali!', order: 1),
          LessonContent(type: 'text', content: '१ = One (एक)\n२ = Two (दुई)\n३ = Three (तीन)', order: 2),
          LessonContent(type: 'text', content: '४ = Four (चार)\n५ = Five (पाँच)', order: 3),
          LessonContent(type: 'text', content: '💡 Practice:\nएक, दुई, तीन, चार, पाँच!', order: 4),
        ],
        xpReward: 40,
        quiz: Quiz(questions: [
          Question(
            id: 'q_nep_1_num_1',
            type: 'multiple_choice',
            question: 'What is "3" in Nepali numbers?',
            options: ['१', '२', '३', '४'],
            correctAnswer: '३',
            explanation: '३ represents Three (तीन) in Nepali.',
          ),
          Question(
            id: 'q_nep_1_num_2',
            type: 'multiple_choice',
            question: 'What is "पाँच" in English?',
            options: ['Three', 'Four', 'Five', 'Two'],
            correctAnswer: 'Five',
            explanation: 'पाँच = Five = ५',
          ),
          Question(
            id: 'q_nep_1_num_3',
            type: 'fill_blank',
            question: 'एक, दुई, ___, चार, पाँच',
            options: ['दुई', 'तीन', 'छ', 'सात'],
            correctAnswer: 'तीन',
            explanation: 'The order is एक, दुई, तीन, चार, पाँच.',
          ),
        ]),
      ));

      // Flashcards - Learn + Quiz
      lessons.add(Lesson(
        id: 'nep_flash_1_1',
        title: 'Animal Names in Nepali',
        description: 'Learn animal names then complete the task!',
        subject: Subject.Nepali,
        classLevel: 1,
        level: 1,
        category: 'Flashcards',
        content: [
          LessonContent(type: 'text', content: '🐾 Let\'s learn animal names in Nepali!', order: 1),
          LessonContent(type: 'text', content: 'Lion = सिंह (Singha)\nElephant = हात्ती (Hatti)\nCow = गाई (Gai)', order: 2),
          LessonContent(type: 'text', content: 'Dog = कुकुर (Kukur)\nCat = बिरालो (Biralo)\nBird = चरा (Chara)', order: 3),
          LessonContent(type: 'text', content: '💡 Say them aloud:\nसिंह, हात्ती, गाई, कुकुर, बिरालो!', order: 4),
        ],
        xpReward: 40,
        quiz: Quiz(questions: [
          Question(
            id: 'q_nep_1_flash_1',
            type: 'translation_match',
            question: 'Match the animals to their Nepali names!',
            answerPairs: {
              'Lion': 'सिंह',
              'Cow': 'गाई',
              'Dog': 'कुकुर',
              'Cat': 'बिरालो',
            },
          ),
        ]),
      ));
    } else if (classLevel == 2) {
      lessons.addAll([
        Lesson(
          id: 'nep_barnamala_2_1',
          title: 'Nepali Consonants (क-ङ)',
          description: 'Learn consonants then complete the task!',
          subject: Subject.Nepali,
          classLevel: 2,
          level: 1,
          category: 'Barnamala',
          content: [
            LessonContent(type: 'text', content: 'Now let\'s learn the consonants (व्यञ्जन)!', order: 1),
            LessonContent(type: 'text', content: 'क - Ka (कपाल: Kapal)\nख - Kha (खरायो: Kharayo)\nग - Ga (गाई: Gai)', order: 2),
            LessonContent(type: 'text', content: 'घ - Gha (घर: Ghar)\nङ - Nga', order: 3),
          ],
          xpReward: 40,
          quiz: Quiz(questions: [
            Question(
              id: 'q_nep_2_barna_1',
              type: 'multiple_choice',
              question: 'Which letter spells "Ka"?',
              options: ['ख', 'क', 'ग', 'घ'],
              correctAnswer: 'क',
              explanation: 'क is pronounced "Ka"!',
            ),
          ]),
        ),
        Lesson(
          id: 'nep_numbers_2_1',
          title: 'Nepali Numbers (१-१०)',
          description: 'Learn and quiz on numbers 1-10',
          subject: Subject.Nepali,
          classLevel: 2,
          level: 1,
          category: 'Numbers',
          content: [
            LessonContent(type: 'text', content: 'Counting in Nepali up to 10!', order: 1),
            LessonContent(type: 'text', content: '१-One, २-Two, ३-Three, ४-Four, ५-Five', order: 2),
            LessonContent(type: 'text', content: '६-Six, ७-Seven, ८-Eight, ९-Nine, १०-Ten', order: 3),
          ],
          xpReward: 40,
          quiz: Quiz(questions: [
            Question(
              id: 'q_nep_2_num_1',
              type: 'multiple_choice',
              question: 'What is "10" in Nepali?',
              options: ['९', '१०', '८', '७'],
              correctAnswer: '१०',
              explanation: '१० = Ten (दश)',
            ),
          ]),
        ),
        Lesson(
          id: 'nepali_2_barakhari_1',
          title: 'Barakhari (का, कि, की)',
          description: 'Learn how vowels change consonants then quiz!',
          subject: Subject.Nepali,
          classLevel: 2,
          level: 1,
          category: 'Barakhari',
          content: [
            LessonContent(type: 'text', content: 'Barakhari: Adding vowels to consonants changes their sound!', order: 1),
            LessonContent(type: 'text', content: 'क + आ = का (Kaa)\nक + इ = कि (Ki)\nक + ई = की (Kee)', order: 2),
            LessonContent(type: 'text', content: 'क + उ = कु (Ku)\nक + ऊ = कू (Koo)', order: 3),
          ],
          xpReward: 50,
          quiz: Quiz(questions: [
            Question(
              id: 'q_nep_2_bara_1',
              type: 'multiple_choice',
              question: 'क + आ = ?',
              options: ['कि', 'का', 'की', 'कु'],
              correctAnswer: 'का',
              explanation: 'क + आ = का (Kaa)',
            ),
          ]),
        ),
      ]);
    } else if (classLevel >= 3) {
      lessons.add(Lesson(
        id: 'nepali_${classLevel}_byakaran_1',
        title: 'Nepali Grammar (Byakaran)',
        description: 'Learn grammar and complete the task!',
        subject: Subject.Nepali,
        classLevel: classLevel,
        level: 1,
        category: 'Byakaran',
        content: [
          LessonContent(type: 'text', content: 'Byakaran means Grammar in Nepali.', order: 1),
          LessonContent(type: 'text', content: 'नाम (Noun): Person, Place or Thing.\nसर्वनाम (Pronoun): He, She, It.', order: 2),
          LessonContent(type: 'text', content: 'क्रियापद (Verb): Action word.\nExample: दौड्नु (to run), खानु (to eat)', order: 3),
        ],
        xpReward: 80,
        quiz: Quiz(questions: [
          Question(
            id: 'q_nep_bya_1_$classLevel',
            type: 'multiple_choice',
            question: 'What is "नाम" in English?',
            options: ['Verb', 'Noun', 'Pronoun', 'Adjective'],
            correctAnswer: 'Noun',
            explanation: 'नाम = Noun (naming word)',
          ),
        ]),
      ));
    }

    return lessons;
  }

  // GK Lessons by Class
  static List<Lesson> _getGKLessons(int classLevel) {
    List<Lesson> lessons = [];
    
    lessons.addAll([
      Lesson(
        id: 'gk_${classLevel}_nepal_1',
        title: 'About Nepal',
        description: 'Learn about our beautiful country',
        subject: Subject.GK,
        classLevel: classLevel,
        level: 1,
        category: 'Nepal Basics',
        content: [
          LessonContent(type: 'text', content: 'Nepal is a beautiful country in South Asia!', order: 1),
          LessonContent(type: 'text', content: 'Capital: Kathmandu\nCurrency: Nepali Rupee\nLanguage: Nepali', order: 2),
          LessonContent(type: 'text', content: 'Mount Everest (8,848m) is the tallest mountain in the world — it is in Nepal!', order: 3),
          LessonContent(type: 'text', content: 'Nepal has 7 provinces and 77 districts.', order: 4),
        ],
        xpReward: 30,
      ),
      Lesson(
        id: 'gk_${classLevel}_nepal_2',
        title: 'Nepal Quiz',
        description: 'Test your knowledge about Nepal',
        subject: Subject.GK,
        classLevel: classLevel,
        level: 2,
        category: 'Nepal Basics',
        content: [LessonContent(type: 'text', content: 'Let\'s see what you learned about Nepal!', order: 1)],
        xpReward: 50,
        quiz: Quiz(
          questions: [
            Question(
              id: 'q_gk_nepal_1_${classLevel}',
              type: 'multiple_choice',
              question: 'What is the capital of Nepal?',
              options: ['Kathmandu', 'Pokhara', 'Lalitpur', 'Bhaktapur'],
              correctAnswer: 'Kathmandu',
              explanation: 'Kathmandu is the capital and largest city of Nepal.',
            ),
            Question(
              id: 'q_gk_nepal_2_${classLevel}',
              type: 'multiple_choice',
              question: 'Which is the tallest mountain in the world?',
              options: ['K2', 'Annapurna', 'Mount Everest', 'Lhotse'],
              correctAnswer: 'Mount Everest',
              explanation: 'Mount Everest at 8,848m is the highest peak on Earth, located in Nepal.',
            ),
          ]
        )
      ),
    ]);

    return lessons;
  }

  // Get grammar exercises for a subject and class
  static List<GrammarExercise> getGrammarExercises(Subject subject, int classLevel) {
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
            explanation: 'She takes apples to the market. Past tense of "take".',
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
            explanation: 'They are playing football now. Present continuous tense.',
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
