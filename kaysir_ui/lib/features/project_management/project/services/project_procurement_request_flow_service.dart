import 'package:flutter/material.dart';

import 'project_procurement_commitment_service.dart';

/// Target timing option used by the procurement request flow.
enum ProjectProcurementRequestWindowOption {
  today,
  thisWeek,
  nextReview,
  deliveryWindow,
}

/// Validation issue emitted for a procurement request draft.
class ProjectProcurementRequestIssue {
  const ProjectProcurementRequestIssue({
    required this.field,
    required this.message,
  });

  final String field;
  final String message;
}

/// Editable procurement request draft captured by the request flow form.
class ProjectProcurementRequestDraft {
  const ProjectProcurementRequestDraft({
    required this.projectId,
    required this.kind,
    required this.title,
    required this.vendor,
    required this.owner,
    required this.amountText,
    required this.windowOption,
    required this.scopeNote,
    required this.evidenceNote,
  });

  final String projectId;
  final ProjectProcurementCommitmentKind kind;
  final String title;
  final String vendor;
  final String owner;
  final String amountText;
  final ProjectProcurementRequestWindowOption windowOption;
  final String scopeNote;
  final String evidenceNote;

  ProjectProcurementRequestDraft copyWith({
    ProjectProcurementCommitmentKind? kind,
    String? title,
    String? vendor,
    String? owner,
    String? amountText,
    ProjectProcurementRequestWindowOption? windowOption,
    String? scopeNote,
    String? evidenceNote,
  }) {
    return ProjectProcurementRequestDraft(
      projectId: projectId,
      kind: kind ?? this.kind,
      title: title ?? this.title,
      vendor: vendor ?? this.vendor,
      owner: owner ?? this.owner,
      amountText: amountText ?? this.amountText,
      windowOption: windowOption ?? this.windowOption,
      scopeNote: scopeNote ?? this.scopeNote,
      evidenceNote: evidenceNote ?? this.evidenceNote,
    );
  }
}

/// Submitted local procurement request for demo workflow history.
class ProjectProcurementRequestSubmission {
  const ProjectProcurementRequestSubmission({
    required this.item,
    required this.routeLabel,
    required this.targetDate,
    required this.submittedAt,
    required this.summaryText,
  });

  final ProjectProcurementCommitmentItem item;
  final String routeLabel;
  final DateTime targetDate;
  final DateTime submittedAt;
  final String summaryText;
}

/// Service for validating and converting procurement request drafts.
class ProjectProcurementRequestFlowService {
  const ProjectProcurementRequestFlowService();

  ProjectProcurementRequestDraft initialDraft(
    ProjectProcurementCommitmentSummary summary,
  ) {
    final primary = summary.primaryItem;

    return ProjectProcurementRequestDraft(
      projectId: summary.projectId,
      kind: primary?.kind ?? ProjectProcurementCommitmentKind.budgetPackage,
      title: '',
      vendor: '',
      owner: primary?.ownerLabel ?? '',
      amountText: '',
      windowOption: _recommendedWindowOption(summary),
      scopeNote: '',
      evidenceNote: '',
    );
  }

  double? amountFor(ProjectProcurementRequestDraft draft) {
    final normalized = draft.amountText.replaceAll(RegExp(r'[^0-9]'), '');
    if (normalized.isEmpty) return null;

    return double.tryParse(normalized);
  }

  String routeLabelFor({
    required ProjectProcurementCommitmentSummary summary,
    required ProjectProcurementRequestDraft draft,
  }) {
    if (summary.level == ProjectProcurementCommitmentLevel.blocked) {
      return 'Procurement hold';
    }
    if (draft.kind == ProjectProcurementCommitmentKind.supplierRisk) {
      return 'Supplier risk review';
    }
    if (draft.kind == ProjectProcurementCommitmentKind.authority) {
      return 'Authority setup';
    }

    final amount = amountFor(draft) ?? 0;
    final share =
        summary.commitmentAmount <= 0 ? 0 : amount / summary.commitmentAmount;
    if (share >= 0.2) return 'Sponsor sourcing';
    if (summary.level == ProjectProcurementCommitmentLevel.review) {
      return 'Procurement review';
    }

    return 'Standard sourcing';
  }

  DateTime targetDateFor({
    required ProjectProcurementCommitmentSummary summary,
    required ProjectProcurementRequestWindowOption option,
  }) {
    final today = DateUtils.dateOnly(DateTime.now());
    switch (option) {
      case ProjectProcurementRequestWindowOption.today:
        return today;
      case ProjectProcurementRequestWindowOption.thisWeek:
        return today.add(const Duration(days: 3));
      case ProjectProcurementRequestWindowOption.nextReview:
        return today.add(
          Duration(
            days:
                summary.level == ProjectProcurementCommitmentLevel.blocked
                    ? 2
                    : 7,
          ),
        );
      case ProjectProcurementRequestWindowOption.deliveryWindow:
        return today.add(const Duration(days: 14));
    }
  }

  List<ProjectProcurementRequestIssue> validate({
    required ProjectProcurementCommitmentSummary summary,
    required ProjectProcurementRequestDraft draft,
  }) {
    final issues = <ProjectProcurementRequestIssue>[];
    final title = draft.title.trim();
    if (title.isEmpty) {
      issues.add(
        const ProjectProcurementRequestIssue(
          field: 'title',
          message: 'Procurement request title is required.',
        ),
      );
    } else if (title.length < 8) {
      issues.add(
        const ProjectProcurementRequestIssue(
          field: 'title',
          message: 'Procurement request title should be specific.',
        ),
      );
    }

    if (draft.vendor.trim().isEmpty) {
      issues.add(
        const ProjectProcurementRequestIssue(
          field: 'vendor',
          message: 'Vendor or supplier is required.',
        ),
      );
    }

    if (draft.owner.trim().isEmpty) {
      issues.add(
        const ProjectProcurementRequestIssue(
          field: 'owner',
          message: 'Procurement owner is required.',
        ),
      );
    }

    final amount = amountFor(draft);
    if (amount == null) {
      issues.add(
        const ProjectProcurementRequestIssue(
          field: 'amount',
          message: 'Procurement amount is required.',
        ),
      );
    } else if (amount <= 0) {
      issues.add(
        const ProjectProcurementRequestIssue(
          field: 'amount',
          message: 'Procurement amount should be greater than zero.',
        ),
      );
    }

    final scopeNote = draft.scopeNote.trim();
    if (scopeNote.isEmpty) {
      issues.add(
        const ProjectProcurementRequestIssue(
          field: 'scope',
          message: 'Scope note is required.',
        ),
      );
    } else if (scopeNote.length < 20) {
      issues.add(
        const ProjectProcurementRequestIssue(
          field: 'scope',
          message: 'Scope note should explain the buying need.',
        ),
      );
    }

    final evidenceNote = draft.evidenceNote.trim();
    if (evidenceNote.isEmpty) {
      issues.add(
        const ProjectProcurementRequestIssue(
          field: 'evidence',
          message: 'Evidence note is required.',
        ),
      );
    } else if (evidenceNote.length < 20) {
      issues.add(
        const ProjectProcurementRequestIssue(
          field: 'evidence',
          message: 'Evidence note should explain quotation or delivery proof.',
        ),
      );
    }

    return List.unmodifiable(issues);
  }

  ProjectProcurementRequestSubmission submit({
    required ProjectProcurementCommitmentSummary summary,
    required ProjectProcurementRequestDraft draft,
    required int queueIndex,
  }) {
    final issues = validate(summary: summary, draft: draft);
    if (issues.isNotEmpty) {
      throw StateError('Procurement request draft is not ready to submit.');
    }

    final routeLabel = routeLabelFor(summary: summary, draft: draft);
    final targetDate = targetDateFor(
      summary: summary,
      option: draft.windowOption,
    );
    final item = ProjectProcurementCommitmentItem(
      id: _requestId(summary.projectName, draft.title, queueIndex),
      title: draft.title.trim(),
      detail: draft.scopeNote.trim(),
      kind: draft.kind,
      level: ProjectProcurementCommitmentLevel.review,
      icon: draft.kind.requestIcon,
      amount: amountFor(draft)!,
      ownerLabel: draft.owner.trim(),
      evidenceLabel: draft.evidenceNote.trim(),
      actionLabel: routeLabel,
      sourceLabel: draft.vendor.trim(),
    );

    return ProjectProcurementRequestSubmission(
      item: item,
      routeLabel: routeLabel,
      targetDate: targetDate,
      submittedAt: DateUtils.dateOnly(DateTime.now()),
      summaryText: _summaryText(
        summary: summary,
        item: item,
        routeLabel: routeLabel,
        targetDate: targetDate,
      ),
    );
  }
}

ProjectProcurementRequestWindowOption _recommendedWindowOption(
  ProjectProcurementCommitmentSummary summary,
) {
  switch (summary.level) {
    case ProjectProcurementCommitmentLevel.blocked:
      return ProjectProcurementRequestWindowOption.today;
    case ProjectProcurementCommitmentLevel.review:
      return ProjectProcurementRequestWindowOption.nextReview;
    case ProjectProcurementCommitmentLevel.ready:
      return ProjectProcurementRequestWindowOption.deliveryWindow;
  }
}

String _summaryText({
  required ProjectProcurementCommitmentSummary summary,
  required ProjectProcurementCommitmentItem item,
  required String routeLabel,
  required DateTime targetDate,
}) {
  return [
    'Procurement request',
    'Project: ${summary.projectName}',
    'Request: ${item.title}',
    'Type: ${item.kind.label}',
    'Amount: ${item.amountLabel}',
    'Vendor: ${item.sourceLabel}',
    'Owner: ${item.ownerLabel}',
    'Route: $routeLabel',
    'Target: ${_dateLabel(targetDate)}',
    'Scope: ${item.detail}',
    'Evidence: ${item.evidenceLabel}',
  ].join('\n');
}

String _requestId(String projectName, String title, int queueIndex) {
  final slug = '$projectName $title'
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');

  return '$slug-procurement-request-$queueIndex';
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

extension ProjectProcurementRequestKindPresentation
    on ProjectProcurementCommitmentKind {
  /// Icon for a procurement request source kind.
  IconData get requestIcon {
    switch (this) {
      case ProjectProcurementCommitmentKind.budgetPackage:
        return Icons.inventory_2_outlined;
      case ProjectProcurementCommitmentKind.spendRoute:
        return Icons.route_outlined;
      case ProjectProcurementCommitmentKind.authority:
        return Icons.verified_user_outlined;
      case ProjectProcurementCommitmentKind.deliveryProof:
        return Icons.fact_check_outlined;
      case ProjectProcurementCommitmentKind.supplierRisk:
        return Icons.report_problem_outlined;
    }
  }
}

extension ProjectProcurementRequestWindowOptionPresentation
    on ProjectProcurementRequestWindowOption {
  /// User-facing label for procurement target timing.
  String get label {
    switch (this) {
      case ProjectProcurementRequestWindowOption.today:
        return 'Today';
      case ProjectProcurementRequestWindowOption.thisWeek:
        return 'This Week';
      case ProjectProcurementRequestWindowOption.nextReview:
        return 'Next Review';
      case ProjectProcurementRequestWindowOption.deliveryWindow:
        return 'Delivery Window';
    }
  }

  /// Icon for procurement target timing.
  IconData get icon {
    switch (this) {
      case ProjectProcurementRequestWindowOption.today:
        return Icons.today_outlined;
      case ProjectProcurementRequestWindowOption.thisWeek:
        return Icons.event_available_outlined;
      case ProjectProcurementRequestWindowOption.nextReview:
        return Icons.assignment_turned_in_outlined;
      case ProjectProcurementRequestWindowOption.deliveryWindow:
        return Icons.local_shipping_outlined;
    }
  }
}
