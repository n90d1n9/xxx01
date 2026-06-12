import 'package:ky_survey/logic/survey_dashboard_role_scope.dart';
import 'package:ky_survey/models/survey_role.dart';
import 'package:ky_survey/models/survey_workspace_intent.dart';
import 'package:test/test.dart';

void main() {
  group('SurveyDashboardRoleScope', () {
    test('deduplicates roles and falls back to all roles when empty', () {
      final scoped = SurveyDashboardRoleScope([
        SurveyRole.admin,
        SurveyRole.admin,
        SurveyRole.analyst,
      ]);
      final defaulted = SurveyDashboardRoleScope(const []);

      expect(scoped.roles, [SurveyRole.admin, SurveyRole.analyst]);
      expect(defaulted.roles, SurveyRole.values);
    });

    test('resolves unavailable roles to the first scoped role', () {
      final scope = SurveyDashboardRoleScope([
        SurveyRole.analyst,
        SurveyRole.reportViewer,
      ]);

      expect(
        scope.resolveRole(SurveyRole.reportViewer),
        SurveyRole.reportViewer,
      );
      expect(scope.resolveRole(SurveyRole.admin), SurveyRole.analyst);
    });

    test('resolves intent roles without changing launch context', () {
      final scope = SurveyDashboardRoleScope([
        SurveyRole.admin,
        SurveyRole.analyst,
      ]);
      const intent = SurveyWorkspaceIntent.reports(
        role: SurveyRole.reportViewer,
      );

      final resolvedIntent = scope.resolveIntent(intent);

      expect(resolvedIntent.role, SurveyRole.admin);
      expect(resolvedIntent.section, SurveyWorkspaceSection.reports);
      expect(resolvedIntent.launchTarget, intent.launchTarget);
      expect(resolvedIntent.surveyId, intent.surveyId);
    });

    test('preserves selected sections when role scope changes', () {
      final scope = SurveyDashboardRoleScope([SurveyRole.admin]);

      final selection = scope.resolveSelection(
        role: SurveyRole.analyst,
        selectedIndex: SurveyRole.analyst.sections.indexOf(
          SurveyWorkspaceSection.analytics,
        ),
      );

      expect(selection.role, SurveyRole.admin);
      expect(selection.section, SurveyWorkspaceSection.analytics);
      expect(
        selection.selectedIndex,
        SurveyRole.admin.sections.indexOf(SurveyWorkspaceSection.analytics),
      );
    });

    test(
      'falls back to the first scoped section when current section is gone',
      () {
        final scope = SurveyDashboardRoleScope([SurveyRole.analyst]);

        final selection = scope.resolveSelection(
          role: SurveyRole.interviewer,
          selectedIndex: SurveyRole.interviewer.sections.indexOf(
            SurveyWorkspaceSection.fieldwork,
          ),
        );

        expect(selection.role, SurveyRole.analyst);
        expect(selection.section, SurveyWorkspaceSection.analytics);
        expect(selection.selectedIndex, 0);
      },
    );
  });
}
