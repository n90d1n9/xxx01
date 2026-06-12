import 'employee_payroll_run_console_audit_decision_models.dart';
import 'employee_payroll_run_console_audit_models.dart';
import 'employee_payroll_run_console_audit_package_models.dart';

/// Workflow status for a payroll console audit package handoff.
enum EmployeePayrollRunConsoleAuditHandoffStatus {
  draft('Draft'),
  readyForReview('Ready for review'),
  submitted('Submitted'),
  approved('Approved'),
  returned('Returned');

  final String label;

  const EmployeePayrollRunConsoleAuditHandoffStatus(this.label);
}

/// Reviewer input captured before submitting a payroll audit handoff.
class EmployeePayrollRunConsoleAuditHandoffDraft {
  final String reviewer;
  final String approver;
  final DateTime? dueDate;
  final String note;

  const EmployeePayrollRunConsoleAuditHandoffDraft({
    this.reviewer = '',
    this.approver = '',
    this.dueDate,
    this.note = '',
  });

  bool get hasInput {
    return reviewer.trim().isNotEmpty ||
        approver.trim().isNotEmpty ||
        note.trim().isNotEmpty;
  }

  EmployeePayrollRunConsoleAuditHandoffDraft copyWith({
    String? reviewer,
    String? approver,
    DateTime? dueDate,
    String? note,
  }) {
    return EmployeePayrollRunConsoleAuditHandoffDraft(
      reviewer: reviewer ?? this.reviewer,
      approver: approver ?? this.approver,
      dueDate: dueDate ?? this.dueDate,
      note: note ?? this.note,
    );
  }
}

/// Immutable audit record for one payroll close handoff submission.
class EmployeePayrollRunConsoleAuditHandoffRecord {
  final String id;
  final String packageReference;
  final String reviewer;
  final String approver;
  final DateTime submittedAt;
  final DateTime dueDate;
  final String note;
  final EmployeePayrollRunConsoleAuditHandoffStatus status;
  final int readyItemCount;
  final int totalItemCount;
  final int evidencedCommandCount;
  final int totalCommandCount;
  final int reviewEventCount;
  final DateTime? decidedAt;
  final String decisionNote;
  final String returnedReason;
  final Set<EmployeePayrollRunConsoleAuditDecisionAttestation>
  decisionAttestations;

  const EmployeePayrollRunConsoleAuditHandoffRecord({
    required this.id,
    required this.packageReference,
    required this.reviewer,
    required this.approver,
    required this.submittedAt,
    required this.dueDate,
    required this.note,
    required this.status,
    required this.readyItemCount,
    required this.totalItemCount,
    required this.evidencedCommandCount,
    required this.totalCommandCount,
    required this.reviewEventCount,
    this.decidedAt,
    this.decisionNote = '',
    this.returnedReason = '',
    this.decisionAttestations = const {},
  });

  String get statusLabel => status.label;

  bool get canApprove {
    return status == EmployeePayrollRunConsoleAuditHandoffStatus.submitted;
  }

  bool get canReturn {
    return status == EmployeePayrollRunConsoleAuditHandoffStatus.submitted;
  }

  bool get isDecided {
    return decidedAt != null &&
        (status == EmployeePayrollRunConsoleAuditHandoffStatus.approved ||
            status == EmployeePayrollRunConsoleAuditHandoffStatus.returned);
  }

  int get requiredDecisionAttestationCount {
    return EmployeePayrollRunConsoleAuditDecisionAttestation.values.length;
  }

  int get decisionAttestationCount => decisionAttestations.length;

  bool get hasCompleteDecisionAttestation {
    return decisionAttestationCount == requiredDecisionAttestationCount;
  }

  String get decisionAttestationLabel {
    if (status == EmployeePayrollRunConsoleAuditHandoffStatus.returned) {
      return 'Return note captured';
    }
    return '$decisionAttestationCount/$requiredDecisionAttestationCount controls';
  }

  String get summaryLabel {
    return switch (status) {
      EmployeePayrollRunConsoleAuditHandoffStatus.approved =>
        decisionNote.isEmpty
            ? 'Approved by $approver for payroll close archive.'
            : 'Approved by $approver: $decisionNote',
      EmployeePayrollRunConsoleAuditHandoffStatus.returned =>
        'Returned by $approver: '
            '${returnedReason.isEmpty ? 'Evidence needs revision.' : returnedReason}',
      EmployeePayrollRunConsoleAuditHandoffStatus.submitted =>
        '$readyItemCount/$totalItemCount package checks, '
            '$evidencedCommandCount/$totalCommandCount command stages.',
      EmployeePayrollRunConsoleAuditHandoffStatus.readyForReview =>
        'Ready for reviewer and approver acknowledgement.',
      EmployeePayrollRunConsoleAuditHandoffStatus.draft =>
        'Handoff draft is being prepared.',
    };
  }

  EmployeePayrollRunConsoleAuditHandoffRecord copyWith({
    EmployeePayrollRunConsoleAuditHandoffStatus? status,
    DateTime? decidedAt,
    String? decisionNote,
    String? returnedReason,
    Set<EmployeePayrollRunConsoleAuditDecisionAttestation>?
    decisionAttestations,
  }) {
    return EmployeePayrollRunConsoleAuditHandoffRecord(
      id: id,
      packageReference: packageReference,
      reviewer: reviewer,
      approver: approver,
      submittedAt: submittedAt,
      dueDate: dueDate,
      note: note,
      status: status ?? this.status,
      readyItemCount: readyItemCount,
      totalItemCount: totalItemCount,
      evidencedCommandCount: evidencedCommandCount,
      totalCommandCount: totalCommandCount,
      reviewEventCount: reviewEventCount,
      decidedAt: decidedAt ?? this.decidedAt,
      decisionNote: decisionNote ?? this.decisionNote,
      returnedReason: returnedReason ?? this.returnedReason,
      decisionAttestations: decisionAttestations ?? this.decisionAttestations,
    );
  }

  EmployeePayrollRunConsoleAuditHandoffRecord approve({
    required DateTime approvedAt,
    required Set<EmployeePayrollRunConsoleAuditDecisionAttestation>
    attestations,
    String note = '',
  }) {
    if (!canApprove) {
      throw StateError('Only submitted handoffs can be approved.');
    }
    if (attestations.length != requiredDecisionAttestationCount) {
      throw StateError('All approval attestations are required.');
    }
    return copyWith(
      status: EmployeePayrollRunConsoleAuditHandoffStatus.approved,
      decidedAt: approvedAt,
      decisionNote: note.trim(),
      decisionAttestations: Set.unmodifiable(attestations),
    );
  }

  EmployeePayrollRunConsoleAuditHandoffRecord returnForRevision({
    required DateTime returnedAt,
    required String reason,
  }) {
    if (!canReturn) {
      throw StateError('Only submitted handoffs can be returned.');
    }
    return copyWith(
      status: EmployeePayrollRunConsoleAuditHandoffStatus.returned,
      decidedAt: returnedAt,
      decisionNote: reason.trim(),
      returnedReason: reason.trim(),
      decisionAttestations: const {},
    );
  }
}

/// Validates a payroll audit package handoff against package readiness.
class EmployeePayrollRunConsoleAuditHandoffReview {
  final EmployeePayrollRunConsoleAuditEvidencePackage package;
  final EmployeePayrollRunConsoleAuditHandoffDraft draft;
  final List<EmployeePayrollRunConsoleAuditHandoffRecord> handoffs;
  final List<String> errors;

  const EmployeePayrollRunConsoleAuditHandoffReview({
    required this.package,
    required this.draft,
    required this.handoffs,
    required this.errors,
  });

  factory EmployeePayrollRunConsoleAuditHandoffReview.fromState({
    required EmployeePayrollRunConsoleAuditEvidencePackage package,
    required EmployeePayrollRunConsoleAuditHandoffDraft draft,
    required List<EmployeePayrollRunConsoleAuditHandoffRecord> handoffs,
  }) {
    final review = EmployeePayrollRunConsoleAuditHandoffReview(
      package: package,
      draft: draft,
      handoffs: handoffs,
      errors: const [],
    );

    return EmployeePayrollRunConsoleAuditHandoffReview(
      package: package,
      draft: draft,
      handoffs: handoffs,
      errors: _validate(review),
    );
  }

  EmployeePayrollRunConsoleAuditSummary get summary => package.summary;

  EmployeePayrollRunConsoleAuditHandoffRecord? get latestHandoff {
    if (handoffs.isEmpty) return null;
    return handoffs.reduce(
      (a, b) => a.submittedAt.isAfter(b.submittedAt) ? a : b,
    );
  }

  int get reviewEventCount => summary.attentionCount;

  bool get canSubmit => errors.isEmpty;

  String get statusLabel {
    final latest = latestHandoff;
    if (latest != null && !latest.canApprove) return latest.statusLabel;
    if (canSubmit) {
      return EmployeePayrollRunConsoleAuditHandoffStatus.readyForReview.label;
    }
    if (summary.eventCount == 0) {
      return EmployeePayrollRunConsoleAuditHandoffStatus.draft.label;
    }
    if (package.report.status ==
            EmployeePayrollRunConsoleAuditEvidenceStatus.ready &&
        package.hasCompleteCommandCoverage &&
        package.readyItemCount == package.totalItemCount) {
      return 'Needs detail';
    }
    return 'Needs review';
  }

  double get completionRatio {
    final checks = [
      summary.eventCount > 0,
      package.report.status ==
          EmployeePayrollRunConsoleAuditEvidenceStatus.ready,
      package.hasCompleteCommandCoverage,
      package.readyItemCount == package.totalItemCount,
      draft.reviewer.trim().length >= 3,
      draft.approver.trim().length >= 3,
      draft.dueDate != null,
      draft.note.trim().length >= 12,
    ];
    return checks.where((check) => check).length / checks.length;
  }

  EmployeePayrollRunConsoleAuditHandoffRecord toRecord({
    required String id,
    required DateTime submittedAt,
  }) {
    if (!canSubmit) {
      throw StateError(errors.first);
    }

    return EmployeePayrollRunConsoleAuditHandoffRecord(
      id: id,
      packageReference: package.packageReference,
      reviewer: draft.reviewer.trim(),
      approver: draft.approver.trim(),
      submittedAt: submittedAt,
      dueDate: draft.dueDate!,
      note: draft.note.trim(),
      status: EmployeePayrollRunConsoleAuditHandoffStatus.submitted,
      readyItemCount: package.readyItemCount,
      totalItemCount: package.totalItemCount,
      evidencedCommandCount: package.evidencedCommandCount,
      totalCommandCount: package.totalCommandCount,
      reviewEventCount: reviewEventCount,
    );
  }
}

List<String> _validate(EmployeePayrollRunConsoleAuditHandoffReview review) {
  final errors = <String>[];
  final package = review.package;
  final draft = review.draft;

  if (package.summary.eventCount == 0) {
    errors.add('Capture command evidence before handoff.');
  }
  if (review.reviewEventCount > 0) {
    errors.add(
      'Resolve ${_plural(review.reviewEventCount, 'audit review event')} '
      'before handoff.',
    );
  }
  if (package.report.status ==
      EmployeePayrollRunConsoleAuditEvidenceStatus.noChange) {
    errors.add('Capture at least one effective payroll update before handoff.');
  }
  if (!package.hasCompleteCommandCoverage) {
    errors.add(
      'Capture evidence for all ${package.totalCommandCount} payroll command '
      'stages.',
    );
  }
  if (package.readyItemCount != package.totalItemCount) {
    errors.add('Complete all evidence package checks before handoff.');
  }
  if (draft.reviewer.trim().length < 3) {
    errors.add('Reviewer is required.');
  }
  if (draft.approver.trim().length < 3) {
    errors.add('Approver is required.');
  }
  if (draft.dueDate == null) {
    errors.add('Handoff due date is required.');
  }
  if (draft.note.trim().length < 12) {
    errors.add('Handoff note must be at least 12 characters.');
  }

  return errors;
}

String _plural(int count, String singular) {
  return '$count $singular${count == 1 ? '' : 's'}';
}
