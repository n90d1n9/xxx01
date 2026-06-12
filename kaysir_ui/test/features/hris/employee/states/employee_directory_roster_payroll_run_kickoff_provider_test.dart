import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/employee/models/employee_directory_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_directory_quality_gate_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_directory_roster_payroll_import_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_directory_roster_payroll_sync_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_directory_roster_payroll_validation_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_directory_roster_publish_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_roster_payroll_import_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_roster_payroll_run_kickoff_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_roster_payroll_sync_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_roster_payroll_validation_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_roster_publish_provider.dart';

void main() {
  test(
    'employee directory roster payroll run kickoff waits for validation',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final review = container.read(
        employeeDirectoryRosterPayrollRunKickoffReviewProvider,
      );

      expect(review.canLaunch, isFalse);
      expect(review.statusLabel, 'No validation');
      expect(
        review.errors.first,
        'Validate payroll import before launching payroll run.',
      );
    },
  );

  test('employee directory roster payroll run kickoff requires funding', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final release = _release(id: '1', versionLabel: '2026.05.30-001');
    final batch = _stageBatch(release);
    final validation = _validationRecord(batch);
    _seedValidatedBatch(container, release, batch, validation);

    final draft = container.read(
      employeeDirectoryRosterPayrollRunKickoffDraftProvider.notifier,
    );
    draft.setRunReference('RUN-202605-001');
    draft.setRunOwner('Payroll Lead');
    draft.setKickoffNote('Funding and payroll launch controls prepared.');
    draft.setConfirmPayslipHold(true);
    draft.setConfirmAuditArchive(true);

    var review = container.read(
      employeeDirectoryRosterPayrollRunKickoffReviewProvider,
    );
    expect(review.canLaunch, isFalse);
    expect(review.statusLabel, 'Funding');
    expect(
      review.errors.first,
      'Confirm payroll funding window before launch.',
    );

    draft.setConfirmFundingWindow(true);
    review = container.read(
      employeeDirectoryRosterPayrollRunKickoffReviewProvider,
    );
    expect(review.canLaunch, isTrue);
  });

  test('employee directory roster payroll run kickoff records launch', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final release = _release(id: '1', versionLabel: '2026.05.30-001');
    final batch = _stageBatch(release);
    final validation = _validationRecord(batch);
    _seedValidatedBatch(container, release, batch, validation);

    final draft = container.read(
      employeeDirectoryRosterPayrollRunKickoffDraftProvider.notifier,
    );
    draft.setRunReference('RUN-202605-001');
    draft.setRunOwner('Payroll Lead');
    draft.setKickoffNote('Funding and payroll launch controls prepared.');
    draft.setConfirmFundingWindow(true);
    draft.setConfirmPayslipHold(true);
    draft.setConfirmAuditArchive(true);

    var review = container.read(
      employeeDirectoryRosterPayrollRunKickoffReviewProvider,
    );
    final record = review.toRecord(
      id: 'payroll-run-kickoff-1',
      launchedAt: DateTime(2026, 5, 30),
    );
    container
        .read(employeeDirectoryRosterPayrollRunKickoffRecordsProvider.notifier)
        .add(record);

    final records = container.read(
      employeeDirectoryRosterPayrollRunKickoffRecordsProvider,
    );
    expect(records, hasLength(1));
    expect(records.first.runReference, 'RUN-202605-001');
    expect(
      records.first.summaryLabel,
      '2 loaded profiles launched with 3 validation items cleared.',
    );

    review = container.read(
      employeeDirectoryRosterPayrollRunKickoffReviewProvider,
    );
    expect(review.statusLabel, 'Launched');
    expect(review.errors.first, 'Latest payroll run is already launched.');
  });
}

void _seedValidatedBatch(
  ProviderContainer container,
  EmployeeDirectoryRosterRelease release,
  EmployeeDirectoryRosterPayrollImportBatch batch,
  EmployeeDirectoryRosterPayrollValidationRecord validation,
) {
  container.read(employeeDirectoryRosterReleasesProvider.notifier).add(release);
  container
      .read(employeeDirectoryRosterPayrollSyncRecordsProvider.notifier)
      .add(_syncRecord(release));
  container
      .read(employeeDirectoryRosterPayrollImportBatchesProvider.notifier)
      .add(batch);
  container
      .read(employeeDirectoryRosterPayrollValidationRecordsProvider.notifier)
      .add(validation);
}

EmployeeDirectoryRosterPayrollValidationRecord _validationRecord(
  EmployeeDirectoryRosterPayrollImportBatch batch,
) {
  return EmployeeDirectoryRosterPayrollValidationRecord(
    id: 'payroll-validation-1',
    batchId: batch.id,
    batchLabel: batch.batchLabel,
    releaseVersion: batch.releaseVersion,
    controlFileName: batch.controlFileName,
    validatedBy: 'Payroll Lead',
    validationNote: 'Import loaded and payroll run controls matched.',
    validatedAt: DateTime(2026, 5, 30),
    loadedProfileCount: batch.includedProfileCount,
    validationItemCount: 3,
    payrollImpactCount: 2,
  );
}

EmployeeDirectoryRosterPayrollImportBatch _stageBatch(
  EmployeeDirectoryRosterRelease release,
) {
  return EmployeeDirectoryRosterPayrollImportBatch(
    id: 'payroll-import-1',
    releaseId: release.id,
    releaseVersion: release.versionLabel,
    syncRecordId: 'payroll-sync-1',
    batchLabel: 'PAY-202605-001',
    preparedBy: 'Payroll Lead',
    importNote: 'Column mapping and payroll preview controls matched.',
    controlFileName: '2026-05-30-001-payroll-import.csv',
    stagedAt: DateTime(2026, 5, 30),
    totalProfileCount: release.memberCount,
    includedProfileCount: release.memberCount,
    attentionProfileCount: 1,
    departmentCount: release.departmentCount,
    payrollImpactCount: 2,
  );
}

EmployeeDirectoryRosterPayrollSyncRecord _syncRecord(
  EmployeeDirectoryRosterRelease release,
) {
  return EmployeeDirectoryRosterPayrollSyncRecord(
    id: 'payroll-sync-1',
    releaseId: release.id,
    releaseVersion: release.versionLabel,
    syncedBy: 'Payroll Lead',
    syncNote: 'Control totals matched payroll staging import.',
    syncedAt: DateTime(2026, 5, 30),
    profileCount: release.memberCount,
    payrollImpactCount: 2,
    acknowledgedHandoffCount: 3,
  );
}

EmployeeDirectoryRosterRelease _release({
  required String id,
  required String versionLabel,
}) {
  return EmployeeDirectoryRosterRelease(
    id: id,
    versionLabel: versionLabel,
    preparedBy: 'Alya Rahman',
    releaseNote: 'Roster packet prepared for payroll cutoff handoff.',
    publishedAt: DateTime(2026, 5, 30),
    asOfDate: DateTime(2026, 5, 30),
    memberCount: 2,
    departmentCount: 1,
    gateStatus: EmployeeDirectoryQualityGateStatus.ready,
    readinessScore: 100,
    signoffId: 'quality-gate-1',
    signoffReviewer: 'Rafi Pratama',
    payrollNotified: true,
    memberSnapshots: [
      _snapshot(id: '1', name: 'Sarah Johnson'),
      _snapshot(
        id: '2',
        name: 'Maya Santoso',
        status: EmployeeDirectoryStatus.watchlist,
      ),
    ],
  );
}

EmployeeDirectoryRosterReleaseMemberSnapshot _snapshot({
  required String id,
  required String name,
  EmployeeDirectoryStatus status = EmployeeDirectoryStatus.active,
}) {
  return EmployeeDirectoryRosterReleaseMemberSnapshot(
    employeeId: id,
    name: name,
    position: 'HR Analyst',
    department: 'People Operations',
    manager: 'Emma Rodriguez',
    location: 'Jakarta',
    email: '$id@example.com',
    phone: '+62 812 0000 0000',
    status: status,
    joiningDate: DateTime(2024, 1, 1),
    performance: 4.5,
  );
}
