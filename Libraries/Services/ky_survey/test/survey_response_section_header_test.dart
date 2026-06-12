import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_survey/logic/survey_response_section_flow.dart';
import 'package:ky_survey/models/question.dart';
import 'package:ky_survey/models/survey.dart';
import 'package:ky_survey/models/survey_response.dart';
import 'package:ky_survey/models/survey_section.dart';
import 'package:ky_survey/validation/survey_response_validator.dart';
import 'package:ky_survey/widgets/survey_response_section_header.dart';

void main() {
  group('SurveyResponseSectionHeader', () {
    testWidgets('shows current section readiness and issue metrics', (
      tester,
    ) async {
      final status = _sectionStatus(
        visitorCountAnswer: 'many',
        noteAnswer: null,
      );

      await tester.pumpWidget(
        _headerHarness(
          SurveyResponseSectionHeader(page: status.page, status: status),
        ),
      );

      expect(find.text('Visit Metrics'), findsOneWidget);
      expect(find.text('2 answer issues'), findsOneWidget);
      expect(find.text('1 of 2 answered'), findsOneWidget);
      expect(find.text('1 required missing'), findsOneWidget);
      expect(find.text('1 invalid answer'), findsOneWidget);
    });

    testWidgets('shows ready state when required answers are complete', (
      tester,
    ) async {
      final status = _sectionStatus(
        visitorCountAnswer: 42,
        noteAnswer: 'Front display checked',
      );

      await tester.pumpWidget(
        _headerHarness(
          SurveyResponseSectionHeader(page: status.page, status: status),
        ),
      );

      expect(find.text('Section ready'), findsOneWidget);
      expect(find.text('2 of 2 answered'), findsOneWidget);
      expect(find.text('Required complete'), findsOneWidget);
    });
  });
}

Widget _headerHarness(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: Padding(padding: const EdgeInsets.all(16), child: child),
    ),
  );
}

SurveyResponseSectionPageStatus _sectionStatus({
  required dynamic visitorCountAnswer,
  required dynamic noteAnswer,
}) {
  final survey = Survey(
    id: 'section-header-survey',
    title: 'Section Header Survey',
    description: 'Section readiness',
    createdAt: DateTime(2026),
    sections: const [
      SurveySection(
        id: 'visit',
        title: 'Visit Metrics',
        description: 'Capture operational observations.',
        order: 0,
      ),
    ],
    questions: [
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
  var response = SurveyResponse(
    id: 'section-header-response',
    surveyId: survey.id,
    respondentId: 'participant',
    respondentName: 'Participant',
    startedAt: DateTime(2026),
  ).upsertAnswer(questionId: 'visitors', value: visitorCountAnswer);

  if (noteAnswer != null) {
    response = response.upsertAnswer(questionId: 'note', value: noteAnswer);
  }

  final flow = SurveyResponseSectionFlow(survey: survey, response: response);
  final validation = SurveyResponseValidator.validate(
    questions: survey.questions,
    response: response,
  );

  return flow.pageStatuses(validation).single;
}
