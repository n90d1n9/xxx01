import 'package:flutter/material.dart';

/// Workflow status for a project decision or decision-adjacent action.
enum ProjectDecisionStatus {
  awaitingDecision,
  inReview,
  approved,
  delegated,
  completed,
  blocked,
}

/// Business priority used to sort decisions across domains and work types.
enum ProjectDecisionPriority { critical, high, medium, low }

/// Origin signal used to explain why a decision record exists.
enum ProjectDecisionSource {
  nextDecision,
  governance,
  risk,
  milestone,
  domainExtension,
}

/// Normalized decision/action row for project governance workspaces.
class ProjectDecisionRecord {
  const ProjectDecisionRecord({
    required this.id,
    required this.projectId,
    required this.title,
    required this.detail,
    required this.ownerLabel,
    required this.owner,
    required this.status,
    required this.priority,
    required this.source,
    required this.domainLabel,
    this.dueDate,
    this.evidenceLabel = '',
    this.customAttributes = const {},
  });

  final String id;
  final String projectId;
  final String title;
  final String detail;
  final String ownerLabel;
  final String owner;
  final ProjectDecisionStatus status;
  final ProjectDecisionPriority priority;
  final ProjectDecisionSource source;
  final String domainLabel;
  final DateTime? dueDate;
  final String evidenceLabel;
  final Map<String, String> customAttributes;

  bool get isOpen =>
      status != ProjectDecisionStatus.approved &&
      status != ProjectDecisionStatus.completed;

  bool isOverdue(DateTime today) {
    final date = dueDate;
    if (date == null || !isOpen) return false;

    return DateUtils.dateOnly(date).isBefore(DateUtils.dateOnly(today));
  }

  String get ownerText => '$ownerLabel: $owner';

  String get dueDateLabel {
    final date = dueDate;
    if (date == null) return '';

    return 'Due ${_projectDecisionDateLabel(date)}';
  }

  String get metadataLabel {
    if (customAttributes.isEmpty) return '';

    return customAttributes.entries
        .map((entry) => '${entry.key}: ${entry.value}')
        .join(' - ');
  }
}

extension ProjectDecisionStatusPresentation on ProjectDecisionStatus {
  /// User-facing label for a project decision status.
  String get label {
    switch (this) {
      case ProjectDecisionStatus.awaitingDecision:
        return 'Awaiting';
      case ProjectDecisionStatus.inReview:
        return 'Review';
      case ProjectDecisionStatus.approved:
        return 'Approved';
      case ProjectDecisionStatus.delegated:
        return 'Delegated';
      case ProjectDecisionStatus.completed:
        return 'Done';
      case ProjectDecisionStatus.blocked:
        return 'Blocked';
    }
  }

  /// Icon for a project decision status.
  IconData get icon {
    switch (this) {
      case ProjectDecisionStatus.awaitingDecision:
        return Icons.pending_actions_outlined;
      case ProjectDecisionStatus.inReview:
        return Icons.rate_review_outlined;
      case ProjectDecisionStatus.approved:
        return Icons.approval_outlined;
      case ProjectDecisionStatus.delegated:
        return Icons.assignment_ind_outlined;
      case ProjectDecisionStatus.completed:
        return Icons.check_circle_outline;
      case ProjectDecisionStatus.blocked:
        return Icons.block_outlined;
    }
  }

  /// Color for a project decision status.
  Color color(ColorScheme colorScheme) {
    switch (this) {
      case ProjectDecisionStatus.awaitingDecision:
      case ProjectDecisionStatus.inReview:
        return Colors.orange.shade700;
      case ProjectDecisionStatus.approved:
      case ProjectDecisionStatus.delegated:
      case ProjectDecisionStatus.completed:
        return Colors.green.shade700;
      case ProjectDecisionStatus.blocked:
        return colorScheme.error;
    }
  }
}

extension ProjectDecisionPriorityPresentation on ProjectDecisionPriority {
  /// User-facing label for a project decision priority.
  String get label {
    switch (this) {
      case ProjectDecisionPriority.critical:
        return 'Critical';
      case ProjectDecisionPriority.high:
        return 'High';
      case ProjectDecisionPriority.medium:
        return 'Medium';
      case ProjectDecisionPriority.low:
        return 'Low';
    }
  }

  /// Icon for a project decision priority.
  IconData get icon {
    switch (this) {
      case ProjectDecisionPriority.critical:
        return Icons.priority_high_rounded;
      case ProjectDecisionPriority.high:
        return Icons.keyboard_double_arrow_up_rounded;
      case ProjectDecisionPriority.medium:
        return Icons.drag_handle_rounded;
      case ProjectDecisionPriority.low:
        return Icons.low_priority_rounded;
    }
  }

  /// Color for a project decision priority.
  Color color(ColorScheme colorScheme) {
    switch (this) {
      case ProjectDecisionPriority.critical:
        return colorScheme.error;
      case ProjectDecisionPriority.high:
        return Colors.orange.shade700;
      case ProjectDecisionPriority.medium:
        return colorScheme.primary;
      case ProjectDecisionPriority.low:
        return Colors.green.shade700;
    }
  }
}

extension ProjectDecisionSourcePresentation on ProjectDecisionSource {
  /// User-facing label for a project decision source.
  String get label {
    switch (this) {
      case ProjectDecisionSource.nextDecision:
        return 'Signal';
      case ProjectDecisionSource.governance:
        return 'Governance';
      case ProjectDecisionSource.risk:
        return 'Risk';
      case ProjectDecisionSource.milestone:
        return 'Milestone';
      case ProjectDecisionSource.domainExtension:
        return 'Domain';
    }
  }

  /// Icon for a project decision source.
  IconData get icon {
    switch (this) {
      case ProjectDecisionSource.nextDecision:
        return Icons.rule_folder_outlined;
      case ProjectDecisionSource.governance:
        return Icons.account_tree_outlined;
      case ProjectDecisionSource.risk:
        return Icons.health_and_safety_outlined;
      case ProjectDecisionSource.milestone:
        return Icons.flag_outlined;
      case ProjectDecisionSource.domainExtension:
        return Icons.extension_outlined;
    }
  }
}

String _projectDecisionDateLabel(DateTime date) {
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
