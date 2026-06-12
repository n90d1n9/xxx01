import 'package:flutter/material.dart';

import '../../gantt/gantt_dashboard.dart' as gantt;
import '../models/project_portfolio_item.dart';

enum ProjectHandoffUrgency { steady, watch, urgent, blocked }

class ProjectHandoffMilestone {
  const ProjectHandoffMilestone({
    required this.label,
    required this.dueDate,
    required this.daysUntilDue,
  });

  final String label;
  final DateTime dueDate;
  final int daysUntilDue;

  bool get isOverdue => daysUntilDue < 0;

  String get dueLabel {
    if (daysUntilDue < 0) return '${daysUntilDue.abs()}d overdue';
    if (daysUntilDue == 0) return 'Due today';
    if (daysUntilDue == 1) return 'Due tomorrow';

    return 'Due in ${daysUntilDue}d';
  }
}

class ProjectHandoffRisk {
  const ProjectHandoffRisk({
    required this.title,
    required this.detail,
    required this.severity,
  });

  final String title;
  final String detail;
  final ProjectHealth severity;
}

class ProjectHandoffBrief {
  const ProjectHandoffBrief({
    required this.project,
    required this.urgency,
    required this.timelineTaskCount,
    required this.overdueTaskCount,
    required this.briefText,
    this.nextMilestone,
    this.topRisk,
  });

  final ProjectPortfolioItem project;
  final ProjectHandoffUrgency urgency;
  final int timelineTaskCount;
  final int overdueTaskCount;
  final String briefText;
  final ProjectHandoffMilestone? nextMilestone;
  final ProjectHandoffRisk? topRisk;

  String get ownerLine {
    final sponsor = project.sponsor.trim();
    if (sponsor.isEmpty) return project.owner;

    return '${project.owner} - Sponsor: $sponsor';
  }

  String get title {
    switch (urgency) {
      case ProjectHandoffUrgency.blocked:
        return 'Handoff blocked delivery';
      case ProjectHandoffUrgency.urgent:
        return 'Handoff recovery actions';
      case ProjectHandoffUrgency.watch:
        return 'Handoff watch items';
      case ProjectHandoffUrgency.steady:
        return 'Handoff routine follow-up';
    }
  }

  String get detail {
    if (project.health == ProjectHealth.blocked) {
      return '${project.owner} owns unblock coordination before the next delivery review.';
    }

    final risk = topRisk;
    if (risk?.severity == ProjectHealth.blocked) {
      return '${risk!.title} needs a signed owner and next action.';
    }

    if (overdueTaskCount > 0) {
      return '$overdueTaskCount linked timeline task${overdueTaskCount == 1 ? '' : 's'} need recovery ownership.';
    }

    final milestone = nextMilestone;
    if (milestone != null && milestone.daysUntilDue <= 14) {
      return '${milestone.label} is ${milestone.dueLabel.toLowerCase()} and should stay in the handoff.';
    }

    return 'Keep owner, milestone, risk, and linked timeline context ready for the next sync.';
  }
}

extension ProjectHandoffUrgencyPresentation on ProjectHandoffUrgency {
  String get label {
    switch (this) {
      case ProjectHandoffUrgency.steady:
        return 'Steady';
      case ProjectHandoffUrgency.watch:
        return 'Watch';
      case ProjectHandoffUrgency.urgent:
        return 'Urgent';
      case ProjectHandoffUrgency.blocked:
        return 'Blocked';
    }
  }

  IconData get icon {
    switch (this) {
      case ProjectHandoffUrgency.steady:
        return Icons.check_circle_outline;
      case ProjectHandoffUrgency.watch:
        return Icons.visibility_outlined;
      case ProjectHandoffUrgency.urgent:
        return Icons.priority_high_rounded;
      case ProjectHandoffUrgency.blocked:
        return Icons.block_outlined;
    }
  }

  Color color(ColorScheme colorScheme) {
    switch (this) {
      case ProjectHandoffUrgency.steady:
        return Colors.green.shade700;
      case ProjectHandoffUrgency.watch:
        return colorScheme.primary;
      case ProjectHandoffUrgency.urgent:
        return Colors.orange.shade700;
      case ProjectHandoffUrgency.blocked:
        return colorScheme.error;
    }
  }
}

ProjectHandoffBrief buildProjectHandoffBrief({
  required ProjectPortfolioItem project,
  required Iterable<gantt.GanttTask> timelineTasks,
  DateTime? today,
}) {
  final taskList = timelineTasks.toList();
  final asOf = DateUtils.dateOnly(today ?? DateTime.now());
  final topRisk = _topHandoffRisk(project.risks);
  final nextMilestone = _nextHandoffMilestone(project.milestones, today: asOf);
  final overdueTaskCount =
      taskList.where((task) {
        final endDate = DateUtils.dateOnly(task.endDate);
        return task.progress < 1 && endDate.isBefore(asOf);
      }).length;
  final urgency = _handoffUrgency(
    project: project,
    topRisk: topRisk,
    nextMilestone: nextMilestone,
    overdueTaskCount: overdueTaskCount,
  );

  return ProjectHandoffBrief(
    project: project,
    urgency: urgency,
    timelineTaskCount: taskList.length,
    overdueTaskCount: overdueTaskCount,
    nextMilestone: nextMilestone,
    topRisk: topRisk,
    briefText: _handoffBriefText(
      project: project,
      urgency: urgency,
      timelineTaskCount: taskList.length,
      overdueTaskCount: overdueTaskCount,
      nextMilestone: nextMilestone,
      topRisk: topRisk,
    ),
  );
}

ProjectHandoffUrgency _handoffUrgency({
  required ProjectPortfolioItem project,
  required ProjectHandoffRisk? topRisk,
  required ProjectHandoffMilestone? nextMilestone,
  required int overdueTaskCount,
}) {
  if (project.health == ProjectHealth.blocked ||
      topRisk?.severity == ProjectHealth.blocked) {
    return ProjectHandoffUrgency.blocked;
  }

  if (project.health == ProjectHealth.atRisk || overdueTaskCount > 0) {
    return ProjectHandoffUrgency.urgent;
  }

  if (nextMilestone != null && nextMilestone.daysUntilDue <= 14) {
    return ProjectHandoffUrgency.watch;
  }

  return ProjectHandoffUrgency.steady;
}

ProjectHandoffRisk? _topHandoffRisk(Iterable<ProjectDeliveryRisk> risks) {
  final activeRisks =
      risks.where((risk) => risk.severity != ProjectHealth.onTrack).toList();
  activeRisks.sort((a, b) {
    return _compareChain([
      _healthRank(a.severity).compareTo(_healthRank(b.severity)),
      a.title.compareTo(b.title),
    ]);
  });

  final topRisk = activeRisks.isEmpty ? null : activeRisks.first;
  if (topRisk == null) return null;

  return ProjectHandoffRisk(
    title: topRisk.title,
    detail: topRisk.detail,
    severity: topRisk.severity,
  );
}

ProjectHandoffMilestone? _nextHandoffMilestone(
  Iterable<ProjectMilestone> milestones, {
  required DateTime today,
}) {
  final openMilestones =
      milestones.where((milestone) => !milestone.isComplete).toList();
  openMilestones.sort((a, b) {
    return _compareChain([
      a.dueDate.compareTo(b.dueDate),
      a.label.compareTo(b.label),
    ]);
  });

  final milestone = openMilestones.isEmpty ? null : openMilestones.first;
  if (milestone == null) return null;

  final dueDate = DateUtils.dateOnly(milestone.dueDate);
  return ProjectHandoffMilestone(
    label: milestone.label,
    dueDate: dueDate,
    daysUntilDue: dueDate.difference(today).inDays,
  );
}

int _healthRank(ProjectHealth health) {
  switch (health) {
    case ProjectHealth.blocked:
      return 0;
    case ProjectHealth.atRisk:
      return 1;
    case ProjectHealth.onTrack:
      return 2;
  }
}

int _compareChain(List<int> comparisons) {
  for (final comparison in comparisons) {
    if (comparison != 0) return comparison;
  }

  return 0;
}

String _handoffBriefText({
  required ProjectPortfolioItem project,
  required ProjectHandoffUrgency urgency,
  required int timelineTaskCount,
  required int overdueTaskCount,
  required ProjectHandoffMilestone? nextMilestone,
  required ProjectHandoffRisk? topRisk,
}) {
  final ownerLine =
      project.sponsor.trim().isEmpty
          ? project.owner
          : '${project.owner} - Sponsor: ${project.sponsor}';

  return [
    '${project.name} handoff brief',
    'Status: ${urgency.label}',
    'Owner: $ownerLine',
    'Client: ${project.client}',
    'Timeline: ${_countLabel(timelineTaskCount, 'linked task')}, ${_countLabel(overdueTaskCount, 'overdue task')}',
    '',
    'Primary handoff',
    '- ${_handoffTitle(urgency)}: ${_handoffDetail(project: project, urgency: urgency, overdueTaskCount: overdueTaskCount, nextMilestone: nextMilestone, topRisk: topRisk)}',
    '',
    'Milestone',
    if (nextMilestone == null)
      '- No open milestone is currently driving the handoff.'
    else
      '- ${nextMilestone.label}: ${nextMilestone.dueLabel}.',
    '',
    'Risk',
    if (topRisk == null)
      '- No active handoff risk; keep progress and milestone context ready.'
    else
      '- ${topRisk.title} (${topRisk.severity.label}): ${topRisk.detail}',
    '',
    'Next action',
    '- ${_nextActionFor(urgency)}',
  ].join('\n');
}

String _handoffTitle(ProjectHandoffUrgency urgency) {
  switch (urgency) {
    case ProjectHandoffUrgency.blocked:
      return 'Blocked delivery';
    case ProjectHandoffUrgency.urgent:
      return 'Recovery ownership';
    case ProjectHandoffUrgency.watch:
      return 'Watch item';
    case ProjectHandoffUrgency.steady:
      return 'Routine follow-up';
  }
}

String _handoffDetail({
  required ProjectPortfolioItem project,
  required ProjectHandoffUrgency urgency,
  required int overdueTaskCount,
  required ProjectHandoffMilestone? nextMilestone,
  required ProjectHandoffRisk? topRisk,
}) {
  switch (urgency) {
    case ProjectHandoffUrgency.blocked:
      return project.health == ProjectHealth.blocked
          ? '${project.owner} owns unblock coordination before the next delivery review.'
          : '${topRisk?.title ?? 'Blocked risk'} needs a signed owner and next action.';
    case ProjectHandoffUrgency.urgent:
      if (overdueTaskCount > 0) {
        return '$overdueTaskCount linked timeline task${overdueTaskCount == 1 ? '' : 's'} need recovery ownership.';
      }
      return '${project.owner} should align recovery ownership before the next sync.';
    case ProjectHandoffUrgency.watch:
      return nextMilestone == null
          ? 'Keep owner, milestone, risk, and linked timeline context ready.'
          : '${nextMilestone.label} is ${nextMilestone.dueLabel.toLowerCase()} and should stay in the handoff.';
    case ProjectHandoffUrgency.steady:
      return 'Keep owner, milestone, risk, and linked timeline context ready for the next sync.';
  }
}

String _nextActionFor(ProjectHandoffUrgency urgency) {
  switch (urgency) {
    case ProjectHandoffUrgency.blocked:
      return 'Confirm unblock owner, decision route, and recovery checkpoint before handing off.';
    case ProjectHandoffUrgency.urgent:
      return 'Confirm recovery owner, overdue work, and next milestone guardrail.';
    case ProjectHandoffUrgency.watch:
      return 'Keep the next milestone and active risk visible in the next update.';
    case ProjectHandoffUrgency.steady:
      return 'Maintain routine follow-up and refresh the handoff at the next sync.';
  }
}

String _countLabel(int count, String label) {
  return '$count $label${count == 1 ? '' : 's'}';
}
