import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_survey/models/survey_role.dart';
import 'package:ky_survey/widgets/dashboard/survey_workspace_shell.dart';

void main() {
  group('SurveyWorkspaceShell', () {
    testWidgets('renders mobile navigation and app bar actions', (
      tester,
    ) async {
      int? selectedIndex;
      var openedSurveyList = false;
      var createdSurvey = false;
      SurveyWorkspaceSection? bodySection;
      bool? bodyIsWide;

      await tester.pumpWidget(
        MaterialApp(
          home: SurveyWorkspaceShell(
            role: SurveyRole.admin,
            sections: const [
              SurveyWorkspaceSection.overview,
              SurveyWorkspaceSection.reports,
            ],
            selectedIndex: 1,
            onDestinationSelected: (index) => selectedIndex = index,
            onSectionSelected: (_) {},
            onOpenSurveyList: () => openedSurveyList = true,
            onCreateSurvey: () => createdSurvey = true,
            bodyBuilder: (context, isWide, selectedSection) {
              bodyIsWide = isWide;
              bodySection = selectedSection;
              return const Center(child: Text('workspace body'));
            },
          ),
        ),
      );

      expect(bodyIsWide, isFalse);
      expect(bodySection, SurveyWorkspaceSection.reports);
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('workspace body'), findsOneWidget);

      await tester.tap(find.text('Overview'));
      await tester.tap(find.byTooltip('Survey list'));
      await tester.tap(find.byTooltip('Create survey'));

      expect(selectedIndex, 0);
      expect(openedSurveyList, isTrue);
      expect(createdSurvey, isTrue);
    });

    testWidgets('renders wide sidebar and forwards section selection', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      SurveyWorkspaceSection? selectedSection;
      SurveyWorkspaceSection? bodySection;
      bool? bodyIsWide;

      await tester.pumpWidget(
        MaterialApp(
          home: SurveyWorkspaceShell(
            role: SurveyRole.admin,
            sections: const [
              SurveyWorkspaceSection.overview,
              SurveyWorkspaceSection.builder,
            ],
            selectedIndex: 1,
            onDestinationSelected: (_) {},
            onSectionSelected: (section) => selectedSection = section,
            onOpenSurveyList: () {},
            onCreateSurvey: () {},
            bodyBuilder: (context, isWide, selectedSection) {
              bodyIsWide = isWide;
              bodySection = selectedSection;
              return const Center(child: Text('wide workspace body'));
            },
          ),
        ),
      );

      expect(bodyIsWide, isTrue);
      expect(bodySection, SurveyWorkspaceSection.builder);
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.text('wide workspace body'), findsOneWidget);

      await tester.tap(find.text('Overview'));

      expect(selectedSection, SurveyWorkspaceSection.overview);
    });

    testWidgets('hides admin app bar actions for focused roles', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SurveyWorkspaceShell(
            role: SurveyRole.interviewer,
            sections: const [
              SurveyWorkspaceSection.fieldwork,
              SurveyWorkspaceSection.participants,
            ],
            selectedIndex: 0,
            onDestinationSelected: (_) {},
            onSectionSelected: (_) {},
            onOpenSurveyList: () {},
            onCreateSurvey: () {},
            bodyBuilder: (context, isWide, selectedSection) {
              return const Center(child: Text('interviewer body'));
            },
          ),
        ),
      );

      expect(find.text('interviewer body'), findsOneWidget);
      expect(find.byTooltip('Survey list'), findsNothing);
      expect(find.byTooltip('Create survey'), findsNothing);
    });
  });
}
