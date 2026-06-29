import 'employee_directory_models.dart';
import 'employee_directory_roster_payroll_sync_models.dart';
import 'employee_directory_roster_publish_models.dart';

/// Captures payroll staging input before creating an import packet.
class EmployeeDirectoryRosterPayrollImportDraft {
  final String batchLabel;
  final String preparedBy;
  final String importNote;
  final bool confirmColumnMapping;
  final bool confirmAttentionProfiles;
  final bool confirmPreviewControls;

  const EmployeeDirectoryRosterPayrollImportDraft({
    this.batchLabel = '',
    this.preparedBy = '',
    this.importNote = '',
    this.confirmColumnMapping = false,
    this.confirmAttentionProfiles = false,
    this.confirmPreviewControls = false,
  });

  bool get hasInput {
    return batchLabel.trim().isNotEmpty ||
        preparedBy.trim().isNotEmpty ||
        importNote.trim().isNotEmpty ||
        confirmColumnMapping ||
        confirmAttentionProfiles ||
        confirmPreviewControls;
  }

  EmployeeDirectoryRosterPayrollImportDraft copyWith({
    String? batchLabel,
    String? preparedBy,
    String? importNote,
    bool? confirmColumnMapping,
    bool? confirmAttentionProfiles,
    bool? confirmPreviewControls,
  }) {
    return EmployeeDirectoryRosterPayrollImportDraft(
      batchLabel: batchLabel ?? this.batchLabel,
      preparedBy: preparedBy ?? this.preparedBy,
      importNote: importNote ?? this.importNote,
      confirmColumnMapping: confirmColumnMapping ?? this.confirmColumnMapping,
      confirmAttentionProfiles:
          confirmAttentionProfiles ?? this.confirmAttentionProfiles,
      confirmPreviewControls:
          confirmPreviewControls ?? this.confirmPreviewControls,
    );
  }
}

/// Immutable audit record for a staged payroll import packet.
class EmployeeDirectoryRosterPayrollImportBatch {
  final String id;
  final String releaseId;
  final String releaseVersion;
  final String syncRecordId;
  final String batchLabel;
  final String preparedBy;
  final String importNote;
  final String controlFileName;
  final DateTime stagedAt;
  final int totalProfileCount;
  final int includedProfileCount;
  final int attentionProfileCount;
  final int departmentCount;
  final int payrollImpactCount;

  const EmployeeDirectoryRosterPayrollImportBatch({
    required this.id,
    required this.releaseId,
    required this.releaseVersion,
    required this.syncRecordId,
    required this.batchLabel,
    required this.preparedBy,
    required this.importNote,
    required this.controlFileName,
    required this.stagedAt,
    required this.totalProfileCount,
    required this.includedProfileCount,
    required this.attentionProfileCount,
    required this.departmentCount,
    required this.payrollImpactCount,
  });

  String get summaryLabel {
    return '$includedProfileCount profile'
        '${includedProfileCount == 1 ? '' : 's'} staged across '
        '$departmentCount department${departmentCount == 1 ? '' : 's'} with '
        '$attentionProfileCount attention profile'
        '${attentionProfileCount == 1 ? '' : 's'} reviewed.';
  }
}

/// Validates readiness for staging the latest synced roster into payroll.
class EmployeeDirectoryRosterPayrollImportReview {
  final EmployeeDirectoryRosterRelease? latestRelease;
  final EmployeeDirectoryRosterPayrollSyncRecord? latestSyncRecord;
  final EmployeeDirectoryRosterPayrollImportDraft draft;
  final List<EmployeeDirectoryRosterPayrollImportBatch> batches;
  final List<String> errors;

  const EmployeeDirectoryRosterPayrollImportReview({
    required this.latestRelease,
    required this.latestSyncRecord,
    required this.draft,
    required this.batches,
    required this.errors,
  });

  factory EmployeeDirectoryRosterPayrollImportReview.fromState({
    required EmployeeDirectoryRosterPayrollSyncReview syncReview,
    required EmployeeDirectoryRosterPayrollImportDraft draft,
    required List<EmployeeDirectoryRosterPayrollImportBatch> batches,
  }) {
    final review = EmployeeDirectoryRosterPayrollImportReview(
      latestRelease: syncReview.latestRelease,
      latestSyncRecord: syncReview.latestReleaseRecord,
      draft: draft,
      batches: batches,
      errors: const [],
    );

    return EmployeeDirectoryRosterPayrollImportReview(
      latestRelease: review.latestRelease,
      latestSyncRecord: review.latestSyncRecord,
      draft: draft,
      batches: batches,
      errors: _validate(review),
    );
  }

  EmployeeDirectoryRosterPayrollImportBatch? get latestBatch {
    return batches.isEmpty ? null : batches.first;
  }

  EmployeeDirectoryRosterPayrollImportBatch? get latestReleaseBatch {
    final release = latestRelease;
    if (release == null) return null;
    for (final batch in batches) {
      if (batch.releaseId == release.id) return batch;
    }
    return null;
  }

  bool get hasSyncedRelease => latestSyncRecord != null;

  bool get isStaged => latestReleaseBatch != null;

  bool get canStage => errors.isEmpty;

  List<EmployeeDirectoryRosterReleaseMemberSnapshot> get snapshots {
    return latestRelease?.memberSnapshots ?? const [];
  }

  int get totalProfileCount {
    return latestRelease?.memberCount ?? 0;
  }

  int get includedProfileCount => totalProfileCount;

  int get departmentCount {
    final release = latestRelease;
    if (release == null) return 0;
    if (snapshots.isEmpty) return release.departmentCount;
    return snapshots.map((snapshot) => snapshot.department).toSet().length;
  }

  int get attentionProfileCount {
    return snapshots
        .where((snapshot) => snapshot.status != EmployeeDirectoryStatus.active)
        .length;
  }

  bool get hasAttentionProfiles => attentionProfileCount > 0;

  int get payrollImpactCount => latestSyncRecord?.payrollImpactCount ?? 0;

  String get controlFileName {
    final release = latestRelease;
    if (release == null) return 'payroll-import.csv';
    return '${_sanitizeFileSegment(release.versionLabel)}-payroll-import.csv';
  }

  String get statusLabel {
    if (latestRelease == null) return 'No release';
    if (!hasSyncedRelease) return 'Needs sync';
    if (isStaged) return 'Staged';
    if (!draft.confirmColumnMapping) return 'Mapping';
    if (hasAttentionProfiles && !draft.confirmAttentionProfiles) {
      return 'Attention review';
    }
    return canStage ? 'Ready' : 'Draft';
  }

  double get completionRatio {
    final checks = [
      latestRelease != null,
      hasSyncedRelease,
      !isStaged,
      draft.batchLabel.trim().length >= 5,
      draft.preparedBy.trim().length >= 3,
      draft.importNote.trim().length >= 16,
      draft.confirmColumnMapping,
      !hasAttentionProfiles || draft.confirmAttentionProfiles,
      draft.confirmPreviewControls,
    ];
    return checks.where((check) => check).length / checks.length;
  }

  EmployeeDirectoryRosterPayrollImportBatch toBatch({
    required String id,
    required DateTime stagedAt,
  }) {
    if (!canStage) {
      throw StateError(errors.first);
    }

    final release = latestRelease!;
    final syncRecord = latestSyncRecord!;
    return EmployeeDirectoryRosterPayrollImportBatch(
      id: id,
      releaseId: release.id,
      releaseVersion: release.versionLabel,
      syncRecordId: syncRecord.id,
      batchLabel: draft.batchLabel.trim(),
      preparedBy: draft.preparedBy.trim(),
      importNote: draft.importNote.trim(),
      controlFileName: controlFileName,
      stagedAt: stagedAt,
      totalProfileCount: totalProfileCount,
      includedProfileCount: includedProfileCount,
      attentionProfileCount: attentionProfileCount,
      departmentCount: departmentCount,
      payrollImpactCount: payrollImpactCount,
    );
  }
}

List<String> _validate(EmployeeDirectoryRosterPayrollImportReview review) {
  final errors = <String>[];
  final draft = review.draft;

  if (review.latestRelease == null) {
    errors.add('Publish a roster packet before staging payroll import.');
  } else if (!review.hasSyncedRelease) {
    errors.add('Sync latest roster packet before staging payroll import.');
  }
  if (review.isStaged) {
    errors.add('Latest roster payroll import packet is already staged.');
  }
  if (draft.batchLabel.trim().length < 5) {
    errors.add('Import batch label is required.');
  }
  if (draft.preparedBy.trim().length < 3) {
    errors.add('Import preparer is required.');
  }
  if (draft.importNote.trim().length < 16) {
    errors.add('Import note must be at least 16 characters.');
  }
  if (!draft.confirmColumnMapping) {
    errors.add('Confirm payroll import column mapping before staging.');
  }
  if (review.hasAttentionProfiles && !draft.confirmAttentionProfiles) {
    errors.add(
      'Review ${review.attentionProfileCount} payroll attention profile'
      '${review.attentionProfileCount == 1 ? '' : 's'} before staging.',
    );
  }
  if (!draft.confirmPreviewControls) {
    errors.add('Confirm payroll preview controls before staging.');
  }

  return errors;
}

String _sanitizeFileSegment(String value) {
  final sanitized = value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
  return sanitized.isEmpty ? 'roster' : sanitized;
}
