import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_survey/logic/survey_response_session_summary.dart';
import 'package:ky_survey/models/question.dart';
import 'package:ky_survey/models/survey.dart';
import 'package:ky_survey/models/survey_response.dart';
import 'package:ky_survey/widgets/survey_response_viewer_header.dart';

void main() {
  group('SurveyResponseViewerHeader', () {
    testWidgets('renders response identity, status, and progress metrics', (
      tester,
    ) async {
      final survey = Survey(
        id: 'viewer-header-survey',
        title: 'Retail Visit',
        description: 'Daily store audit',
        createdAt: DateTime(2026),
        questions: [
          Question(
            id: 'store-name',
            text: 'Store name',
            type: QuestionType.singleLineText,
            required: true,
          ),
          Question(
            id: 'visitor-count',
            text: 'Visitor count',
            type: QuestionType.number,
            required: true,
          ),
        ],
      );
      final response =
          SurveyResponse(
            id: 'response-1',
            surveyId: survey.id,
            respondentId: 'participant',
            respondentName: 'Participant',
            startedAt: DateTime(2026, 1, 1, 9),
          ).upsertAnswer(
            questionId: 'store-name',
            value: 'Kaysir Mart',
            answeredAt: DateTime(2026, 1, 1, 9, 1),
          );
      final summary = SurveyResponseSessionSummary.evaluate(
        survey: survey,
        response: response,
        now: DateTime(2026, 1, 1, 9, 4),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SurveyResponseViewerHeader(survey: survey, summary: summary),
          ),
        ),
      );

      expect(find.text('Retail Visit'), findsOneWidget);
      expect(find.text('Daily store audit'), findsOneWidget);
      expect(find.text('1 required missing'), findsOneWidget);
      expect(find.text('1 of 2 answered'), findsOneWidget);
      expect(find.text('50% complete'), findsOneWidget);
      expect(find.text('1 of 2 required answered'), findsOneWidget);
      expect(find.text('Last saved 09:01 • 4m session'), findsOneWidget);
    });
  });
}
