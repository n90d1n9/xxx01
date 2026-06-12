import 'package:flutter/material.dart';

import '../models/project_portfolio_item.dart';

enum ProjectMilestoneForecastState { overdue, dueSoon, upcoming, scheduled }

class ProjectMilestoneForecastItem {
  const ProjectMilestoneForecastItem({
    required this.projectId,
    required this.projectName,
    required this.projectHealth,
    required this.label,
    required this.dueDate,
    required this.daysFromToday,
    required this.state,
  });

  final String projectId;
  final String projectName;
  final ProjectHealth projectHealth;
  final String label;
  final DateTime dueDate;
  final int daysFromToday;
  final ProjectMilestoneForecastState state;
}

class ProjectMilestoneForecastSummary {
  const ProjectMilestoneForecastSummary({
    required this.items,
    required this.horizonDays,
  });

  final List<ProjectMilestoneForecastItem> items;
  final int horizonDays;

  int get totalCount => items.length;
  int get overdueCount =>
      items
          .where((item) => item.state == ProjectMilestoneForecastState.overdue)
          .length;
  int get dueSoonCount =>
      items
          .where((item) => item.state == ProjectMilestoneForecastState.dueSoon)
          .length;
  int get upcomingCount =>
      items
          .where((item) => item.state == ProjectMilestoneForecastState.upcoming)
          .length;
  int get projectCount => items.map((item) => item.projectId).toSet().length;

  ProjectMilestoneForecastItem? get nextItem {
    final activeItems =
        items
            .where(
              (item) =>
                  item.state != ProjectMilestoneForecastState.scheduled ||
                  item.daysFromToday >= 0,
            )
            .toList()
          ..sort((left, right) {
            final leftDue = left.daysFromToday < 0 ? 0 : left.daysFromToday;
            final rightDue = right.daysFromToday < 0 ? 0 : right.daysFromToday;
            final dueCompare = leftDue.compareTo(rightDue);
            if (dueCompare != 0) return dueCompare;
            return left.projectName.compareTo(right.projectName);
          });

    return activeItems.isEmpty ? null : activeItems.first;
  }
}

extension ProjectMilestoneForecastStatePresentation
    on ProjectMilestoneForecastState {
  String get label {
    switch (this) {
      case ProjectMilestoneForecastState.overdue:
        return 'Overdue';
      case ProjectMilestoneForecastState.dueSoon:
        return 'Due Soon';
      case ProjectMilestoneForecastState.upcoming:
        return 'Upcoming';
      case ProjectMilestoneForecastState.scheduled:
        return 'Scheduled';
    }
  }

  IconData get icon {
    switch (this) {
      case ProjectMilestoneForecastState.overdue:
        return Icons.event_busy_outlined;
      case ProjectMilestoneForecastState.dueSoon:
        return Icons.notification_important_outlined;
      case ProjectMilestoneForecastState.upcoming:
        return Icons.flag_outlined;
      case ProjectMilestoneForecastState.scheduled:
        return Icons.event_available_outlined;
    }
  }

  Color color(ColorScheme colorScheme) {
    switch (this) {
      case ProjectMilestoneForecastState.overdue:
        return colorScheme.error;
      case ProjectMilestoneForecastState.dueSoon:
        return Colors.orange.shade700;
      case ProjectMilestoneForecastState.upcoming:
        return colorScheme.primary;
      case ProjectMilestoneForecastState.scheduled:
        return Colors.indigo.shade600;
    }
  }
}

ProjectMilestoneForecastSummary buildProjectMilestoneForecastSummary({
  required List<ProjectPortfolioItem> projects,
  DateTime? today,
  int horizonDays = 45,
}) {
  final asOf = DateUtils.dateOnly(today ?? DateTime.now());
  final items = <ProjectMilestoneForecastItem>[];

  for (final project in projects) {
    for (final milestone in project.milestones) {
      if (milestone.isComplete) continue;

      final dueDate = DateUtils.dateOnly(milestone.dueDate);
      final daysFromToday = dueDate.difference(asOf).inDays;
      if (daysFromToday > horizonDays) continue;

      items.add(
        ProjectMilestoneForecastItem(
          projectId: project.id,
          projectName: project.name,
          projectHealth: project.health,
          label: milestone.label,
          dueDate: dueDate,
          daysFromToday: daysFromToday,
          state: _forecastState(daysFromToday),
        ),
      );
    }
  }

  items.sort(_compareForecastItems);

  return ProjectMilestoneForecastSummary(
    items: List.unmodifiable(items),
    horizonDays: horizonDays,
  );
}

String projectMilestoneForecastDetail(ProjectMilestoneForecastItem item) {
  final days = item.daysFromToday.abs();
  final dayLabel = 'day${days == 1 ? '' : 's'}';

  if (item.daysFromToday < 0) {
    return '${item.projectName} is waiting on this milestone, $days $dayLabel overdue.';
  }

  if (item.daysFromToday == 0) {
    return '${item.projectName} has this milestone due today.';
  }

  return '${item.projectName} has this milestone due in $days $dayLabel.';
}

ProjectMilestoneForecastState _forecastState(int daysFromToday) {
  if (daysFromToday < 0) return ProjectMilestoneForecastState.overdue;
  if (daysFromToday <= 7) return ProjectMilestoneForecastState.dueSoon;
  if (daysFromToday <= 30) return ProjectMilestoneForecastState.upcoming;
  return ProjectMilestoneForecastState.scheduled;
}

int _compareForecastItems(
  ProjectMilestoneForecastItem left,
  ProjectMilestoneForecastItem right,
) {
  final stateCompare = _stateRank(
    left.state,
  ).compareTo(_stateRank(right.state));
  if (stateCompare != 0) return stateCompare;

  final dateCompare = left.dueDate.compareTo(right.dueDate);
  if (dateCompare != 0) return dateCompare;

  return left.projectName.compareTo(right.projectName);
}

int _stateRank(ProjectMilestoneForecastState state) {
  switch (state) {
    case ProjectMilestoneForecastState.overdue:
      return 0;
    case ProjectMilestoneForecastState.dueSoon:
      return 1;
    case ProjectMilestoneForecastState.upcoming:
      return 2;
    case ProjectMilestoneForecastState.scheduled:
      return 3;
  }
}
