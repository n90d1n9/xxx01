import 'package:flutter/material.dart';

import '../models/project_decision_record.dart';
import 'project_decision_register_service.dart';

/// Severity signal for a decision owner's current action load.
enum ProjectDecisionOwnerSignal { critical, attention, clear }

/// Owner-level action plan derived from open project decision records.
class ProjectDecisionOwnerAction {
  const ProjectDecisionOwnerAction({
    required this.owner,
    required this.ownerLabel,
    required this.records,
    required this.today,
  });

  final String owner;
  final String ownerLabel;
  final List<ProjectDecisionRecord> records;
  final DateTime today;

  ProjectDecisionRecord get primaryRecord => records.first;
  int get openCount => records.where((record) => record.isOpen).length;
  int get overdueCount =>
      records.where((record) => record.isOverdue(today)).length;
  int get blockedCount =>
      records
          .where((record) => record.status == ProjectDecisionStatus.blocked)
          .length;
  int get awaitingCount =>
      records
          .where(
            (record) =>
                record.status == ProjectDecisionStatus.awaitingDecision ||
                record.status == ProjectDecisionStatus.inReview,
          )
          .length;
  int get highPriorityCount =>
      records
          .where(
            (record) =>
                record.priority == ProjectDecisionPriority.critical ||
                record.priority == ProjectDecisionPriority.high,
          )
          .length;

  ProjectDecisionOwnerSignal get signal {
    if (overdueCount > 0 || blockedCount > 0) {
      return ProjectDecisionOwnerSignal.critical;
    }
    if (awaitingCount > 0 || highPriorityCount > 0) {
      return ProjectDecisionOwnerSignal.attention;
    }

    return ProjectDecisionOwnerSignal.clear;
  }

  String get sourceMixLabel {
    final labels = <String>[];
    for (final record in records) {
      final label = record.source.label;
      if (!labels.contains(label)) labels.add(label);
    }

    return labels.join(', ');
  }

  String get nextStepLabel {
    final dueDateLabel = primaryRecord.dueDateLabel;
    if (dueDateLabel.isEmpty) return primaryRecord.title;

    return '${primaryRecord.title} - $dueDateLabel';
  }
}

/// Decision action plan grouped by accountable owners.
class ProjectDecisionActionPlanSummary {
  const ProjectDecisionActionPlanSummary({
    required this.register,
    required this.ownerActions,
  });

  final ProjectDecisionRegisterSummary register;
  final List<ProjectDecisionOwnerAction> ownerActions;

  int get ownerCount => ownerActions.length;
  int get openCount => register.openCount;
  int get overdueCount => register.overdueCount;
  int get blockedCount => register.blockedCount;
  int get awaitingCount => register.awaitingDecisionCount;

  ProjectDecisionOwnerAction? get primaryAction {
    if (ownerActions.isEmpty) return null;

    return ownerActions.first;
  }

  ProjectDecisionOwnerSignal get signal {
    if (overdueCount > 0 || blockedCount > 0) {
      return ProjectDecisionOwnerSignal.critical;
    }
    if (awaitingCount > 0) return ProjectDecisionOwnerSignal.attention;

    return ProjectDecisionOwnerSignal.clear;
  }

  String get title {
    if (ownerActions.isEmpty) return 'Decision owners clear';
    if (signal == ProjectDecisionOwnerSignal.critical) {
      return 'Decision owners need recovery';
    }
    if (signal == ProjectDecisionOwnerSignal.attention) {
      return 'Decision owners need attention';
    }

    return 'Decision owners aligned';
  }

  String get detail {
    if (ownerActions.isEmpty) {
      return 'No open decision actions are waiting on owners.';
    }

    final primary = primaryAction!;
    return '$openCount open actions across $ownerCount owners - '
        '$awaitingCount awaiting - next owner: ${primary.owner}.';
  }
}

/// Builds an owner action plan from a project decision register.
ProjectDecisionActionPlanSummary buildProjectDecisionActionPlan(
  ProjectDecisionRegisterSummary register,
) {
  final groupedRecords = <String, List<ProjectDecisionRecord>>{};
  final labelsByOwner = <String, List<String>>{};

  for (final record in register.records.where((record) => record.isOpen)) {
    final owner = record.owner.trim().isEmpty ? 'Project Owner' : record.owner;
    groupedRecords.putIfAbsent(owner, () => []).add(record);
    labelsByOwner.putIfAbsent(owner, () => []).add(record.ownerLabel);
  }

  final ownerActions = [
    for (final entry in groupedRecords.entries)
      ProjectDecisionOwnerAction(
        owner: entry.key,
        ownerLabel: _ownerLabel(labelsByOwner[entry.key] ?? const []),
        records: List.unmodifiable(entry.value),
        today: register.today,
      ),
  ]..sort(_compareOwnerActions);

  return ProjectDecisionActionPlanSummary(
    register: register,
    ownerActions: List.unmodifiable(ownerActions),
  );
}

int _compareOwnerActions(
  ProjectDecisionOwnerAction left,
  ProjectDecisionOwnerAction right,
) {
  final signalComparison = _signalPriority(
    left.signal,
  ).compareTo(_signalPriority(right.signal));
  if (signalComparison != 0) return signalComparison;

  final overdueComparison = right.overdueCount.compareTo(left.overdueCount);
  if (overdueComparison != 0) return overdueComparison;

  final blockedComparison = right.blockedCount.compareTo(left.blockedCount);
  if (blockedComparison != 0) return blockedComparison;

  final awaitingComparison = right.awaitingCount.compareTo(left.awaitingCount);
  if (awaitingComparison != 0) return awaitingComparison;

  final openComparison = right.openCount.compareTo(left.openCount);
  if (openComparison != 0) return openComparison;

  return left.owner.compareTo(right.owner);
}

int _signalPriority(ProjectDecisionOwnerSignal signal) {
  switch (signal) {
    case ProjectDecisionOwnerSignal.critical:
      return 0;
    case ProjectDecisionOwnerSignal.attention:
      return 1;
    case ProjectDecisionOwnerSignal.clear:
      return 2;
  }
}

String _ownerLabel(List<String> labels) {
  if (labels.contains('Sponsor')) return 'Sponsor';
  if (labels.isEmpty) return 'Owner';

  return labels.first;
}

extension ProjectDecisionOwnerSignalPresentation on ProjectDecisionOwnerSignal {
  /// User-facing label for a decision owner action signal.
  String get label {
    switch (this) {
      case ProjectDecisionOwnerSignal.critical:
        return 'Recovery';
      case ProjectDecisionOwnerSignal.attention:
        return 'Attention';
      case ProjectDecisionOwnerSignal.clear:
        return 'Clear';
    }
  }

  /// Icon for a decision owner action signal.
  IconData get icon {
    switch (this) {
      case ProjectDecisionOwnerSignal.critical:
        return Icons.priority_high_rounded;
      case ProjectDecisionOwnerSignal.attention:
        return Icons.pending_actions_outlined;
      case ProjectDecisionOwnerSignal.clear:
        return Icons.verified_outlined;
    }
  }

  /// Color for a decision owner action signal.
  Color color(ColorScheme colorScheme) {
    switch (this) {
      case ProjectDecisionOwnerSignal.critical:
        return colorScheme.error;
      case ProjectDecisionOwnerSignal.attention:
        return Colors.orange.shade700;
      case ProjectDecisionOwnerSignal.clear:
        return Colors.green.shade700;
    }
  }
}
