import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/employee/models/employee_directory_quality_gate_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_directory_roster_handoff_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_directory_roster_publish_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_roster_handoff_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_roster_publish_provider.dart';

void main() {
  test('employee directory roster handoff is empty before release', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final review = container.read(employeeDirectoryRosterHandoffReviewProvider);

    expect(review.hasRelease, isFalse);
    expect(review.statusLabel, 'No release');
    expect(review.summaryLabel, 'No roster packet published yet.');
    expect(review.recipients, isEmpty);
  });

  test('employee directory roster handoff seeds release recipients', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container
        .read(employeeDirectoryRosterReleasesProvider.notifier)
        .add(_release());

    final review = container.read(employeeDirectoryRosterHandoffReviewProvider);

    expect(review.hasRelease, isTrue);
    expect(review.recipients, hasLength(3));
    expect(review.openCount, 3);
    expect(review.acknowledgedCount, 0);
    expect(review.statusLabel, 'Pending');
    expect(
      review.summaryLabel,
      '0 acknowledged, 3 pending for 2026.05.30-001.',
    );
    expect(review.recipients.first.teamName, 'Payroll Operations');
  });

  test('employee directory roster handoff updates recipient workflow', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final release = _release();
    container
        .read(employeeDirectoryRosterReleasesProvider.notifier)
        .add(release);

    final records = container.read(
      employeeDirectoryRosterHandoffRecordsProvider.notifier,
    );
    records.acknowledge(release, 'payroll', DateTime(2026, 5, 30));
    records.resend(release, 'finance', DateTime(2026, 5, 30));
    records.escalate(release, 'peopleOps', DateTime(2026, 5, 30));

    final review = container.read(employeeDirectoryRosterHandoffReviewProvider);
    final payroll = review.recipients.firstWhere(
      (recipient) => recipient.id == 'payroll',
    );
    final finance = review.recipients.firstWhere(
      (recipient) => recipient.id == 'finance',
    );
    final peopleOps = review.recipients.firstWhere(
      (recipient) => recipient.id == 'peopleOps',
    );

    expect(review.acknowledgedCount, 1);
    expect(review.escalatedCount, 1);
    expect(review.openCount, 2);
    expect(review.statusLabel, 'Escalated');
    expect(
      review.summaryLabel,
      '1 acknowledged, 2 pending for 2026.05.30-001.',
    );
    expect(payroll.status, EmployeeDirectoryRosterHandoffStatus.acknowledged);
    expect(finance.note, 'Reminder sent to Finance Control.');
    expect(peopleOps.status, EmployeeDirectoryRosterHandoffStatus.escalated);
  });
}

EmployeeDirectoryRosterRelease _release() {
  return EmployeeDirectoryRosterRelease(
    id: 'roster-release-1',
    versionLabel: '2026.05.30-001',
    preparedBy: 'Alya Rahman',
    releaseNote: 'Roster packet approved for payroll handoff.',
    publishedAt: DateTime(2026, 5, 30),
    asOfDate: DateTime(2026, 5, 30),
    memberCount: 3,
    departmentCount: 1,
    gateStatus: EmployeeDirectoryQualityGateStatus.review,
    readinessScore: 67,
    signoffId: 'quality-gate-1',
    signoffReviewer: 'Alya Rahman',
    payrollNotified: true,
  );
}
