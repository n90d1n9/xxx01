import 'sample_responses.dart';
import '../models/option.dart';
import '../models/question.dart';
import '../models/question_visibility_rule.dart';
import '../models/survey.dart';
import '../models/survey_section.dart';
import '../models/survey_status.dart';

// Sample surveys for demonstration
final List<Survey> sampleSurveys = [
  Survey(
    id: '1',
    title: 'Customer Satisfaction',
    description: 'Please provide your feedback on our services',
    sections: const [
      SurveySection(
        id: 'cs-experience',
        title: 'Experience',
        description: 'Measure the visit and service experience.',
        order: 0,
      ),
      SurveySection(
        id: 'cs-profile',
        title: 'Customer Profile',
        description: 'Capture segment and product usage context.',
        order: 1,
      ),
    ],
    questions: [
      Question(
        id: '1',
        text: 'How satisfied are you with our service?',
        type: QuestionType.rating,
        required: true,
        sectionId: 'cs-experience',
        minRating: 1,
        maxRating: 5,
      ),
      Question(
        id: '2',
        text: 'What is your age group?',
        type: QuestionType.singleChoice,
        required: true,
        sectionId: 'cs-profile',
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
        sectionId: 'cs-profile',
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
        sectionId: 'cs-experience',
        hint: 'Please share your thoughts...',
        maxLength: 500,
        visibilityRules: const [
          QuestionVisibilityRule(
            sourceQuestionId: '1',
            operator: QuestionVisibilityOperator.lessThanOrEqual,
            value: 4,
          ),
        ],
      ),
    ],
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
    updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    status: SurveyStatus.collecting,
    responseCount: submittedSampleResponseCount('1'),
    targetResponses: 8,
    publishedAt: DateTime.now().subtract(const Duration(days: 20)),
    closesAt: DateTime.now().add(const Duration(days: 5)),
    ownerName: 'Survey Ops',
    assigneeNames: const ['Ari', 'Nadia', 'Raka'],
  ),
  Survey(
    id: '2',
    title: 'Product Feedback',
    description: 'Help us improve our products',
    sections: const [
      SurveySection(
        id: 'pf-context',
        title: 'Product Context',
        description: 'Identify the reviewed product and purchase timing.',
        order: 0,
      ),
      SurveySection(
        id: 'pf-evaluation',
        title: 'Evaluation',
        description: 'Capture quality rating and improvement ideas.',
        order: 1,
      ),
    ],
    questions: [
      Question(
        id: '1',
        text: 'Which product are you reviewing?',
        type: QuestionType.singleLineText,
        required: true,
        sectionId: 'pf-context',
      ),
      Question(
        id: '2',
        text: 'When did you purchase the product?',
        type: QuestionType.date,
        required: true,
        sectionId: 'pf-context',
      ),
      Question(
        id: '3',
        text: 'Please rate the product quality',
        type: QuestionType.rating,
        required: true,
        sectionId: 'pf-evaluation',
        minRating: 1,
        maxRating: 10,
      ),
      Question(
        id: '4',
        text: 'What improvements would you suggest?',
        type: QuestionType.multiLineText,
        required: false,
        sectionId: 'pf-evaluation',
        maxLength: 300,
      ),
    ],
    createdAt: DateTime.now().subtract(const Duration(days: 15)),
    updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    status: SurveyStatus.analyzing,
    responseCount: submittedSampleResponseCount('2'),
    targetResponses: 6,
    publishedAt: DateTime.now().subtract(const Duration(days: 12)),
    closesAt: DateTime.now().subtract(const Duration(days: 1)),
    ownerName: 'Product Research',
    assigneeNames: const ['Dimas', 'Maya'],
  ),
];
