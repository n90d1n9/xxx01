import 'package:flutter/material.dart';

import '../../logic/survey_role_capabilities.dart';
import '../../logic/survey_workspace_survey_selector.dart';
import '../../models/survey.dart';
import '../../models/survey_role.dart';
import 'survey_workspace_navigation.dart';

/// Builds reusable workspace screen shortcuts from survey state and actions.
class SurveyWorkspaceShortcutBuilder {
  final SurveyRole role;
  final List<Survey> surveys;
  final VoidCallback onOpenSurveyList;
  final VoidCallback onCreateSurvey;
  final ValueChanged<Survey> onEditSurvey;
  final ValueChanged<Survey> onOpenSurvey;

  const SurveyWorkspaceShortcutBuilder({
    this.role = SurveyRole.admin,
    required this.surveys,
    required this.onOpenSurveyList,
    required this.onCreateSurvey,
    required this.onEditSurvey,
    required this.onOpenSurvey,
  });

  List<SurveyWorkspaceShortcut> build() {
    final recentSurvey = mostRecentSurvey(surveys);
    final capabilities = SurveyRoleCapabilities.forRole(role);
    final shortcuts = <SurveyWorkspaceShortcut>[];

    if (capabilities.can(SurveyWorkspaceAction.viewSurveyList)) {
      shortcuts.add(
        SurveyWorkspaceShortcut(
          label: 'Survey list',
          subtitle: 'Browse and manage all surveys',
          icon: Icons.view_list_outlined,
          onPressed: onOpenSurveyList,
        ),
      );
    }

    if (capabilities.can(SurveyWorkspaceAction.createSurvey)) {
      shortcuts.add(
        SurveyWorkspaceShortcut(
          label: 'New builder',
          subtitle: 'Create a survey from a clean draft',
          icon: Icons.add_circle_outline,
          onPressed: onCreateSurvey,
        ),
      );
    }

    if (capabilities.can(SurveyWorkspaceAction.editSurvey)) {
      shortcuts.add(
        SurveyWorkspaceShortcut(
          label: 'Latest builder',
          subtitle: recentSurvey?.title ?? 'Create a survey first',
          icon: Icons.edit_note_outlined,
          onPressed: recentSurvey == null
              ? null
              : () => onEditSurvey(recentSurvey),
        ),
      );
    }

    if (capabilities.can(SurveyWorkspaceAction.openIntake)) {
      shortcuts.add(
        SurveyWorkspaceShortcut(
          label: 'Intake screen',
          subtitle: recentSurvey?.title ?? 'Create a survey first',
          icon: Icons.fact_check_outlined,
          onPressed: recentSurvey == null
              ? null
              : () => onOpenSurvey(recentSurvey),
        ),
      );
    }

    return shortcuts;
  }

  static Survey? mostRecentSurvey(List<Survey> surveys) {
    return SurveyWorkspaceSurveySelector.mostRecentSurvey(surveys);
  }
}
