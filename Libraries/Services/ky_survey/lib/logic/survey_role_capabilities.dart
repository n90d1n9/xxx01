import '../models/survey_role.dart';
import '../models/survey_workspace_intent.dart';

/// Identifies a workspace action that can be enabled or hidden per role.
enum SurveyWorkspaceAction {
  viewSurveyList,
  createSurvey,
  editSurvey,
  openIntake,
  manageSurveyLifecycle,
  manageAssignments,
  reviewResponses,
  syncEvidence,
  viewAnalytics,
  viewReports,
}

/// Describes the survey workspace actions available to a specific role.
class SurveyRoleCapabilities {
  final SurveyRole role;
  final Set<SurveyWorkspaceAction> actions;

  const SurveyRoleCapabilities._(this.role, this.actions);

  static const admin = SurveyRoleCapabilities._(SurveyRole.admin, {
    SurveyWorkspaceAction.viewSurveyList,
    SurveyWorkspaceAction.createSurvey,
    SurveyWorkspaceAction.editSurvey,
    SurveyWorkspaceAction.openIntake,
    SurveyWorkspaceAction.manageSurveyLifecycle,
    SurveyWorkspaceAction.manageAssignments,
    SurveyWorkspaceAction.reviewResponses,
    SurveyWorkspaceAction.syncEvidence,
    SurveyWorkspaceAction.viewAnalytics,
    SurveyWorkspaceAction.viewReports,
  });

  static const interviewer = SurveyRoleCapabilities._(SurveyRole.interviewer, {
    SurveyWorkspaceAction.openIntake,
    SurveyWorkspaceAction.manageAssignments,
    SurveyWorkspaceAction.syncEvidence,
  });

  static const participant = SurveyRoleCapabilities._(SurveyRole.participant, {
    SurveyWorkspaceAction.openIntake,
  });

  static const analyst = SurveyRoleCapabilities._(SurveyRole.analyst, {
    SurveyWorkspaceAction.reviewResponses,
    SurveyWorkspaceAction.syncEvidence,
    SurveyWorkspaceAction.viewAnalytics,
    SurveyWorkspaceAction.viewReports,
  });

  static const reportViewer = SurveyRoleCapabilities._(
    SurveyRole.reportViewer,
    {SurveyWorkspaceAction.viewAnalytics, SurveyWorkspaceAction.viewReports},
  );

  factory SurveyRoleCapabilities.forRole(SurveyRole role) {
    switch (role) {
      case SurveyRole.admin:
        return admin;
      case SurveyRole.interviewer:
        return interviewer;
      case SurveyRole.participant:
        return participant;
      case SurveyRole.analyst:
        return analyst;
      case SurveyRole.reportViewer:
        return reportViewer;
    }
  }

  bool can(SurveyWorkspaceAction action) {
    return actions.contains(action);
  }

  bool canOpenSection(SurveyWorkspaceSection section) {
    return role.sections.contains(section);
  }

  bool canLaunch(SurveyWorkspaceLaunchTarget launchTarget) {
    final action = _actionForLaunchTarget(launchTarget);
    return action == null || can(action);
  }

  static SurveyWorkspaceAction? _actionForLaunchTarget(
    SurveyWorkspaceLaunchTarget launchTarget,
  ) {
    switch (launchTarget) {
      case SurveyWorkspaceLaunchTarget.workspace:
        return null;
      case SurveyWorkspaceLaunchTarget.surveyList:
        return SurveyWorkspaceAction.viewSurveyList;
      case SurveyWorkspaceLaunchTarget.createSurvey:
        return SurveyWorkspaceAction.createSurvey;
      case SurveyWorkspaceLaunchTarget.editSurvey:
        return SurveyWorkspaceAction.editSurvey;
      case SurveyWorkspaceLaunchTarget.intake:
        return SurveyWorkspaceAction.openIntake;
    }
  }
}
