import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_survey/widgets/dashboard/survey_read_only_pill.dart';

void main() {
  group('SurveyDashboardStatePill', () {
    testWidgets('renders a generic dashboard state pill', (tester) async {
      await tester.pumpWidget(
        _pillHarness(
          const SurveyDashboardStatePill(
            label: 'Up to date',
            tooltip: 'No operations need attention',
            icon: Icons.task_alt_outlined,
          ),
        ),
      );

      expect(find.text('Up to date'), findsOneWidget);
      expect(find.byTooltip('No operations need attention'), findsOneWidget);
      expect(find.byIcon(Icons.task_alt_outlined), findsOneWidget);
    });
  });

  group('SurveyReadOnlyPill', () {
    testWidgets('renders the default read-only affordance', (tester) async {
      await tester.pumpWidget(
        _pillHarness(
          const SurveyReadOnlyPill(tooltip: 'Read-only assignment summary'),
        ),
      );

      expect(find.text('View only'), findsOneWidget);
      expect(find.byTooltip('Read-only assignment summary'), findsOneWidget);
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });

    testWidgets('supports compact contextual variants', (tester) async {
      await tester.pumpWidget(
        _pillHarness(
          const SurveyReadOnlyPill(
            label: 'Locked',
            tooltip: 'Read-only compact summary',
            icon: Icons.lock_outline,
            compact: true,
          ),
        ),
      );

      expect(find.text('Locked'), findsOneWidget);
      expect(find.byTooltip('Read-only compact summary'), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    });
  });
}

Widget _pillHarness(Widget child) {
  return MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );
}
