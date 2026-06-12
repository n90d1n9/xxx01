import 'package:flutter/material.dart';

import '../models/project_decision_record.dart';
import 'project_decision_register_service.dart';

/// Review outcome that advances or redirects an existing decision record.
enum ProjectDecisionReviewOutcome {
  approve,
  requestEvidence,
  delegate,
  escalate,
  close,
}

/// Validation issue emitted by the project decision review flow.
class ProjectDecisionReviewIssue {
  const ProjectDecisionReviewIssue({
    required this.field,
    required this.message,
  });

  final String field;
  final String message;
}

/// Editable review draft for one existing project decision record.
class ProjectDecisionReviewDraft {
  const ProjectDecisionReviewDraft({
    required this.recordId,
    required this.outcome,
    required this.owner,
    required this.note,
    this.evidenceLabel = '',
  });

  final String recordId;
  final ProjectDecisionReviewOutcome outcome;
  final String owner;
  final String note;
  final String evidenceLabel;

  ProjectDecisionReviewDraft copyWith({
    String? recordId,
    ProjectDecisionReviewOutcome? outcome,
    String? owner,
    String? note,
    String? evidenceLabel,
  }) {
    return ProjectDecisionReviewDraft(
      recordId: recordId ?? this.recordId,
      outcome: outcome ?? this.outcome,
      owner: owner ?? this.owner,
      note: note ?? this.note,
      evidenceLabel: evidenceLabel ?? this.evidenceLabel,
    );
  }
}

/// Submitted local review outcome for demo workflow history.
class ProjectDecisionReviewSubmission {
  const ProjectDecisionReviewSubmission({
    required this.originalRecord,
    required this.outcome,
    required this.resultingStatus,
    required this.owner,
    required this.submittedAt,
    required this.routeLabel,
    required this.summaryText,
  });

  final ProjectDecisionRecord originalRecord;
  final ProjectDecisionReviewOutcome outcome;
  final ProjectDecisionStatus resultingStatus;
  final String owner;
  final DateTime submittedAt;
  final String routeLabel;
  final String summaryText;
}

/// Service for validating and submitting local decision review outcomes.
class ProjectDecisionReviewFlowService {
  const ProjectDecisionReviewFlowService();

  List<ProjectDecisionRecord> reviewableRecords(
    ProjectDecisionRegisterSummary register,
  ) {
    final openRecords = [
      for (final record in register.records)
        if (record.isOpen) record,
    ];
    if (openRecords.isNotEmpty) return List.unmodifiable(openRecords);

    return register.records;
  }

  ProjectDecisionReviewDraft initialDraft(
    ProjectDecisionRegisterSummary register,
  ) {
    final record = reviewableRecords(register).first;

    return draftForRecord(record);
  }

  ProjectDecisionReviewDraft draftForRecord(ProjectDecisionRecord record) {
    return ProjectDecisionReviewDraft(
      recordId: record.id,
      outcome: recommendedOutcome(record),
      owner: record.owner,
      note: '',
      evidenceLabel: record.evidenceLabel,
    );
  }

  ProjectDecisionRecord? recordFor(
    ProjectDecisionRegisterSummary register,
    String recordId,
  ) {
    for (final record in register.records) {
      if (record.id == recordId) return record;
    }

    return null;
  }

  ProjectDecisionReviewOutcome recommendedOutcome(
    ProjectDecisionRecord record,
  ) {
    if (record.status == ProjectDecisionStatus.blocked ||
        record.priority == ProjectDecisionPriority.critical) {
      return ProjectDecisionReviewOutcome.escalate;
    }
    if (record.evidenceLabel.trim().isEmpty &&
        record.status != ProjectDecisionStatus.delegated) {
      return ProjectDecisionReviewOutcome.requestEvidence;
    }
    if (record.status == ProjectDecisionStatus.delegated) {
      return ProjectDecisionReviewOutcome.close;
    }
    if (record.status == ProjectDecisionStatus.inReview) {
      return ProjectDecisionReviewOutcome.approve;
    }

    return ProjectDecisionReviewOutcome.delegate;
  }

  ProjectDecisionStatus statusFor(ProjectDecisionReviewOutcome outcome) {
    switch (outcome) {
      case ProjectDecisionReviewOutcome.approve:
        return ProjectDecisionStatus.approved;
      case ProjectDecisionReviewOutcome.requestEvidence:
        return ProjectDecisionStatus.inReview;
      case ProjectDecisionReviewOutcome.delegate:
        return ProjectDecisionStatus.delegated;
      case ProjectDecisionReviewOutcome.escalate:
        return ProjectDecisionStatus.awaitingDecision;
      case ProjectDecisionReviewOutcome.close:
        return ProjectDecisionStatus.completed;
    }
  }

  String routeLabelFor(ProjectDecisionReviewOutcome outcome) {
    switch (outcome) {
      case ProjectDecisionReviewOutcome.approve:
      case ProjectDecisionReviewOutcome.close:
        return 'Approval route';
      case ProjectDecisionReviewOutcome.requestEvidence:
        return 'Evidence route';
      case ProjectDecisionReviewOutcome.delegate:
        return 'Owner route';
      case ProjectDecisionReviewOutcome.escalate:
        return 'Sponsor route';
    }
  }

  List<ProjectDecisionReviewIssue> validate({
    required ProjectDecisionRegisterSummary register,
    required ProjectDecisionReviewDraft draft,
  }) {
    final issues = <ProjectDecisionReviewIssue>[];
    final record = recordFor(register, draft.recordId);
    if (record == null) {
      issues.add(
        const ProjectDecisionReviewIssue(
          field: 'record',
          message: 'Select a decision record to review.',
        ),
      );
    }
    if (draft.owner.trim().isEmpty) {
      issues.add(
        const ProjectDecisionReviewIssue(
          field: 'owner',
          message: 'Review owner is required.',
        ),
      );
    }
    if (draft.note.trim().length < 20) {
      issues.add(
        const ProjectDecisionReviewIssue(
          field: 'note',
          message: 'Review note should explain the decision outcome.',
        ),
      );
    }
    if ((draft.outcome == ProjectDecisionReviewOutcome.approve ||
            draft.outcome == ProjectDecisionReviewOutcome.close) &&
        draft.evidenceLabel.trim().isEmpty) {
      issues.add(
        const ProjectDecisionReviewIssue(
          field: 'evidence',
          message: 'Approval and closure outcomes need evidence.',
        ),
      );
    }

    return List.unmodifiable(issues);
  }

  ProjectDecisionReviewSubmission submit({
    required ProjectDecisionRegisterSummary register,
    required ProjectDecisionReviewDraft draft,
  }) {
    final issues = validate(register: register, draft: draft);
    if (issues.isNotEmpty) {
      throw StateError('Decision review draft is not ready to submit.');
    }

    final record = recordFor(register, draft.recordId)!;
    final resultingStatus = statusFor(draft.outcome);
    final routeLabel = routeLabelFor(draft.outcome);

    return ProjectDecisionReviewSubmission(
      originalRecord: record,
      outcome: draft.outcome,
      resultingStatus: resultingStatus,
      owner: draft.owner.trim(),
      submittedAt: register.today,
      routeLabel: routeLabel,
      summaryText: _summaryText(
        record: record,
        draft: draft,
        resultingStatus: resultingStatus,
        routeLabel: routeLabel,
      ),
    );
  }
}

String _summaryText({
  required ProjectDecisionRecord record,
  required ProjectDecisionReviewDraft draft,
  required ProjectDecisionStatus resultingStatus,
  required String routeLabel,
}) {
  return [
    'Decision review outcome',
    'Decision: ${record.title}',
    'Outcome: ${draft.outcome.label}',
    'Resulting status: ${resultingStatus.label}',
    'Owner: ${draft.owner.trim()}',
    'Route: $routeLabel',
    if (draft.evidenceLabel.trim().isNotEmpty)
      'Evidence: ${draft.evidenceLabel.trim()}',
    'Note: ${draft.note.trim()}',
  ].join('\n');
}

extension ProjectDecisionReviewOutcomePresentation
    on ProjectDecisionReviewOutcome {
  /// User-facing label for a review outcome.
  String get label {
    switch (this) {
      case ProjectDecisionReviewOutcome.approve:
        return 'Approve';
      case ProjectDecisionReviewOutcome.requestEvidence:
        return 'Request evidence';
      case ProjectDecisionReviewOutcome.delegate:
        return 'Delegate';
      case ProjectDecisionReviewOutcome.escalate:
        return 'Escalate';
      case ProjectDecisionReviewOutcome.close:
        return 'Close';
    }
  }

  /// Icon for a review outcome.
  IconData get icon {
    switch (this) {
      case ProjectDecisionReviewOutcome.approve:
        return Icons.approval_outlined;
      case ProjectDecisionReviewOutcome.requestEvidence:
        return Icons.fact_check_outlined;
      case ProjectDecisionReviewOutcome.delegate:
        return Icons.assignment_ind_outlined;
      case ProjectDecisionReviewOutcome.escalate:
        return Icons.notification_important_outlined;
      case ProjectDecisionReviewOutcome.close:
        return Icons.check_circle_outline;
    }
  }

  /// Color for a review outcome.
  Color color(ColorScheme colorScheme) {
    switch (this) {
      case ProjectDecisionReviewOutcome.approve:
      case ProjectDecisionReviewOutcome.close:
        return Colors.green.shade700;
      case ProjectDecisionReviewOutcome.requestEvidence:
      case ProjectDecisionReviewOutcome.delegate:
        return Colors.orange.shade700;
      case ProjectDecisionReviewOutcome.escalate:
        return colorScheme.error;
    }
  }
}
