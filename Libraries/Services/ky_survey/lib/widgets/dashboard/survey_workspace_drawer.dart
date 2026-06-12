import 'package:flutter/material.dart';

import '../../models/survey_role.dart';
import 'survey_workspace_menu.dart';
import 'survey_workspace_navigation.dart';

class SurveyWorkspaceDrawer extends StatelessWidget {
  final SurveyRole role;
  final List<SurveyWorkspaceSection> sections;
  final SurveyWorkspaceSection selectedSection;
  final ValueChanged<SurveyWorkspaceSection> onSectionSelected;
  final List<SurveyWorkspaceShortcut> shortcuts;
  final Map<SurveyWorkspaceSection, SurveyWorkspaceSectionBadge> sectionBadges;

  const SurveyWorkspaceDrawer({
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
    return Drawer(
      width: 320,
      child: SafeArea(
        bottom: false,
        child: SurveyWorkspaceMenu(
          role: role,
          sections: sections,
          selectedSection: selectedSection,
          onSectionSelected: (section) => _selectSection(context, section),
          shortcuts: _shortcutsForDrawer(context),
          sectionBadges: sectionBadges,
        ),
      ),
    );
  }

  void _selectSection(BuildContext context, SurveyWorkspaceSection section) {
    Navigator.of(context).pop();
    onSectionSelected(section);
  }

  List<SurveyWorkspaceShortcut> _shortcutsForDrawer(BuildContext context) {
    return shortcuts
        .map((shortcut) {
          final action = shortcut.onPressed;

          return SurveyWorkspaceShortcut(
            label: shortcut.label,
            subtitle: shortcut.subtitle,
            icon: shortcut.icon,
            onPressed: action == null
                ? null
                : () => _runShortcutAfterClose(context, action),
          );
        })
        .toList(growable: false);
  }

  void _runShortcutAfterClose(BuildContext context, VoidCallback action) {
    Navigator.of(context).pop();
    WidgetsBinding.instance.addPostFrameCallback((_) => action());
  }
}
