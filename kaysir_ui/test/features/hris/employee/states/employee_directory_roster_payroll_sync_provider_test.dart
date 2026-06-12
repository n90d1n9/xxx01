import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/employee/models/employee_directory_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_directory_quality_gate_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_directory_roster_publish_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_roster_handoff_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_roster_payroll_sync_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_roster_publish_provider.dart';

void main() {
  test('employee directory roster payroll sync waits for release', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final review = container.read(
      employeeDirectoryRosterPayrollSyncReviewProvider,
    );

    expect(review.canSync, isFalse);
    expect(review.statusLabel, 'No release');
    expect(review.errors.first, 'Publish a roster packet before payroll sync.');
  });

  test(
    'employee directory roster payroll sync waits for handoff completion',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container
          .read(employeeDirectoryRosterReleasesProvider.notifier)
          .add(_release(id: '1', versionLabel: '2026.05.30-001'));
      final draft = container.read(
        employeeDirectoryRosterPayrollSyncDraftProvider.notifier,
      );
      draft.setSyncedBy('Payroll Lead');
      draft.setSyncNote('Control totals matched staging import.');
      draft.setConfirmControlTotals(true);

      final review = container.read(
        employeeDirectoryRosterPayrollSyncReviewProvider,
      );

      expect(review.canSync, isFalse);
      expect(review.statusLabel, 'Waiting handoff');
      expect(
        review.errors.first,
        'Complete 3 handoff acknowledgements before payroll sync.',
      );
    },
  );

  test('employee directory roster payroll sync records clean release', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final release = _release(id: '1', versionLabel: '2026.05.30-001');
    container
        .read(employeeDirectoryRosterReleasesProvider.notifier)
        .add(release);
    _acknowledgeAll(container, release);

    final draft = container.read(
      employeeDirectoryRosterPayrollSyncDraftProvider.notifier,
    );
    draft.setSyncedBy('Payroll Lead');
    draft.setSyncNote('Control totals matched staging import.');
    draft.setConfirmControlTotals(true);

    final review = container.read(
      employeeDirectoryRosterPayrollSyncReviewProvider,
    );

    expect(review.canSync, isTrue);
    expect(review.statusLabel, 'Ready');
    expect(review.payrollImpactCount, 0);

    final record = review.toRecord(
      id: 'payroll-sync-1',
      syncedAt: DateTime(2026, 5, 30),
    );
    container
        .read(employeeDirectoryRosterPayrollSyncRecordsProvider.notifier)
        .add(record);

    final history = container.read(
      employeeDirectoryRosterPayrollSyncRecordsProvider,
    );
    expect(history, hasLength(1));
    expect(
      history.first.summaryLabel,
      '2 profiles synced with 0 payroll-impacting changes reviewed.',
    );
  });

  test('employee directory roster payroll sync requires impact review', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final previous = _release(
      id: '1',
      versionLabel: '2026.05.30-001',
      members: [
        _snapshot(id: '1', name: 'Sarah Johnson', department: 'Design'),
      ],
    );
    final latest = _release(
      id: '2',
      versionLabel: '2026.05.30-002',
      members: [
        _snapshot(
          id: '1',
          name: 'Sarah Johnson',
          department: 'People Operations',
        ),
      ],
    );
    final releases = container.read(
      employeeDirectoryRosterReleasesProvider.notifier,
    );
    releases.add(previous);
    releases.add(latest);
    _acknowledgeAll(container, latest);

    final draft = container.read(
      employeeDirectoryRosterPayrollSyncDraftProvider.notifier,
    );
    draft.setSyncedBy('Payroll Lead');
    draft.setSyncNote('Control totals matched staging import.');
    draft.setConfirmControlTotals(true);

    var review = container.read(
      employeeDirectoryRosterPayrollSyncReviewProvider,
    );
    expect(review.canSync, isFalse);
    expect(review.statusLabel, 'Impact review');
    expect(
      review.errors.first,
      'Review 1 payroll-impacting change before sync.',
    );

    draft.setConfirmPayrollImpactReview(true);
    review = container.read(employeeDirectoryRosterPayrollSyncReviewProvider);
    expect(review.canSync, isTrue);
    expect(review.payrollImpactCount, 1);
  });
}

void _acknowledgeAll(
  ProviderContainer container,
  EmployeeDirectoryRosterRelease release,
) {
  final records = container.read(
    employeeDirectoryRosterHandoffRecordsProvider.notifier,
  );
  for (final recipientId in ['payroll', 'finance', 'peopleOps']) {
    records.acknowledge(release, recipientId, DateTime(2026, 5, 30));
  }
}

EmployeeDirectoryRosterRelease _release({
  required String id,
  required String versionLabel,
  List<EmployeeDirectoryRosterReleaseMemberSnapshot>? members,
}) {
  final snapshots =
      members ??
      [
        _snapshot(id: '1', name: 'Sarah Johnson'),
        _snapshot(id: '2', name: 'Maya Santoso', department: 'Finance'),
      ];

  return EmployeeDirectoryRosterRelease(
    id: 'roster-release-$id',
    versionLabel: versionLabel,
    preparedBy: 'Alya Rahman',
    releaseNote: 'Roster packet approved for payroll handoff.',
    publishedAt: DateTime(2026, 5, 30),
    asOfDate: DateTime(2026, 5, 30),
    memberCount: snapshots.length,
    departmentCount:
        snapshots.map((snapshot) => snapshot.department).toSet().length,
    gateStatus: EmployeeDirectoryQualityGateStatus.ready,
    readinessScore: 100,
    signoffId: 'quality-gate-1',
    signoffReviewer: 'Alya Rahman',
    payrollNotified: true,
    memberSnapshots: snapshots,
  );
}

EmployeeDirectoryRosterReleaseMemberSnapshot _snapshot({
  required String id,
  required String name,
  String department = 'People Operations',
}) {
  return EmployeeDirectoryRosterReleaseMemberSnapshot(
    employeeId: id,
    name: name,
    position: 'HR Analyst',
    department: department,
    manager: 'Emma Rodriguez',
    location: 'Jakarta',
    email: '$id@example.com',
    phone: '+62 812 0000 0000',
    status: EmployeeDirectoryStatus.active,
    joiningDate: DateTime(2024, 1, 1),
    performance: 4.4,
  );
}
