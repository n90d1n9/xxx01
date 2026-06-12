import 'package:flutter/material.dart';

import '../../models/survey_role.dart';
import 'survey_workspace_menu.dart';
import 'survey_workspace_navigation.dart';

class SurveyWorkspaceSidebar extends StatelessWidget {
  final SurveyRole role;
  final List<SurveyWorkspaceSection> sections;
  final SurveyWorkspaceSection selectedSection;
  final ValueChanged<SurveyWorkspaceSection> onSectionSelected;
  final List<SurveyWorkspaceShortcut> shortcuts;
  final Map<SurveyWorkspaceSection, SurveyWorkspaceSectionBadge> sectionBadges;

  const SurveyWorkspaceSidebar({
    super.key,
    required this.role,
    required this.sections,
    required this.selectedSection,
    required this.onSectionSelected,
    this.shortcuts = const [],
    this.sectionBadges = const {},
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 284,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(right: BorderSide(color: colorScheme.outlineVariant)),
        ),
        child: SafeArea(
          bottom: false,
          child: SurveyWorkspaceMenu(
            role: role,
            sections: sections,
            selectedSection: selectedSection,
            onSectionSelected: onSectionSelected,
            shortcuts: shortcuts,
            sectionBadges: sectionBadges,
          ),
        ),
      ),
    );
  }
}
