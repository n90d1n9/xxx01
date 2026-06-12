import 'package:flutter/material.dart';

import '../models/project_decision_record.dart';
import 'project_decision_register_service.dart';

/// Overall workflow health for the decision board.
enum ProjectDecisionWorkflowSignal { blocked, active, clear }

/// Decision records grouped into a workflow stage.
class ProjectDecisionWorkflowStage {
  const ProjectDecisionWorkflowStage({
    required this.status,
    required this.records,
    required this.today,
  });

  final ProjectDecisionStatus status;
  final List<ProjectDecisionRecord> records;
  final DateTime today;

  int get count => records.length;
  int get overdueCount =>
      records.where((record) => record.isOverdue(today)).length;
  bool get isEmpty => records.isEmpty;

  ProjectDecisionRecord? get primaryRecord {
    if (records.isEmpty) return null;

    return records.first;
  }

  String get detail {
    final primary = primaryRecord;
    if (primary == null) return 'No decision records in this workflow stage.';

    return '$count records - $overdueCount overdue - priority: ${primary.title}.';
  }
}

/// Decision workflow board with stages, counts, and copy-ready snapshot text.
class ProjectDecisionWorkflowBoardSummary {
  const ProjectDecisionWorkflowBoardSummary({
    required this.register,
    required this.stages,
    required this.snapshotText,
  });

  final ProjectDecisionRegisterSummary register;
  final List<ProjectDecisionWorkflowStage> stages;
  final String snapshotText;

  int get stageCount => stages.length;
  int get recordCount => register.recordCount;
  int get blockedCount => _count(ProjectDecisionStatus.blocked);
  int get awaitingCount => _count(ProjectDecisionStatus.awaitingDecision);
  int get reviewCount => _count(ProjectDecisionStatus.inReview);
  int get delegatedCount => _count(ProjectDecisionStatus.delegated);
  int get closedCount =>
      _count(ProjectDecisionStatus.approved) +
      _count(ProjectDecisionStatus.completed);
  int get activeCount => recordCount - closedCount;

  ProjectDecisionWorkflowSignal get signal {
    if (blockedCount > 0 || register.overdueCount > 0) {
      return ProjectDecisionWorkflowSignal.blocked;
    }
    if (activeCount > 0) return ProjectDecisionWorkflowSignal.active;

    return ProjectDecisionWorkflowSignal.clear;
  }

  ProjectDecisionWorkflowStage get primaryStage {
    return stages.firstWhere(
      (stage) => stage.status == _primaryStatus,
      orElse: () => stages.first,
    );
  }

  ProjectDecisionStatus get _primaryStatus {
    if (blockedCount > 0) return ProjectDecisionStatus.blocked;
    if (awaitingCount > 0) return ProjectDecisionStatus.awaitingDecision;
    if (reviewCount > 0) return ProjectDecisionStatus.inReview;
    if (delegatedCount > 0) return ProjectDecisionStatus.delegated;

    return ProjectDecisionStatus.approved;
  }

  int _count(ProjectDecisionStatus status) {
    return stages.firstWhere((stage) => stage.status == status).records.length;
  }
}

/// Builds a stage-based workflow board from decision register records.
ProjectDecisionWorkflowBoardSummary buildProjectDecisionWorkflowBoard(
  ProjectDecisionRegisterSummary register,
) {
  final stages = [
    for (final status in ProjectDecisionStatus.values)
      ProjectDecisionWorkflowStage(
        status: status,
        records: _recordsForStatus(register, status),
        today: register.today,
      ),
  ];
  final summary = ProjectDecisionWorkflowBoardSummary(
    register: register,
    stages: List.unmodifiable(stages),
    snapshotText: '',
  );

  return ProjectDecisionWorkflowBoardSummary(
    register: register,
    stages: summary.stages,
    snapshotText: _snapshotText(summary),
  );
}

List<ProjectDecisionRecord> _recordsForStatus(
  ProjectDecisionRegisterSummary register,
  ProjectDecisionStatus status,
) {
  return [
    for (final record in register.records)
      if (record.status == status) record,
  ]..sort((left, right) => _compareRecords(left, right, register.today));
}

int _compareRecords(
  ProjectDecisionRecord left,
  ProjectDecisionRecord right,
  DateTime today,
) {
  final overdueComparison = _overduePriority(
    left,
    today,
  ).compareTo(_overduePriority(right, today));
  if (overdueComparison != 0) return overdueComparison;

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

int _overduePriority(ProjectDecisionRecord record, DateTime today) {
  return record.isOverdue(today) ? 0 : 1;
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

String _snapshotText(ProjectDecisionWorkflowBoardSummary summary) {
  return [
    '${summary.register.project.name} decision workflow board',
    'Signal: ${summary.signal.label}',
    'Active: ${summary.activeCount}',
    'Blocked: ${summary.blockedCount}',
    'Awaiting: ${summary.awaitingCount}',
    'Review: ${summary.reviewCount}',
    'Delegated: ${summary.delegatedCount}',
    'Closed: ${summary.closedCount}',
    '',
    'Workflow stages:',
    for (final stage in summary.stages)
      '- ${stage.status.label}: ${stage.count} records'
          '${stage.primaryRecord == null ? '' : ' - ${stage.primaryRecord!.title}'}',
  ].join('\n');
}

extension ProjectDecisionWorkflowSignalPresentation
    on ProjectDecisionWorkflowSignal {
  /// User-facing label for a decision workflow signal.
  String get label {
    switch (this) {
      case ProjectDecisionWorkflowSignal.blocked:
        return 'Blocked';
      case ProjectDecisionWorkflowSignal.active:
        return 'Active';
      case ProjectDecisionWorkflowSignal.clear:
        return 'Clear';
    }
  }

  /// Icon for a decision workflow signal.
  IconData get icon {
    switch (this) {
      case ProjectDecisionWorkflowSignal.blocked:
        return Icons.block_outlined;
      case ProjectDecisionWorkflowSignal.active:
        return Icons.view_kanban_outlined;
      case ProjectDecisionWorkflowSignal.clear:
        return Icons.verified_outlined;
    }
  }

  /// Color for a decision workflow signal.
  Color color(ColorScheme colorScheme) {
    switch (this) {
      case ProjectDecisionWorkflowSignal.blocked:
        return colorScheme.error;
      case ProjectDecisionWorkflowSignal.active:
        return Colors.orange.shade700;
      case ProjectDecisionWorkflowSignal.clear:
        return Colors.green.shade700;
    }
  }
}
