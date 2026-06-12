import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_filter_chip_group.dart';

import '../gantt_dashboard.dart' as gantt;
import '../services/gantt_saved_view_service.dart';
import '../services/gantt_timeline_saved_view_presentation_service.dart';
import '../services/gantt_timeline_saved_view_summary_service.dart';

/// Saved timeline view selector with count-aware labels and tooltips.
class GanttTimelineSavedViewsBar extends StatelessWidget {
  const GanttTimelineSavedViewsBar({
    required this.tasks,
    required this.value,
    required this.onChanged,
    this.dependencyTasks,
    this.today,
    super.key,
  });

  final List<gantt.GanttTask> tasks;
  final List<gantt.GanttTask>? dependencyTasks;
  final GanttTimelineViewPreset value;
  final ValueChanged<GanttTimelineViewPreset> onChanged;
  final DateTime? today;

  @override
  Widget build(BuildContext context) {
    final counts = countGanttTimelineViews(
      tasks,
      dependencyTasks: dependencyTasks,
      today: today,
    );
    const summaryService = GanttTimelineSavedViewSummaryService();

    return AppFilterChipGroup<GanttTimelineViewPreset>(
      value: value,
      options: [
        for (final presentation in ganttTimelineSavedViewPresentations)
          _optionFor(
            presentation: presentation,
            count: counts[presentation.preset] ?? 0,
            summaryService: summaryService,
          ),
      ],
      onChanged: onChanged,
    );
  }

  AppFilterChipOption<GanttTimelineViewPreset> _optionFor({
    required GanttTimelineSavedViewPresentation presentation,
    required int count,
    required GanttTimelineSavedViewSummaryService summaryService,
  }) {
    final summary = summaryService.summaryFor(
      preset: presentation.preset,
      count: count,
    );

    return AppFilterChipOption(
      value: presentation.preset,
      label: presentation.label,
      icon: presentation.icon,
      count: count,
      tooltip: '${summary.intentLabel} - ${summary.tooltip}',
    );
  }
}
