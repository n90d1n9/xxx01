import 'package:flutter/material.dart';

import '../models/project_decision_record.dart';
import 'project_decision_register_service.dart';

/// Business area affected by a project decision record.
enum ProjectDecisionImpactArea { delivery, governance, risk, milestone, domain }

/// Impact level used to prioritize decisions by operational consequence.
enum ProjectDecisionImpactLevel { severe, high, moderate, low }

/// Overall impact signal for the project decision matrix.
enum ProjectDecisionImpactSignal { critical, elevated, stable }

/// Impact row derived from a project decision register record.
class ProjectDecisionImpactItem {
  const ProjectDecisionImpactItem({
    required this.record,
    required this.area,
    required this.level,
    required this.score,
    required this.mitigationLabel,
  });

  final ProjectDecisionRecord record;
  final ProjectDecisionImpactArea area;
  final ProjectDecisionImpactLevel level;
  final int score;
  final String mitigationLabel;

  String get title => record.title;
  String get owner => record.owner;
  String get dueDateLabel => record.dueDateLabel;
}

/// Decision impact matrix with indexed risk and copy-ready impact text.
class ProjectDecisionImpactMatrixSummary {
  const ProjectDecisionImpactMatrixSummary({
    required this.register,
    required this.items,
    required this.impactText,
  });

  final ProjectDecisionRegisterSummary register;
  final List<ProjectDecisionImpactItem> items;
  final String impactText;

  int get itemCount => items.length;
  int get impactIndex {
    if (items.isEmpty) return 0;

    final totalScore = items.fold<int>(0, (sum, item) => sum + item.score);
    return (totalScore / items.length).round();
  }

  int get severeCount =>
      items
          .where((item) => item.level == ProjectDecisionImpactLevel.severe)
          .length;
  int get highCount =>
      items
          .where((item) => item.level == ProjectDecisionImpactLevel.high)
          .length;
  int get elevatedCount =>
      items
          .where(
            (item) =>
                item.level == ProjectDecisionImpactLevel.severe ||
                item.level == ProjectDecisionImpactLevel.high,
          )
          .length;
  int get ownerCount => {for (final item in items) item.owner}.length;

  ProjectDecisionImpactSignal get signal {
    if (severeCount > 0 || impactIndex >= 75) {
      return ProjectDecisionImpactSignal.critical;
    }
    if (highCount > 0 || impactIndex >= 45) {
      return ProjectDecisionImpactSignal.elevated;
    }

    return ProjectDecisionImpactSignal.stable;
  }

  ProjectDecisionImpactItem? get primaryItem {
    if (items.isEmpty) return null;

    return items.first;
  }
}

/// Builds an operational impact matrix from project decision register records.
ProjectDecisionImpactMatrixSummary buildProjectDecisionImpactMatrix(
  ProjectDecisionRegisterSummary register,
) {
  final items = [
    for (final record in register.records) _impactItem(register, record),
  ]..sort(_compareItems);
  final summary = ProjectDecisionImpactMatrixSummary(
    register: register,
    items: List.unmodifiable(items),
    impactText: '',
  );

  return ProjectDecisionImpactMatrixSummary(
    register: register,
    items: summary.items,
    impactText: _impactText(summary),
  );
}

ProjectDecisionImpactItem _impactItem(
  ProjectDecisionRegisterSummary register,
  ProjectDecisionRecord record,
) {
  final score = _impactScore(register, record);
  final area = _impactArea(record);

  return ProjectDecisionImpactItem(
    record: record,
    area: area,
    level: _impactLevel(score),
    score: score,
    mitigationLabel: _mitigationLabel(record, area),
  );
}

int _impactScore(
  ProjectDecisionRegisterSummary register,
  ProjectDecisionRecord record,
) {
  final priorityScore = switch (record.priority) {
    ProjectDecisionPriority.critical => 45,
    ProjectDecisionPriority.high => 34,
    ProjectDecisionPriority.medium => 22,
    ProjectDecisionPriority.low => 10,
  };
  final statusScore = switch (record.status) {
    ProjectDecisionStatus.blocked => 35,
    ProjectDecisionStatus.awaitingDecision => 22,
    ProjectDecisionStatus.inReview => 18,
    ProjectDecisionStatus.delegated => 8,
    ProjectDecisionStatus.approved => 3,
    ProjectDecisionStatus.completed => 0,
  };
  final sourceScore = switch (record.source) {
    ProjectDecisionSource.risk => 14,
    ProjectDecisionSource.governance => 12,
    ProjectDecisionSource.nextDecision => 10,
    ProjectDecisionSource.milestone => 9,
    ProjectDecisionSource.domainExtension => 6,
  };
  final overdueScore = record.isOverdue(register.today) ? 24 : 0;
  final evidenceScore = record.evidenceLabel.trim().isEmpty ? 8 : 0;

  return (priorityScore +
          statusScore +
          sourceScore +
          overdueScore +
          evidenceScore)
      .clamp(0, 100);
}

ProjectDecisionImpactArea _impactArea(ProjectDecisionRecord record) {
  switch (record.source) {
    case ProjectDecisionSource.nextDecision:
      return ProjectDecisionImpactArea.delivery;
    case ProjectDecisionSource.governance:
      return ProjectDecisionImpactArea.governance;
    case ProjectDecisionSource.risk:
      return ProjectDecisionImpactArea.risk;
    case ProjectDecisionSource.milestone:
      return ProjectDecisionImpactArea.milestone;
    case ProjectDecisionSource.domainExtension:
      return ProjectDecisionImpactArea.domain;
  }
}

ProjectDecisionImpactLevel _impactLevel(int score) {
  if (score >= 75) return ProjectDecisionImpactLevel.severe;
  if (score >= 55) return ProjectDecisionImpactLevel.high;
  if (score >= 30) return ProjectDecisionImpactLevel.moderate;

  return ProjectDecisionImpactLevel.low;
}

String _mitigationLabel(
  ProjectDecisionRecord record,
  ProjectDecisionImpactArea area,
) {
  if (record.status == ProjectDecisionStatus.blocked) {
    return 'Escalate recovery route and proof owner';
  }
  if (record.isOpen) {
    return switch (area) {
      ProjectDecisionImpactArea.delivery =>
        'Confirm delivery owner and next gate',
      ProjectDecisionImpactArea.governance =>
        'Lock authority route and sponsor response',
      ProjectDecisionImpactArea.risk =>
        'Attach risk decision and mitigation proof',
      ProjectDecisionImpactArea.milestone =>
        'Confirm acceptance criteria and sign-off',
      ProjectDecisionImpactArea.domain =>
        'Refresh domain field and evidence link',
    };
  }

  return 'Keep record available for audit and handoff';
}

int _compareItems(
  ProjectDecisionImpactItem left,
  ProjectDecisionImpactItem right,
) {
  final scoreComparison = right.score.compareTo(left.score);
  if (scoreComparison != 0) return scoreComparison;

  return left.title.compareTo(right.title);
}

String _impactText(ProjectDecisionImpactMatrixSummary summary) {
  return [
    '${summary.register.project.name} decision impact matrix',
    'Signal: ${summary.signal.label}',
    'Impact index: ${summary.impactIndex}',
    'Elevated impacts: ${summary.elevatedCount}',
    'Owners: ${summary.ownerCount}',
    '',
    'Impact priorities:',
    for (final item in summary.items.take(8))
      '- [${item.level.label} / ${item.area.label} / ${item.score}] ${item.title}: ${item.owner} - ${item.mitigationLabel}',
  ].join('\n');
}

extension ProjectDecisionImpactAreaPresentation on ProjectDecisionImpactArea {
  /// User-facing label for a decision impact area.
  String get label {
    switch (this) {
      case ProjectDecisionImpactArea.delivery:
        return 'Delivery';
      case ProjectDecisionImpactArea.governance:
        return 'Governance';
      case ProjectDecisionImpactArea.risk:
        return 'Risk';
      case ProjectDecisionImpactArea.milestone:
        return 'Milestone';
      case ProjectDecisionImpactArea.domain:
        return 'Domain';
    }
  }

  /// Icon for a decision impact area.
  IconData get icon {
    switch (this) {
      case ProjectDecisionImpactArea.delivery:
        return Icons.route_outlined;
      case ProjectDecisionImpactArea.governance:
        return Icons.account_tree_outlined;
      case ProjectDecisionImpactArea.risk:
        return Icons.health_and_safety_outlined;
      case ProjectDecisionImpactArea.milestone:
        return Icons.flag_outlined;
      case ProjectDecisionImpactArea.domain:
        return Icons.extension_outlined;
    }
  }
}

extension ProjectDecisionImpactLevelPresentation on ProjectDecisionImpactLevel {
  /// User-facing label for a decision impact level.
  String get label {
    switch (this) {
      case ProjectDecisionImpactLevel.severe:
        return 'Severe';
      case ProjectDecisionImpactLevel.high:
        return 'High';
      case ProjectDecisionImpactLevel.moderate:
        return 'Moderate';
      case ProjectDecisionImpactLevel.low:
        return 'Low';
    }
  }

  /// Icon for a decision impact level.
  IconData get icon {
    switch (this) {
      case ProjectDecisionImpactLevel.severe:
        return Icons.priority_high_rounded;
      case ProjectDecisionImpactLevel.high:
        return Icons.keyboard_double_arrow_up_rounded;
      case ProjectDecisionImpactLevel.moderate:
        return Icons.drag_handle_rounded;
      case ProjectDecisionImpactLevel.low:
        return Icons.low_priority_rounded;
    }
  }

  /// Color for a decision impact level.
  Color color(ColorScheme colorScheme) {
    switch (this) {
      case ProjectDecisionImpactLevel.severe:
        return colorScheme.error;
      case ProjectDecisionImpactLevel.high:
        return Colors.orange.shade700;
      case ProjectDecisionImpactLevel.moderate:
        return colorScheme.primary;
      case ProjectDecisionImpactLevel.low:
        return Colors.green.shade700;
    }
  }
}

extension ProjectDecisionImpactSignalPresentation
    on ProjectDecisionImpactSignal {
  /// User-facing label for an overall decision impact signal.
  String get label {
    switch (this) {
      case ProjectDecisionImpactSignal.critical:
        return 'Critical';
      case ProjectDecisionImpactSignal.elevated:
        return 'Elevated';
      case ProjectDecisionImpactSignal.stable:
        return 'Stable';
    }
  }

  /// Icon for an overall decision impact signal.
  IconData get icon {
    switch (this) {
      case ProjectDecisionImpactSignal.critical:
        return Icons.priority_high_rounded;
      case ProjectDecisionImpactSignal.elevated:
        return Icons.insights_outlined;
      case ProjectDecisionImpactSignal.stable:
        return Icons.verified_outlined;
    }
  }

  /// Color for an overall decision impact signal.
  Color color(ColorScheme colorScheme) {
    switch (this) {
      case ProjectDecisionImpactSignal.critical:
        return colorScheme.error;
      case ProjectDecisionImpactSignal.elevated:
        return Colors.orange.shade700;
      case ProjectDecisionImpactSignal.stable:
        return Colors.green.shade700;
    }
  }
}
