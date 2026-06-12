/// Current aggregate collapse state for visible Gantt task branches.
enum GanttTreeCollapseState { expanded, mixed, collapsed }

/// Summary of visible branch collapse progress and available tree actions.
class GanttTreeControlSummary {
  const GanttTreeControlSummary({
    required this.branchCount,
    required this.collapsedCount,
    required this.state,
  });

  final int branchCount;
  final int collapsedCount;
  final GanttTreeCollapseState state;

  double get collapsedRatio {
    if (branchCount <= 0) return 0;
    return collapsedCount / branchCount;
  }

  String get countLabel => '$collapsedCount of $branchCount collapsed';

  String get stateLabel {
    switch (state) {
      case GanttTreeCollapseState.expanded:
        return 'Expanded';
      case GanttTreeCollapseState.mixed:
        return 'Mixed';
      case GanttTreeCollapseState.collapsed:
        return 'Collapsed';
    }
  }

  String get percentLabel {
    final percent = (collapsedRatio * 100).round();
    return '$percent% hidden';
  }

  bool get canCollapseAll => branchCount > 0 && collapsedCount < branchCount;

  bool get canExpandAll => collapsedCount > 0;

  String get collapseActionTooltip {
    if (!canCollapseAll) return 'All visible branches are already collapsed';

    return 'Collapse all visible branches';
  }

  String get expandActionTooltip {
    if (!canExpandAll) return 'All visible branches are already expanded';

    return 'Expand all visible branches';
  }

  String get tooltip {
    switch (state) {
      case GanttTreeCollapseState.expanded:
        return 'All visible branches are expanded';
      case GanttTreeCollapseState.mixed:
        return '$countLabel across visible branches';
      case GanttTreeCollapseState.collapsed:
        return 'All visible branches are collapsed';
    }
  }
}

/// Builds task-tree collapse summaries from visible branch counts.
class GanttTreeControlSummaryService {
  const GanttTreeControlSummaryService();

  GanttTreeControlSummary summaryFor({
    required int branchCount,
    required int collapsedCount,
  }) {
    final normalizedBranchCount = branchCount < 0 ? 0 : branchCount;
    final normalizedCollapsedCount =
        collapsedCount.clamp(0, normalizedBranchCount).toInt();

    return GanttTreeControlSummary(
      branchCount: normalizedBranchCount,
      collapsedCount: normalizedCollapsedCount,
      state: _stateFor(
        branchCount: normalizedBranchCount,
        collapsedCount: normalizedCollapsedCount,
      ),
    );
  }

  GanttTreeCollapseState _stateFor({
    required int branchCount,
    required int collapsedCount,
  }) {
    if (branchCount <= 0 || collapsedCount <= 0) {
      return GanttTreeCollapseState.expanded;
    }
    if (collapsedCount >= branchCount) return GanttTreeCollapseState.collapsed;

    return GanttTreeCollapseState.mixed;
  }
}
