import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/employee/models/employee_directory_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_directory_quality_gate_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_directory_roster_payroll_import_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_directory_roster_payroll_sync_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_directory_roster_publish_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_roster_payroll_import_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_roster_payroll_sync_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_roster_payroll_validation_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_roster_publish_provider.dart';

void main() {
  test(
    'employee directory roster payroll validation waits for import batch',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final review = container.read(
        employeeDirectoryRosterPayrollValidationReviewProvider,
      );

      expect(review.canValidate, isFalse);
      expect(review.statusLabel, 'No packet');
      expect(
        review.errors.first,
        'Stage payroll import packet before validation.',
      );
    },
  );

  test('employee directory roster payroll validation requires item review', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final release = _release(id: '1', versionLabel: '2026.05.30-001');
    final batch = _stageBatch(release, attentionCount: 1, impactCount: 2);
    container
        .read(employeeDirectoryRosterReleasesProvider.notifier)
        .add(release);
    container
        .read(employeeDirectoryRosterPayrollSyncRecordsProvider.notifier)
        .add(_syncRecord(release, impactCount: 2));
    container
        .read(employeeDirectoryRosterPayrollImportBatchesProvider.notifier)
        .add(batch);

    final draft = container.read(
      employeeDirectoryRosterPayrollValidationDraftProvider.notifier,
    );
    draft.setValidatedBy('Payroll Lead');
    draft.setValidationNote('Import loaded and run controls matched.');
    draft.setConfirmFileLoaded(true);
    draft.setConfirmPayrollRunControls(true);

    var review = container.read(
      employeeDirectoryRosterPayrollValidationReviewProvider,
    );
    expect(review.canValidate, isFalse);
    expect(review.statusLabel, 'Item review');
    expect(
      review.errors.first,
      'Review 3 payroll import validation items before approval.',
    );

    draft.setConfirmValidationItems(true);
    review = container.read(
      employeeDirectoryRosterPayrollValidationReviewProvider,
    );
    expect(review.canValidate, isTrue);
  });

  test('employee directory roster payroll validation records approval', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final release = _release(id: '1', versionLabel: '2026.05.30-001');
    final batch = _stageBatch(release, attentionCount: 1, impactCount: 2);
    container
        .read(employeeDirectoryRosterReleasesProvider.notifier)
        .add(release);
    container
        .read(employeeDirectoryRosterPayrollSyncRecordsProvider.notifier)
        .add(_syncRecord(release, impactCount: 2));
    container
        .read(employeeDirectoryRosterPayrollImportBatchesProvider.notifier)
        .add(batch);

    final draft = container.read(
      employeeDirectoryRosterPayrollValidationDraftProvider.notifier,
    );
    draft.setValidatedBy('Payroll Lead');
    draft.setValidationNote('Import loaded and run controls matched.');
    draft.setConfirmFileLoaded(true);
    draft.setConfirmValidationItems(true);
    draft.setConfirmPayrollRunControls(true);

    var review = container.read(
      employeeDirectoryRosterPayrollValidationReviewProvider,
    );
    final record = review.toRecord(
      id: 'payroll-validation-1',
      validatedAt: DateTime(2026, 5, 30),
    );
    container
        .read(employeeDirectoryRosterPayrollValidationRecordsProvider.notifier)
        .add(record);

    final records = container.read(
      employeeDirectoryRosterPayrollValidationRecordsProvider,
    );
    expect(records, hasLength(1));
    expect(records.first.batchLabel, 'PAY-202605-001');
    expect(
      records.first.summaryLabel,
      '2 loaded profiles approved with 3 validation items reviewed.',
    );

    review = container.read(
      employeeDirectoryRosterPayrollValidationReviewProvider,
    );
    expect(review.statusLabel, 'Validated');
    expect(
      review.errors.first,
      'Latest payroll import packet is already validated.',
    );
  });
}

EmployeeDirectoryRosterPayrollImportBatch _stageBatch(
  EmployeeDirectoryRosterRelease release, {
  required int attentionCount,
  required int impactCount,
}) {
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
    attentionProfileCount: attentionCount,
    departmentCount: release.departmentCount,
    payrollImpactCount: impactCount,
  );
}

EmployeeDirectoryRosterPayrollSyncRecord _syncRecord(
  EmployeeDirectoryRosterRelease release, {
  required int impactCount,
}) {
  return EmployeeDirectoryRosterPayrollSyncRecord(
    id: 'payroll-sync-1',
    releaseId: release.id,
    releaseVersion: release.versionLabel,
    syncedBy: 'Payroll Lead',
    syncNote: 'Control totals matched payroll staging import.',
    syncedAt: DateTime(2026, 5, 30),
    profileCount: release.memberCount,
    payrollImpactCount: impactCount,
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
