import 'package:flutter/material.dart';

import '../models/project_decision_record.dart';
import 'project_decision_register_service.dart';

/// Escalation urgency for the project decision ladder.
enum ProjectDecisionEscalationSignal { urgent, watch, clear }

/// Escalation tier used to route decision actions to the right audience.
enum ProjectDecisionEscalationTier { sponsor, owner, deliveryTeam, monitor }

/// Decision records grouped by escalation tier with next-action metadata.
class ProjectDecisionEscalationStep {
  const ProjectDecisionEscalationStep({
    required this.tier,
    required this.records,
    required this.today,
  });

  final ProjectDecisionEscalationTier tier;
  final List<ProjectDecisionRecord> records;
  final DateTime today;

  int get count => records.length;
  int get blockedCount =>
      records
          .where((record) => record.status == ProjectDecisionStatus.blocked)
          .length;
  int get overdueCount =>
      records.where((record) => record.isOverdue(today)).length;
  int get sameDayCount =>
      records.where((record) => _needsSameDayAction(record, today)).length;
  int get highPriorityCount =>
      records
          .where(
            (record) =>
                record.priority == ProjectDecisionPriority.critical ||
                record.priority == ProjectDecisionPriority.high,
          )
          .length;

  ProjectDecisionRecord get primaryRecord => records.first;

  ProjectDecisionEscalationSignal get signal {
    if (tier == ProjectDecisionEscalationTier.sponsor ||
        blockedCount > 0 ||
        overdueCount > 0) {
      return ProjectDecisionEscalationSignal.urgent;
    }
    if (highPriorityCount > 0 || count > 0) {
      return ProjectDecisionEscalationSignal.watch;
    }

    return ProjectDecisionEscalationSignal.clear;
  }

  String get title {
    switch (tier) {
      case ProjectDecisionEscalationTier.sponsor:
        return 'Sponsor escalation';
      case ProjectDecisionEscalationTier.owner:
        return 'Owner decision lane';
      case ProjectDecisionEscalationTier.deliveryTeam:
        return 'Team follow-through';
      case ProjectDecisionEscalationTier.monitor:
        return 'Monitor and confirm';
    }
  }

  String get detail {
    return '$count records - $sameDayCount same-day - '
        '$highPriorityCount high priority - primary: ${primaryRecord.title}.';
  }

  String get actionLabel {
    switch (tier) {
      case ProjectDecisionEscalationTier.sponsor:
        return 'Confirm sponsor call and unblock decision path';
      case ProjectDecisionEscalationTier.owner:
        return 'Secure owner answer, review, or approval evidence';
      case ProjectDecisionEscalationTier.deliveryTeam:
        return 'Track delegated work until the decision is closed';
      case ProjectDecisionEscalationTier.monitor:
        return 'Keep low-risk decisions visible in the next review';
    }
  }

  String get ownerMixLabel =>
      _uniqueLabels(records.map((record) => record.owner).toList());

  String get sourceMixLabel =>
      _uniqueLabels(records.map((record) => record.source.label).toList());
}

/// Escalation ladder summary with tier counts and copy-ready brief text.
class ProjectDecisionEscalationLadderSummary {
  const ProjectDecisionEscalationLadderSummary({
    required this.register,
    required this.steps,
    required this.briefText,
  });

  final ProjectDecisionRegisterSummary register;
  final List<ProjectDecisionEscalationStep> steps;
  final String briefText;

  int get stepCount => steps.length;
  int get openCount => register.openCount;
  int get sameDayCount => steps.fold(0, (sum, step) => sum + step.sameDayCount);
  int get sponsorCount => _count(ProjectDecisionEscalationTier.sponsor);
  int get ownerCount => _count(ProjectDecisionEscalationTier.owner);
  int get deliveryTeamCount =>
      _count(ProjectDecisionEscalationTier.deliveryTeam);
  int get monitorCount => _count(ProjectDecisionEscalationTier.monitor);

  ProjectDecisionEscalationStep? get primaryStep {
    if (steps.isEmpty) return null;

    return steps.first;
  }

  ProjectDecisionEscalationSignal get signal {
    if (sponsorCount > 0 ||
        register.blockedCount > 0 ||
        register.overdueCount > 0) {
      return ProjectDecisionEscalationSignal.urgent;
    }
    if (openCount > 0) return ProjectDecisionEscalationSignal.watch;

    return ProjectDecisionEscalationSignal.clear;
  }

  String get title {
    switch (signal) {
      case ProjectDecisionEscalationSignal.urgent:
        return 'Escalation ladder needs sponsor action';
      case ProjectDecisionEscalationSignal.watch:
        return 'Escalation ladder tracking owner actions';
      case ProjectDecisionEscalationSignal.clear:
        return 'Escalation ladder clear';
    }
  }

  String get subtitle {
    final primary = primaryStep;
    if (primary == null) {
      return 'No open decisions need escalation right now.';
    }

    return '$openCount open decisions - $sameDayCount same-day - '
        'next lane: ${primary.tier.label}.';
  }

  int _count(ProjectDecisionEscalationTier tier) {
    return steps
        .where((step) => step.tier == tier)
        .fold(0, (sum, step) => sum + step.count);
  }
}

/// Builds an escalation ladder from the normalized decision register.
ProjectDecisionEscalationLadderSummary buildProjectDecisionEscalationLadder(
  ProjectDecisionRegisterSummary register,
) {
  final recordsByTier = {
    for (final tier in ProjectDecisionEscalationTier.values)
      tier: <ProjectDecisionRecord>[],
  };

  for (final record in register.records) {
    final tier = _tierForRecord(record, register.today);
    if (tier == null) continue;

    recordsByTier[tier]!.add(record);
  }

  final steps = [
    for (final tier in ProjectDecisionEscalationTier.values)
      if (recordsByTier[tier]!.isNotEmpty)
        ProjectDecisionEscalationStep(
          tier: tier,
          records: List.unmodifiable(
            recordsByTier[tier]!..sort(
              (left, right) => _compareRecords(left, right, register.today),
            ),
          ),
          today: register.today,
        ),
  ];
  final summary = ProjectDecisionEscalationLadderSummary(
    register: register,
    steps: List.unmodifiable(steps),
    briefText: '',
  );

  return ProjectDecisionEscalationLadderSummary(
    register: register,
    steps: summary.steps,
    briefText: _briefText(summary),
  );
}

ProjectDecisionEscalationTier? _tierForRecord(
  ProjectDecisionRecord record,
  DateTime today,
) {
  if (!record.isOpen) return null;

  if (record.status == ProjectDecisionStatus.blocked ||
      record.isOverdue(today) ||
      record.priority == ProjectDecisionPriority.critical ||
      record.ownerLabel.toLowerCase() == 'sponsor') {
    return ProjectDecisionEscalationTier.sponsor;
  }
  if (record.status == ProjectDecisionStatus.awaitingDecision ||
      record.status == ProjectDecisionStatus.inReview ||
      record.priority == ProjectDecisionPriority.high) {
    return ProjectDecisionEscalationTier.owner;
  }
  if (record.status == ProjectDecisionStatus.delegated) {
    return ProjectDecisionEscalationTier.deliveryTeam;
  }

  return ProjectDecisionEscalationTier.monitor;
}

int _compareRecords(
  ProjectDecisionRecord left,
  ProjectDecisionRecord right,
  DateTime today,
) {
  final sameDayComparison = _sameDayPriority(
    left,
    today,
  ).compareTo(_sameDayPriority(right, today));
  if (sameDayComparison != 0) return sameDayComparison;

  final priorityComparison = _priorityValue(
    left.priority,
  ).compareTo(_priorityValue(right.priority));
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

  return left.title.compareTo(right.title);
}

int _sameDayPriority(ProjectDecisionRecord record, DateTime today) {
  return _needsSameDayAction(record, today) ? 0 : 1;
}

bool _needsSameDayAction(ProjectDecisionRecord record, DateTime today) {
  return record.status == ProjectDecisionStatus.blocked ||
      record.isOverdue(today) ||
      record.priority == ProjectDecisionPriority.critical;
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

String _briefText(ProjectDecisionEscalationLadderSummary summary) {
  return [
    '${summary.register.project.name} decision escalation ladder',
    'Signal: ${summary.signal.label}',
    'Open decisions: ${summary.openCount}',
    'Same-day actions: ${summary.sameDayCount}',
    'Sponsor: ${summary.sponsorCount}',
    'Owner: ${summary.ownerCount}',
    'Team: ${summary.deliveryTeamCount}',
    'Monitor: ${summary.monitorCount}',
    '',
    'Escalation steps:',
    for (final step in summary.steps)
      '- ${step.tier.label}: ${step.count} records - '
          '${step.actionLabel} - ${step.primaryRecord.title}',
  ].join('\n');
}

String _uniqueLabels(List<String> labels) {
  final uniqueLabels = <String>[];
  for (final label in labels) {
    final normalizedLabel = label.trim();
    if (normalizedLabel.isEmpty || uniqueLabels.contains(normalizedLabel)) {
      continue;
    }

    uniqueLabels.add(normalizedLabel);
  }

  if (uniqueLabels.isEmpty) return 'Unassigned';
  if (uniqueLabels.length == 1) return uniqueLabels.first;

  return '${uniqueLabels.first} + ${uniqueLabels.length - 1} more';
}

extension ProjectDecisionEscalationSignalPresentation
    on ProjectDecisionEscalationSignal {
  /// User-facing label for escalation urgency.
  String get label {
    switch (this) {
      case ProjectDecisionEscalationSignal.urgent:
        return 'Urgent';
      case ProjectDecisionEscalationSignal.watch:
        return 'Watch';
      case ProjectDecisionEscalationSignal.clear:
        return 'Clear';
    }
  }

  /// Icon for escalation urgency.
  IconData get icon {
    switch (this) {
      case ProjectDecisionEscalationSignal.urgent:
        return Icons.priority_high_rounded;
      case ProjectDecisionEscalationSignal.watch:
        return Icons.pending_actions_outlined;
      case ProjectDecisionEscalationSignal.clear:
        return Icons.verified_outlined;
    }
  }

  /// Color for escalation urgency.
  Color color(ColorScheme colorScheme) {
    switch (this) {
      case ProjectDecisionEscalationSignal.urgent:
        return colorScheme.error;
      case ProjectDecisionEscalationSignal.watch:
        return Colors.orange.shade700;
      case ProjectDecisionEscalationSignal.clear:
        return Colors.green.shade700;
    }
  }
}

extension ProjectDecisionEscalationTierPresentation
    on ProjectDecisionEscalationTier {
  /// User-facing label for an escalation tier.
  String get label {
    switch (this) {
      case ProjectDecisionEscalationTier.sponsor:
        return 'Sponsor';
      case ProjectDecisionEscalationTier.owner:
        return 'Owner';
      case ProjectDecisionEscalationTier.deliveryTeam:
        return 'Team';
      case ProjectDecisionEscalationTier.monitor:
        return 'Monitor';
    }
  }

  /// Icon for an escalation tier.
  IconData get icon {
    switch (this) {
      case ProjectDecisionEscalationTier.sponsor:
        return Icons.notification_important_outlined;
      case ProjectDecisionEscalationTier.owner:
        return Icons.account_circle_outlined;
      case ProjectDecisionEscalationTier.deliveryTeam:
        return Icons.groups_outlined;
      case ProjectDecisionEscalationTier.monitor:
        return Icons.visibility_outlined;
    }
  }

  /// Color for an escalation tier.
  Color color(ColorScheme colorScheme) {
    switch (this) {
      case ProjectDecisionEscalationTier.sponsor:
        return colorScheme.error;
      case ProjectDecisionEscalationTier.owner:
        return Colors.orange.shade700;
      case ProjectDecisionEscalationTier.deliveryTeam:
        return colorScheme.primary;
      case ProjectDecisionEscalationTier.monitor:
        return Colors.green.shade700;
    }
  }
}
