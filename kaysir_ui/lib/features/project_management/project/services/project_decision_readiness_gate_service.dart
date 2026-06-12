import 'package:flutter/material.dart';

import '../models/project_decision_record.dart';
import 'project_decision_register_service.dart';

/// Overall readiness health for moving project decisions through governance.
enum ProjectDecisionReadinessSignal { blocked, attention, ready }

/// Readiness lane for a decision record before it can move cleanly.
enum ProjectDecisionReadinessGate {
  blocked,
  needsDecision,
  needsEvidence,
  ready,
}

/// Decision record enriched with readiness score and gate classification.
class ProjectDecisionReadinessRecord {
  const ProjectDecisionReadinessRecord({
    required this.record,
    required this.today,
  });

  final ProjectDecisionRecord record;
  final DateTime today;

  bool get isClosed => !record.isOpen;
  bool get isBlocked =>
      record.status == ProjectDecisionStatus.blocked || record.isOverdue(today);
  bool get hasEvidence =>
      record.evidenceLabel.trim().isNotEmpty ||
      record.customAttributes.isNotEmpty;

  ProjectDecisionReadinessGate get gate {
    if (isBlocked) return ProjectDecisionReadinessGate.blocked;
    if (record.status == ProjectDecisionStatus.awaitingDecision ||
        record.status == ProjectDecisionStatus.inReview) {
      return ProjectDecisionReadinessGate.needsDecision;
    }
    if (!hasEvidence) return ProjectDecisionReadinessGate.needsEvidence;

    return ProjectDecisionReadinessGate.ready;
  }

  int get score {
    if (isClosed) return 100;

    var value = 100;
    if (record.status == ProjectDecisionStatus.blocked) value -= 45;
    if (record.isOverdue(today)) value -= 25;
    if (record.status == ProjectDecisionStatus.awaitingDecision) value -= 18;
    if (record.status == ProjectDecisionStatus.inReview) value -= 10;
    if (record.status == ProjectDecisionStatus.delegated) value -= 6;
    if (!hasEvidence) value -= 15;
    if (record.dueDate == null) value -= 8;
    if (record.priority == ProjectDecisionPriority.critical) value -= 5;

    return value.clamp(0, 100);
  }

  String get readinessLabel {
    if (isClosed) return 'Closed and ready';
    if (isBlocked) return 'Blocked before governance';
    if (gate == ProjectDecisionReadinessGate.needsDecision) {
      return 'Decision answer needed';
    }
    if (gate == ProjectDecisionReadinessGate.needsEvidence) {
      return 'Evidence needed';
    }

    return 'Ready for governance';
  }
}

/// Group of decision readiness records in a single readiness lane.
class ProjectDecisionReadinessLane {
  const ProjectDecisionReadinessLane({
    required this.gate,
    required this.records,
  });

  final ProjectDecisionReadinessGate gate;
  final List<ProjectDecisionReadinessRecord> records;

  int get count => records.length;
  bool get isEmpty => records.isEmpty;

  ProjectDecisionReadinessRecord? get primaryRecord {
    if (records.isEmpty) return null;

    return records.first;
  }

  int get averageScore {
    if (records.isEmpty) return 0;

    final total = records.fold(0, (sum, record) => sum + record.score);
    return (total / records.length).round();
  }

  String get detail {
    final primary = primaryRecord;
    if (primary == null) return 'No decisions in this readiness lane.';

    return '$count decisions - $averageScore readiness - '
        'primary: ${primary.record.title}.';
  }
}

/// Decision readiness gate summary with score, lanes, and copy-ready text.
class ProjectDecisionReadinessGateSummary {
  const ProjectDecisionReadinessGateSummary({
    required this.register,
    required this.records,
    required this.lanes,
    required this.briefText,
  });

  final ProjectDecisionRegisterSummary register;
  final List<ProjectDecisionReadinessRecord> records;
  final List<ProjectDecisionReadinessLane> lanes;
  final String briefText;

  int get recordCount => records.length;
  int get laneCount => lanes.where((lane) => !lane.isEmpty).length;
  int get averageScore {
    if (records.isEmpty) return 100;

    final total = records.fold(0, (sum, record) => sum + record.score);
    return (total / records.length).round();
  }

  int get blockedCount => _count(ProjectDecisionReadinessGate.blocked);
  int get needsDecisionCount =>
      _count(ProjectDecisionReadinessGate.needsDecision);
  int get needsEvidenceCount =>
      _count(ProjectDecisionReadinessGate.needsEvidence);
  int get readyCount => _count(ProjectDecisionReadinessGate.ready);

  ProjectDecisionReadinessLane? get primaryLane {
    for (final lane in lanes) {
      if (!lane.isEmpty) return lane;
    }

    return null;
  }

  ProjectDecisionReadinessSignal get signal {
    if (blockedCount > 0 || averageScore < 60) {
      return ProjectDecisionReadinessSignal.blocked;
    }
    if (needsDecisionCount > 0 || needsEvidenceCount > 0) {
      return ProjectDecisionReadinessSignal.attention;
    }

    return ProjectDecisionReadinessSignal.ready;
  }

  String get title {
    switch (signal) {
      case ProjectDecisionReadinessSignal.blocked:
        return 'Decision readiness has blockers';
      case ProjectDecisionReadinessSignal.attention:
        return 'Decision readiness needs preparation';
      case ProjectDecisionReadinessSignal.ready:
        return 'Decision readiness is healthy';
    }
  }

  String get subtitle {
    final primary = primaryLane;
    if (primary == null) return 'No decision records need readiness review.';

    return '$averageScore readiness score - $recordCount records - '
        'primary lane: ${primary.gate.label}.';
  }

  int _count(ProjectDecisionReadinessGate gate) {
    return lanes
        .where((lane) => lane.gate == gate)
        .fold(0, (sum, lane) => sum + lane.count);
  }
}

/// Builds a readiness gate from the normalized decision register.
ProjectDecisionReadinessGateSummary buildProjectDecisionReadinessGate(
  ProjectDecisionRegisterSummary register,
) {
  final records = [
    for (final record in register.records)
      ProjectDecisionReadinessRecord(record: record, today: register.today),
  ]..sort(_compareRecords);
  final lanes = [
    for (final gate in ProjectDecisionReadinessGate.values)
      ProjectDecisionReadinessLane(
        gate: gate,
        records: List.unmodifiable(
          records.where((record) => record.gate == gate).toList(),
        ),
      ),
  ];
  final summary = ProjectDecisionReadinessGateSummary(
    register: register,
    records: List.unmodifiable(records),
    lanes: List.unmodifiable(lanes),
    briefText: '',
  );

  return ProjectDecisionReadinessGateSummary(
    register: register,
    records: summary.records,
    lanes: summary.lanes,
    briefText: _briefText(summary),
  );
}

int _compareRecords(
  ProjectDecisionReadinessRecord left,
  ProjectDecisionReadinessRecord right,
) {
  final gateComparison = _gatePriority(
    left.gate,
  ).compareTo(_gatePriority(right.gate));
  if (gateComparison != 0) return gateComparison;

  final scoreComparison = left.score.compareTo(right.score);
  if (scoreComparison != 0) return scoreComparison;

  final priorityComparison = _priorityValue(
    left.record.priority,
  ).compareTo(_priorityValue(right.record.priority));
  if (priorityComparison != 0) return priorityComparison;

  return left.record.title.compareTo(right.record.title);
}

int _gatePriority(ProjectDecisionReadinessGate gate) {
  switch (gate) {
    case ProjectDecisionReadinessGate.blocked:
      return 0;
    case ProjectDecisionReadinessGate.needsDecision:
      return 1;
    case ProjectDecisionReadinessGate.needsEvidence:
      return 2;
    case ProjectDecisionReadinessGate.ready:
      return 3;
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

String _briefText(ProjectDecisionReadinessGateSummary summary) {
  return [
    '${summary.register.project.name} decision readiness gate',
    'Signal: ${summary.signal.label}',
    'Readiness score: ${summary.averageScore}',
    'Records: ${summary.recordCount}',
    'Blocked: ${summary.blockedCount}',
    'Needs decision: ${summary.needsDecisionCount}',
    'Needs evidence: ${summary.needsEvidenceCount}',
    'Ready: ${summary.readyCount}',
    '',
    'Readiness lanes:',
    for (final lane in summary.lanes)
      '- ${lane.gate.label}: ${lane.count} decisions'
          '${lane.primaryRecord == null ? '' : ' - ${lane.primaryRecord!.record.title}'}',
  ].join('\n');
}

extension ProjectDecisionReadinessSignalPresentation
    on ProjectDecisionReadinessSignal {
  /// User-facing label for decision readiness health.
  String get label {
    switch (this) {
      case ProjectDecisionReadinessSignal.blocked:
        return 'Blocked';
      case ProjectDecisionReadinessSignal.attention:
        return 'Attention';
      case ProjectDecisionReadinessSignal.ready:
        return 'Ready';
    }
  }

  /// Icon for decision readiness health.
  IconData get icon {
    switch (this) {
      case ProjectDecisionReadinessSignal.blocked:
        return Icons.block_outlined;
      case ProjectDecisionReadinessSignal.attention:
        return Icons.pending_actions_outlined;
      case ProjectDecisionReadinessSignal.ready:
        return Icons.verified_outlined;
    }
  }

  /// Color for decision readiness health.
  Color color(ColorScheme colorScheme) {
    switch (this) {
      case ProjectDecisionReadinessSignal.blocked:
        return colorScheme.error;
      case ProjectDecisionReadinessSignal.attention:
        return Colors.orange.shade700;
      case ProjectDecisionReadinessSignal.ready:
        return Colors.green.shade700;
    }
  }
}

extension ProjectDecisionReadinessGatePresentation
    on ProjectDecisionReadinessGate {
  /// User-facing label for a decision readiness lane.
  String get label {
    switch (this) {
      case ProjectDecisionReadinessGate.blocked:
        return 'Blocked';
      case ProjectDecisionReadinessGate.needsDecision:
        return 'Decision';
      case ProjectDecisionReadinessGate.needsEvidence:
        return 'Evidence';
      case ProjectDecisionReadinessGate.ready:
        return 'Ready';
    }
  }

  /// Icon for a decision readiness lane.
  IconData get icon {
    switch (this) {
      case ProjectDecisionReadinessGate.blocked:
        return Icons.block_outlined;
      case ProjectDecisionReadinessGate.needsDecision:
        return Icons.rule_folder_outlined;
      case ProjectDecisionReadinessGate.needsEvidence:
        return Icons.fact_check_outlined;
      case ProjectDecisionReadinessGate.ready:
        return Icons.verified_outlined;
    }
  }

  /// Color for a decision readiness lane.
  Color color(ColorScheme colorScheme) {
    switch (this) {
      case ProjectDecisionReadinessGate.blocked:
        return colorScheme.error;
      case ProjectDecisionReadinessGate.needsDecision:
      case ProjectDecisionReadinessGate.needsEvidence:
        return Colors.orange.shade700;
      case ProjectDecisionReadinessGate.ready:
        return Colors.green.shade700;
    }
  }
}
