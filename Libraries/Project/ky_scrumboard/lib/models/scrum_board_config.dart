import 'scrum_board_view_preset.dart';
import 'scrum_task_status.dart';
import 'scrum_sprint.dart';
import 'scrum_workflow_policy.dart';

const defaultScrumTaskStatuses = [
  ScrumTaskStatus.backlog,
  ScrumTaskStatus.todo,
  ScrumTaskStatus.inProgress,
  ScrumTaskStatus.review,
  ScrumTaskStatus.done,
];

class ScrumBoardConfig {
  const ScrumBoardConfig({
    this.title = 'Scrum Board',
    this.subtitle = 'Delivery board for sprint planning, review, and handoff.',
    this.statuses = defaultScrumTaskStatuses,
    this.statusLabels = const {},
    this.viewPresets = defaultScrumBoardViewPresets,
    this.sprint,
    this.policy = const ScrumWorkflowPolicy(),
    this.showInsights = true,
    this.showActivityFeed = true,
    this.showPriorityFilter = true,
    this.showAssigneeFilter = true,
    this.showSortControl = true,
    this.showViewPresets = true,
    this.showBulkActions = true,
    this.initialStatusFilter,
    this.initialViewPresetId,
    this.activityFeedLimit = 5,
    this.compactBreakpoint = 760,
    this.wideInsightsBreakpoint = 1180,
    this.columnWidth = 320,
    this.compactColumnHeight = 420,
    this.insightsPanelWidth = 340,
  });

  final String title;
  final String subtitle;
  final List<ScrumTaskStatus> statuses;
  final Map<ScrumTaskStatus, String> statusLabels;
  final List<ScrumBoardViewPreset> viewPresets;
  final ScrumSprint? sprint;
  final ScrumWorkflowPolicy policy;
  final bool showInsights;
  final bool showActivityFeed;
  final bool showPriorityFilter;
  final bool showAssigneeFilter;
  final bool showSortControl;
  final bool showViewPresets;
  final bool showBulkActions;
  final ScrumTaskStatus? initialStatusFilter;
  final String? initialViewPresetId;
  final int activityFeedLimit;
  final double compactBreakpoint;
  final double wideInsightsBreakpoint;
  final double columnWidth;
  final double compactColumnHeight;
  final double insightsPanelWidth;

  List<ScrumTaskStatus> get visibleStatuses {
    final normalized = <ScrumTaskStatus>[];
    for (final status in statuses) {
      if (!normalized.contains(status)) normalized.add(status);
    }
    return normalized.isEmpty
        ? defaultScrumTaskStatuses
        : List<ScrumTaskStatus>.unmodifiable(normalized);
  }

  List<ScrumBoardViewPreset> get visibleViewPresets {
    final normalized = <ScrumBoardViewPreset>[];
    final ids = <String>{};
    for (final preset in viewPresets) {
      final id = preset.id.trim();
      if (id.isEmpty || !ids.add(id)) continue;
      normalized.add(preset);
    }
    return List<ScrumBoardViewPreset>.unmodifiable(normalized);
  }

  ScrumBoardViewPreset? presetById(String id) {
    final normalizedId = id.trim();
    for (final preset in visibleViewPresets) {
      if (preset.id == normalizedId) return preset;
    }
    return null;
  }

  String labelFor(ScrumTaskStatus status) {
    return statusLabels[status] ?? status.label;
  }

  bool includesStatus(ScrumTaskStatus status) {
    return visibleStatuses.contains(status);
  }

  ScrumBoardConfig copyWith({
    String? title,
    String? subtitle,
    List<ScrumTaskStatus>? statuses,
    Map<ScrumTaskStatus, String>? statusLabels,
    List<ScrumBoardViewPreset>? viewPresets,
    ScrumSprint? sprint,
    ScrumWorkflowPolicy? policy,
    bool? showInsights,
    bool? showActivityFeed,
    bool? showPriorityFilter,
    bool? showAssigneeFilter,
    bool? showSortControl,
    bool? showViewPresets,
    bool? showBulkActions,
    ScrumTaskStatus? initialStatusFilter,
    String? initialViewPresetId,
    int? activityFeedLimit,
    double? compactBreakpoint,
    double? wideInsightsBreakpoint,
    double? columnWidth,
    double? compactColumnHeight,
    double? insightsPanelWidth,
  }) {
    return ScrumBoardConfig(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      statuses: statuses ?? this.statuses,
      statusLabels: statusLabels ?? this.statusLabels,
      viewPresets: viewPresets ?? this.viewPresets,
      sprint: sprint ?? this.sprint,
      policy: policy ?? this.policy,
      showInsights: showInsights ?? this.showInsights,
      showActivityFeed: showActivityFeed ?? this.showActivityFeed,
      showPriorityFilter: showPriorityFilter ?? this.showPriorityFilter,
      showAssigneeFilter: showAssigneeFilter ?? this.showAssigneeFilter,
      showSortControl: showSortControl ?? this.showSortControl,
      showViewPresets: showViewPresets ?? this.showViewPresets,
      showBulkActions: showBulkActions ?? this.showBulkActions,
      initialStatusFilter: initialStatusFilter ?? this.initialStatusFilter,
      initialViewPresetId: initialViewPresetId ?? this.initialViewPresetId,
      activityFeedLimit: activityFeedLimit ?? this.activityFeedLimit,
      compactBreakpoint: compactBreakpoint ?? this.compactBreakpoint,
      wideInsightsBreakpoint:
          wideInsightsBreakpoint ?? this.wideInsightsBreakpoint,
      columnWidth: columnWidth ?? this.columnWidth,
      compactColumnHeight: compactColumnHeight ?? this.compactColumnHeight,
      insightsPanelWidth: insightsPanelWidth ?? this.insightsPanelWidth,
    );
  }
}
