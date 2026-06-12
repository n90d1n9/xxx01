import 'package:ky_survey/models/survey_role.dart';
import 'package:ky_survey/models/survey_workspace_intent.dart';
import 'package:test/test.dart';

void main() {
  group('SurveyWorkspaceIntent', () {
    test('selects a role-aware dashboard section without opening a screen', () {
      const intent = SurveyWorkspaceIntent.analytics();

      expect(intent.role, SurveyRole.analyst);
      expect(intent.section, SurveyWorkspaceSection.analytics);
      expect(intent.effectiveSection, SurveyWorkspaceSection.analytics);
      expect(intent.selectedIndex, 0);
      expect(intent.launchTarget, SurveyWorkspaceLaunchTarget.workspace);
      expect(intent.opensScreen, isFalse);
    });

    test('falls back to the first available role section when unavailable', () {
      const intent = SurveyWorkspaceIntent(
        role: SurveyRole.participant,
        section: SurveyWorkspaceSection.reports,
      );

      expect(intent.effectiveSection, SurveyWorkspaceSection.participants);
      expect(intent.selectedIndex, 0);
    });

    test('builder intents distinguish module focus from editor launch', () {
      const moduleIntent = SurveyWorkspaceIntent.builder();
      const editorIntent = SurveyWorkspaceIntent.builder(surveyId: 'survey-1');
      const newIntent = SurveyWorkspaceIntent.newBuilder();

      expect(moduleIntent.section, SurveyWorkspaceSection.builder);
      expect(moduleIntent.opensScreen, isFalse);
      expect(editorIntent.launchTarget, SurveyWorkspaceLaunchTarget.editSurvey);
      expect(editorIntent.needsSurvey, isTrue);
      expect(editorIntent.surveyId, 'survey-1');
      expect(newIntent.launchTarget, SurveyWorkspaceLaunchTarget.createSurvey);
      expect(newIntent.needsSurvey, isFalse);
    });

    test('intake and survey list intents expose their launch targets', () {
      const intakeIntent = SurveyWorkspaceIntent.intake(surveyId: 'survey-2');
      const listIntent = SurveyWorkspaceIntent.surveyList();

      expect(intakeIntent.role, SurveyRole.participant);
      expect(
        intakeIntent.effectiveSection,
        SurveyWorkspaceSection.participants,
      );
      expect(intakeIntent.launchTarget, SurveyWorkspaceLaunchTarget.intake);
      expect(intakeIntent.needsSurvey, isTrue);
      expect(listIntent.launchTarget, SurveyWorkspaceLaunchTarget.surveyList);
      expect(listIntent.opensScreen, isTrue);
    });

    test('copyWith preserves survey id unless explicitly cleared', () {
      const intent = SurveyWorkspaceIntent.builder(surveyId: 'survey-1');

      expect(
        intent.copyWith(section: SurveyWorkspaceSection.reports),
        SurveyWorkspaceIntent(
          role: SurveyRole.admin,
          section: SurveyWorkspaceSection.reports,
          launchTarget: SurveyWorkspaceLaunchTarget.editSurvey,
          surveyId: 'survey-1',
        ),
      );
      expect(intent.copyWith(clearSurveyId: true).surveyId, isNull);
    });
  });
}
