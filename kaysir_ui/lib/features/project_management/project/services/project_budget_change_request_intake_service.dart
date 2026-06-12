import 'package:flutter/material.dart';

import 'project_budget_change_workspace_service.dart';

/// Review timing option for a budget change request.
enum ProjectBudgetChangeReviewOption {
  sameDay,
  nextGovernance,
  nextWeek,
  baselineCycle,
}

/// Validation issue emitted for a budget change request draft.
class ProjectBudgetChangeRequestIssue {
  const ProjectBudgetChangeRequestIssue({
    required this.field,
    required this.message,
  });

  final String field;
  final String message;
}

/// Editable draft captured by the budget change request form.
class ProjectBudgetChangeRequestDraft {
  const ProjectBudgetChangeRequestDraft({
    required this.projectId,
    required this.kind,
    required this.title,
    required this.owner,
    required this.amountText,
    required this.reviewOption,
    required this.impactNote,
    required this.evidenceNote,
  });

  final String projectId;
  final ProjectBudgetChangeKind kind;
  final String title;
  final String owner;
  final String amountText;
  final ProjectBudgetChangeReviewOption reviewOption;
  final String impactNote;
  final String evidenceNote;

  ProjectBudgetChangeRequestDraft copyWith({
    ProjectBudgetChangeKind? kind,
    String? title,
    String? owner,
    String? amountText,
    ProjectBudgetChangeReviewOption? reviewOption,
    String? impactNote,
    String? evidenceNote,
  }) {
    return ProjectBudgetChangeRequestDraft(
      projectId: projectId,
      kind: kind ?? this.kind,
      title: title ?? this.title,
      owner: owner ?? this.owner,
      amountText: amountText ?? this.amountText,
      reviewOption: reviewOption ?? this.reviewOption,
      impactNote: impactNote ?? this.impactNote,
      evidenceNote: evidenceNote ?? this.evidenceNote,
    );
  }
}

/// Submitted local budget change request for demo workflow history.
class ProjectBudgetChangeRequestSubmission {
  const ProjectBudgetChangeRequestSubmission({
    required this.request,
    required this.routeLabel,
    required this.reviewDate,
    required this.submittedAt,
    required this.summaryText,
  });

  final ProjectBudgetChangeRequest request;
  final String routeLabel;
  final DateTime reviewDate;
  final DateTime submittedAt;
  final String summaryText;
}

/// Service for validating and submitting budget change request drafts.
class ProjectBudgetChangeRequestIntakeService {
  const ProjectBudgetChangeRequestIntakeService();

  ProjectBudgetChangeRequestDraft initialDraft(
    ProjectBudgetChangeWorkspaceSummary summary,
  ) {
    final primary = summary.primaryRequest;

    return ProjectBudgetChangeRequestDraft(
      projectId: summary.projectId,
      kind: primary?.kind ?? ProjectBudgetChangeKind.baselineLog,
      title: '',
      owner: primary?.ownerLabel ?? '',
      amountText: '',
      reviewOption: _recommendedReviewOption(summary),
      impactNote: '',
      evidenceNote: '',
    );
  }

  double? amountFor(ProjectBudgetChangeRequestDraft draft) {
    final normalized = draft.amountText.replaceAll(RegExp(r'[^0-9]'), '');
    if (normalized.isEmpty) return null;

    return double.tryParse(normalized);
  }

  bool amountRequiredFor(ProjectBudgetChangeKind kind) {
    switch (kind) {
      case ProjectBudgetChangeKind.varianceRecovery:
      case ProjectBudgetChangeKind.costReforecast:
      case ProjectBudgetChangeKind.contingencyRelease:
        return true;
      case ProjectBudgetChangeKind.evidenceChange:
      case ProjectBudgetChangeKind.baselineLog:
        return false;
    }
  }

  String routeLabelFor({
    required ProjectBudgetChangeWorkspaceSummary summary,
    required ProjectBudgetChangeRequestDraft draft,
  }) {
    if (summary.level == ProjectBudgetChangeLevel.blocked ||
        draft.kind == ProjectBudgetChangeKind.varianceRecovery ||
        draft.kind == ProjectBudgetChangeKind.contingencyRelease) {
      return 'Sponsor approval';
    }
    if (draft.kind == ProjectBudgetChangeKind.evidenceChange) {
      return 'Evidence review';
    }
    if (summary.level == ProjectBudgetChangeLevel.review) {
      return 'Finance review';
    }

    return 'Baseline log';
  }

  DateTime reviewDateFor({
    required ProjectBudgetChangeWorkspaceSummary summary,
    required ProjectBudgetChangeReviewOption option,
  }) {
    final today = DateUtils.dateOnly(DateTime.now());
    switch (option) {
      case ProjectBudgetChangeReviewOption.sameDay:
        return today;
      case ProjectBudgetChangeReviewOption.nextGovernance:
        return today.add(const Duration(days: 3));
      case ProjectBudgetChangeReviewOption.nextWeek:
        return today.add(const Duration(days: 7));
      case ProjectBudgetChangeReviewOption.baselineCycle:
        return today.add(const Duration(days: 14));
    }
  }

  List<ProjectBudgetChangeRequestIssue> validate({
    required ProjectBudgetChangeWorkspaceSummary summary,
    required ProjectBudgetChangeRequestDraft draft,
  }) {
    final issues = <ProjectBudgetChangeRequestIssue>[];
    final title = draft.title.trim();
    if (title.isEmpty) {
      issues.add(
        const ProjectBudgetChangeRequestIssue(
          field: 'title',
          message: 'Budget change title is required.',
        ),
      );
    } else if (title.length < 8) {
      issues.add(
        const ProjectBudgetChangeRequestIssue(
          field: 'title',
          message: 'Budget change title should be specific.',
        ),
      );
    }

    if (draft.owner.trim().isEmpty) {
      issues.add(
        const ProjectBudgetChangeRequestIssue(
          field: 'owner',
          message: 'Budget change owner is required.',
        ),
      );
    }

    final amount = amountFor(draft);
    if (amountRequiredFor(draft.kind) && amount == null) {
      issues.add(
        const ProjectBudgetChangeRequestIssue(
          field: 'amount',
          message: 'Requested amount is required.',
        ),
      );
    } else if (amount != null && amount <= 0) {
      issues.add(
        const ProjectBudgetChangeRequestIssue(
          field: 'amount',
          message: 'Requested amount should be greater than zero.',
        ),
      );
    }

    final impactNote = draft.impactNote.trim();
    if (impactNote.isEmpty) {
      issues.add(
        const ProjectBudgetChangeRequestIssue(
          field: 'impact',
          message: 'Impact note is required.',
        ),
      );
    } else if (impactNote.length < 20) {
      issues.add(
        const ProjectBudgetChangeRequestIssue(
          field: 'impact',
          message: 'Impact note should explain the scope or funding tradeoff.',
        ),
      );
    }

    final evidenceNote = draft.evidenceNote.trim();
    if (evidenceNote.isEmpty) {
      issues.add(
        const ProjectBudgetChangeRequestIssue(
          field: 'evidence',
          message: 'Evidence note is required.',
        ),
      );
    } else if (evidenceNote.length < 20) {
      issues.add(
        const ProjectBudgetChangeRequestIssue(
          field: 'evidence',
          message: 'Evidence note should explain the approval proof.',
        ),
      );
    }

    return List.unmodifiable(issues);
  }

  ProjectBudgetChangeRequestSubmission submit({
    required ProjectBudgetChangeWorkspaceSummary summary,
    required ProjectBudgetChangeRequestDraft draft,
    required int queueIndex,
  }) {
    final issues = validate(summary: summary, draft: draft);
    if (issues.isNotEmpty) {
      throw StateError('Budget change request draft is not ready to submit.');
    }

    final routeLabel = routeLabelFor(summary: summary, draft: draft);
    final reviewDate = reviewDateFor(
      summary: summary,
      option: draft.reviewOption,
    );
    final amount = amountFor(draft) ?? 0;
    final request = ProjectBudgetChangeRequest(
      id: _requestId(summary.projectName, draft.title, queueIndex),
      title: draft.title.trim(),
      detail: draft.impactNote.trim(),
      kind: draft.kind,
      level: ProjectBudgetChangeLevel.review,
      icon: draft.kind.icon,
      requestedAmount: amount,
      ownerLabel: draft.owner.trim(),
      approvalLabel: routeLabel,
      evidenceLabel: draft.evidenceNote.trim(),
      impactLabel: draft.impactNote.trim(),
    );

    return ProjectBudgetChangeRequestSubmission(
      request: request,
      routeLabel: routeLabel,
      reviewDate: reviewDate,
      submittedAt: DateUtils.dateOnly(DateTime.now()),
      summaryText: _summaryText(
        summary: summary,
        request: request,
        routeLabel: routeLabel,
        reviewDate: reviewDate,
      ),
    );
  }
}

ProjectBudgetChangeReviewOption _recommendedReviewOption(
  ProjectBudgetChangeWorkspaceSummary summary,
) {
  switch (summary.level) {
    case ProjectBudgetChangeLevel.blocked:
      return ProjectBudgetChangeReviewOption.sameDay;
    case ProjectBudgetChangeLevel.review:
      return ProjectBudgetChangeReviewOption.nextGovernance;
    case ProjectBudgetChangeLevel.ready:
      return ProjectBudgetChangeReviewOption.baselineCycle;
  }
}

String _summaryText({
  required ProjectBudgetChangeWorkspaceSummary summary,
  required ProjectBudgetChangeRequest request,
  required String routeLabel,
  required DateTime reviewDate,
}) {
  return [
    'Budget change request',
    'Project: ${summary.projectName}',
    'Request: ${request.title}',
    'Type: ${request.kind.label}',
    'Amount: ${request.requestedAmountLabel}',
    'Owner: ${request.ownerLabel}',
    'Route: $routeLabel',
    'Review: ${_dateLabel(reviewDate)}',
    'Impact: ${request.impactLabel}',
    'Evidence: ${request.evidenceLabel}',
  ].join('\n');
}

String _requestId(String projectName, String title, int queueIndex) {
  final slug = '$projectName $title'
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');

  return '$slug-budget-change-$queueIndex';
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

extension ProjectBudgetChangeKindPresentation on ProjectBudgetChangeKind {
  /// User-facing label for a budget change type.
  String get label {
    switch (this) {
      case ProjectBudgetChangeKind.varianceRecovery:
        return 'Variance Recovery';
      case ProjectBudgetChangeKind.costReforecast:
        return 'Cost Reforecast';
      case ProjectBudgetChangeKind.contingencyRelease:
        return 'Contingency';
      case ProjectBudgetChangeKind.evidenceChange:
        return 'Evidence Change';
      case ProjectBudgetChangeKind.baselineLog:
        return 'Baseline Log';
    }
  }

  /// Icon for a budget change type.
  IconData get icon {
    switch (this) {
      case ProjectBudgetChangeKind.varianceRecovery:
        return Icons.account_balance_wallet_outlined;
      case ProjectBudgetChangeKind.costReforecast:
        return Icons.insights_outlined;
      case ProjectBudgetChangeKind.contingencyRelease:
        return Icons.savings_outlined;
      case ProjectBudgetChangeKind.evidenceChange:
        return Icons.fact_check_outlined;
      case ProjectBudgetChangeKind.baselineLog:
        return Icons.rule_folder_outlined;
    }
  }
}

extension ProjectBudgetChangeReviewOptionPresentation
    on ProjectBudgetChangeReviewOption {
  /// User-facing label for a budget change review timing option.
  String get label {
    switch (this) {
      case ProjectBudgetChangeReviewOption.sameDay:
        return 'Same Day';
      case ProjectBudgetChangeReviewOption.nextGovernance:
        return 'Governance';
      case ProjectBudgetChangeReviewOption.nextWeek:
        return 'Next Week';
      case ProjectBudgetChangeReviewOption.baselineCycle:
        return 'Baseline';
    }
  }

  /// Icon for a budget change review timing option.
  IconData get icon {
    switch (this) {
      case ProjectBudgetChangeReviewOption.sameDay:
        return Icons.priority_high_outlined;
      case ProjectBudgetChangeReviewOption.nextGovernance:
        return Icons.account_tree_outlined;
      case ProjectBudgetChangeReviewOption.nextWeek:
        return Icons.event_available_outlined;
      case ProjectBudgetChangeReviewOption.baselineCycle:
        return Icons.flag_outlined;
    }
  }
}
