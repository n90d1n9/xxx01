import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/employee/models/employee_directory_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_directory_quality_gate_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_directory_roster_diff_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_directory_roster_publish_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_roster_diff_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_roster_publish_provider.dart';

void main() {
  test('employee directory roster diff is empty before release', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final review = container.read(employeeDirectoryRosterDiffReviewProvider);

    expect(review.hasRelease, isFalse);
    expect(review.statusLabel, 'No release');
    expect(
      review.summaryLabel,
      'Publish a roster packet to start diff review.',
    );
    expect(review.items, isEmpty);
  });

  test('employee directory roster diff marks first release baseline', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container
        .read(employeeDirectoryRosterReleasesProvider.notifier)
        .add(_release(id: '1', versionLabel: '2026.05.30-001'));

    final review = container.read(employeeDirectoryRosterDiffReviewProvider);

    expect(review.hasRelease, isTrue);
    expect(review.hasBaseline, isFalse);
    expect(review.statusLabel, 'Baseline');
    expect(
      review.summaryLabel,
      '2026.05.30-001 is the first roster release baseline.',
    );
    expect(review.items, isEmpty);
  });

  test('employee directory roster diff detects release changes', () {
    final previous = _release(
      id: '1',
      versionLabel: '2026.05.30-001',
      members: [
        _snapshot(id: '1', name: 'Sarah Johnson', department: 'Design'),
        _snapshot(id: '2', name: 'Maya Santoso', department: 'Finance'),
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
          status: EmployeeDirectoryStatus.watchlist,
        ),
        _snapshot(id: '3', name: 'Rafi Pratama', department: 'Operations'),
      ],
    );
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final releases = container.read(
      employeeDirectoryRosterReleasesProvider.notifier,
    );
    releases.add(previous);
    releases.add(latest);

    final review = container.read(employeeDirectoryRosterDiffReviewProvider);

    expect(review.hasBaseline, isTrue);
    expect(review.statusLabel, 'Changes found');
    expect(review.addedCount, 1);
    expect(review.removedCount, 1);
    expect(review.changedCount, 2);
    expect(review.payrollImpactCount, 4);
    expect(review.summaryLabel, '4 changes since 2026.05.30-001.');
    expect(
      review.items.map((item) => item.type),
      containsAll([
        EmployeeDirectoryRosterDiffType.added,
        EmployeeDirectoryRosterDiffType.removed,
        EmployeeDirectoryRosterDiffType.departmentChanged,
        EmployeeDirectoryRosterDiffType.statusChanged,
      ]),
    );
  });
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
  EmployeeDirectoryStatus status = EmployeeDirectoryStatus.active,
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
    status: status,
    joiningDate: DateTime(2024, 1, 1),
    performance: 4.4,
  );
}
