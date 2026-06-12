import 'package:flutter/material.dart';

import '../../logic/survey_role_capabilities.dart';
import '../../models/survey_role.dart';
import 'survey_workspace_bottom_navigation.dart';
import 'survey_workspace_drawer.dart';
import 'survey_workspace_navigation.dart';
import 'survey_workspace_sidebar.dart';

typedef SurveyWorkspaceShellBodyBuilder =
    Widget Function(
      BuildContext context,
      bool isWide,
      SurveyWorkspaceSection selectedSection,
    );

/// Provides the responsive shell for survey workspace navigation and actions.
class SurveyWorkspaceShell extends StatelessWidget {
  final SurveyRole role;
  final List<SurveyWorkspaceSection> sections;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final ValueChanged<SurveyWorkspaceSection> onSectionSelected;
  final List<SurveyWorkspaceShortcut> shortcuts;
  final Map<SurveyWorkspaceSection, SurveyWorkspaceSectionBadge> sectionBadges;
  final VoidCallback onOpenSurveyList;
  final VoidCallback onCreateSurvey;
  final SurveyWorkspaceShellBodyBuilder bodyBuilder;
  final double wideBreakpoint;

  const SurveyWorkspaceShell({
    super.key,
    required this.role,
    required this.sections,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.onSectionSelected,
    required this.onOpenSurveyList,
    required this.onCreateSurvey,
    required this.bodyBuilder,
    this.shortcuts = const [],
    this.sectionBadges = const {},
    this.wideBreakpoint = 960,
  }) : assert(sections.length > 0);

  @override
  Widget build(BuildContext context) {
    final effectiveIndex = selectedIndex.clamp(0, sections.length - 1);
    final selectedSection = sections[effectiveIndex];
    final capabilities = SurveyRoleCapabilities.forRole(role);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= wideBreakpoint;

        return Scaffold(
          drawer: isWide
              ? null
              : SurveyWorkspaceDrawer(
                  role: role,
                  sections: sections,
                  selectedSection: selectedSection,
                  onSectionSelected: onSectionSelected,
                  shortcuts: shortcuts,
                  sectionBadges: sectionBadges,
                ),
          appBar: AppBar(
            title: Text(role.workspaceTitle),
            actions: [
              if (capabilities.can(SurveyWorkspaceAction.viewSurveyList))
                IconButton(
                  tooltip: 'Survey list',
                  icon: const Icon(Icons.view_list_outlined),
                  onPressed: onOpenSurveyList,
                ),
              if (capabilities.can(SurveyWorkspaceAction.createSurvey))
                IconButton(
                  tooltip: 'Create survey',
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: onCreateSurvey,
                ),
            ],
          ),
          body: Row(
            children: [
              if (isWide)
                SurveyWorkspaceSidebar(
                  role: role,
                  sections: sections,
                  selectedSection: selectedSection,
                  onSectionSelected: onSectionSelected,
                  shortcuts: shortcuts,
                  sectionBadges: sectionBadges,
                ),
              Expanded(child: bodyBuilder(context, isWide, selectedSection)),
            ],
          ),
          bottomNavigationBar: isWide
              ? null
              : SurveyWorkspaceBottomNavigation(
                  sections: sections,
                  selectedIndex: effectiveIndex,
                  onDestinationSelected: onDestinationSelected,
                  sectionBadges: sectionBadges,
                ),
        );
      },
    );
  }
}
