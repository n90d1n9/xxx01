import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_survey/models/survey_role.dart';
import 'package:ky_survey/widgets/dashboard/survey_workspace_navigation.dart';

void main() {
  group('SurveyWorkspaceSectionNavigationIcon', () {
    testWidgets('renders a tone-aware badge around section icons', (
      tester,
    ) async {
      late ColorScheme colorScheme;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              colorScheme = Theme.of(context).colorScheme;

              return const Scaffold(
                body: SurveyWorkspaceSectionNavigationIcon(
                  section: SurveyWorkspaceSection.reports,
                  badge: SurveyWorkspaceSectionBadge(
                    label: '7',
                    tone: SurveyWorkspaceSectionBadgeTone.warning,
                    tooltip: '7 uploads pending',
                  ),
                ),
              );
            },
          ),
        ),
      );

      final badge = tester.widget<Badge>(find.byType(Badge));

      expect(find.byIcon(Icons.summarize_outlined), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
      expect(badge.backgroundColor, colorScheme.tertiary);
    });
  });
}
