import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_survey/logic/survey_response_question_status.dart';
import 'package:ky_survey/logic/survey_response_section_flow.dart';
import 'package:ky_survey/models/question.dart';
import 'package:ky_survey/models/survey.dart';
import 'package:ky_survey/models/survey_response.dart';
import 'package:ky_survey/models/survey_section.dart';
import 'package:ky_survey/validation/survey_response_validator.dart';
import 'package:ky_survey/widgets/survey_response_question_status_map.dart';

void main() {
  group('SurveyResponseQuestionStatusSummary', () {
    test('classifies section questions by response state', () {
      final summary = _questionStatusSummary();

      expect(summary.answeredCount, 1);
      expect(summary.missingRequiredCount, 1);
      expect(summary.invalidCount, 1);
      expect(summary.optionalPendingCount, 1);
      expect(
        summary.statusLabel,
        '1 answered - 1 required missing - 1 invalid - 1 optional open',
      );
      expect(summary.items.map((item) => item.shortStatusLabel), [
        'Answered',
        'Invalid',
        'Missing',
        'Optional',
      ]);
      expect(summary.items[1].detailLabel, 'Visitor count must be a number');
      expect(
        summary.items[2].tooltipLabel,
        'Q3: Field note - Field note is required',
      );
    });
  });

  group('SurveyResponseQuestionStatusMap', () {
    testWidgets('renders question chips and forwards selected question', (
      tester,
    ) async {
      var selectedQuestionId = '';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: SurveyResponseQuestionStatusMap(
                summary: _questionStatusSummary(),
                selectedQuestionId: 'visitors',
                onQuestionSelected: (questionId) {
                  selectedQuestionId = questionId;
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('Question status'), findsOneWidget);
      expect(find.text('Q1 Answered'), findsOneWidget);
      expect(find.text('Q2 Invalid'), findsOneWidget);
      expect(find.text('Q3 Missing'), findsOneWidget);
      expect(find.text('Q4 Optional'), findsOneWidget);

      await tester.tap(find.text('Q3 Missing'));
      await tester.pump();

      expect(selectedQuestionId, 'note');
    });
  });
}

SurveyResponseQuestionStatusSummary _questionStatusSummary() {
  final survey = Survey(
    id: 'question-status-survey',
    title: 'Question Status Survey',
    description: 'Question-level response states',
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
      Question(
        id: 'optional',
        text: 'Optional context',
        type: QuestionType.multiLineText,
        required: false,
        sectionId: 'visit',
      ),
    ],
  );
  final response =
      SurveyResponse(
            id: 'question-status-response',
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
  final pageStatus = flow.pageStatuses(validation).single;

  return SurveyResponseQuestionStatusSummary.fromPageStatus(pageStatus);
}
