import 'employee_directory_roster_diff_models.dart';
import 'employee_directory_roster_handoff_models.dart';
import 'employee_directory_roster_publish_models.dart';

/// Captures payroll operator input before syncing a roster release packet.
class EmployeeDirectoryRosterPayrollSyncDraft {
  final String syncedBy;
  final String syncNote;
  final bool confirmPayrollImpactReview;
  final bool confirmControlTotals;

  const EmployeeDirectoryRosterPayrollSyncDraft({
    this.syncedBy = '',
    this.syncNote = '',
    this.confirmPayrollImpactReview = false,
    this.confirmControlTotals = false,
  });

  bool get hasInput {
    return syncedBy.trim().isNotEmpty ||
        syncNote.trim().isNotEmpty ||
        confirmPayrollImpactReview ||
        confirmControlTotals;
  }

  EmployeeDirectoryRosterPayrollSyncDraft copyWith({
    String? syncedBy,
    String? syncNote,
    bool? confirmPayrollImpactReview,
    bool? confirmControlTotals,
  }) {
    return EmployeeDirectoryRosterPayrollSyncDraft(
      syncedBy: syncedBy ?? this.syncedBy,
      syncNote: syncNote ?? this.syncNote,
      confirmPayrollImpactReview:
          confirmPayrollImpactReview ?? this.confirmPayrollImpactReview,
      confirmControlTotals: confirmControlTotals ?? this.confirmControlTotals,
    );
  }
}

/// Immutable audit record for a roster release synced into payroll.
class EmployeeDirectoryRosterPayrollSyncRecord {
  final String id;
  final String releaseId;
  final String releaseVersion;
  final String syncedBy;
  final String syncNote;
  final DateTime syncedAt;
  final int profileCount;
  final int payrollImpactCount;
  final int acknowledgedHandoffCount;

  const EmployeeDirectoryRosterPayrollSyncRecord({
    required this.id,
    required this.releaseId,
    required this.releaseVersion,
    required this.syncedBy,
    required this.syncNote,
    required this.syncedAt,
    required this.profileCount,
    required this.payrollImpactCount,
    required this.acknowledgedHandoffCount,
  });

  String get summaryLabel {
    return '$profileCount profile${profileCount == 1 ? '' : 's'} synced with '
        '$payrollImpactCount payroll-impacting change'
        '${payrollImpactCount == 1 ? '' : 's'} reviewed.';
  }
}

/// Validates payroll sync readiness for the latest roster release packet.
class EmployeeDirectoryRosterPayrollSyncReview {
  final EmployeeDirectoryRosterRelease? latestRelease;
  final EmployeeDirectoryRosterDiffReview diffReview;
  final EmployeeDirectoryRosterHandoffReview handoffReview;
  final EmployeeDirectoryRosterPayrollSyncDraft draft;
  final List<EmployeeDirectoryRosterPayrollSyncRecord> records;
  final List<String> errors;

  const EmployeeDirectoryRosterPayrollSyncReview({
    required this.latestRelease,
    required this.diffReview,
    required this.handoffReview,
    required this.draft,
    required this.records,
    required this.errors,
  });

  factory EmployeeDirectoryRosterPayrollSyncReview.fromState({
    required EmployeeDirectoryRosterDiffReview diffReview,
    required EmployeeDirectoryRosterHandoffReview handoffReview,
    required EmployeeDirectoryRosterPayrollSyncDraft draft,
    required List<EmployeeDirectoryRosterPayrollSyncRecord> records,
  }) {
    final latestRelease = diffReview.latestRelease;
    final review = EmployeeDirectoryRosterPayrollSyncReview(
      latestRelease: latestRelease,
      diffReview: diffReview,
      handoffReview: handoffReview,
      draft: draft,
      records: records,
      errors: const [],
    );

    return EmployeeDirectoryRosterPayrollSyncReview(
      latestRelease: latestRelease,
      diffReview: diffReview,
      handoffReview: handoffReview,
      draft: draft,
      records: records,
      errors: _validate(review),
    );
  }

  EmployeeDirectoryRosterPayrollSyncRecord? get latestRecord {
    return records.isEmpty ? null : records.first;
  }

  EmployeeDirectoryRosterPayrollSyncRecord? get latestReleaseRecord {
    final release = latestRelease;
    if (release == null) return null;
    for (final record in records) {
      if (record.releaseId == release.id) return record;
    }
    return null;
  }

  int get payrollImpactCount => diffReview.payrollImpactCount;

  bool get hasPayrollImpact => payrollImpactCount > 0;

  bool get isSynced => latestReleaseRecord != null;

  bool get canSync => errors.isEmpty;

  String get statusLabel {
    if (latestRelease == null) return 'No release';
    if (isSynced) return 'Synced';
    if (handoffReview.openCount > 0) return 'Waiting handoff';
    if (hasPayrollImpact && !draft.confirmPayrollImpactReview) {
      return 'Impact review';
    }
    return canSync ? 'Ready' : 'Draft';
  }

  double get completionRatio {
    final checks = [
      latestRelease != null,
      handoffReview.openCount == 0,
      !hasPayrollImpact || draft.confirmPayrollImpactReview,
      draft.confirmControlTotals,
      draft.syncedBy.trim().length >= 3,
      draft.syncNote.trim().length >= 16,
      !isSynced,
    ];
    return checks.where((check) => check).length / checks.length;
  }

  EmployeeDirectoryRosterPayrollSyncRecord toRecord({
    required String id,
    required DateTime syncedAt,
  }) {
    if (!canSync) {
      throw StateError(errors.first);
    }

    final release = latestRelease!;
    return EmployeeDirectoryRosterPayrollSyncRecord(
      id: id,
      releaseId: release.id,
      releaseVersion: release.versionLabel,
      syncedBy: draft.syncedBy.trim(),
      syncNote: draft.syncNote.trim(),
      syncedAt: syncedAt,
      profileCount: release.memberCount,
      payrollImpactCount: payrollImpactCount,
      acknowledgedHandoffCount: handoffReview.acknowledgedCount,
    );
  }
}

List<String> _validate(EmployeeDirectoryRosterPayrollSyncReview review) {
  final errors = <String>[];
  final draft = review.draft;
  final release = review.latestRelease;

  if (release == null) {
    errors.add('Publish a roster packet before payroll sync.');
  }
  if (review.isSynced) {
    errors.add('Latest roster packet is already synced to payroll.');
  }
  if (review.handoffReview.escalatedCount > 0) {
    errors.add(
      'Resolve ${review.handoffReview.escalatedCount} escalated handoff'
      '${review.handoffReview.escalatedCount == 1 ? '' : 's'} before payroll sync.',
    );
  }
  if (review.handoffReview.openCount > 0) {
    errors.add(
      'Complete ${review.handoffReview.openCount} handoff acknowledgement'
      '${review.handoffReview.openCount == 1 ? '' : 's'} before payroll sync.',
    );
  }
  if (review.hasPayrollImpact && !draft.confirmPayrollImpactReview) {
    errors.add(
      'Review ${review.payrollImpactCount} payroll-impacting change'
      '${review.payrollImpactCount == 1 ? '' : 's'} before sync.',
    );
  }
  if (!draft.confirmControlTotals) {
    errors.add('Confirm payroll control totals before sync.');
  }
  if (draft.syncedBy.trim().length < 3) {
    errors.add('Payroll operator is required.');
  }
  if (draft.syncNote.trim().length < 16) {
    errors.add('Sync note must be at least 16 characters.');
  }

  return errors;
}
