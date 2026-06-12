import 'package:flutter/material.dart';

import '../models/restaurant_models.dart';
import '../models/restaurant_task_filter.dart';
import '../models/restaurant_task_panel_data.dart';
import 'filtered_panel_body.dart';
import 'restaurant_empty_state.dart';
import 'restaurant_spaced_list.dart';
import 'restaurant_task_filter_bar.dart';
import 'restaurant_task_summary_strip.dart';
import 'shift_task_card.dart';

/// Builds the task panel body from task summary, filters, and visible tasks.
class RestaurantTaskPanelBody extends StatelessWidget {
  const RestaurantTaskPanelBody({
    super.key,
    required this.data,
    required this.onFilterChanged,
    required this.onShowAll,
    this.onCompleteTask,
    this.focusedTaskId,
  });

  final RestaurantTaskPanelData data;
  final ValueChanged<RestaurantTaskFilter> onFilterChanged;
  final VoidCallback onShowAll;
  final ValueChanged<String>? onCompleteTask;
  final String? focusedTaskId;

  @override
  Widget build(BuildContext context) {
    return RestaurantFilteredPanelBody(
      hasItems: data.hasTasks,
      hasVisibleItems: data.hasVisibleTasks,
      emptyState: const RestaurantEmptyState(
        icon: Icons.task_outlined,
        message: 'Follow-up work will appear here during service.',
      ),
      controls: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RestaurantTaskSummaryStrip(summary: data.summary),
          const SizedBox(height: 14),
          RestaurantTaskFilterBar(
            tasks: data.tasks,
            selectedFilter: data.selectedFilter,
            onFilterChanged: onFilterChanged,
          ),
        ],
      ),
      emptyResultsState: RestaurantEmptyState(
        icon: Icons.task_outlined,
        message:
            'No ${data.selectedFilter.label.toLowerCase()} follow-up tasks right now.',
        actionLabel: 'Show all',
        onAction: onShowAll,
      ),
      results: _ShiftTaskList(
        tasks: data.visibleTasks,
        onCompleteTask: onCompleteTask,
        focusedTaskId: focusedTaskId,
      ),
    );
  }
}

/// Renders filtered shift tasks with consistent spacing between cards.
class _ShiftTaskList extends StatelessWidget {
  const _ShiftTaskList({
    required this.tasks,
    required this.onCompleteTask,
    this.focusedTaskId,
  });

  final List<RestaurantShiftTask> tasks;
  final ValueChanged<String>? onCompleteTask;
  final String? focusedTaskId;

  @override
  Widget build(BuildContext context) {
    return RestaurantSpacedList<RestaurantShiftTask>(
      items: tasks,
      itemBuilder: (context, task, index) {
        return RestaurantShiftTaskCard(
          task: task,
          onCompleteTask: onCompleteTask,
          focused: task.id == focusedTaskId,
        );
      },
    );
  }
}
