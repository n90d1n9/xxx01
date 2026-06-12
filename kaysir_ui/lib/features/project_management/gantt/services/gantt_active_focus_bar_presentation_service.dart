import 'package:flutter/material.dart';

/// Visual roles for focus chips shown in the active focus bar.
enum GanttActiveFocusChipRole {
  result,
  project,
  branch,
  branchTaskCount,
  branchProgress,
  branchDateRange,
  branchRisk,
  view,
  range,
  status,
  query,
}

/// Accent group used to resolve active focus chip colors.
enum GanttActiveFocusChipAccent { primary, secondary, tertiary, error, custom }

const ganttActiveFocusClearProjectButtonKey = ValueKey(
  'gantt-active-focus-clear-project-button',
);
const ganttActiveFocusClearBranchButtonKey = ValueKey(
  'gantt-active-focus-clear-branch-button',
);
const ganttActiveFocusClearViewButtonKey = ValueKey(
  'gantt-active-focus-clear-view-button',
);
const ganttActiveFocusClearRangeButtonKey = ValueKey(
  'gantt-active-focus-clear-range-button',
);
const ganttActiveFocusClearStatusButtonKey = ValueKey(
  'gantt-active-focus-clear-status-button',
);
const ganttActiveFocusClearQueryButtonKey = ValueKey(
  'gantt-active-focus-clear-query-button',
);

/// Layout values for the active focus bar.
class GanttActiveFocusBarLayout {
  const GanttActiveFocusBarLayout({
    required this.topPadding,
    required this.spacing,
    required this.runSpacing,
  });

  final double topPadding;
  final double spacing;
  final double runSpacing;
}

/// Visual metadata for the active focus bar leading summary.
class GanttActiveFocusHeaderPresentation {
  const GanttActiveFocusHeaderPresentation({
    required this.title,
    required this.icon,
    required this.minWidth,
    required this.maxWidth,
  });

  final String title;
  final IconData icon;
  final double minWidth;
  final double maxWidth;
}

/// Visual metadata for a focus chip.
class GanttActiveFocusChipPresentation {
  const GanttActiveFocusChipPresentation({
    required this.role,
    required this.icon,
    required this.maxWidth,
    required this.accent,
    this.clearButtonKey,
    this.clearTooltip,
  });

  final GanttActiveFocusChipRole role;
  final IconData? icon;
  final double maxWidth;
  final GanttActiveFocusChipAccent accent;
  final Key? clearButtonKey;
  final String? clearTooltip;

  Color colorFor(ColorScheme colorScheme, {Color? customColor}) {
    switch (accent) {
      case GanttActiveFocusChipAccent.primary:
        return colorScheme.primary;
      case GanttActiveFocusChipAccent.secondary:
        return colorScheme.secondary;
      case GanttActiveFocusChipAccent.tertiary:
        return colorScheme.tertiary;
      case GanttActiveFocusChipAccent.error:
        return colorScheme.error;
      case GanttActiveFocusChipAccent.custom:
        return customColor ?? colorScheme.primary;
    }
  }
}

/// Provides reusable layout and chip presentation for the active focus bar.
class GanttActiveFocusBarPresentationService {
  const GanttActiveFocusBarPresentationService();

  static const layout = GanttActiveFocusBarLayout(
    topPadding: 12,
    spacing: 10,
    runSpacing: 10,
  );

  static const header = GanttActiveFocusHeaderPresentation(
    title: 'Active focus',
    icon: Icons.filter_alt_outlined,
    minWidth: 170,
    maxWidth: 260,
  );

  GanttActiveFocusChipPresentation chipPresentationFor(
    GanttActiveFocusChipRole role,
  ) {
    for (final presentation in ganttActiveFocusChipPresentations) {
      if (presentation.role == role) return presentation;
    }

    throw ArgumentError.value(role, 'role', 'Unknown active focus chip role');
  }
}

const ganttActiveFocusChipPresentations = [
  GanttActiveFocusChipPresentation(
    role: GanttActiveFocusChipRole.result,
    icon: Icons.visibility_outlined,
    maxWidth: 180,
    accent: GanttActiveFocusChipAccent.primary,
  ),
  GanttActiveFocusChipPresentation(
    role: GanttActiveFocusChipRole.project,
    icon: Icons.workspaces_outline,
    maxWidth: 240,
    accent: GanttActiveFocusChipAccent.primary,
    clearButtonKey: ganttActiveFocusClearProjectButtonKey,
    clearTooltip: 'Clear project focus',
  ),
  GanttActiveFocusChipPresentation(
    role: GanttActiveFocusChipRole.branch,
    icon: Icons.account_tree_outlined,
    maxWidth: 240,
    accent: GanttActiveFocusChipAccent.secondary,
    clearButtonKey: ganttActiveFocusClearBranchButtonKey,
    clearTooltip: 'Clear branch focus',
  ),
  GanttActiveFocusChipPresentation(
    role: GanttActiveFocusChipRole.branchTaskCount,
    icon: Icons.format_list_bulleted_rounded,
    maxWidth: 120,
    accent: GanttActiveFocusChipAccent.secondary,
  ),
  GanttActiveFocusChipPresentation(
    role: GanttActiveFocusChipRole.branchProgress,
    icon: Icons.trending_up_rounded,
    maxWidth: 120,
    accent: GanttActiveFocusChipAccent.primary,
  ),
  GanttActiveFocusChipPresentation(
    role: GanttActiveFocusChipRole.branchDateRange,
    icon: Icons.date_range_outlined,
    maxWidth: 150,
    accent: GanttActiveFocusChipAccent.tertiary,
  ),
  GanttActiveFocusChipPresentation(
    role: GanttActiveFocusChipRole.branchRisk,
    icon: Icons.warning_amber_rounded,
    maxWidth: 120,
    accent: GanttActiveFocusChipAccent.error,
  ),
  GanttActiveFocusChipPresentation(
    role: GanttActiveFocusChipRole.view,
    icon: null,
    maxWidth: 200,
    accent: GanttActiveFocusChipAccent.primary,
    clearButtonKey: ganttActiveFocusClearViewButtonKey,
    clearTooltip: 'Clear timeline view',
  ),
  GanttActiveFocusChipPresentation(
    role: GanttActiveFocusChipRole.range,
    icon: null,
    maxWidth: 200,
    accent: GanttActiveFocusChipAccent.tertiary,
    clearButtonKey: ganttActiveFocusClearRangeButtonKey,
    clearTooltip: 'Clear range preset',
  ),
  GanttActiveFocusChipPresentation(
    role: GanttActiveFocusChipRole.status,
    icon: null,
    maxWidth: 180,
    accent: GanttActiveFocusChipAccent.custom,
    clearButtonKey: ganttActiveFocusClearStatusButtonKey,
    clearTooltip: 'Clear status filter',
  ),
  GanttActiveFocusChipPresentation(
    role: GanttActiveFocusChipRole.query,
    icon: Icons.search,
    maxWidth: 220,
    accent: GanttActiveFocusChipAccent.secondary,
    clearButtonKey: ganttActiveFocusClearQueryButtonKey,
    clearTooltip: 'Clear search',
  ),
];
