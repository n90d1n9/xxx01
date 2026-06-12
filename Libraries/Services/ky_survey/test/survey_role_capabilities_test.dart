import 'package:flutter_test/flutter_test.dart';
import 'package:ky_survey/logic/survey_role_capabilities.dart';
import 'package:ky_survey/models/survey_role.dart';
import 'package:ky_survey/models/survey_workspace_intent.dart';

void main() {
  group('SurveyRoleCapabilities', () {
    test('allows admin to reach builder, intake, analytics, and reports', () {
      final capabilities = SurveyRoleCapabilities.forRole(SurveyRole.admin);

      expect(capabilities.can(SurveyWorkspaceAction.createSurvey), isTrue);
      expect(capabilities.can(SurveyWorkspaceAction.editSurvey), isTrue);
      expect(capabilities.can(SurveyWorkspaceAction.openIntake), isTrue);
      expect(
        capabilities.canOpenSection(SurveyWorkspaceSection.reports),
        isTrue,
      );
      expect(
        capabilities.canLaunch(SurveyWorkspaceLaunchTarget.createSurvey),
        isTrue,
      );
    });

    test('keeps participant focused on intake without builder access', () {
      final capabilities = SurveyRoleCapabilities.forRole(
        SurveyRole.participant,
      );

      expect(capabilities.can(SurveyWorkspaceAction.openIntake), isTrue);
      expect(capabilities.can(SurveyWorkspaceAction.createSurvey), isFalse);
      expect(capabilities.can(SurveyWorkspaceAction.editSurvey), isFalse);
      expect(
        capabilities.canLaunch(SurveyWorkspaceLaunchTarget.createSurvey),
        isFalse,
      );
      expect(
        capabilities.canLaunch(SurveyWorkspaceLaunchTarget.intake),
        isTrue,
      );
    });

    test('keeps report viewers out of mutable survey screens', () {
      final capabilities = SurveyRoleCapabilities.forRole(
        SurveyRole.reportViewer,
      );

      expect(capabilities.can(SurveyWorkspaceAction.viewReports), isTrue);
      expect(capabilities.can(SurveyWorkspaceAction.viewAnalytics), isTrue);
      expect(capabilities.can(SurveyWorkspaceAction.openIntake), isFalse);
      expect(capabilities.can(SurveyWorkspaceAction.editSurvey), isFalse);
      expect(
        capabilities.canLaunch(SurveyWorkspaceLaunchTarget.editSurvey),
        isFalse,
      );
    });
  });
}
