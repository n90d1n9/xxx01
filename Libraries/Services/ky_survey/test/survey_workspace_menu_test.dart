import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_survey/models/survey_role.dart';
import 'package:ky_survey/widgets/dashboard/survey_workspace_menu.dart';
import 'package:ky_survey/widgets/dashboard/survey_workspace_navigation.dart';

void main() {
  group('SurveyWorkspaceMenu', () {
    testWidgets('renders module badges without changing selection', (
      tester,
    ) async {
      SurveyWorkspaceSection? selectedSection;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 320,
              height: 560,
              child: SurveyWorkspaceMenu(
                role: SurveyRole.admin,
                sections: const [
                  SurveyWorkspaceSection.overview,
                  SurveyWorkspaceSection.fieldwork,
                ],
                selectedSection: SurveyWorkspaceSection.overview,
                sectionBadges: const {
                  SurveyWorkspaceSection.fieldwork: SurveyWorkspaceSectionBadge(
                    label: '3',
                    tone: SurveyWorkspaceSectionBadgeTone.error,
                    tooltip: '3 responses need review',
                  ),
                },
                showFooter: false,
                onSectionSelected: (section) => selectedSection = section,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Overview'), findsOneWidget);
      expect(find.text('Fieldwork'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);

      await tester.tap(find.text('Fieldwork'));
      await tester.pump();

      expect(selectedSection, SurveyWorkspaceSection.fieldwork);
    });
  });
}
