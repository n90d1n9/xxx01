import 'package:flutter/material.dart';

import 'project_approval_workspace_service.dart';

/// Outcome that can be applied to an approval queue item.
enum ProjectApprovalActionOutcome {
  approve,
  requestEvidence,
  delegate,
  escalate,
  reject,
}

/// Validation issue emitted for an approval action draft.
class ProjectApprovalActionIssue {
  const ProjectApprovalActionIssue({
    required this.field,
    required this.message,
  });

  final String field;
  final String message;
}

/// Editable approval action draft for one approval queue item.
class ProjectApprovalActionDraft {
  const ProjectApprovalActionDraft({
    required this.itemId,
    required this.outcome,
    required this.approver,
    required this.evidenceRef,
    required this.note,
  });

  final String itemId;
  final ProjectApprovalActionOutcome outcome;
  final String approver;
  final String evidenceRef;
  final String note;

  ProjectApprovalActionDraft copyWith({
    String? itemId,
    ProjectApprovalActionOutcome? outcome,
    String? approver,
    String? evidenceRef,
    String? note,
  }) {
    return ProjectApprovalActionDraft(
      itemId: itemId ?? this.itemId,
      outcome: outcome ?? this.outcome,
      approver: approver ?? this.approver,
      evidenceRef: evidenceRef ?? this.evidenceRef,
      note: note ?? this.note,
    );
  }
}

/// Submitted local approval action for demo workflow history.
class ProjectApprovalActionSubmission {
  const ProjectApprovalActionSubmission({
    required this.item,
    required this.outcome,
    required this.resultingLevel,
    required this.approver,
    required this.routeLabel,
    required this.summaryText,
    required this.submittedAt,
  });

  final ProjectApprovalWorkspaceItem item;
  final ProjectApprovalActionOutcome outcome;
  final ProjectApprovalWorkspaceLevel resultingLevel;
  final String approver;
  final String routeLabel;
  final String summaryText;
  final DateTime submittedAt;
}

/// Service for validating and submitting local approval actions.
class ProjectApprovalActionFlowService {
  const ProjectApprovalActionFlowService();

  List<ProjectApprovalWorkspaceItem> actionableItems(
    ProjectApprovalWorkspaceSummary summary,
  ) {
    final openItems = [
      for (final item in summary.items)
        if (!item.isReady) item,
    ];
    if (openItems.isNotEmpty) return List.unmodifiable(openItems);

    return summary.items;
  }

  ProjectApprovalActionDraft initialDraft(
    ProjectApprovalWorkspaceSummary summary,
  ) {
    final items = actionableItems(summary);
    if (items.isEmpty) {
      return const ProjectApprovalActionDraft(
        itemId: '',
        outcome: ProjectApprovalActionOutcome.approve,
        approver: '',
        evidenceRef: '',
        note: '',
      );
    }

    return draftForItem(items.first);
  }

  ProjectApprovalActionDraft draftForItem(ProjectApprovalWorkspaceItem item) {
    return ProjectApprovalActionDraft(
      itemId: item.id,
      outcome: recommendedOutcome(item),
      approver: item.approverLabel,
      evidenceRef: item.evidenceLabel,
      note: '',
    );
  }

  ProjectApprovalWorkspaceItem? itemFor(
    ProjectApprovalWorkspaceSummary summary,
    String itemId,
  ) {
    for (final item in summary.items) {
      if (item.id == itemId) return item;
    }

    return null;
  }

  ProjectApprovalActionOutcome recommendedOutcome(
    ProjectApprovalWorkspaceItem item,
  ) {
    if (item.level == ProjectApprovalWorkspaceLevel.blocked) {
      return ProjectApprovalActionOutcome.escalate;
    }
    if (item.kind == ProjectApprovalWorkspaceKind.evidenceSignOff) {
      return ProjectApprovalActionOutcome.requestEvidence;
    }
    if (item.level == ProjectApprovalWorkspaceLevel.ready) {
      return ProjectApprovalActionOutcome.approve;
    }

    return ProjectApprovalActionOutcome.approve;
  }

  ProjectApprovalWorkspaceLevel resultingLevelFor(
    ProjectApprovalActionOutcome outcome,
  ) {
    switch (outcome) {
      case ProjectApprovalActionOutcome.approve:
        return ProjectApprovalWorkspaceLevel.ready;
      case ProjectApprovalActionOutcome.requestEvidence:
      case ProjectApprovalActionOutcome.delegate:
        return ProjectApprovalWorkspaceLevel.review;
      case ProjectApprovalActionOutcome.escalate:
      case ProjectApprovalActionOutcome.reject:
        return ProjectApprovalWorkspaceLevel.blocked;
    }
  }

  String routeLabelFor(ProjectApprovalActionOutcome outcome) {
    switch (outcome) {
      case ProjectApprovalActionOutcome.approve:
        return 'Approval route';
      case ProjectApprovalActionOutcome.requestEvidence:
        return 'Evidence route';
      case ProjectApprovalActionOutcome.delegate:
        return 'Owner route';
      case ProjectApprovalActionOutcome.escalate:
        return 'Sponsor route';
      case ProjectApprovalActionOutcome.reject:
        return 'Rejection route';
    }
  }

  List<ProjectApprovalActionIssue> validate({
    required ProjectApprovalWorkspaceSummary summary,
    required ProjectApprovalActionDraft draft,
  }) {
    final issues = <ProjectApprovalActionIssue>[];
    final item = itemFor(summary, draft.itemId);
    if (item == null) {
      issues.add(
        const ProjectApprovalActionIssue(
          field: 'item',
          message: 'Select an approval item to action.',
        ),
      );
    }

    if (draft.approver.trim().isEmpty) {
      issues.add(
        const ProjectApprovalActionIssue(
          field: 'approver',
          message: 'Approver is required.',
        ),
      );
    }

    if ((draft.outcome == ProjectApprovalActionOutcome.approve ||
            draft.outcome == ProjectApprovalActionOutcome.reject) &&
        draft.evidenceRef.trim().isEmpty) {
      issues.add(
        const ProjectApprovalActionIssue(
          field: 'evidence',
          message: 'Approval and rejection actions need evidence.',
        ),
      );
    }

    if (draft.note.trim().length < 20) {
      issues.add(
        const ProjectApprovalActionIssue(
          field: 'note',
          message: 'Approval note should explain the action.',
        ),
      );
    }

    return List.unmodifiable(issues);
  }

  ProjectApprovalActionSubmission submit({
    required ProjectApprovalWorkspaceSummary summary,
    required ProjectApprovalActionDraft draft,
  }) {
    final issues = validate(summary: summary, draft: draft);
    if (issues.isNotEmpty) {
      throw StateError('Approval action draft is not ready to submit.');
    }

    final item = itemFor(summary, draft.itemId)!;
    final routeLabel = routeLabelFor(draft.outcome);
    final resultingLevel = resultingLevelFor(draft.outcome);

    return ProjectApprovalActionSubmission(
      item: item,
      outcome: draft.outcome,
      resultingLevel: resultingLevel,
      approver: draft.approver.trim(),
      routeLabel: routeLabel,
      summaryText: _summaryText(
        item: item,
        draft: draft,
        resultingLevel: resultingLevel,
        routeLabel: routeLabel,
      ),
      submittedAt: DateUtils.dateOnly(DateTime.now()),
    );
  }
}

String _summaryText({
  required ProjectApprovalWorkspaceItem item,
  required ProjectApprovalActionDraft draft,
  required ProjectApprovalWorkspaceLevel resultingLevel,
  required String routeLabel,
}) {
  return [
    'Approval action',
    'Item: ${item.title}',
    'Outcome: ${draft.outcome.label}',
    'Resulting level: ${resultingLevel.label}',
    'Approver: ${draft.approver.trim()}',
    'Route: $routeLabel',
    if (draft.evidenceRef.trim().isNotEmpty)
      'Evidence: ${draft.evidenceRef.trim()}',
    'Note: ${draft.note.trim()}',
  ].join('\n');
}

extension ProjectApprovalActionOutcomePresentation
    on ProjectApprovalActionOutcome {
  /// User-facing label for an approval action outcome.
  String get label {
    switch (this) {
      case ProjectApprovalActionOutcome.approve:
        return 'Approve';
      case ProjectApprovalActionOutcome.requestEvidence:
        return 'Request Evidence';
      case ProjectApprovalActionOutcome.delegate:
        return 'Delegate';
      case ProjectApprovalActionOutcome.escalate:
        return 'Escalate';
      case ProjectApprovalActionOutcome.reject:
        return 'Reject';
    }
  }

  /// Icon for an approval action outcome.
  IconData get icon {
    switch (this) {
      case ProjectApprovalActionOutcome.approve:
        return Icons.approval_outlined;
      case ProjectApprovalActionOutcome.requestEvidence:
        return Icons.fact_check_outlined;
      case ProjectApprovalActionOutcome.delegate:
        return Icons.assignment_ind_outlined;
      case ProjectApprovalActionOutcome.escalate:
        return Icons.notification_important_outlined;
      case ProjectApprovalActionOutcome.reject:
        return Icons.block_outlined;
    }
  }

  /// Color for an approval action outcome.
  Color color(ColorScheme colorScheme) {
    switch (this) {
      case ProjectApprovalActionOutcome.approve:
        return Colors.green.shade700;
      case ProjectApprovalActionOutcome.requestEvidence:
      case ProjectApprovalActionOutcome.delegate:
        return Colors.orange.shade700;
      case ProjectApprovalActionOutcome.escalate:
      case ProjectApprovalActionOutcome.reject:
        return colorScheme.error;
    }
  }
}
