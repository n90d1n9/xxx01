import 'package:flutter/material.dart';

import '../models/project_decision_record.dart';
import 'project_decision_register_service.dart';

/// Readiness state for proof attached to a project decision record.
enum ProjectDecisionEvidenceState { missing, review, ready, signedOff }

/// Decision evidence category used to keep proof reusable across domains.
enum ProjectDecisionEvidenceKind {
  governanceRoute,
  decision,
  ownerAction,
  risk,
  milestone,
  domain,
}

/// Overall proof readiness signal for the project decision evidence matrix.
enum ProjectDecisionEvidenceSignal { blocked, review, ready }

/// Evidence item derived from a project decision register record.
class ProjectDecisionEvidenceItem {
  const ProjectDecisionEvidenceItem({
    required this.id,
    required this.title,
    required this.detail,
    required this.owner,
    required this.evidenceLabel,
    required this.state,
    required this.kind,
    required this.record,
    this.dueDate,
  });

  final String id;
  final String title;
  final String detail;
  final String owner;
  final String evidenceLabel;
  final ProjectDecisionEvidenceState state;
  final ProjectDecisionEvidenceKind kind;
  final ProjectDecisionRecord record;
  final DateTime? dueDate;

  String get dueDateLabel {
    final date = dueDate;
    if (date == null) return '';

    return 'Due ${_dateLabel(date)}';
  }
}

/// Decision evidence matrix with readiness counts and copy-ready proof text.
class ProjectDecisionEvidenceMatrixSummary {
  const ProjectDecisionEvidenceMatrixSummary({
    required this.register,
    required this.items,
    required this.packText,
  });

  final ProjectDecisionRegisterSummary register;
  final List<ProjectDecisionEvidenceItem> items;
  final String packText;

  int get itemCount => items.length;
  int get missingCount =>
      items
          .where((item) => item.state == ProjectDecisionEvidenceState.missing)
          .length;
  int get reviewCount =>
      items
          .where((item) => item.state == ProjectDecisionEvidenceState.review)
          .length;
  int get readyCount =>
      items
          .where((item) => item.state == ProjectDecisionEvidenceState.ready)
          .length;
  int get signedOffCount =>
      items
          .where((item) => item.state == ProjectDecisionEvidenceState.signedOff)
          .length;

  int get readinessPercent {
    if (items.isEmpty) return 100;

    return ((readyCount + signedOffCount) / items.length * 100).round();
  }

  ProjectDecisionEvidenceSignal get signal {
    if (missingCount > 0) return ProjectDecisionEvidenceSignal.blocked;
    if (reviewCount > 0) return ProjectDecisionEvidenceSignal.review;

    return ProjectDecisionEvidenceSignal.ready;
  }

  ProjectDecisionEvidenceItem? get primaryItem {
    if (items.isEmpty) return null;

    return items.firstWhere(
      (item) => item.state == _primaryState,
      orElse: () => items.first,
    );
  }

  ProjectDecisionEvidenceState get _primaryState {
    if (missingCount > 0) return ProjectDecisionEvidenceState.missing;
    if (reviewCount > 0) return ProjectDecisionEvidenceState.review;
    if (readyCount > 0) return ProjectDecisionEvidenceState.ready;

    return ProjectDecisionEvidenceState.signedOff;
  }
}

/// Builds proof readiness from decision register records.
ProjectDecisionEvidenceMatrixSummary buildProjectDecisionEvidenceMatrix(
  ProjectDecisionRegisterSummary register,
) {
  final items = [
    for (final record in register.records) _evidenceItem(register, record),
  ]..sort((left, right) => _compareItems(left, right, register.today));

  final summary = ProjectDecisionEvidenceMatrixSummary(
    register: register,
    items: List.unmodifiable(items),
    packText: '',
  );

  return ProjectDecisionEvidenceMatrixSummary(
    register: register,
    items: summary.items,
    packText: _packText(summary),
  );
}

ProjectDecisionEvidenceItem _evidenceItem(
  ProjectDecisionRegisterSummary register,
  ProjectDecisionRecord record,
) {
  final state = _evidenceState(register, record);
  final kind = _evidenceKind(record);
  final evidenceLabel = _evidenceLabel(record, kind);

  return ProjectDecisionEvidenceItem(
    id: 'evidence-${record.id}',
    title: record.title,
    detail: _evidenceDetail(record: record, state: state, label: evidenceLabel),
    owner: record.owner,
    evidenceLabel: evidenceLabel,
    state: state,
    kind: kind,
    record: record,
    dueDate: record.dueDate,
  );
}

ProjectDecisionEvidenceState _evidenceState(
  ProjectDecisionRegisterSummary register,
  ProjectDecisionRecord record,
) {
  if (record.status == ProjectDecisionStatus.blocked ||
      record.isOverdue(register.today)) {
    return ProjectDecisionEvidenceState.missing;
  }

  switch (record.status) {
    case ProjectDecisionStatus.awaitingDecision:
    case ProjectDecisionStatus.inReview:
      return ProjectDecisionEvidenceState.review;
    case ProjectDecisionStatus.delegated:
      return ProjectDecisionEvidenceState.ready;
    case ProjectDecisionStatus.approved:
    case ProjectDecisionStatus.completed:
      return ProjectDecisionEvidenceState.signedOff;
    case ProjectDecisionStatus.blocked:
      return ProjectDecisionEvidenceState.missing;
  }
}

ProjectDecisionEvidenceKind _evidenceKind(ProjectDecisionRecord record) {
  switch (record.source) {
    case ProjectDecisionSource.governance:
      return ProjectDecisionEvidenceKind.governanceRoute;
    case ProjectDecisionSource.nextDecision:
      return ProjectDecisionEvidenceKind.decision;
    case ProjectDecisionSource.risk:
      return ProjectDecisionEvidenceKind.risk;
    case ProjectDecisionSource.milestone:
      return ProjectDecisionEvidenceKind.milestone;
    case ProjectDecisionSource.domainExtension:
      return ProjectDecisionEvidenceKind.domain;
  }
}

String _evidenceLabel(
  ProjectDecisionRecord record,
  ProjectDecisionEvidenceKind kind,
) {
  final explicitLabel = record.evidenceLabel.trim();
  if (explicitLabel.isNotEmpty) return explicitLabel;

  return '${kind.label} proof';
}

String _evidenceDetail({
  required ProjectDecisionRecord record,
  required ProjectDecisionEvidenceState state,
  required String label,
}) {
  switch (state) {
    case ProjectDecisionEvidenceState.missing:
      return '$label is missing or blocked; confirm owner, route, and recovery proof before sign-off.';
    case ProjectDecisionEvidenceState.review:
      return '$label needs review while ${record.owner} clears ${record.title}.';
    case ProjectDecisionEvidenceState.ready:
      return '$label is ready for governance review and final sign-off.';
    case ProjectDecisionEvidenceState.signedOff:
      return '$label is signed off and can be used for handoff, audit, or closeout.';
  }
}

int _compareItems(
  ProjectDecisionEvidenceItem left,
  ProjectDecisionEvidenceItem right,
  DateTime today,
) {
  final stateComparison = _statePriority(
    left.state,
  ).compareTo(_statePriority(right.state));
  if (stateComparison != 0) return stateComparison;

  final priorityComparison = _recordPriority(
    left.record,
    today,
  ).compareTo(_recordPriority(right.record, today));
  if (priorityComparison != 0) return priorityComparison;

  final leftDueDate = left.dueDate;
  final rightDueDate = right.dueDate;
  if (leftDueDate != null && rightDueDate != null) {
    final dateComparison = leftDueDate.compareTo(rightDueDate);
    if (dateComparison != 0) return dateComparison;
  } else if (leftDueDate != null) {
    return -1;
  } else if (rightDueDate != null) {
    return 1;
  }

  return left.title.compareTo(right.title);
}

int _statePriority(ProjectDecisionEvidenceState state) {
  switch (state) {
    case ProjectDecisionEvidenceState.missing:
      return 0;
    case ProjectDecisionEvidenceState.review:
      return 1;
    case ProjectDecisionEvidenceState.ready:
      return 2;
    case ProjectDecisionEvidenceState.signedOff:
      return 3;
  }
}

int _recordPriority(ProjectDecisionRecord record, DateTime today) {
  if (record.isOverdue(today)) return 0;
  if (record.priority == ProjectDecisionPriority.critical) return 1;
  if (record.priority == ProjectDecisionPriority.high) return 2;
  if (record.priority == ProjectDecisionPriority.medium) return 3;

  return 4;
}

String _packText(ProjectDecisionEvidenceMatrixSummary summary) {
  return [
    '${summary.register.project.name} decision evidence matrix',
    'Status: ${summary.signal.label}',
    'Readiness: ${summary.readinessPercent}%',
    'Missing: ${summary.missingCount}',
    'Review: ${summary.reviewCount}',
    'Ready: ${summary.readyCount}',
    'Signed off: ${summary.signedOffCount}',
    '',
    'Proof checklist:',
    for (final item in summary.items.take(8))
      '- [${item.state.label} / ${item.kind.label}] ${item.title}: ${item.owner} - ${item.evidenceLabel}',
  ].join('\n');
}

String _dateLabel(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

extension ProjectDecisionEvidenceStatePresentation
    on ProjectDecisionEvidenceState {
  /// User-facing label for a decision evidence readiness state.
  String get label {
    switch (this) {
      case ProjectDecisionEvidenceState.missing:
        return 'Missing';
      case ProjectDecisionEvidenceState.review:
        return 'Review';
      case ProjectDecisionEvidenceState.ready:
        return 'Ready';
      case ProjectDecisionEvidenceState.signedOff:
        return 'Signed Off';
    }
  }

  /// Icon for a decision evidence readiness state.
  IconData get icon {
    switch (this) {
      case ProjectDecisionEvidenceState.missing:
        return Icons.block_outlined;
      case ProjectDecisionEvidenceState.review:
        return Icons.rate_review_outlined;
      case ProjectDecisionEvidenceState.ready:
        return Icons.fact_check_outlined;
      case ProjectDecisionEvidenceState.signedOff:
        return Icons.verified_outlined;
    }
  }

  /// Color for a decision evidence readiness state.
  Color color(ColorScheme colorScheme) {
    switch (this) {
      case ProjectDecisionEvidenceState.missing:
        return colorScheme.error;
      case ProjectDecisionEvidenceState.review:
        return Colors.orange.shade700;
      case ProjectDecisionEvidenceState.ready:
        return colorScheme.primary;
      case ProjectDecisionEvidenceState.signedOff:
        return Colors.green.shade700;
    }
  }
}

extension ProjectDecisionEvidenceKindPresentation
    on ProjectDecisionEvidenceKind {
  /// User-facing label for a decision evidence category.
  String get label {
    switch (this) {
      case ProjectDecisionEvidenceKind.governanceRoute:
        return 'Governance';
      case ProjectDecisionEvidenceKind.decision:
        return 'Decision';
      case ProjectDecisionEvidenceKind.ownerAction:
        return 'Owner';
      case ProjectDecisionEvidenceKind.risk:
        return 'Risk';
      case ProjectDecisionEvidenceKind.milestone:
        return 'Milestone';
      case ProjectDecisionEvidenceKind.domain:
        return 'Domain';
    }
  }

  /// Icon for a decision evidence category.
  IconData get icon {
    switch (this) {
      case ProjectDecisionEvidenceKind.governanceRoute:
        return Icons.account_tree_outlined;
      case ProjectDecisionEvidenceKind.decision:
        return Icons.rule_folder_outlined;
      case ProjectDecisionEvidenceKind.ownerAction:
        return Icons.groups_outlined;
      case ProjectDecisionEvidenceKind.risk:
        return Icons.health_and_safety_outlined;
      case ProjectDecisionEvidenceKind.milestone:
        return Icons.flag_outlined;
      case ProjectDecisionEvidenceKind.domain:
        return Icons.extension_outlined;
    }
  }
}

extension ProjectDecisionEvidenceSignalPresentation
    on ProjectDecisionEvidenceSignal {
  /// User-facing label for an overall decision evidence signal.
  String get label {
    switch (this) {
      case ProjectDecisionEvidenceSignal.blocked:
        return 'Blocked';
      case ProjectDecisionEvidenceSignal.review:
        return 'Review';
      case ProjectDecisionEvidenceSignal.ready:
        return 'Ready';
    }
  }

  /// Icon for an overall decision evidence signal.
  IconData get icon {
    switch (this) {
      case ProjectDecisionEvidenceSignal.blocked:
        return Icons.block_outlined;
      case ProjectDecisionEvidenceSignal.review:
        return Icons.rate_review_outlined;
      case ProjectDecisionEvidenceSignal.ready:
        return Icons.verified_outlined;
    }
  }

  /// Color for an overall decision evidence signal.
  Color color(ColorScheme colorScheme) {
    switch (this) {
      case ProjectDecisionEvidenceSignal.blocked:
        return colorScheme.error;
      case ProjectDecisionEvidenceSignal.review:
        return Colors.orange.shade700;
      case ProjectDecisionEvidenceSignal.ready:
        return Colors.green.shade700;
    }
  }
}
