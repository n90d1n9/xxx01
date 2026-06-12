import 'package:flutter/material.dart';

import '../models/project_decision_record.dart';
import 'project_decision_register_service.dart';

/// Overall timing health for open project decision records.
enum ProjectDecisionSlaSignal { breached, dueSoon, healthy }

/// Due-date lane used to group open project decision records.
enum ProjectDecisionSlaBucket {
  overdue,
  dueToday,
  dueSoon,
  onTrack,
  unscheduled,
}

/// Decision record with computed SLA timing metadata.
class ProjectDecisionSlaItem {
  const ProjectDecisionSlaItem({required this.record, required this.today});

  final ProjectDecisionRecord record;
  final DateTime today;

  DateTime? get dueDate => record.dueDate;

  int? get daysRemaining {
    final date = dueDate;
    if (date == null) return null;

    return DateUtils.dateOnly(
      date,
    ).difference(DateUtils.dateOnly(today)).inDays;
  }

  ProjectDecisionSlaBucket get bucket {
    final days = daysRemaining;
    if (days == null) return ProjectDecisionSlaBucket.unscheduled;
    if (days < 0) return ProjectDecisionSlaBucket.overdue;
    if (days == 0) return ProjectDecisionSlaBucket.dueToday;
    if (days <= 7) return ProjectDecisionSlaBucket.dueSoon;

    return ProjectDecisionSlaBucket.onTrack;
  }

  ProjectDecisionSlaSignal get signal {
    switch (bucket) {
      case ProjectDecisionSlaBucket.overdue:
        return ProjectDecisionSlaSignal.breached;
      case ProjectDecisionSlaBucket.dueToday:
      case ProjectDecisionSlaBucket.dueSoon:
      case ProjectDecisionSlaBucket.unscheduled:
        return ProjectDecisionSlaSignal.dueSoon;
      case ProjectDecisionSlaBucket.onTrack:
        return ProjectDecisionSlaSignal.healthy;
    }
  }

  String get timingLabel {
    final days = daysRemaining;
    if (days == null) return 'No due date';
    if (days < 0) return '${days.abs()} days overdue';
    if (days == 0) return 'Due today';
    if (days == 1) return 'Due tomorrow';

    return 'Due in $days days';
  }
}

/// Open decision records grouped into one SLA timing lane.
class ProjectDecisionSlaBucketSummary {
  const ProjectDecisionSlaBucketSummary({
    required this.bucket,
    required this.items,
  });

  final ProjectDecisionSlaBucket bucket;
  final List<ProjectDecisionSlaItem> items;

  int get count => items.length;
  bool get isEmpty => items.isEmpty;

  ProjectDecisionSlaItem? get primaryItem {
    if (items.isEmpty) return null;

    return items.first;
  }

  ProjectDecisionSlaSignal get signal {
    switch (bucket) {
      case ProjectDecisionSlaBucket.overdue:
        return ProjectDecisionSlaSignal.breached;
      case ProjectDecisionSlaBucket.dueToday:
      case ProjectDecisionSlaBucket.dueSoon:
      case ProjectDecisionSlaBucket.unscheduled:
        return ProjectDecisionSlaSignal.dueSoon;
      case ProjectDecisionSlaBucket.onTrack:
        return ProjectDecisionSlaSignal.healthy;
    }
  }

  String get detail {
    final primary = primaryItem;
    if (primary == null) return 'No open decisions in this SLA lane.';

    return '$count decisions - ${primary.timingLabel} - priority: ${primary.record.title}.';
  }
}

/// SLA tracker summary for decision timing, counts, and copy-ready text.
class ProjectDecisionSlaTrackerSummary {
  const ProjectDecisionSlaTrackerSummary({
    required this.register,
    required this.buckets,
    required this.briefText,
  });

  final ProjectDecisionRegisterSummary register;
  final List<ProjectDecisionSlaBucketSummary> buckets;
  final String briefText;

  int get openCount => register.openCount;
  int get bucketCount => buckets.where((bucket) => !bucket.isEmpty).length;
  int get overdueCount => _count(ProjectDecisionSlaBucket.overdue);
  int get dueTodayCount => _count(ProjectDecisionSlaBucket.dueToday);
  int get dueSoonCount => _count(ProjectDecisionSlaBucket.dueSoon);
  int get onTrackCount => _count(ProjectDecisionSlaBucket.onTrack);
  int get unscheduledCount => _count(ProjectDecisionSlaBucket.unscheduled);
  int get urgentCount => overdueCount + dueTodayCount + dueSoonCount;

  ProjectDecisionSlaBucketSummary? get primaryBucket {
    for (final bucket in buckets) {
      if (!bucket.isEmpty) return bucket;
    }

    return null;
  }

  ProjectDecisionSlaSignal get signal {
    if (overdueCount > 0) return ProjectDecisionSlaSignal.breached;
    if (dueTodayCount > 0 || dueSoonCount > 0 || unscheduledCount > 0) {
      return ProjectDecisionSlaSignal.dueSoon;
    }

    return ProjectDecisionSlaSignal.healthy;
  }

  String get title {
    switch (signal) {
      case ProjectDecisionSlaSignal.breached:
        return 'Decision SLA has breached items';
      case ProjectDecisionSlaSignal.dueSoon:
        return 'Decision SLA needs timing attention';
      case ProjectDecisionSlaSignal.healthy:
        return 'Decision SLA on track';
    }
  }

  String get subtitle {
    final primary = primaryBucket;
    if (primary == null) return 'No open decisions need timing follow-up.';

    return '$openCount open decisions - $urgentCount urgent - '
        'primary lane: ${primary.bucket.label}.';
  }

  int _count(ProjectDecisionSlaBucket bucket) {
    return buckets
        .where((summary) => summary.bucket == bucket)
        .fold(0, (sum, summary) => sum + summary.count);
  }
}

/// Builds a decision SLA tracker from the normalized decision register.
ProjectDecisionSlaTrackerSummary buildProjectDecisionSlaTracker(
  ProjectDecisionRegisterSummary register,
) {
  final items = [
    for (final record in register.records)
      if (record.isOpen)
        ProjectDecisionSlaItem(record: record, today: register.today),
  ]..sort(_compareItems);
  final bucketSummaries = [
    for (final bucket in ProjectDecisionSlaBucket.values)
      ProjectDecisionSlaBucketSummary(
        bucket: bucket,
        items: List.unmodifiable(
          items.where((item) => item.bucket == bucket).toList(),
        ),
      ),
  ];
  final summary = ProjectDecisionSlaTrackerSummary(
    register: register,
    buckets: List.unmodifiable(bucketSummaries),
    briefText: '',
  );

  return ProjectDecisionSlaTrackerSummary(
    register: register,
    buckets: summary.buckets,
    briefText: _briefText(summary),
  );
}

int _compareItems(ProjectDecisionSlaItem left, ProjectDecisionSlaItem right) {
  final bucketComparison = _bucketPriority(
    left.bucket,
  ).compareTo(_bucketPriority(right.bucket));
  if (bucketComparison != 0) return bucketComparison;

  final priorityComparison = _priorityValue(
    left.record.priority,
  ).compareTo(_priorityValue(right.record.priority));
  if (priorityComparison != 0) return priorityComparison;

  final leftDueDate = left.dueDate;
  final rightDueDate = right.dueDate;
  if (leftDueDate != null && rightDueDate != null) {
    final dueDateComparison = leftDueDate.compareTo(rightDueDate);
    if (dueDateComparison != 0) return dueDateComparison;
  } else if (leftDueDate != null) {
    return -1;
  } else if (rightDueDate != null) {
    return 1;
  }

  return left.record.title.compareTo(right.record.title);
}

int _bucketPriority(ProjectDecisionSlaBucket bucket) {
  switch (bucket) {
    case ProjectDecisionSlaBucket.overdue:
      return 0;
    case ProjectDecisionSlaBucket.dueToday:
      return 1;
    case ProjectDecisionSlaBucket.dueSoon:
      return 2;
    case ProjectDecisionSlaBucket.unscheduled:
      return 3;
    case ProjectDecisionSlaBucket.onTrack:
      return 4;
  }
}

int _priorityValue(ProjectDecisionPriority priority) {
  switch (priority) {
    case ProjectDecisionPriority.critical:
      return 0;
    case ProjectDecisionPriority.high:
      return 1;
    case ProjectDecisionPriority.medium:
      return 2;
    case ProjectDecisionPriority.low:
      return 3;
  }
}

String _briefText(ProjectDecisionSlaTrackerSummary summary) {
  return [
    '${summary.register.project.name} decision SLA tracker',
    'Signal: ${summary.signal.label}',
    'Open decisions: ${summary.openCount}',
    'Overdue: ${summary.overdueCount}',
    'Due today: ${summary.dueTodayCount}',
    'Due soon: ${summary.dueSoonCount}',
    'On track: ${summary.onTrackCount}',
    'Unscheduled: ${summary.unscheduledCount}',
    '',
    'SLA lanes:',
    for (final bucket in summary.buckets)
      '- ${bucket.bucket.label}: ${bucket.count} decisions'
          '${bucket.primaryItem == null ? '' : ' - ${bucket.primaryItem!.record.title}'}',
  ].join('\n');
}

extension ProjectDecisionSlaSignalPresentation on ProjectDecisionSlaSignal {
  /// User-facing label for decision SLA health.
  String get label {
    switch (this) {
      case ProjectDecisionSlaSignal.breached:
        return 'Breached';
      case ProjectDecisionSlaSignal.dueSoon:
        return 'Due soon';
      case ProjectDecisionSlaSignal.healthy:
        return 'Healthy';
    }
  }

  /// Icon for decision SLA health.
  IconData get icon {
    switch (this) {
      case ProjectDecisionSlaSignal.breached:
        return Icons.event_busy_outlined;
      case ProjectDecisionSlaSignal.dueSoon:
        return Icons.event_available_outlined;
      case ProjectDecisionSlaSignal.healthy:
        return Icons.verified_outlined;
    }
  }

  /// Color for decision SLA health.
  Color color(ColorScheme colorScheme) {
    switch (this) {
      case ProjectDecisionSlaSignal.breached:
        return colorScheme.error;
      case ProjectDecisionSlaSignal.dueSoon:
        return Colors.orange.shade700;
      case ProjectDecisionSlaSignal.healthy:
        return Colors.green.shade700;
    }
  }
}

extension ProjectDecisionSlaBucketPresentation on ProjectDecisionSlaBucket {
  /// User-facing label for an SLA timing lane.
  String get label {
    switch (this) {
      case ProjectDecisionSlaBucket.overdue:
        return 'Overdue';
      case ProjectDecisionSlaBucket.dueToday:
        return 'Today';
      case ProjectDecisionSlaBucket.dueSoon:
        return 'Next 7d';
      case ProjectDecisionSlaBucket.onTrack:
        return 'On track';
      case ProjectDecisionSlaBucket.unscheduled:
        return 'Unscheduled';
    }
  }

  /// Icon for an SLA timing lane.
  IconData get icon {
    switch (this) {
      case ProjectDecisionSlaBucket.overdue:
        return Icons.event_busy_outlined;
      case ProjectDecisionSlaBucket.dueToday:
        return Icons.today_outlined;
      case ProjectDecisionSlaBucket.dueSoon:
        return Icons.event_available_outlined;
      case ProjectDecisionSlaBucket.onTrack:
        return Icons.verified_outlined;
      case ProjectDecisionSlaBucket.unscheduled:
        return Icons.event_note_outlined;
    }
  }

  /// Color for an SLA timing lane.
  Color color(ColorScheme colorScheme) {
    switch (this) {
      case ProjectDecisionSlaBucket.overdue:
        return colorScheme.error;
      case ProjectDecisionSlaBucket.dueToday:
      case ProjectDecisionSlaBucket.dueSoon:
      case ProjectDecisionSlaBucket.unscheduled:
        return Colors.orange.shade700;
      case ProjectDecisionSlaBucket.onTrack:
        return Colors.green.shade700;
    }
  }
}
