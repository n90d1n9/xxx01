import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_survey/models/survey.dart';
import 'package:ky_survey/models/survey_status.dart';
import 'package:ky_survey/widgets/dashboard/survey_progress_list.dart';

void main() {
  group('SurveyProgressList', () {
    testWidgets('marks rows as view-only when no selection callback exists', (
      tester,
    ) async {
      await tester.pumpWidget(_progressListHarness(surveys: [_survey()]));

      expect(find.text('Customer Pulse'), findsOneWidget);
      expect(find.text('24 / 60 responses'), findsOneWidget);
      expect(find.text('View only'), findsOneWidget);
      expect(find.byTooltip('Read-only survey summary'), findsOneWidget);
      expect(find.byTooltip('Open survey'), findsNothing);
    });

    testWidgets('opens a survey row when selection callback is provided', (
      tester,
    ) async {
      final survey = _survey();
      Survey? selectedSurvey;

      await tester.pumpWidget(
        _progressListHarness(
          surveys: [survey],
          onSurveySelected: (survey) => selectedSurvey = survey,
        ),
      );

      expect(find.text('View only'), findsNothing);
      expect(find.byTooltip('Open survey'), findsOneWidget);

      await tester.tap(find.text('Customer Pulse'));
      await tester.pump();

      expect(selectedSurvey, same(survey));
    });

    testWidgets('renders an empty state when no surveys are available', (
      tester,
    ) async {
      await tester.pumpWidget(_progressListHarness(surveys: const []));

      expect(find.text('No surveys yet'), findsOneWidget);
      expect(find.text('Survey queue is empty.'), findsOneWidget);
    });
  });
}

Widget _progressListHarness({
  required List<Survey> surveys,
  ValueChanged<Survey>? onSurveySelected,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SurveyProgressList(
          surveys: surveys,
          onSurveySelected: onSurveySelected,
        ),
      ),
    ),
  );
}

Survey _survey() {
  return Survey(
    id: 'customer-pulse',
    title: 'Customer Pulse',
    description: 'Progress list test survey',
    questions: const [],
    createdAt: DateTime(2026, 6),
    status: SurveyStatus.collecting,
    responseCount: 24,
    targetResponses: 60,
  );
}
