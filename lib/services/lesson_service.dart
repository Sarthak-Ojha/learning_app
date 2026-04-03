import '../models/lesson.dart';

class LessonService {
  static List<Lesson> getNepalClass1Lessons() {
    return [
      Lesson(
        id: 'math_1_1',
        title: 'Numbers 1-10',
        description: 'Learn numbers from 1 to 10 with Nepali examples',
        subject: Subject.Math,
        classLevel: 1,
        level: 1,
        content: [
          LessonContent(
            type: 'text',
            content: 'Welcome to learning numbers! Let\'s start with 1 to 10.',
            nepaliTranslation: 'संख्या सिक्न स्वागत छ! हामी १ देखि १० सम्म सिक्नेछौं।',
          ),
          LessonContent(
            type: 'example',
            content: '1 - One (एक) - Like one mountain peak',
            nepaliTranslation: '१ - एक - जस्तै एउटा हिमालको चुचुरो',
          ),
          LessonContent(
            type: 'example',
            content: '2 - Two (दुई) - Like two prayer flags',
            nepaliTranslation: '२ - दुई - जस्तै दुई वटा प्रार्थना झण्डा',
          ),
          LessonContent(
            type: 'example',
            content: '3 - Three (तीन) - Like three rhododendron flowers',
            nepaliTranslation: '३ - तीन - जस्तै तीन वटा लालीगुराँस',
          ),
          LessonContent(
            type: 'example',
            content: '4 - Four (चार) - Like four directions',
            nepaliTranslation: '४ - चार - जस्तै चार दिशा',
          ),
          LessonContent(
            type: 'example',
            content: '5 - Five (पाँच) - Like five fingers',
            nepaliTranslation: '५ - पाँच - जस्तै पाँच औंला',
          ),
        ],
        quiz: Quiz(questions: [
          Question(
            id: 'q1',
            question: 'How many mountain peaks are there in the example for number 1?',
            nepaliQuestion: 'संख्या १ को उदाहरणमा कति हिमालका चुचुराहरू छन्?',
            options: ['1', '2', '3', '4'],
            correctAnswer: '1',
            explanation: 'Number 1 is represented by one mountain peak.',
          ),
          Question(
            id: 'q2',
            question: 'What is the Nepali word for number 3?',
            nepaliQuestion: 'संख्या ३ को नेपाली शब्द के हो?',
            options: ['एक', 'दुई', 'तीन', 'चार'],
            correctAnswer: 'तीन',
            explanation: 'Three is called "तीन" in Nepali.',
          ),
          Question(
            id: 'q3',
            question: 'How many fingers do we have on one hand?',
            nepaliQuestion: 'एउटा हातमा कति औंला हुन्छन्?',
            options: ['3', '4', '5', '6'],
            correctAnswer: '5',
            explanation: 'We have 5 fingers on one hand.',
          ),
        ]),
      ),
      Lesson(
        id: 'math_1_2',
        title: 'Numbers 11-20',
        description: 'Learn numbers from 11 to 20 with mountain examples',
        subject: Subject.Math,
        classLevel: 1,
        level: 2,
        content: [
          LessonContent(
            type: 'text',
            content: 'Now let\'s learn numbers from 11 to 20!',
            nepaliTranslation: 'अब हामी ११ देखि २० सम्म संख्या सिक्नेछौं!',
          ),
          LessonContent(
            type: 'example',
            content: '11 - Eleven (एघार) - Like 11 students in a class',
            nepaliTranslation: '११ - एघार - जस्तै कक्षामा ११ जना विद्यार्थी',
          ),
          LessonContent(
            type: 'example',
            content: '15 - Fifteen (पन्ध्र) - Like 15 prayer beads',
            nepaliTranslation: '१५ - पन्ध्र - जस्तै १५ वटा माला',
          ),
          LessonContent(
            type: 'example',
            content: '20 - Twenty (बीस) - Like 20 rupees note',
            nepaliTranslation: '२० - बीस - जस्तै २० रुपैयाँको नोट',
          ),
        ],
        quiz: Quiz(questions: [
          Question(
            id: 'q1',
            question: 'What is the Nepali word for number 15?',
            nepaliQuestion: 'संख्या १५ को नेपाली शब्द के हो?',
            options: ['एघार', 'बाह्र', 'पन्ध्र', 'बीस'],
            correctAnswer: 'पन्ध्र',
            explanation: 'Fifteen is called "पन्ध्र" in Nepali.',
          ),
          Question(
            id: 'q2',
            question: 'Which currency note represents number 20?',
            nepaliQuestion: 'कुन मुद्रा नोटले संख्या २० लाई प्रतिनिधित्व गर्छ?',
            options: ['१० रुपैयाँ', '२० रुपैयाँ', '५० रुपैयाँ', '१०० रुपैयाँ'],
            correctAnswer: '२० रुपैयाँ',
            explanation: 'The 20 rupees note represents number 20.',
          ),
        ]),
      ),
      Lesson(
        id: 'math_1_3',
        title: 'Basic Addition',
        description: 'Learn simple addition with Nepal examples',
        subject: Subject.Math,
        classLevel: 1,
        level: 3,
        content: [
          LessonContent(
            type: 'text',
            content: 'Let\'s learn addition! Adding numbers together.',
            nepaliTranslation: 'गणित सिक्नेछौं! संख्याहरूलाई एकसाथ थप्ने।',
          ),
          LessonContent(
            type: 'example',
            content: '1 + 1 = 2',
            nepaliTranslation: '१ + १ = २ - एउटा हिमाल + एउटा हिमाल = दुई हिमाल',
          ),
          LessonContent(
            type: 'example',
            content: '2 + 3 = 5',
            nepaliTranslation: '२ + ३ = ५ - दुई फूल + तीन फूल = पाँच फूल',
          ),
          LessonContent(
            type: 'example',
            content: '5 + 5 = 10',
            nepaliTranslation: '५ + ५ = १० - पाँच औंला + पाँच औंला = दश औंला',
          ),
        ],
        quiz: Quiz(questions: [
          Question(
            id: 'q1',
            question: 'What is 1 + 1?',
            nepaliQuestion: '१ + १ कति हुन्छ?',
            options: ['1', '2', '3', '4'],
            correctAnswer: '2',
            explanation: '1 + 1 = 2. One plus one equals two.',
          ),
          Question(
            id: 'q2',
            question: 'What is 2 + 3?',
            nepaliQuestion: '२ + ३ कति हुन्छ?',
            options: ['4', '5', '6', '7'],
            correctAnswer: '5',
            explanation: '2 + 3 = 5. Two plus three equals five.',
          ),
          Question(
            id: 'q3',
            question: 'If you have 5 rupees and get 5 more, how much do you have?',
            nepaliQuestion: 'यदि तिमीसँग ५ रुपैयाँ छ र तिमीलाई ५ और भयो भने, तिमीसँग कति हुन्छ?',
            options: ['8', '9', '10', '11'],
            correctAnswer: '10',
            explanation: '5 + 5 = 10. You would have 10 rupees.',
          ),
        ]),
      ),
    ];
  }
}
