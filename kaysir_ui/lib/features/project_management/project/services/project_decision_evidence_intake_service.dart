import 'package:flutter/material.dart';

import '../models/project_decision_record.dart';
import 'project_decision_register_service.dart';

/// Evidence type captured by the decision evidence intake flow.
enum ProjectDecisionEvidenceIntakeKind {
  approval,
  checklist,
  budget,
  risk,
  stakeholder,
  fileLink,
}

/// Review confidence for newly attached decision evidence.
enum ProjectDecisionEvidenceConfidence { draft, reviewed, signedOff }

/// Validation issue emitted for an evidence intake draft.
class ProjectDecisionEvidenceIntakeIssue {
  const ProjectDecisionEvidenceIntakeIssue({
    required this.field,
    required this.message,
  });

  final String field;
  final String message;
}

/// Editable evidence draft linked to one decision register record.
class ProjectDecisionEvidenceIntakeDraft {
  const ProjectDecisionEvidenceIntakeDraft({
    required this.recordId,
    required this.kind,
    required this.confidence,
    required this.title,
    required this.reference,
    required this.note,
  });

  final String recordId;
  final ProjectDecisionEvidenceIntakeKind kind;
  final ProjectDecisionEvidenceConfidence confidence;
  final String title;
  final String reference;
  final String note;

  ProjectDecisionEvidenceIntakeDraft copyWith({
    String? recordId,
    ProjectDecisionEvidenceIntakeKind? kind,
    ProjectDecisionEvidenceConfidence? confidence,
    String? title,
    String? reference,
    String? note,
  }) {
    return ProjectDecisionEvidenceIntakeDraft(
      recordId: recordId ?? this.recordId,
      kind: kind ?? this.kind,
      confidence: confidence ?? this.confidence,
      title: title ?? this.title,
      reference: reference ?? this.reference,
      note: note ?? this.note,
    );
  }
}

/// Submitted local evidence intake item for demo workflow history.
class ProjectDecisionEvidenceIntakeSubmission {
  const ProjectDecisionEvidenceIntakeSubmission({
    required this.record,
    required this.kind,
    required this.confidence,
    required this.title,
    required this.reference,
    required this.note,
    required this.submittedAt,
    required this.evidenceLabel,
    required this.summaryText,
  });

  final ProjectDecisionRecord record;
  final ProjectDecisionEvidenceIntakeKind kind;
  final ProjectDecisionEvidenceConfidence confidence;
  final String title;
  final String reference;
  final String note;
  final DateTime submittedAt;
  final String evidenceLabel;
  final String summaryText;
}

/// Service for validating and submitting decision evidence intake drafts.
class ProjectDecisionEvidenceIntakeService {
  const ProjectDecisionEvidenceIntakeService();

  List<ProjectDecisionRecord> evidenceTargets(
    ProjectDecisionRegisterSummary register,
  ) {
    final openRecords = [
      for (final record in register.records)
        if (record.isOpen) record,
    ];
    if (openRecords.isNotEmpty) return List.unmodifiable(openRecords);

    return register.records;
  }

  ProjectDecisionEvidenceIntakeDraft initialDraft(
    ProjectDecisionRegisterSummary register,
  ) {
    final records = evidenceTargets(register);
    if (records.isEmpty) {
      return const ProjectDecisionEvidenceIntakeDraft(
        recordId: '',
        kind: ProjectDecisionEvidenceIntakeKind.approval,
        confidence: ProjectDecisionEvidenceConfidence.draft,
        title: '',
        reference: '',
        note: '',
      );
    }

    return draftForRecord(records.first);
  }

  ProjectDecisionEvidenceIntakeDraft draftForRecord(
    ProjectDecisionRecord record,
  ) {
    return ProjectDecisionEvidenceIntakeDraft(
      recordId: record.id,
      kind: recommendedKind(record),
      confidence: recommendedConfidence(record),
      title: '',
      reference: '',
      note: '',
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

  ProjectDecisionEvidenceIntakeKind recommendedKind(
    ProjectDecisionRecord record,
  ) {
    final searchable = '${record.title} ${record.detail}'.toLowerCase();
    if (searchable.contains('budget') ||
        searchable.contains('cost') ||
        searchable.contains('cash')) {
      return ProjectDecisionEvidenceIntakeKind.budget;
    }

    switch (record.source) {
      case ProjectDecisionSource.nextDecision:
      case ProjectDecisionSource.governance:
        return ProjectDecisionEvidenceIntakeKind.approval;
      case ProjectDecisionSource.risk:
        return ProjectDecisionEvidenceIntakeKind.risk;
      case ProjectDecisionSource.milestone:
        return ProjectDecisionEvidenceIntakeKind.checklist;
      case ProjectDecisionSource.domainExtension:
        return ProjectDecisionEvidenceIntakeKind.stakeholder;
    }
  }

  ProjectDecisionEvidenceConfidence recommendedConfidence(
    ProjectDecisionRecord record,
  ) {
    switch (record.status) {
      case ProjectDecisionStatus.approved:
      case ProjectDecisionStatus.completed:
        return ProjectDecisionEvidenceConfidence.signedOff;
      case ProjectDecisionStatus.inReview:
      case ProjectDecisionStatus.delegated:
        return ProjectDecisionEvidenceConfidence.reviewed;
      case ProjectDecisionStatus.awaitingDecision:
      case ProjectDecisionStatus.blocked:
        return ProjectDecisionEvidenceConfidence.draft;
    }
  }

  String evidenceLabelFor(ProjectDecisionEvidenceIntakeDraft draft) {
    return '${draft.kind.label} - ${draft.confidence.label}';
  }

  List<ProjectDecisionEvidenceIntakeIssue> validate({
    required ProjectDecisionRegisterSummary register,
    required ProjectDecisionEvidenceIntakeDraft draft,
  }) {
    final issues = <ProjectDecisionEvidenceIntakeIssue>[];
    final record = recordFor(register, draft.recordId);
    if (record == null) {
      issues.add(
        const ProjectDecisionEvidenceIntakeIssue(
          field: 'decision',
          message: 'Select a decision record to attach evidence.',
        ),
      );
    }

    final title = draft.title.trim();
    if (title.isEmpty) {
      issues.add(
        const ProjectDecisionEvidenceIntakeIssue(
          field: 'title',
          message: 'Evidence title is required.',
        ),
      );
    } else if (title.length < 8) {
      issues.add(
        const ProjectDecisionEvidenceIntakeIssue(
          field: 'title',
          message: 'Evidence title should be specific.',
        ),
      );
    }

    final reference = draft.reference.trim();
    if (reference.isEmpty) {
      issues.add(
        const ProjectDecisionEvidenceIntakeIssue(
          field: 'reference',
          message: 'Reference is required.',
        ),
      );
    } else if (reference.length < 4) {
      issues.add(
        const ProjectDecisionEvidenceIntakeIssue(
          field: 'reference',
          message: 'Reference should identify a file, URL, memo, or ticket.',
        ),
      );
    }

    final note = draft.note.trim();
    if (note.isEmpty) {
      issues.add(
        const ProjectDecisionEvidenceIntakeIssue(
          field: 'note',
          message: 'Evidence note is required.',
        ),
      );
    } else if (note.length < 20) {
      issues.add(
        const ProjectDecisionEvidenceIntakeIssue(
          field: 'note',
          message: 'Evidence note should explain what the proof confirms.',
        ),
      );
    }

    if (draft.confidence == ProjectDecisionEvidenceConfidence.signedOff &&
        reference.isNotEmpty &&
        reference.length < 6) {
      issues.add(
        const ProjectDecisionEvidenceIntakeIssue(
          field: 'confidence',
          message: 'Signed-off evidence needs a stable reference.',
        ),
      );
    }

    return List.unmodifiable(issues);
  }

  ProjectDecisionEvidenceIntakeSubmission submit({
    required ProjectDecisionRegisterSummary register,
    required ProjectDecisionEvidenceIntakeDraft draft,
  }) {
    final issues = validate(register: register, draft: draft);
    if (issues.isNotEmpty) {
      throw StateError('Decision evidence draft is not ready to submit.');
    }

    final record = recordFor(register, draft.recordId)!;
    final evidenceLabel = evidenceLabelFor(draft);

    return ProjectDecisionEvidenceIntakeSubmission(
      record: record,
      kind: draft.kind,
      confidence: draft.confidence,
      title: draft.title.trim(),
      reference: draft.reference.trim(),
      note: draft.note.trim(),
      submittedAt: register.today,
      evidenceLabel: evidenceLabel,
      summaryText: _summaryText(
        record: record,
        draft: draft,
        evidenceLabel: evidenceLabel,
      ),
    );
  }
}

String _summaryText({
  required ProjectDecisionRecord record,
  required ProjectDecisionEvidenceIntakeDraft draft,
  required String evidenceLabel,
}) {
  return [
    'Decision evidence intake',
    'Decision: ${record.title}',
    'Evidence: ${draft.title.trim()}',
    'Type: $evidenceLabel',
    'Reference: ${draft.reference.trim()}',
    'Owner: ${record.owner}',
    'Note: ${draft.note.trim()}',
  ].join('\n');
}

extension ProjectDecisionEvidenceIntakeKindPresentation
    on ProjectDecisionEvidenceIntakeKind {
  /// User-facing label for an evidence intake type.
  String get label {
    switch (this) {
      case ProjectDecisionEvidenceIntakeKind.approval:
        return 'Approval';
      case ProjectDecisionEvidenceIntakeKind.checklist:
        return 'Checklist';
      case ProjectDecisionEvidenceIntakeKind.budget:
        return 'Budget';
      case ProjectDecisionEvidenceIntakeKind.risk:
        return 'Risk';
      case ProjectDecisionEvidenceIntakeKind.stakeholder:
        return 'Stakeholder';
      case ProjectDecisionEvidenceIntakeKind.fileLink:
        return 'File / Link';
    }
  }

  /// Icon for an evidence intake type.
  IconData get icon {
    switch (this) {
      case ProjectDecisionEvidenceIntakeKind.approval:
        return Icons.approval_outlined;
      case ProjectDecisionEvidenceIntakeKind.checklist:
        return Icons.fact_check_outlined;
      case ProjectDecisionEvidenceIntakeKind.budget:
        return Icons.account_balance_wallet_outlined;
      case ProjectDecisionEvidenceIntakeKind.risk:
        return Icons.health_and_safety_outlined;
      case ProjectDecisionEvidenceIntakeKind.stakeholder:
        return Icons.groups_outlined;
      case ProjectDecisionEvidenceIntakeKind.fileLink:
        return Icons.attach_file_outlined;
    }
  }
}

extension ProjectDecisionEvidenceConfidencePresentation
    on ProjectDecisionEvidenceConfidence {
  /// User-facing label for evidence confidence.
  String get label {
    switch (this) {
      case ProjectDecisionEvidenceConfidence.draft:
        return 'Draft';
      case ProjectDecisionEvidenceConfidence.reviewed:
        return 'Reviewed';
      case ProjectDecisionEvidenceConfidence.signedOff:
        return 'Signed Off';
    }
  }

  /// Icon for evidence confidence.
  IconData get icon {
    switch (this) {
      case ProjectDecisionEvidenceConfidence.draft:
        return Icons.edit_note_outlined;
      case ProjectDecisionEvidenceConfidence.reviewed:
        return Icons.rate_review_outlined;
      case ProjectDecisionEvidenceConfidence.signedOff:
        return Icons.verified_outlined;
    }
  }

  /// Color for evidence confidence.
  Color color(ColorScheme colorScheme) {
    switch (this) {
      case ProjectDecisionEvidenceConfidence.draft:
        return colorScheme.primary;
      case ProjectDecisionEvidenceConfidence.reviewed:
        return Colors.orange.shade700;
      case ProjectDecisionEvidenceConfidence.signedOff:
        return Colors.green.shade700;
    }
  }
}
