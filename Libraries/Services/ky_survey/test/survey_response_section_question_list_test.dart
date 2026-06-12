import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_survey/logic/survey_response_section_flow.dart';
import 'package:ky_survey/models/question.dart';
import 'package:ky_survey/models/survey.dart';
import 'package:ky_survey/models/survey_response.dart';
import 'package:ky_survey/models/survey_section.dart';
import 'package:ky_survey/validation/survey_response_validator.dart';
import 'package:ky_survey/widgets/survey_response_section_question_list.dart';

void main() {
  group('SurveyResponseSectionQuestionList', () {
    testWidgets('renders statuses, focuses a question, and forwards edits', (
      tester,
    ) async {
      final fixture = _sectionFixture();
      String? changedQuestionId;
      dynamic changedValue;

      await tester.pumpWidget(
        _listHarness(
          SurveyResponseSectionQuestionList(
            page: fixture.status.page,
            status: fixture.status,
            valueForQuestion: fixture.response.valueFor,
            issuesForQuestion: fixture.validation.issuesForQuestion,
            onAnswerChanged: (question, value) {
              changedQuestionId = question.id;
              changedValue = value;
            },
          ),
        ),
      );

      expect(find.text('Visit'), findsOneWidget);
      expect(find.text('Question status'), findsOneWidget);
      expect(find.text('Q1 Answered'), findsOneWidget);
      expect(find.text('Q2 Invalid'), findsOneWidget);
      expect(find.text('Q3 Missing'), findsOneWidget);

      await tester.tap(find.text('Q3 Missing'));
      await tester.pumpAndSettle();

      expect(find.text('Focused'), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, 'Updated store');
      await tester.pump();

      expect(changedQuestionId, 'name');
      expect(changedValue, 'Updated store');
    });

    testWidgets('focuses an externally requested question', (tester) async {
      final fixture = _sectionFixture();

      await tester.pumpWidget(
        _listHarness(
          SurveyResponseSectionQuestionList(
            page: fixture.status.page,
            status: fixture.status,
            focusedQuestionId: 'visitors',
            focusRequestKey: 1,
            valueForQuestion: fixture.response.valueFor,
            issuesForQuestion: fixture.validation.issuesForQuestion,
            onAnswerChanged: (_, _) {},
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Q2 Invalid'), findsOneWidget);
      expect(find.text('Focused'), findsOneWidget);
    });
  });
}

Widget _listHarness(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    ),
  );
}

_SectionFixture _sectionFixture() {
  final survey = Survey(
    id: 'section-question-list-survey',
    title: 'Question List Survey',
    description: 'Reusable question section body',
    createdAt: DateTime(2026),
    sections: const [SurveySection(id: 'visit', title: 'Visit', order: 0)],
    questions: [
      Question(
        id: 'name',
        text: 'Store name',
        type: QuestionType.singleLineText,
        required: true,
        sectionId: 'visit',
      ),
      Question(
        id: 'visitors',
        text: 'Visitor count',
        type: QuestionType.number,
        required: true,
        sectionId: 'visit',
      ),
      Question(
        id: 'note',
        text: 'Field note',
        type: QuestionType.singleLineText,
        required: true,
        sectionId: 'visit',
      ),
    ],
  );
  final response =
      SurveyResponse(
            id: 'section-question-list-response',
            surveyId: survey.id,
            respondentId: 'participant',
            respondentName: 'Participant',
            startedAt: DateTime(2026),
          )
          .upsertAnswer(questionId: 'name', value: 'Kaysir Mart')
          .upsertAnswer(questionId: 'visitors', value: 'many');
  final flow = SurveyResponseSectionFlow(survey: survey, response: response);
  final validation = SurveyResponseValidator.validate(
    questions: survey.questions,
    response: response,
  );

  return _SectionFixture(
    response: response,
    validation: validation,
    status: flow.pageStatuses(validation).single,
  );
}

/// Holds the response section state used by the question list widget tests.
class _SectionFixture {
  final SurveyResponse response;
  final SurveyResponseValidationResult validation;
  final SurveyResponseSectionPageStatus status;

  const _SectionFixture({
    required this.response,
    required this.validation,
    required this.status,
  });
}
