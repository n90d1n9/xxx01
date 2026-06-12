import 'package:ky_survey/models/option.dart';
import 'package:ky_survey/models/question.dart';
import 'package:ky_survey/models/question_visibility_rule.dart';
import 'package:ky_survey/models/survey.dart';
import 'package:ky_survey/models/survey_response.dart';
import 'package:ky_survey/models/survey_section.dart';
import 'package:ky_survey/models/survey_status.dart';
import 'package:ky_survey/validation/question_validator.dart';
import 'package:ky_survey/validation/survey_readiness_validator.dart';
import 'package:ky_survey/validation/survey_response_validator.dart';
import 'package:test/test.dart';

void main() {
  group('SurveyResponseValidator', () {
    test('validates only questions visible to the response', () {
      final ratingQuestion = Question(
        id: 'rating',
        text: 'Rate your visit',
        type: QuestionType.rating,
        required: true,
        minRating: 1,
        maxRating: 5,
      );
      final hiddenRequiredQuestion = Question(
        id: 'follow-up',
        text: 'What should we improve?',
        type: QuestionType.multiLineText,
        required: true,
        visibilityRules: const [
          QuestionVisibilityRule(
            sourceQuestionId: 'rating',
            operator: QuestionVisibilityOperator.lessThanOrEqual,
            value: 3,
          ),
        ],
      );
      final response = SurveyResponse(
        id: 'r1',
        surveyId: 's1',
        respondentId: 'u1',
        respondentName: 'Participant',
        startedAt: DateTime(2026),
      ).upsertAnswer(questionId: 'rating', value: 5);

      final validation = SurveyResponseValidator.validate(
        questions: [ratingQuestion, hiddenRequiredQuestion],
        response: response,
      );

      expect(validation.isValid, isTrue);
      expect(validation.visibleQuestions.map((question) => question.id), [
        'rating',
      ]);
    });

    test('rejects invalid choices, text, numbers, dates, and ratings', () {
      final questions = [
        Question(
          id: 'single',
          text: 'Single choice',
          type: QuestionType.singleChoice,
          required: true,
          options: [
            Option(id: 'a', text: 'A'),
            Option(id: 'b', text: 'B'),
          ],
        ),
        Question(
          id: 'multi',
          text: 'Multiple choice',
          type: QuestionType.multipleChoice,
          required: true,
          options: [
            Option(id: 'a', text: 'A'),
            Option(id: 'b', text: 'B'),
          ],
        ),
        Question(
          id: 'text',
          text: 'Short text',
          type: QuestionType.singleLineText,
          required: true,
          maxLength: 4,
        ),
        Question(
          id: 'number',
          text: 'Amount',
          type: QuestionType.number,
          required: true,
        ),
        Question(
          id: 'date',
          text: 'Visit date',
          type: QuestionType.date,
          required: true,
        ),
        Question(
          id: 'rating',
          text: 'Score',
          type: QuestionType.rating,
          required: true,
          minRating: 1,
          maxRating: 5,
        ),
      ];
      var response = SurveyResponse(
        id: 'r2',
        surveyId: 's1',
        respondentId: 'u2',
        respondentName: 'Participant',
        startedAt: DateTime(2026),
      );
      response = response
          .upsertAnswer(questionId: 'single', value: 'z')
          .upsertAnswer(questionId: 'multi', value: ['a', 'a'])
          .upsertAnswer(questionId: 'text', value: 'too long')
          .upsertAnswer(questionId: 'number', value: 'abc')
          .upsertAnswer(questionId: 'date', value: 'not-a-date')
          .upsertAnswer(questionId: 'rating', value: 7);

      final validation = SurveyResponseValidator.validate(
        questions: questions,
        response: response,
      );

      expect(validation.isValid, isFalse);
      expect(validation.issues, hasLength(6));
      expect(
        validation.issues.map((issue) => issue.type),
        containsAll([
          SurveyResponseValidationIssueType.invalidChoice,
          SurveyResponseValidationIssueType.outOfRange,
          SurveyResponseValidationIssueType.invalidType,
        ]),
      );
      expect(
        validation.firstIssue?.message,
        'Single choice has an invalid option',
      );
      expect(
        validation.issuesForQuestion('single').single.message,
        contains('invalid option'),
      );
      expect(validation.issuesForQuestion('missing'), isEmpty);
    });
  });

  group('QuestionValidator', () {
    test('rejects choice questions with empty or duplicate options', () {
      final result = QuestionValidator.validateDraft(
        text: 'Favorite channel?',
        type: QuestionType.singleChoice,
        options: [
          Option(id: '1', text: 'WhatsApp'),
          Option(id: '2', text: ''),
          Option(id: '3', text: 'WhatsApp'),
        ],
        maxLengthText: '',
        minRatingText: '1',
        maxRatingText: '5',
      );

      expect(result.isValid, isFalse);
      expect(result.errors, contains('Option labels must be unique'));
    });

    test('rejects invalid rating ranges', () {
      final result = QuestionValidator.validateDraft(
        text: 'Rate the visit',
        type: QuestionType.rating,
        options: const [],
        maxLengthText: '',
        minRatingText: '5',
        maxRatingText: '5',
      );

      expect(result.isValid, isFalse);
      expect(result.firstError, 'Max rating must be greater than min rating');
    });
  });

  group('SurveyReadinessValidator', () {
    test('blocks collection for empty draft surveys', () {
      final survey = Survey(
        id: 'empty',
        title: 'New Survey',
        description: '',
        questions: const [],
        createdAt: DateTime(2026),
      );

      final readiness = SurveyReadinessValidator.validate(survey);

      expect(readiness.canCollect, isFalse);
      expect(readiness.blockers.map((issue) => issue.message), [
        'Add at least one question',
      ]);
      expect(SurveyReadinessValidator.nextStatuses(survey), [
        SurveyStatus.review,
      ]);
    });

    test('allows ready surveys to move toward publishing', () {
      final survey = Survey(
        id: 'ready',
        title: 'Ready Survey',
        description: 'Ready for publish',
        status: SurveyStatus.review,
        targetResponses: 20,
        createdAt: DateTime(2026),
        questions: [
          Question(
            id: 'q1',
            text: 'Rate us',
            type: QuestionType.rating,
            required: true,
            minRating: 1,
            maxRating: 5,
          ),
        ],
      );

      final readiness = SurveyReadinessValidator.validate(survey);

      expect(readiness.canCollect, isTrue);
      expect(readiness.summary, 'Ready');
      expect(SurveyReadinessValidator.nextStatuses(survey), [
        SurveyStatus.draft,
        SurveyStatus.published,
      ]);
    });

    test('detects broken choice configuration', () {
      final survey = Survey(
        id: 'broken-choice',
        title: 'Broken Choice',
        description: 'Bad options',
        createdAt: DateTime(2026),
        questions: [
          Question(
            id: 'q1',
            text: 'Pick one',
            type: QuestionType.singleChoice,
            required: true,
            options: [
              Option(id: '1', text: 'Same'),
              Option(id: '2', text: 'Same'),
            ],
          ),
        ],
      );

      final readiness = SurveyReadinessValidator.validate(survey);

      expect(readiness.canCollect, isFalse);
      expect(
        readiness.blockers.map((issue) => issue.message),
        contains('Pick one has duplicate options'),
      );
    });

    test('blocks invalid conditional visibility rules', () {
      final survey = Survey(
        id: 'bad-logic',
        title: 'Bad Logic',
        description: 'Invalid branching',
        createdAt: DateTime(2026),
        questions: [
          Question(
            id: 'q1',
            text: 'Pick one',
            type: QuestionType.singleChoice,
            required: true,
            options: [
              Option(id: 'yes', text: 'Yes'),
              Option(id: 'no', text: 'No'),
            ],
          ),
          Question(
            id: 'q2',
            text: 'Follow up',
            type: QuestionType.multiLineText,
            required: false,
            visibilityRules: const [
              QuestionVisibilityRule(
                sourceQuestionId: 'missing',
                operator: QuestionVisibilityOperator.equals,
                value: 'yes',
              ),
            ],
          ),
          Question(
            id: 'q3',
            text: 'Future dependency',
            type: QuestionType.singleLineText,
            required: false,
            visibilityRules: const [
              QuestionVisibilityRule(sourceQuestionId: 'q4'),
            ],
          ),
          Question(
            id: 'q4',
            text: 'Later question',
            type: QuestionType.singleLineText,
            required: false,
          ),
        ],
      );

      final readiness = SurveyReadinessValidator.validate(survey);
      final messages = readiness.blockers.map((issue) => issue.message);

      expect(
        messages,
        contains(
          'Follow up has a visibility rule linked to a missing question',
        ),
      );
      expect(
        messages,
        contains('Future dependency must depend on an earlier question'),
      );
    });

    test('reports invalid section structure', () {
      final survey = Survey(
        id: 'bad-sections',
        title: 'Bad Sections',
        description: 'Section issues',
        createdAt: DateTime(2026),
        sections: const [
          SurveySection(id: 's1', title: ''),
          SurveySection(id: 's2', title: 'Profile'),
          SurveySection(id: 's3', title: 'profile'),
        ],
        questions: [
          Question(
            id: 'q1',
            text: 'Name',
            type: QuestionType.singleLineText,
            required: true,
            sectionId: 'missing',
          ),
        ],
      );

      final readiness = SurveyReadinessValidator.validate(survey);
      final blockerMessages = readiness.blockers.map((issue) => issue.message);
      final warningMessages = readiness.warnings.map((issue) => issue.message);

      expect(blockerMessages, contains('Section title is required'));
      expect(warningMessages, contains('Duplicate section title: profile'));
      expect(warningMessages, contains('Name references a missing section'));
    });
  });
}
