import '../models/survey.dart';
import '../models/survey_workspace_intent.dart';
import 'survey_role_capabilities.dart';
import 'survey_workspace_survey_selector.dart';

typedef SurveyWorkspaceSurveyLaunchAction = void Function(Survey survey);
typedef SurveyWorkspaceIntentUnavailableAction =
    void Function(SurveyWorkspaceIntent intent);

/// Dispatches workspace launch intents to navigation and survey actions.
class SurveyWorkspaceIntentLauncher {
  final List<Survey> surveys;
  final void Function() onOpenSurveyList;
  final void Function() onCreateSurvey;
  final SurveyWorkspaceSurveyLaunchAction onEditSurvey;
  final SurveyWorkspaceSurveyLaunchAction onOpenSurvey;
  final SurveyWorkspaceIntentUnavailableAction onUnavailable;
  final SurveyRoleCapabilities? capabilities;

  const SurveyWorkspaceIntentLauncher({
    required this.surveys,
    required this.onOpenSurveyList,
    required this.onCreateSurvey,
    required this.onEditSurvey,
    required this.onOpenSurvey,
    required this.onUnavailable,
    this.capabilities,
  });

  void launch(SurveyWorkspaceIntent intent) {
    final effectiveCapabilities =
        capabilities ?? SurveyRoleCapabilities.forRole(intent.role);
    if (!effectiveCapabilities.canLaunch(intent.launchTarget)) {
      onUnavailable(intent);
      return;
    }

    switch (intent.launchTarget) {
      case SurveyWorkspaceLaunchTarget.workspace:
        return;
      case SurveyWorkspaceLaunchTarget.surveyList:
        onOpenSurveyList();
      case SurveyWorkspaceLaunchTarget.createSurvey:
        onCreateSurvey();
      case SurveyWorkspaceLaunchTarget.editSurvey:
        final survey = SurveyWorkspaceSurveySelector.surveyForIntent(
          intent,
          surveys,
        );
        if (survey == null) {
          onUnavailable(intent);
          return;
        }
        onEditSurvey(survey);
      case SurveyWorkspaceLaunchTarget.intake:
        final survey = SurveyWorkspaceSurveySelector.surveyForIntent(
          intent,
          surveys,
        );
        if (survey == null) {
          onUnavailable(intent);
          return;
        }
        onOpenSurvey(survey);
    }
  }
}
