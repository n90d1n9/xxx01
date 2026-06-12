import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_survey/models/survey_role.dart';
import 'package:ky_survey/widgets/dashboard/survey_workspace_bottom_navigation.dart';
import 'package:ky_survey/widgets/dashboard/survey_workspace_navigation.dart';

void main() {
  group('SurveyWorkspaceBottomNavigation', () {
    testWidgets('renders section destinations with badges', (tester) async {
      int? selectedIndex;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: SurveyWorkspaceBottomNavigation(
              sections: const [
                SurveyWorkspaceSection.overview,
                SurveyWorkspaceSection.reports,
              ],
              selectedIndex: 0,
              sectionBadges: const {
                SurveyWorkspaceSection.reports: SurveyWorkspaceSectionBadge(
                  label: '5',
                  tone: SurveyWorkspaceSectionBadgeTone.warning,
                  tooltip: '5 evidence uploads pending',
                ),
              },
              onDestinationSelected: (index) => selectedIndex = index,
            ),
          ),
        ),
      );

      expect(find.text('Overview'), findsOneWidget);
      expect(find.text('Reports'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);

      await tester.tap(find.text('Reports'));
      await tester.pump();

      expect(selectedIndex, 1);
    });
  });
}
