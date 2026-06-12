import 'package:flutter/material.dart';

import '../../models/survey_role.dart';

class SurveyWorkspaceShortcut {
  final String label;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onPressed;

  const SurveyWorkspaceShortcut({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.onPressed,
  });
}

enum SurveyWorkspaceSectionBadgeTone { neutral, success, warning, error }

/// Describes a compact status badge for a survey workspace module.
class SurveyWorkspaceSectionBadge {
  final String label;
  final SurveyWorkspaceSectionBadgeTone tone;
  final String? tooltip;

  const SurveyWorkspaceSectionBadge({
    required this.label,
    this.tone = SurveyWorkspaceSectionBadgeTone.neutral,
    this.tooltip,
  });
}

/// Resolves the shared Material color for workspace section badge tones.
Color surveyWorkspaceSectionBadgeColor(
  ColorScheme colorScheme,
  SurveyWorkspaceSectionBadgeTone tone,
) {
  switch (tone) {
    case SurveyWorkspaceSectionBadgeTone.neutral:
      return colorScheme.onSurfaceVariant;
    case SurveyWorkspaceSectionBadgeTone.success:
      return colorScheme.primary;
    case SurveyWorkspaceSectionBadgeTone.warning:
      return colorScheme.tertiary;
    case SurveyWorkspaceSectionBadgeTone.error:
      return colorScheme.error;
  }
}

/// Renders a workspace section icon with an optional status badge.
class SurveyWorkspaceSectionNavigationIcon extends StatelessWidget {
  final SurveyWorkspaceSection section;
  final bool selected;
  final SurveyWorkspaceSectionBadge? badge;

  const SurveyWorkspaceSectionNavigationIcon({
    super.key,
    required this.section,
    this.selected = false,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final icon = Icon(surveyWorkspaceSectionIcon(section, selected: selected));
    final badge = this.badge;
    if (badge == null) {
      return icon;
    }

    final child = Badge(
      backgroundColor: surveyWorkspaceSectionBadgeColor(
        Theme.of(context).colorScheme,
        badge.tone,
      ),
      label: Text(badge.label),
      child: icon,
    );
    final tooltip = badge.tooltip;
    if (tooltip == null || tooltip.isEmpty) {
      return child;
    }

    return Tooltip(message: tooltip, child: child);
  }
}

IconData surveyWorkspaceSectionIcon(
  SurveyWorkspaceSection section, {
  bool selected = false,
}) {
  switch (section) {
    case SurveyWorkspaceSection.overview:
      return selected ? Icons.dashboard : Icons.dashboard_outlined;
    case SurveyWorkspaceSection.builder:
      return selected ? Icons.edit_note : Icons.edit_note_outlined;
    case SurveyWorkspaceSection.fieldwork:
      return selected ? Icons.assignment_ind : Icons.assignment_ind_outlined;
    case SurveyWorkspaceSection.participants:
      return selected ? Icons.groups : Icons.groups_outlined;
    case SurveyWorkspaceSection.analytics:
      return selected ? Icons.query_stats : Icons.query_stats_outlined;
    case SurveyWorkspaceSection.reports:
      return selected ? Icons.summarize : Icons.summarize_outlined;
  }
}

String surveyWorkspaceSectionDescription(SurveyWorkspaceSection section) {
  switch (section) {
    case SurveyWorkspaceSection.overview:
      return 'Command metrics and attention signals';
    case SurveyWorkspaceSection.builder:
      return 'Forms, logic, publishing, and evidence rules';
    case SurveyWorkspaceSection.fieldwork:
      return 'Assignments, interview progress, and queues';
    case SurveyWorkspaceSection.participants:
      return 'Survey intake and respondent access';
    case SurveyWorkspaceSection.analytics:
      return 'Question mix, quality, and review insights';
    case SurveyWorkspaceSection.reports:
      return 'Report packets, exports, and evidence sync';
  }
}
