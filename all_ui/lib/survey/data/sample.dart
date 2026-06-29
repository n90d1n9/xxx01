import '../models/option.dart';
import '../models/question.dart';
import '../models/survey.dart';

// Sample surveys for demonstration
final List<Survey> sampleSurveys = [
  Survey(
    id: '1',
    title: 'Customer Satisfaction',
    description: 'Please provide your feedback on our services',
    questions: [
      Question(
        id: '1',
        text: 'How satisfied are you with our service?',
        type: QuestionType.rating,
        required: true,
        minRating: 1,
        maxRating: 5,
      ),
      Question(
        id: '2',
        text: 'What is your age group?',
        type: QuestionType.singleChoice,
        required: true,
        options: [
          Option(id: '1', text: 'Under 18'),
          Option(id: '2', text: '18-24'),
          Option(id: '3', text: '25-34'),
          Option(id: '4', text: '35-44'),
          Option(id: '5', text: '45+'),
        ],
      ),
      Question(
        id: '3',
        text: 'Which of our products do you use?',
        type: QuestionType.multipleChoice,
        required: false,
        options: [
          Option(id: '1', text: 'Product A'),
          Option(id: '2', text: 'Product B'),
          Option(id: '3', text: 'Product C'),
          Option(id: '4', text: 'Product D'),
        ],
      ),
      Question(
        id: '4',
        text: 'Any additional comments?',
        type: QuestionType.multiLineText,
        required: false,
        hint: 'Please share your thoughts...',
        maxLength: 500,
      ),
    ],
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
  ),
  Survey(
    id: '2',
    title: 'Product Feedback',
    description: 'Help us improve our products',
    questions: [
      Question(
        id: '1',
        text: 'Which product are you reviewing?',
        type: QuestionType.singleLineText,
        required: true,
      ),
      Question(
        id: '2',
        text: 'When did you purchase the product?',
        type: QuestionType.date,
        required: true,
      ),
      Question(
        id: '3',
        text: 'Please rate the product quality',
        type: QuestionType.rating,
        required: true,
        minRating: 1,
        maxRating: 10,
      ),
      Question(
        id: '4',
        text: 'What improvements would you suggest?',
        type: QuestionType.multiLineText,
        required: false,
        maxLength: 300,
      ),
    ],
    createdAt: DateTime.now().subtract(const Duration(days: 15)),
  ),
];
