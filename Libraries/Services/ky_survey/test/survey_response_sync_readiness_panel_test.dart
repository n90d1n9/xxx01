import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_survey/analytics/survey_response_sync_readiness.dart';
import 'package:ky_survey/models/question.dart';
import 'package:ky_survey/models/survey.dart';
import 'package:ky_survey/models/survey_response.dart';
import 'package:ky_survey/widgets/dashboard/survey_response_sync_readiness_panel.dart';

void main() {
  group('SurveyResponseSyncReadinessPanel', () {
    testWidgets('marks queue rows as read-only without an open callback', (
      tester,
    ) async {
      await tester.pumpWidget(_readinessHarness());

      expect(find.text('Fieldwork Action Queue'), findsOneWidget);
      expect(find.text('Participant draft-1'), findsOneWidget);
      expect(find.text('View only'), findsOneWidget);
      expect(find.byTooltip('Read-only response summary'), findsOneWidget);
      expect(find.byTooltip('Resume answers'), findsNothing);
    });

    testWidgets('opens queue rows when an open callback is provided', (
      tester,
    ) async {
      SurveyResponseSyncReadiness? openedItem;

      await tester.pumpWidget(
        _readinessHarness(onOpenResponse: (item) => openedItem = item),
      );

      expect(find.text('View only'), findsNothing);
      expect(find.byTooltip('Resume answers'), findsOneWidget);

      await tester.tap(find.byTooltip('Resume answers'));
      await tester.pump();

      expect(openedItem?.response.id, 'draft-1');
    });
  });
}

Widget _readinessHarness({
  ValueChanged<SurveyResponseSyncReadiness>? onOpenResponse,
}) {
  final survey = _survey();
  final response = _response();

  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SurveyResponseSyncReadinessPanel(
          insights: SurveyResponseSyncReadinessInsights.evaluate(
            surveys: [survey],
            responses: [response],
            now: _now,
          ),
          onOpenResponse: onOpenResponse,
        ),
      ),
    ),
  );
}

final _now = DateTime(2026, 6, 11, 9);

Survey _survey() {
  return Survey(
    id: 'retail-audit',
    title: 'Retail Audit',
    description: 'Readiness panel test',
    createdAt: DateTime(2026),
    questions: [
      Question(
        id: 'display-note',
        text: 'What did you observe?',
        type: QuestionType.singleLineText,
        required: true,
      ),
    ],
  );
}

SurveyResponse _response() {
  return SurveyResponse(
    id: 'draft-1',
    surveyId: 'retail-audit',
    respondentId: 'participant-draft-1',
    respondentName: 'Participant draft-1',
    startedAt: _now.subtract(const Duration(minutes: 20)),
  );
}
