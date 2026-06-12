import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_survey/analytics/survey_fieldwork_insights.dart';
import 'package:ky_survey/analytics/survey_response_sync_readiness.dart';
import 'package:ky_survey/models/survey.dart';
import 'package:ky_survey/models/survey_assignment.dart';
import 'package:ky_survey/widgets/dashboard/survey_fieldwork_board.dart';

void main() {
  group('SurveyFieldworkBoard', () {
    testWidgets('shows assignment cards as read-only without actions', (
      tester,
    ) async {
      final survey = _survey();
      final assignment = _assignment();

      await tester.pumpWidget(
        _fieldworkHarness(surveys: [survey], assignments: [assignment]),
      );

      expect(find.text('Assignment Queue'), findsOneWidget);
      expect(find.text('Retail Audit'), findsOneWidget);
      expect(find.text('View only'), findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, 'Open'), findsNothing);
      expect(find.widgetWithText(FilledButton, 'In Progress'), findsNothing);
    });

    testWidgets('forwards open and assignment status actions', (tester) async {
      final survey = _survey();
      final assignment = _assignment();
      Survey? openedSurvey;
      SurveyAssignmentStatus? selectedStatus;

      await tester.pumpWidget(
        _fieldworkHarness(
          surveys: [survey],
          assignments: [assignment],
          onOpenSurvey: (survey) => openedSurvey = survey,
          onStatusChanged: (_, status) => selectedStatus = status,
        ),
      );

      expect(find.widgetWithText(OutlinedButton, 'Open'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'In Progress'), findsOneWidget);
      expect(find.text('View only'), findsNothing);

      final openButton = find.widgetWithText(OutlinedButton, 'Open');
      final inProgressButton = find.widgetWithText(FilledButton, 'In Progress');

      await tester.ensureVisible(openButton);
      await tester.tap(openButton);
      await tester.ensureVisible(inProgressButton);
      await tester.tap(inProgressButton);
      await tester.pump();

      expect(openedSurvey, same(survey));
      expect(selectedStatus, SurveyAssignmentStatus.inProgress);
    });
  });
}

Widget _fieldworkHarness({
  required List<Survey> surveys,
  required List<SurveyAssignment> assignments,
  ValueChanged<Survey>? onOpenSurvey,
  SurveyAssignmentStatusChanged? onStatusChanged,
}) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        child: SurveyFieldworkBoard(
          insights: SurveyFieldworkInsights(
            surveys: surveys,
            assignments: assignments,
          ),
          responseSyncReadiness: SurveyResponseSyncReadinessInsights.evaluate(
            surveys: surveys,
            responses: const [],
          ),
          onOpenSurvey: onOpenSurvey,
          onStatusChanged: onStatusChanged,
        ),
      ),
    ),
  );
}

Survey _survey() {
  return Survey(
    id: 'retail-audit',
    title: 'Retail Audit',
    description: 'Fieldwork board test',
    questions: const [],
    createdAt: DateTime(2026, 6),
  );
}

SurveyAssignment _assignment() {
  return SurveyAssignment(
    id: 'assignment-1',
    surveyId: 'retail-audit',
    assigneeId: 'surveyor-1',
    assigneeName: 'Alya Rahman',
    territory: 'North Market',
    dueAt: DateTime(2099, 7, 1),
    assignedAt: DateTime(2026, 6, 1),
    targetResponses: 10,
    completedResponses: 2,
  );
}
