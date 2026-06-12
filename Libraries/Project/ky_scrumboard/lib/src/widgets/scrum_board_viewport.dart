import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../controllers/scrum_board_controller.dart';
import '../../models/scrum_board_config.dart';
import '../../models/scrum_board_filter.dart';
import '../../models/scrum_task.dart';
import '../../models/scrum_task_status.dart';
import '../scrum_board_palette.dart';
import 'board_lane_callbacks.dart';
import 'board_lane_collection.dart';
import 'board_lane_surface.dart';
import 'board_task_callbacks.dart';
import 'scrum_board_insights_panel.dart';

/// Responsive board viewport that arranges lanes and optional insights.
class ScrumBoardViewport extends StatelessWidget {
  const ScrumBoardViewport({
    super.key,
    required this.controller,
    required this.config,
    required this.filter,
    required this.selectedTaskIds,
    required this.collapsedStatuses,
    required this.onFilterChanged,
    required this.onColumnCollapsedChanged,
    required this.onVisibleColumnsCollapsedChanged,
    required this.onCreateTask,
    required this.onTaskPressed,
    this.onTaskSelectionChanged,
    this.onTaskBatchSelectionChanged,
  });

  final ScrumBoardController controller;
  final ScrumBoardConfig config;
  final ScrumBoardFilter filter;
  final Set<String> selectedTaskIds;
  final Set<ScrumTaskStatus> collapsedStatuses;
  final ValueChanged<ScrumBoardFilter> onFilterChanged;
  final ScrumColumnCollapseChanged onColumnCollapsedChanged;
  final ScrumVisibleColumnsCollapseChanged onVisibleColumnsCollapsedChanged;
  final ScrumTaskCreateRequest onCreateTask;
  final ValueChanged<ScrumTask> onTaskPressed;
  final ScrumTaskSelectionHandler? onTaskSelectionChanged;
  final ScrumTaskBatchSelectionHandler? onTaskBatchSelectionChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < config.compactBreakpoint;
          final wide = constraints.maxWidth >= config.wideInsightsBreakpoint;
          final statuses = _visibleStatusesFor(config, filter);
          final insightsPanel = ScrumBoardInsightsPanel(
            summary: controller.summary,
            insights: controller.insights(),
            assigneeLoads: controller.assigneeLoads(),
            recentActivities: config.showActivityFeed
                ? controller.recentActivities(limit: config.activityFeedLimit)
                : const [],
            statusLabelFor: config.labelFor,
            sprint: config.sprint,
          );
          final columnBoard = BoardLaneCollection(
            controller: controller,
            config: config,
            filter: filter,
            statuses: statuses,
            compact: compact,
            selectedTaskIds: selectedTaskIds,
            collapsedStatuses: collapsedStatuses,
            onFilterChanged: onFilterChanged,
            onColumnCollapsedChanged: onColumnCollapsedChanged,
            onCreateTask: onCreateTask,
            onTaskPressed: onTaskPressed,
            onTaskSelectionChanged: onTaskSelectionChanged,
            onTaskBatchSelectionChanged: onTaskBatchSelectionChanged,
          );
          final boardSurface = BoardLaneSurface(
            statuses: statuses,
            collapsedStatuses: collapsedStatuses,
            onCollapsedChanged: onVisibleColumnsCollapsedChanged,
            child: columnBoard,
          );

          if (!config.showInsights) return boardSurface;

          if (wide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: boardSurface),
                const SizedBox(width: 14),
                SizedBox(
                  width: config.insightsPanelWidth,
                  child: insightsPanel,
                ),
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              insightsPanel,
              const SizedBox(height: 14),
              Expanded(child: boardSurface),
            ],
          );
        },
      ),
    );
  }
}

/// Preview for the extracted board viewport in its desktop layout.
@Preview(group: 'Ky Scrumboard', name: 'Board viewport', size: Size(1200, 760))
Widget scrumBoardViewportPreview() {
  const config = ScrumBoardConfig();
  final controller = ScrumBoardController.demo(config: config);

  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true),
    home: Scaffold(
      backgroundColor: ScrumBoardPalette.background,
      body: ScrumBoardViewport(
        controller: controller,
        config: config,
        filter: const ScrumBoardFilter(),
        selectedTaskIds: const {},
        collapsedStatuses: const {},
        onFilterChanged: (_) {},
        onColumnCollapsedChanged: (_, _) {},
        onVisibleColumnsCollapsedChanged: (_, _) {},
        onCreateTask: ({ScrumTaskStatus? status}) {},
        onTaskPressed: (_) {},
      ),
    ),
  );
}

List<ScrumTaskStatus> _visibleStatusesFor(
  ScrumBoardConfig config,
  ScrumBoardFilter filter,
) {
  final visibleStatuses = config.visibleStatuses;
  final filteredStatus = filter.status;
  if (filteredStatus == null || !visibleStatuses.contains(filteredStatus)) {
    return visibleStatuses;
  }
  return [filteredStatus];
}
