import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/employee/models/employee_directory_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_directory_quality_gate_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_directory_roster_payroll_sync_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_directory_roster_publish_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_roster_payroll_import_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_roster_payroll_sync_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_roster_publish_provider.dart';

void main() {
  test('employee directory roster payroll import waits for payroll sync', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container
        .read(employeeDirectoryRosterReleasesProvider.notifier)
        .add(_release(id: '1', versionLabel: '2026.05.30-001'));

    final review = container.read(
      employeeDirectoryRosterPayrollImportReviewProvider,
    );

    expect(review.canStage, isFalse);
    expect(review.statusLabel, 'Needs sync');
    expect(
      review.errors.first,
      'Sync latest roster packet before staging payroll import.',
    );
  });

  test(
    'employee directory roster payroll import requires attention review',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final release = _release(
        id: '1',
        versionLabel: '2026.05.30-001',
        includeAttention: true,
      );
      container
          .read(employeeDirectoryRosterReleasesProvider.notifier)
          .add(release);
      container
          .read(employeeDirectoryRosterPayrollSyncRecordsProvider.notifier)
          .add(_syncRecord(release));

      final draft = container.read(
        employeeDirectoryRosterPayrollImportDraftProvider.notifier,
      );
      draft.setBatchLabel('PAY-202605-001');
      draft.setPreparedBy('Payroll Lead');
      draft.setImportNote('Column mapping matched payroll staging preview.');
      draft.setConfirmColumnMapping(true);
      draft.setConfirmPreviewControls(true);

      var review = container.read(
        employeeDirectoryRosterPayrollImportReviewProvider,
      );
      expect(review.canStage, isFalse);
      expect(review.statusLabel, 'Attention review');
      expect(
        review.errors.first,
        'Review 1 payroll attention profile before staging.',
      );

      draft.setConfirmAttentionProfiles(true);
      review = container.read(
        employeeDirectoryRosterPayrollImportReviewProvider,
      );
      expect(review.canStage, isTrue);
    },
  );

  test('employee directory roster payroll import stages valid batch', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final release = _release(
      id: '1',
      versionLabel: '2026.05.30-001',
      includeAttention: true,
    );
    container
        .read(employeeDirectoryRosterReleasesProvider.notifier)
        .add(release);
    container
        .read(employeeDirectoryRosterPayrollSyncRecordsProvider.notifier)
        .add(_syncRecord(release));

    final draft = container.read(
      employeeDirectoryRosterPayrollImportDraftProvider.notifier,
    );
    draft.setBatchLabel('PAY-202605-001');
    draft.setPreparedBy('Payroll Lead');
    draft.setImportNote('Column mapping matched payroll staging preview.');
    draft.setConfirmColumnMapping(true);
    draft.setConfirmAttentionProfiles(true);
    draft.setConfirmPreviewControls(true);

    var review = container.read(
      employeeDirectoryRosterPayrollImportReviewProvider,
    );
    final batch = review.toBatch(
      id: 'payroll-import-1',
      stagedAt: DateTime(2026, 5, 30),
    );
    container
        .read(employeeDirectoryRosterPayrollImportBatchesProvider.notifier)
        .add(batch);

    final batches = container.read(
      employeeDirectoryRosterPayrollImportBatchesProvider,
    );
    expect(batches, hasLength(1));
    expect(batches.first.batchLabel, 'PAY-202605-001');
    expect(batches.first.controlFileName, '2026-05-30-001-payroll-import.csv');
    expect(
      batches.first.summaryLabel,
      '2 profiles staged across 1 department with 1 attention profile reviewed.',
    );

    review = container.read(employeeDirectoryRosterPayrollImportReviewProvider);
    expect(review.statusLabel, 'Staged');
    expect(
      review.errors.first,
      'Latest roster payroll import packet is already staged.',
    );
  });
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
    payrollImpactCount: 0,
    acknowledgedHandoffCount: 3,
  );
}

EmployeeDirectoryRosterRelease _release({
  required String id,
  required String versionLabel,
  bool includeAttention = false,
}) {
  final snapshots = [
    _snapshot(id: '1', name: 'Sarah Johnson'),
    if (includeAttention)
      _snapshot(
        id: '2',
        name: 'Maya Santoso',
        status: EmployeeDirectoryStatus.watchlist,
      ),
  ];

  return EmployeeDirectoryRosterRelease(
    id: id,
    versionLabel: versionLabel,
    preparedBy: 'Alya Rahman',
    releaseNote: 'Roster packet prepared for payroll cutoff handoff.',
    publishedAt: DateTime(2026, 5, 30),
    asOfDate: DateTime(2026, 5, 30),
    memberCount: snapshots.length,
    departmentCount: 1,
    gateStatus: EmployeeDirectoryQualityGateStatus.ready,
    readinessScore: 100,
    signoffId: 'quality-gate-1',
    signoffReviewer: 'Rafi Pratama',
    payrollNotified: true,
    memberSnapshots: snapshots,
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
