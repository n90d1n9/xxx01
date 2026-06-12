import 'package:flutter/material.dart';

import '../models/project_portfolio_item.dart';

enum ProjectMilestoneTimelineState {
  overdue,
  dueSoon,
  upcoming,
  scheduled,
  done,
}

class ProjectMilestoneTimelineItem {
  const ProjectMilestoneTimelineItem({
    required this.label,
    required this.dueDate,
    required this.isComplete,
    required this.daysFromToday,
    required this.state,
  });

  final String label;
  final DateTime dueDate;
  final bool isComplete;
  final int daysFromToday;
  final ProjectMilestoneTimelineState state;

  String get dueLabel {
    if (isComplete) return 'Done';
    if (daysFromToday < 0) return '${daysFromToday.abs()}d overdue';
    if (daysFromToday == 0) return 'Due today';
    if (daysFromToday == 1) return 'Due tomorrow';

    return 'Due in ${daysFromToday}d';
  }
}

class ProjectMilestoneTimelineSummary {
  const ProjectMilestoneTimelineSummary({required this.items});

  final List<ProjectMilestoneTimelineItem> items;

  int get totalCount => items.length;
  int get openCount => items.where((item) => !item.isComplete).length;
  int get doneCount => items.where((item) => item.isComplete).length;
  int get overdueCount =>
      items
          .where((item) => item.state == ProjectMilestoneTimelineState.overdue)
          .length;
  int get dueSoonCount =>
      items
          .where((item) => item.state == ProjectMilestoneTimelineState.dueSoon)
          .length;

  ProjectMilestoneTimelineItem? get nextOpenItem {
    for (final item in items) {
      if (!item.isComplete) return item;
    }

    return null;
  }

  ProjectMilestoneTimelineState get signalState {
    if (overdueCount > 0) return ProjectMilestoneTimelineState.overdue;
    if (dueSoonCount > 0) return ProjectMilestoneTimelineState.dueSoon;
    if (openCount > 0) return ProjectMilestoneTimelineState.upcoming;

    return ProjectMilestoneTimelineState.done;
  }
}

extension ProjectMilestoneTimelineStatePresentation
    on ProjectMilestoneTimelineState {
  String get label {
    switch (this) {
      case ProjectMilestoneTimelineState.overdue:
        return 'Overdue';
      case ProjectMilestoneTimelineState.dueSoon:
        return 'Due Soon';
      case ProjectMilestoneTimelineState.upcoming:
        return 'Upcoming';
      case ProjectMilestoneTimelineState.scheduled:
        return 'Scheduled';
      case ProjectMilestoneTimelineState.done:
        return 'Done';
    }
  }

  IconData get icon {
    switch (this) {
      case ProjectMilestoneTimelineState.overdue:
        return Icons.event_busy_outlined;
      case ProjectMilestoneTimelineState.dueSoon:
        return Icons.notification_important_outlined;
      case ProjectMilestoneTimelineState.upcoming:
        return Icons.flag_outlined;
      case ProjectMilestoneTimelineState.scheduled:
        return Icons.event_available_outlined;
      case ProjectMilestoneTimelineState.done:
        return Icons.check_circle_outline;
    }
  }

  Color color(ColorScheme colorScheme) {
    switch (this) {
      case ProjectMilestoneTimelineState.overdue:
        return colorScheme.error;
      case ProjectMilestoneTimelineState.dueSoon:
        return Colors.orange.shade700;
      case ProjectMilestoneTimelineState.upcoming:
        return colorScheme.primary;
      case ProjectMilestoneTimelineState.scheduled:
        return Colors.indigo.shade600;
      case ProjectMilestoneTimelineState.done:
        return Colors.green.shade700;
    }
  }
}

ProjectMilestoneTimelineSummary buildProjectMilestoneTimelineSummary({
  required List<ProjectMilestone> milestones,
  DateTime? today,
  int dueSoonDays = 7,
  int upcomingDays = 30,
}) {
  final asOf = DateUtils.dateOnly(today ?? DateTime.now());
  final items = [
    for (final milestone in milestones)
      _timelineItem(
        milestone,
        today: asOf,
        dueSoonDays: dueSoonDays,
        upcomingDays: upcomingDays,
      ),
  ]..sort(_compareTimelineItems);

  return ProjectMilestoneTimelineSummary(items: List.unmodifiable(items));
}

ProjectMilestoneTimelineItem _timelineItem(
  ProjectMilestone milestone, {
  required DateTime today,
  required int dueSoonDays,
  required int upcomingDays,
}) {
  final dueDate = DateUtils.dateOnly(milestone.dueDate);
  final daysFromToday = dueDate.difference(today).inDays;

  return ProjectMilestoneTimelineItem(
    label: milestone.label,
    dueDate: dueDate,
    isComplete: milestone.isComplete,
    daysFromToday: daysFromToday,
    state: _stateFor(
      isComplete: milestone.isComplete,
      daysFromToday: daysFromToday,
      dueSoonDays: dueSoonDays,
      upcomingDays: upcomingDays,
    ),
  );
}

ProjectMilestoneTimelineState _stateFor({
  required bool isComplete,
  required int daysFromToday,
  required int dueSoonDays,
  required int upcomingDays,
}) {
  if (isComplete) return ProjectMilestoneTimelineState.done;
  if (daysFromToday < 0) return ProjectMilestoneTimelineState.overdue;
  if (daysFromToday <= dueSoonDays) {
    return ProjectMilestoneTimelineState.dueSoon;
  }
  if (daysFromToday <= upcomingDays) {
    return ProjectMilestoneTimelineState.upcoming;
  }

  return ProjectMilestoneTimelineState.scheduled;
}

int _compareTimelineItems(
  ProjectMilestoneTimelineItem left,
  ProjectMilestoneTimelineItem right,
) {
  final stateCompare = _stateRank(
    left.state,
  ).compareTo(_stateRank(right.state));
  if (stateCompare != 0) return stateCompare;

  final dateCompare = left.dueDate.compareTo(right.dueDate);
  if (dateCompare != 0) return dateCompare;

  return left.label.compareTo(right.label);
}

int _stateRank(ProjectMilestoneTimelineState state) {
  switch (state) {
    case ProjectMilestoneTimelineState.overdue:
      return 0;
    case ProjectMilestoneTimelineState.dueSoon:
      return 1;
    case ProjectMilestoneTimelineState.upcoming:
      return 2;
    case ProjectMilestoneTimelineState.scheduled:
      return 3;
    case ProjectMilestoneTimelineState.done:
      return 4;
  }
}
