import 'package:flutter/material.dart';

import '../models/project_finance_ledger.dart';
import 'project_petty_cash_workspace_service.dart';

/// Business purpose captured by the petty-cash request intake flow.
enum ProjectPettyCashRequestPurpose {
  fieldOperations,
  supplies,
  logistics,
  eventOperations,
  emergency,
  other,
}

/// Reconciliation due-date option for a petty-cash request.
enum ProjectPettyCashRequestDueOption {
  threeDays,
  sevenDays,
  fourteenDays,
  closeout,
}

/// Validation issue emitted for a petty-cash request draft.
class ProjectPettyCashRequestIssue {
  const ProjectPettyCashRequestIssue({
    required this.field,
    required this.message,
  });

  final String field;
  final String message;
}

/// Editable petty-cash request draft captured by the intake form.
class ProjectPettyCashRequestDraft {
  const ProjectPettyCashRequestDraft({
    required this.projectId,
    required this.title,
    required this.custodian,
    required this.amountText,
    required this.purpose,
    required this.dueOption,
    required this.evidenceNote,
  });

  final String projectId;
  final String title;
  final String custodian;
  final String amountText;
  final ProjectPettyCashRequestPurpose purpose;
  final ProjectPettyCashRequestDueOption dueOption;
  final String evidenceNote;

  ProjectPettyCashRequestDraft copyWith({
    String? title,
    String? custodian,
    String? amountText,
    ProjectPettyCashRequestPurpose? purpose,
    ProjectPettyCashRequestDueOption? dueOption,
    String? evidenceNote,
  }) {
    return ProjectPettyCashRequestDraft(
      projectId: projectId,
      title: title ?? this.title,
      custodian: custodian ?? this.custodian,
      amountText: amountText ?? this.amountText,
      purpose: purpose ?? this.purpose,
      dueOption: dueOption ?? this.dueOption,
      evidenceNote: evidenceNote ?? this.evidenceNote,
    );
  }
}

/// Submitted local petty-cash request used by the demo queue.
class ProjectPettyCashRequestSubmission {
  const ProjectPettyCashRequestSubmission({
    required this.entry,
    required this.purpose,
    required this.routeLabel,
    required this.amountLabel,
    required this.submittedAt,
    required this.summaryText,
  });

  final ProjectPettyCashEntry entry;
  final ProjectPettyCashRequestPurpose purpose;
  final String routeLabel;
  final String amountLabel;
  final DateTime submittedAt;
  final String summaryText;
}

/// Service for validating and building petty-cash request submissions.
class ProjectPettyCashRequestIntakeService {
  const ProjectPettyCashRequestIntakeService();

  ProjectPettyCashRequestDraft initialDraft(
    ProjectPettyCashWorkspaceSummary summary,
  ) {
    return ProjectPettyCashRequestDraft(
      projectId: summary.projectId,
      title: '',
      custodian: summary.primaryEntry?.custodian ?? '',
      amountText: '',
      purpose: recommendedPurpose(summary),
      dueOption: ProjectPettyCashRequestDueOption.fourteenDays,
      evidenceNote: '',
    );
  }

  ProjectPettyCashRequestPurpose recommendedPurpose(
    ProjectPettyCashWorkspaceSummary summary,
  ) {
    final domain = summary.businessDomain.toLowerCase();
    if (domain.contains('event') ||
        domain.contains('wedding') ||
        domain.contains('music')) {
      return ProjectPettyCashRequestPurpose.eventOperations;
    }
    if (domain.contains('warehouse') || domain.contains('logistic')) {
      return ProjectPettyCashRequestPurpose.logistics;
    }
    if (domain.contains('construction') || domain.contains('education')) {
      return ProjectPettyCashRequestPurpose.supplies;
    }

    return ProjectPettyCashRequestPurpose.fieldOperations;
  }

  double? amountFor(ProjectPettyCashRequestDraft draft) {
    final normalized = draft.amountText.replaceAll(RegExp(r'[^0-9]'), '');
    if (normalized.isEmpty) return null;

    return double.tryParse(normalized);
  }

  String routeLabelFor({
    required ProjectPettyCashWorkspaceSummary summary,
    required ProjectPettyCashRequestDraft draft,
  }) {
    if (summary.level == ProjectPettyCashWorkspaceLevel.blocked) {
      return 'Blocked control';
    }

    final amount = amountFor(draft) ?? 0;
    final approvalFloor =
        summary.openFloatAmount > 0 ? summary.openFloatAmount : 5000000;
    if (amount > approvalFloor) return 'Finance approval';
    if (summary.openCount > 0) return 'Custodian review';

    return 'Standard release';
  }

  DateTime dueDateFor({
    required ProjectPettyCashWorkspaceSummary summary,
    required ProjectPettyCashRequestDueOption option,
  }) {
    final today = DateUtils.dateOnly(summary.today);
    switch (option) {
      case ProjectPettyCashRequestDueOption.threeDays:
        return today.add(const Duration(days: 3));
      case ProjectPettyCashRequestDueOption.sevenDays:
        return today.add(const Duration(days: 7));
      case ProjectPettyCashRequestDueOption.fourteenDays:
        return today.add(const Duration(days: 14));
      case ProjectPettyCashRequestDueOption.closeout:
        return today.add(const Duration(days: 30));
    }
  }

  List<ProjectPettyCashRequestIssue> validate({
    required ProjectPettyCashWorkspaceSummary summary,
    required ProjectPettyCashRequestDraft draft,
  }) {
    final issues = <ProjectPettyCashRequestIssue>[];

    if (summary.level == ProjectPettyCashWorkspaceLevel.blocked) {
      issues.add(
        const ProjectPettyCashRequestIssue(
          field: 'controls',
          message: 'Resolve blocked petty-cash controls before a new request.',
        ),
      );
    }

    final title = draft.title.trim();
    if (title.isEmpty) {
      issues.add(
        const ProjectPettyCashRequestIssue(
          field: 'title',
          message: 'Request title is required.',
        ),
      );
    } else if (title.length < 8) {
      issues.add(
        const ProjectPettyCashRequestIssue(
          field: 'title',
          message: 'Request title should be specific.',
        ),
      );
    }

    if (draft.custodian.trim().isEmpty) {
      issues.add(
        const ProjectPettyCashRequestIssue(
          field: 'custodian',
          message: 'Custodian is required.',
        ),
      );
    }

    final amount = amountFor(draft);
    if (amount == null) {
      issues.add(
        const ProjectPettyCashRequestIssue(
          field: 'amount',
          message: 'Amount is required.',
        ),
      );
    } else if (amount <= 0) {
      issues.add(
        const ProjectPettyCashRequestIssue(
          field: 'amount',
          message: 'Amount should be greater than zero.',
        ),
      );
    }

    final note = draft.evidenceNote.trim();
    if (note.isEmpty) {
      issues.add(
        const ProjectPettyCashRequestIssue(
          field: 'evidence',
          message: 'Evidence note is required.',
        ),
      );
    } else if (note.length < 20) {
      issues.add(
        const ProjectPettyCashRequestIssue(
          field: 'evidence',
          message: 'Evidence note should explain receipts and purpose.',
        ),
      );
    }

    return List.unmodifiable(issues);
  }

  ProjectPettyCashRequestSubmission submit({
    required ProjectPettyCashWorkspaceSummary summary,
    required ProjectPettyCashRequestDraft draft,
    required int queueIndex,
  }) {
    final issues = validate(summary: summary, draft: draft);
    if (issues.isNotEmpty) {
      throw StateError('Petty-cash request draft is not ready to submit.');
    }

    final amount = amountFor(draft)!;
    final routeLabel = routeLabelFor(summary: summary, draft: draft);
    final dueDate = dueDateFor(summary: summary, option: draft.dueOption);
    final entry = ProjectPettyCashEntry(
      id: _requestId(summary.projectName, draft.title, queueIndex),
      projectId: summary.projectId,
      title: draft.title.trim(),
      custodian: draft.custodian.trim(),
      amount: amount,
      status: ProjectFinanceRecordStatus.submitted,
      reconciliationDueDate: dueDate,
    );

    return ProjectPettyCashRequestSubmission(
      entry: entry,
      purpose: draft.purpose,
      routeLabel: routeLabel,
      amountLabel: _money(amount),
      submittedAt: summary.today,
      summaryText: _summaryText(
        summary: summary,
        draft: draft,
        entry: entry,
        routeLabel: routeLabel,
      ),
    );
  }
}

String _summaryText({
  required ProjectPettyCashWorkspaceSummary summary,
  required ProjectPettyCashRequestDraft draft,
  required ProjectPettyCashEntry entry,
  required String routeLabel,
}) {
  return [
    'Petty cash request',
    'Project: ${summary.projectName}',
    'Request: ${entry.title}',
    'Amount: ${_money(entry.amount)}',
    'Custodian: ${entry.custodian}',
    'Purpose: ${draft.purpose.label}',
    'Route: $routeLabel',
    'Reconcile by: ${_dateLabel(entry.reconciliationDueDate)}',
    'Evidence: ${draft.evidenceNote.trim()}',
  ].join('\n');
}

String _requestId(String projectName, String title, int queueIndex) {
  final slug = '$projectName $title'
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');

  return '$slug-float-$queueIndex';
}

String _money(double value) {
  if (value <= 0) return '-';
  if (value >= 1000000000) {
    return '${(value / 1000000000).toStringAsFixed(1)}B';
  }
  if (value >= 1000000) {
    return '${(value / 1000000).toStringAsFixed(1)}M';
  }
  if (value >= 1000) {
    return '${(value / 1000).toStringAsFixed(0)}K';
  }
  return value.toStringAsFixed(0);
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

extension ProjectPettyCashRequestPurposePresentation
    on ProjectPettyCashRequestPurpose {
  /// User-facing label for a petty-cash request purpose.
  String get label {
    switch (this) {
      case ProjectPettyCashRequestPurpose.fieldOperations:
        return 'Field Ops';
      case ProjectPettyCashRequestPurpose.supplies:
        return 'Supplies';
      case ProjectPettyCashRequestPurpose.logistics:
        return 'Logistics';
      case ProjectPettyCashRequestPurpose.eventOperations:
        return 'Event Ops';
      case ProjectPettyCashRequestPurpose.emergency:
        return 'Emergency';
      case ProjectPettyCashRequestPurpose.other:
        return 'Other';
    }
  }

  /// Icon for a petty-cash request purpose.
  IconData get icon {
    switch (this) {
      case ProjectPettyCashRequestPurpose.fieldOperations:
        return Icons.storefront_outlined;
      case ProjectPettyCashRequestPurpose.supplies:
        return Icons.inventory_2_outlined;
      case ProjectPettyCashRequestPurpose.logistics:
        return Icons.local_shipping_outlined;
      case ProjectPettyCashRequestPurpose.eventOperations:
        return Icons.event_available_outlined;
      case ProjectPettyCashRequestPurpose.emergency:
        return Icons.emergency_outlined;
      case ProjectPettyCashRequestPurpose.other:
        return Icons.more_horiz_outlined;
    }
  }
}

extension ProjectPettyCashRequestDueOptionPresentation
    on ProjectPettyCashRequestDueOption {
  /// User-facing label for petty-cash reconciliation timing.
  String get label {
    switch (this) {
      case ProjectPettyCashRequestDueOption.threeDays:
        return '3 Days';
      case ProjectPettyCashRequestDueOption.sevenDays:
        return '7 Days';
      case ProjectPettyCashRequestDueOption.fourteenDays:
        return '14 Days';
      case ProjectPettyCashRequestDueOption.closeout:
        return 'Closeout';
    }
  }

  /// Icon for petty-cash reconciliation timing.
  IconData get icon {
    switch (this) {
      case ProjectPettyCashRequestDueOption.threeDays:
      case ProjectPettyCashRequestDueOption.sevenDays:
        return Icons.timer_outlined;
      case ProjectPettyCashRequestDueOption.fourteenDays:
        return Icons.event_available_outlined;
      case ProjectPettyCashRequestDueOption.closeout:
        return Icons.flag_outlined;
    }
  }
}
