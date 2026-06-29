import 'employee_directory_roster_payroll_validation_models.dart';

/// Captures payroll operator input before launching a validated payroll run.
class EmployeeDirectoryRosterPayrollRunKickoffDraft {
  final String runReference;
  final String runOwner;
  final String kickoffNote;
  final bool confirmFundingWindow;
  final bool confirmPayslipHold;
  final bool confirmAuditArchive;

  const EmployeeDirectoryRosterPayrollRunKickoffDraft({
    this.runReference = '',
    this.runOwner = '',
    this.kickoffNote = '',
    this.confirmFundingWindow = false,
    this.confirmPayslipHold = false,
    this.confirmAuditArchive = false,
  });

  bool get hasInput {
    return runReference.trim().isNotEmpty ||
        runOwner.trim().isNotEmpty ||
        kickoffNote.trim().isNotEmpty ||
        confirmFundingWindow ||
        confirmPayslipHold ||
        confirmAuditArchive;
  }

  EmployeeDirectoryRosterPayrollRunKickoffDraft copyWith({
    String? runReference,
    String? runOwner,
    String? kickoffNote,
    bool? confirmFundingWindow,
    bool? confirmPayslipHold,
    bool? confirmAuditArchive,
  }) {
    return EmployeeDirectoryRosterPayrollRunKickoffDraft(
      runReference: runReference ?? this.runReference,
      runOwner: runOwner ?? this.runOwner,
      kickoffNote: kickoffNote ?? this.kickoffNote,
      confirmFundingWindow: confirmFundingWindow ?? this.confirmFundingWindow,
      confirmPayslipHold: confirmPayslipHold ?? this.confirmPayslipHold,
      confirmAuditArchive: confirmAuditArchive ?? this.confirmAuditArchive,
    );
  }
}

/// Immutable audit record for a launched payroll run.
class EmployeeDirectoryRosterPayrollRunKickoffRecord {
  final String id;
  final String validationRecordId;
  final String batchLabel;
  final String releaseVersion;
  final String runReference;
  final String runOwner;
  final String kickoffNote;
  final DateTime launchedAt;
  final int loadedProfileCount;
  final int validationItemCount;
  final int payrollImpactCount;

  const EmployeeDirectoryRosterPayrollRunKickoffRecord({
    required this.id,
    required this.validationRecordId,
    required this.batchLabel,
    required this.releaseVersion,
    required this.runReference,
    required this.runOwner,
    required this.kickoffNote,
    required this.launchedAt,
    required this.loadedProfileCount,
    required this.validationItemCount,
    required this.payrollImpactCount,
  });

  String get summaryLabel {
    return '$loadedProfileCount loaded profile'
        '${loadedProfileCount == 1 ? '' : 's'} launched with '
        '$validationItemCount validation item'
        '${validationItemCount == 1 ? '' : 's'} cleared.';
  }
}

/// Validates whether the latest payroll import validation can launch a run.
class EmployeeDirectoryRosterPayrollRunKickoffReview {
  final EmployeeDirectoryRosterPayrollValidationRecord? latestValidation;
  final EmployeeDirectoryRosterPayrollRunKickoffDraft draft;
  final List<EmployeeDirectoryRosterPayrollRunKickoffRecord> records;
  final List<String> errors;

  const EmployeeDirectoryRosterPayrollRunKickoffReview({
    required this.latestValidation,
    required this.draft,
    required this.records,
    required this.errors,
  });

  factory EmployeeDirectoryRosterPayrollRunKickoffReview.fromState({
    required EmployeeDirectoryRosterPayrollValidationReview validationReview,
    required EmployeeDirectoryRosterPayrollRunKickoffDraft draft,
    required List<EmployeeDirectoryRosterPayrollRunKickoffRecord> records,
  }) {
    final review = EmployeeDirectoryRosterPayrollRunKickoffReview(
      latestValidation: validationReview.latestBatchRecord,
      draft: draft,
      records: records,
      errors: const [],
    );

    return EmployeeDirectoryRosterPayrollRunKickoffReview(
      latestValidation: review.latestValidation,
      draft: draft,
      records: records,
      errors: _validate(review),
    );
  }

  EmployeeDirectoryRosterPayrollRunKickoffRecord? get latestRecord {
    return records.isEmpty ? null : records.first;
  }

  EmployeeDirectoryRosterPayrollRunKickoffRecord? get latestValidationRecord {
    final validation = latestValidation;
    if (validation == null) return null;
    for (final record in records) {
      if (record.validationRecordId == validation.id) return record;
    }
    return null;
  }

  bool get hasValidation => latestValidation != null;

  bool get isLaunched => latestValidationRecord != null;

  bool get canLaunch => errors.isEmpty;

  String get statusLabel {
    if (!hasValidation) return 'No validation';
    if (isLaunched) return 'Launched';
    if (!draft.confirmFundingWindow) return 'Funding';
    if (!draft.confirmPayslipHold) return 'Payslip hold';
    return canLaunch ? 'Ready' : 'Draft';
  }

  double get completionRatio {
    final checks = [
      hasValidation,
      !isLaunched,
      draft.runReference.trim().length >= 5,
      draft.runOwner.trim().length >= 3,
      draft.kickoffNote.trim().length >= 16,
      draft.confirmFundingWindow,
      draft.confirmPayslipHold,
      draft.confirmAuditArchive,
    ];
    return checks.where((check) => check).length / checks.length;
  }

  EmployeeDirectoryRosterPayrollRunKickoffRecord toRecord({
    required String id,
    required DateTime launchedAt,
  }) {
    if (!canLaunch) {
      throw StateError(errors.first);
    }

    final validation = latestValidation!;
    return EmployeeDirectoryRosterPayrollRunKickoffRecord(
      id: id,
      validationRecordId: validation.id,
      batchLabel: validation.batchLabel,
      releaseVersion: validation.releaseVersion,
      runReference: draft.runReference.trim(),
      runOwner: draft.runOwner.trim(),
      kickoffNote: draft.kickoffNote.trim(),
      launchedAt: launchedAt,
      loadedProfileCount: validation.loadedProfileCount,
      validationItemCount: validation.validationItemCount,
      payrollImpactCount: validation.payrollImpactCount,
    );
  }
}

List<String> _validate(EmployeeDirectoryRosterPayrollRunKickoffReview review) {
  final errors = <String>[];
  final draft = review.draft;

  if (!review.hasValidation) {
    errors.add('Validate payroll import before launching payroll run.');
  }
  if (review.isLaunched) {
    errors.add('Latest payroll run is already launched.');
  }
  if (draft.runReference.trim().length < 5) {
    errors.add('Payroll run reference is required.');
  }
  if (draft.runOwner.trim().length < 3) {
    errors.add('Payroll run owner is required.');
  }
  if (draft.kickoffNote.trim().length < 16) {
    errors.add('Kickoff note must be at least 16 characters.');
  }
  if (!draft.confirmFundingWindow) {
    errors.add('Confirm payroll funding window before launch.');
  }
  if (!draft.confirmPayslipHold) {
    errors.add('Confirm payslip release hold before launch.');
  }
  if (!draft.confirmAuditArchive) {
    errors.add('Confirm payroll audit trail archive before launch.');
  }

  return errors;
}
