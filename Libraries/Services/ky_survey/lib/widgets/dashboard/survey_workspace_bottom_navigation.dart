import 'package:flutter/material.dart';

import '../../models/survey_role.dart';
import 'survey_workspace_navigation.dart';

/// Renders the mobile workspace navigation bar with module status badges.
class SurveyWorkspaceBottomNavigation extends StatelessWidget {
  final List<SurveyWorkspaceSection> sections;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Map<SurveyWorkspaceSection, SurveyWorkspaceSectionBadge> sectionBadges;

  const SurveyWorkspaceBottomNavigation({
    super.key,
    required this.sections,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.sectionBadges = const {},
  });

  @override
  Widget build(BuildContext context) {
    if (sections.isEmpty) {
      return const SizedBox.shrink();
    }

    final effectiveIndex = selectedIndex.clamp(0, sections.length - 1);

    return NavigationBar(
      selectedIndex: effectiveIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: [
        for (final section in sections)
          NavigationDestination(
            icon: SurveyWorkspaceSectionNavigationIcon(
              section: section,
              badge: sectionBadges[section],
            ),
            selectedIcon: SurveyWorkspaceSectionNavigationIcon(
              section: section,
              selected: true,
              badge: sectionBadges[section],
            ),
            label: section.label,
          ),
      ],
    );
  }
}
