import '../models/lesson.dart';

class MultiSubjectService {
  // Get all lessons for a specific class and subject
  static List<Lesson> getLessonsForClass(int classLevel, Subject subject) {
    switch (subject) {
      case Subject.Math:
        return _getMathLessons(classLevel);
      case Subject.English:
        return _getEnglishLessons(classLevel);
      case Subject.Nepali:
        return _getNepaliLessons(classLevel);
      case Subject.GK:
        return _getGKLessons(classLevel);
    }
  }

  // Math Lessons by Class
  static List<Lesson> _getMathLessons(int classLevel) {
    switch (classLevel) {
      case 1:
        return [
          // Learning Category
          Lesson(
            id: 'math_1_1',
            title: 'Numbers 1-10',
            description: 'Learn basic numbers with Nepal examples',
            subject: Subject.Math,
            classLevel: 1,
            level: 1,
            category: 'Learning',
            content: [
              LessonContent(
                type: 'text',
                data: {'content': 'Let\'s learn numbers 1-10! These are the building blocks of mathematics.', 'nepali': 'संख्यहरू १-१० सिक्ननुहरूलाई!'},
                order: 1,
              ),
              LessonContent(
                type: 'image',
                data: {'image': 'numbers_1_10', 'caption': 'Count the mountains: १, २, ३...'},
                order: 2,
              ),
            ],
            xpReward: 50,
            quiz: Quiz(
              questions: [
                Question(
                  id: 'q_math_1_1_1',
                  type: 'multiple_choice',
                  question: 'How many mountains are shown?',
                  options: ['1', '2', '3', '5'],
                  correctAnswer: '1',
                  explanation: 'There is 1 large mountain peak shown.',
                ),
              ]
            )
          ),
          // Fill in the Blanks Category
          Lesson(
            id: 'math_1_fb_1',
            title: 'Fill the Missing Number',
            description: 'Find the missing number in sequence',
            subject: Subject.Math,
            classLevel: 1,
            level: 1,
            category: 'Fill-in-the-Blanks',
            content: [
              LessonContent(type: 'text', data: {'content': 'Look at the sequence and find what is missing.'}, order: 1),
            ],
            xpReward: 60,
            quiz: Quiz(
              questions: [
                Question(
                  id: 'q_math_1_fb_1',
                  type: 'fill_blank',
                  question: '1, 2, ___, 4',
                  options: ['3', '5', '0', '6'],
                  correctAnswer: '3',
                  explanation: '3 comes after 2 and before 4.',
                ),
                Question(
                  id: 'q_math_1_fb_2',
                  type: 'fill_blank',
                  question: '5 + 2 = ___',
                  options: ['7', '8', '6', '9'],
                  correctAnswer: '7',
                  explanation: '5 plus 2 equals 7.',
                ),
              ]
            )
          ),
          // True/False Category
          Lesson(
            id: 'math_1_tf_1',
            title: 'Math Facts check',
            description: 'Are these math facts correct?',
            subject: Subject.Math,
            classLevel: 1,
            level: 1,
            category: 'True-False',
            content: [
              LessonContent(type: 'text', data: {'content': 'Decide if the statement is True or False.'}, order: 1),
            ],
            xpReward: 60,
            quiz: Quiz(
              questions: [
                Question(
                  id: 'q_math_1_tf_1',
                  type: 'multiple_choice',
                  question: '2 + 2 = 4',
                  options: ['True', 'False'],
                  correctAnswer: 'True',
                  explanation: 'Yes, 2 plus 2 is exactly 4.',
                ),
                Question(
                  id: 'q_math_1_tf_2',
                  type: 'multiple_choice',
                  question: '5 is smaller than 3',
                  options: ['True', 'False'],
                  correctAnswer: 'False',
                  explanation: '5 is actually larger than 3.',
                ),
              ]
            )
          ),
          // Counting Category
          Lesson(
            id: 'math_1_c_1',
            title: 'Counting Objects',
            description: 'Count how many items you see',
            subject: Subject.Math,
            classLevel: 1,
            level: 1,
            category: 'Counting',
            content: [
              LessonContent(type: 'text', data: {'content': 'Let\'s count the objects on the screen!'}, order: 1),
            ],
            xpReward: 70,
            quiz: Quiz(
              questions: [
                Question(
                  id: 'q_math_1_c_1',
                  type: 'image_identification',
                  question: 'How many apples are there?',
                  imageUrl: 'https://img.icons8.com/color/144/apple.png', 
                  options: ['1', '2', '3', '4'],
                  correctAnswer: '1',
                  explanation: 'There is only 1 apple shown.',
                ),
              ]
            )
          ),
        ];
      case 2:
        return [
          Lesson(
            id: 'math_2_1',
            title: 'Basic Addition',
            description: 'Learn addition with Nepal examples',
            subject: Subject.Math,
            classLevel: 2,
            level: 1,
            content: [
              LessonContent(
                type: 'text',
                data: {'content': 'Addition helps us combine quantities. Let\'s add mountain heights!', 'nepali': 'थपाइ सिक्ननुहरूलाई!'},
                order: 1,
              ),
            ],
            xpReward: 50,
          ),
          Lesson(
            id: 'math_2_2',
            title: 'Basic Subtraction',
            description: 'Take away numbers',
            subject: Subject.Math,
            classLevel: 2,
            level: 2,
            prerequisites: ['math_2_1'],
            content: [
              LessonContent(type: 'text', data: {'content': 'Let\'s learn subtraction!'}, order: 1),
            ],
            xpReward: 60,
          ),
        ];
      case 3:
        return [
          Lesson(
            id: 'math_3_1',
            title: 'Multiplication',
            description: 'Learn multiplication tables',
            subject: Subject.Math,
            classLevel: 3,
            level: 1,
            content: [
              LessonContent(
                type: 'text',
                data: {'content': 'Multiplication is repeated addition. Let\'s multiply like growing rhododendrons!', 'nepali': 'गुणन सिक्ननुहरूलाई!'},
                order: 1,
              ),
            ],
            xpReward: 70,
          ),
          Lesson(
            id: 'math_3_2',
            title: 'Basic Division',
            description: 'Sharing into equal groups',
            subject: Subject.Math,
            classLevel: 3,
            level: 2,
            prerequisites: ['math_3_1'],
            content: [
              LessonContent(type: 'text', data: {'content': 'Division is the opposite of multiplication!'}, order: 1),
            ],
            xpReward: 80,
          ),
        ];
      case 4:
        return [
          Lesson(
            id: 'math_4_1',
            title: 'Fractions',
            description: 'Introduction to fractions',
            subject: Subject.Math,
            classLevel: 4,
            level: 1,
            content: [
              LessonContent(
                type: 'text',
                data: {'content': 'Fractions help us share things equally, like sharing momos!', 'nepali': 'भिन्नहरू सिक्ननुहरूलाई!'},
                order: 1,
              ),
            ],
            xpReward: 80,
          ),
          Lesson(
            id: 'math_4_2',
            title: 'Decimals',
            description: 'Understanding parts of a whole',
            subject: Subject.Math,
            classLevel: 4,
            level: 2,
            prerequisites: ['math_4_1'],
            content: [
              LessonContent(type: 'text', data: {'content': 'Decimals are another way to write fractions!'}, order: 1),
            ],
            xpReward: 100,
          ),
        ];
      case 5:
        return [
          Lesson(
            id: 'math_5_1',
            title: 'Advanced Operations',
            description: 'Complex mathematical operations',
            subject: Subject.Math,
            classLevel: 5,
            level: 1,
            content: [
              LessonContent(
                type: 'text',
                data: {'content': 'Advanced math prepares us for secondary school challenges!', 'nepali': 'उन्तोत्तरिक गणित सिक्ननुहरूलाई!'},
                order: 1,
              ),
            ],
            xpReward: 100,
          ),
          Lesson(
            id: 'math_5_2',
            title: 'Geometry',
            description: 'Shapes, angles, and areas',
            subject: Subject.Math,
            classLevel: 5,
            level: 2,
            prerequisites: ['math_5_1'],
            content: [
              LessonContent(type: 'text', data: {'content': 'Welcome to the world of geometry!'}, order: 1),
            ],
            xpReward: 120,
          ),
        ];
    }
    return [];
  }

  // English Lessons by Class
  static List<Lesson> _getEnglishLessons(int classLevel) {
    switch (classLevel) {
      case 1:
        return [
          Lesson(
            id: 'english_1_1',
            title: 'Welcome to English',
            description: 'Learn the English alphabet A-Z!',
            subject: Subject.English,
            classLevel: 1,
            level: 1,
            category: 'Learning',
            content: [
              LessonContent(type: 'text', data: {'content': 'Let\'s learn the English alphabet A-Z!'}, order: 1),
            ],
            xpReward: 50,
            quiz: Quiz(
              questions: [
                Question(
                  id: 'q_eng_1_1',
                  type: 'multiple_choice',
                  question: 'Which letter comes after A?',
                  options: ['B', 'C', 'D', 'E'],
                  correctAnswer: 'B',
                  explanation: 'B comes immediately after A.',
                ),
              ]
            )
          ),
          Lesson(
            id: 'english_1_fb_1',
            title: 'Missing Letters',
            description: 'Find the missing letter in the word',
            subject: Subject.English,
            classLevel: 1,
            level: 1,
            category: 'Fill-in-the-Blanks',
            content: [
              LessonContent(type: 'text', data: {'content': 'Try to fill in the missing letters.'}, order: 1),
            ],
            xpReward: 60,
            quiz: Quiz(
              questions: [
                Question(
                  id: 'q_eng_fb_1',
                  type: 'fill_blank',
                  question: 'C ___ T',
                  options: ['A', 'E', 'I', 'O'],
                  correctAnswer: 'A',
                  explanation: 'The word is CAT.',
                ),
              ]
            )
          ),
        ];
      case 2:
        return [
          Lesson(
            id: 'english_2_1',
            title: 'Simple Sentences',
            description: 'Form basic English sentences',
            subject: Subject.English,
            classLevel: 2,
            level: 1,
            content: [
              LessonContent(
                type: 'text',
                data: {'content': 'Let\'s learn to make simple sentences!'},
                order: 1,
              ),
            ],
            xpReward: 60,
          ),
        ];
      case 3:
        return [
          Lesson(
            id: 'english_3_1',
            title: 'Grammar Basics',
            description: 'Introduction to English grammar',
            subject: Subject.English,
            classLevel: 3,
            level: 1,
            content: [
              LessonContent(
                type: 'text',
                data: {'content': 'Grammar helps us speak correctly!'},
                order: 1,
              ),
            ],
            xpReward: 70,
          ),
        ];
      case 4:
        return [
          Lesson(
            id: 'english_4_1',
            title: 'Essay Writing',
            description: 'Learn to write short essays',
            subject: Subject.English,
            classLevel: 4,
            level: 1,
            content: [
              LessonContent(
                type: 'text',
                data: {'content': 'Essay writing helps us express our ideas!'},
                order: 1,
              ),
            ],
            xpReward: 80,
          ),
        ];
      case 5:
        return [
          Lesson(
            id: 'english_5_1',
            title: 'Advanced Grammar',
            description: 'Complex English grammar rules',
            subject: Subject.English,
            classLevel: 5,
            level: 1,
            content: [
              LessonContent(
                type: 'text',
                data: {'content': 'Advanced grammar prepares us for higher studies!'},
                order: 1,
              ),
            ],
            xpReward: 100,
          ),
        ];
    }
    return [];
  }

  // Nepali Lessons by Class
  static List<Lesson> _getNepaliLessons(int classLevel) {
    switch (classLevel) {
      case 1:
        return [
          Lesson(
            id: 'nepali_1_1',
            title: 'vowels (अ, आ...)',
            description: 'Learn Nepali vowels with examples',
            subject: Subject.Nepali,
            classLevel: 1,
            level: 1,
            category: 'Learning',
            content: [
              LessonContent(type: 'text', data: {'content': 'अ, आ, इ, ई... सिक्नुहोस्।'}, order: 1),
            ],
            xpReward: 50,
            quiz: Quiz(
              questions: [
                Question(
                  id: 'q_nep_1_1',
                  type: 'multiple_choice',
                  question: 'Select the first vowel.',
                  options: ['अ', 'आ', 'इ', 'ई'],
                  correctAnswer: 'अ',
                  explanation: 'अ is the starting vowel.',
                ),
              ]
            )
          ),
          Lesson(
            id: 'nepali_1_match_1',
            title: 'Action Matching',
            description: 'Match actions to Nepali words',
            subject: Subject.Nepali,
            classLevel: 1,
            level: 1,
            category: 'Matching',
            content: [
              LessonContent(type: 'text', data: {'content': 'Can you match the action to its Nepali name?'}, order: 1),
            ],
            xpReward: 75,
            quiz: Quiz(
              questions: [
                Question(
                  id: 'q_nep_match_1',
                  type: 'translation_match',
                  question: 'Match the Actions!',
                  answerPairs: {
                    'Eat': 'खाने',
                    'Sleep': 'सुत्ने',
                    'Sit': 'बस्ने',
                    'Walk': 'हिड्ने',
                  },
                ),
              ]
            )
          ),
        ];
      case 2:
        return [
          Lesson(
            id: 'nepali_2_1',
            title: 'Simple Words',
            description: 'Basic Nepali vocabulary',
            subject: Subject.Nepali,
            classLevel: 2,
            level: 1,
            content: [
              LessonContent(
                type: 'text',
                data: {'content': 'Let\'s learn simple Nepali words!'},
                order: 1,
              ),
            ],
            xpReward: 60,
          ),
        ];
      case 3:
        return [
          Lesson(
            id: 'nepali_3_1',
            title: 'Grammar Basics',
            description: 'Introduction to Nepali grammar',
            subject: Subject.Nepali,
            classLevel: 3,
            level: 1,
            content: [
              LessonContent(
                type: 'text',
                data: {'content': 'Let\'s learn Nepali grammar rules!'},
                order: 1,
              ),
            ],
            xpReward: 70,
          ),
        ];
      case 4:
        return [
          Lesson(
            id: 'nepali_4_1',
            title: 'Essay Writing',
            description: 'Write essays in Nepali',
            subject: Subject.Nepali,
            classLevel: 4,
            level: 1,
            content: [
              LessonContent(
                type: 'text',
                data: {'content': 'Essay writing helps us express ourselves in Nepali!'},
                order: 1,
              ),
            ],
            xpReward: 80,
          ),
        ];
      case 5:
        return [
          Lesson(
            id: 'nepali_5_1',
            title: 'Advanced Grammar',
            description: 'Complex Nepali grammar',
            subject: Subject.Nepali,
            classLevel: 5,
            level: 1,
            content: [
              LessonContent(
                type: 'text',
                data: {'content': 'Advanced Nepali grammar for higher studies!'},
                order: 1,
              ),
            ],
            xpReward: 100,
          ),
        ];
    }
    return [];
  }

  // GK Lessons by Class
  static List<Lesson> _getGKLessons(int classLevel) {
    switch (classLevel) {
      case 1:
        return [
          Lesson(
            id: 'gk_1_1',
            title: 'Nepal Basics',
            description: 'Learn about Nepal\'s flag, capital, and currency',
            subject: Subject.GK,
            classLevel: 1,
            level: 1,
            content: [
              LessonContent(
                type: 'text',
                data: {'content': 'Nepal has a beautiful red and blue flag!', 'nepali': 'नेपालको सुन्दर रातो नीलो रङ्ग छ!'},
                order: 1,
              ),
              LessonContent(
                type: 'text',
                data: {'content': 'Our capital is Kathmandu!', 'nepali': 'हाम्रादुवा काठमाडु!'},
                order: 2,
              ),
              LessonContent(
                type: 'text',
                data: {'content': 'Our currency is Nepali Rupee!', 'nepali': 'नेपाली मुद्रा हो!'},
                order: 3,
              ),
            ],
            xpReward: 50,
          ),
        ];
      case 2:
        return [
          Lesson(
            id: 'gk_2_1',
            title: 'Nepal Geography',
            description: 'Learn about mountains and provinces',
            subject: Subject.GK,
            classLevel: 2,
            level: 1,
            content: [
              LessonContent(
                type: 'text',
                data: {'content': 'Nepal has 8 provinces and many mountains!', 'nepali': 'नेपालको ८ वटा र पहाडहरू!'},
                order: 1,
              ),
            ],
            xpReward: 60,
          ),
        ];
      case 3:
        return [
          Lesson(
            id: 'gk_3_1',
            title: 'Famous People',
            description: 'Learn about great Nepali personalities',
            subject: Subject.GK,
            classLevel: 3,
            level: 1,
            content: [
              LessonContent(
                type: 'text',
                data: {'content': 'Learn about famous Nepalis!', 'nepali': 'प्रसिद्त नेपालीहरूलाई!'},
                order: 1,
              ),
            ],
            xpReward: 70,
          ),
        ];
      case 4:
        return [
          Lesson(
            id: 'gk_4_1',
            title: 'Nepal Culture',
            description: 'Learn about festivals and traditions',
            subject: Subject.GK,
            classLevel: 4,
            level: 1,
            content: [
              LessonContent(
                type: 'text',
                data: {'content': 'Learn about Nepal\'s rich culture!', 'nepali': 'नेपालको सांस्कृतिक सिक्ननुहरूलाई!'},
                order: 1,
              ),
            ],
            xpReward: 80,
          ),
        ];
      case 5:
        return [
          Lesson(
            id: 'gk_5_1',
            title: 'Current Affairs',
            description: 'Learn about modern Nepal',
            subject: Subject.GK,
            classLevel: 5,
            level: 1,
            content: [
              LessonContent(
                type: 'text',
                data: {'content': 'Learn about current events in Nepal!', 'nepali': 'नेपालको वर्तमान समाचारहरूलाई!'},
                order: 1,
              ),
            ],
            xpReward: 100,
          ),
        ];
    }
    return [];
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
