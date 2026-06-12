import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/employee/models/employee_directory_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_directory_quality_gate_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_directory_quality_signoff_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_quality_signoff_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_roster_publish_provider.dart';

void main() {
  test('employee directory roster publish blocks critical gate', () {
    final container = ProviderContainer(
      overrides: [
        employeeDirectoryAsOfDateProvider.overrideWithValue(
          DateTime(2026, 5, 30),
        ),
        employeeDirectoryMembersProvider.overrideWith(
          (ref) => EmployeeDirectoryNotifier([
            _member(
              id: '1',
              name: 'Sarah Johnson',
              email: 'shared@example.com',
            ),
            _member(id: '2', name: 'Maya Santoso', email: 'shared@example.com'),
          ]),
        ),
      ],
    );
    addTearDown(container.dispose);

    final draft = container.read(
      employeeDirectoryRosterPublishDraftProvider.notifier,
    );
    draft.setPreparedBy('Alya Rahman');
    draft.setReleaseNote('Roster packet ready for payroll handoff.');
    draft.setConfirmPayrollHandoff(true);

    final review = container.read(employeeDirectoryRosterPublishReviewProvider);

    expect(review.canPublish, isFalse);
    expect(review.statusLabel, 'Blocked');
    expect(
      review.errors.first,
      'Resolve 2 payroll blockers before publishing.',
    );
  });

  test('employee directory roster publish requires sign-off and handoff', () {
    final container = ProviderContainer(
      overrides: [
        employeeDirectoryAsOfDateProvider.overrideWithValue(
          DateTime(2026, 5, 30),
        ),
        employeeDirectoryMembersProvider.overrideWith(
          (ref) => EmployeeDirectoryNotifier([
            _member(id: '1', name: 'Sarah Johnson', email: 'sarah@example.com'),
            _member(id: '2', name: 'Maya Santoso', email: 'maya@example.com'),
          ]),
        ),
      ],
    );
    addTearDown(container.dispose);

    final draft = container.read(
      employeeDirectoryRosterPublishDraftProvider.notifier,
    );
    draft.setPreparedBy('Alya Rahman');
    draft.setReleaseNote('Roster packet ready for payroll handoff.');

    var review = container.read(employeeDirectoryRosterPublishReviewProvider);
    expect(review.canPublish, isFalse);
    expect(review.errors.first, 'Sign off the roster gate before publishing.');

    container
        .read(employeeDirectoryQualityGateSignoffsProvider.notifier)
        .add(_signoff());

    review = container.read(employeeDirectoryRosterPublishReviewProvider);
    expect(review.canPublish, isFalse);
    expect(review.errors.first, 'Confirm payroll handoff before publishing.');

    draft.setConfirmPayrollHandoff(true);
    review = container.read(employeeDirectoryRosterPublishReviewProvider);

    expect(review.canPublish, isTrue);
    expect(review.statusLabel, 'Ready');
    expect(review.nextVersionLabel, '2026.05.30-001');

    final release = review.toRelease(
      id: 'roster-release-1',
      publishedAt: DateTime(2026, 5, 30),
    );
    container
        .read(employeeDirectoryRosterReleasesProvider.notifier)
        .add(release);

    final history = container.read(employeeDirectoryRosterReleasesProvider);
    expect(history, hasLength(1));
    expect(
      history.first.summaryLabel,
      '2 profiles, 1 department, 100% readiness.',
    );
    expect(history.first.handoffLabel, 'Payroll notified');
    expect(history.first.memberSnapshots, hasLength(2));
    expect(history.first.memberSnapshots.first.name, 'Sarah Johnson');
  });

  test('employee directory roster publish rejects stale sign-off', () {
    final container = ProviderContainer(
      overrides: [
        employeeDirectoryAsOfDateProvider.overrideWithValue(
          DateTime(2026, 5, 30),
        ),
        employeeDirectoryMembersProvider.overrideWith(
          (ref) => EmployeeDirectoryNotifier([
            _member(id: '1', name: 'Sarah Johnson', email: 'sarah@example.com'),
            _member(id: '2', name: 'Maya Santoso', email: 'maya@example.com'),
          ]),
        ),
      ],
    );
    addTearDown(container.dispose);

    container
        .read(employeeDirectoryQualityGateSignoffsProvider.notifier)
        .add(_signoff());
    container
        .read(employeeDirectoryMembersProvider.notifier)
        .addMember(
          _member(id: '3', name: 'Rafi Pratama', email: 'rafi@example.com'),
        );

    final draft = container.read(
      employeeDirectoryRosterPublishDraftProvider.notifier,
    );
    draft.setPreparedBy('Alya Rahman');
    draft.setReleaseNote('Roster packet ready for payroll handoff.');
    draft.setConfirmPayrollHandoff(true);

    final review = container.read(employeeDirectoryRosterPublishReviewProvider);

    expect(review.canPublish, isFalse);
    expect(
      review.errors.first,
      'Refresh roster gate sign-off before publishing.',
    );
  });
}

EmployeeDirectoryQualityGateSignoff _signoff() {
  return EmployeeDirectoryQualityGateSignoff(
    id: 'quality-gate-1',
    reviewer: 'Alya Rahman',
    note: 'Roster gate reviewed and ready.',
    signedAt: DateTime(2026, 5, 30),
    gateStatus: EmployeeDirectoryQualityGateStatus.ready,
    readinessScore: 100,
    memberCount: 2,
    acceptedReviewCount: 0,
  );
}

EmployeeDirectoryMember _member({
  required String id,
  required String name,
  String email = 'person@example.com',
  String phone = '+62 812 0000 0000',
  String manager = 'Emma Rodriguez',
}) {
  return EmployeeDirectoryMember(
    id: id,
    name: name,
    position: 'HR Analyst',
    department: 'People Operations',
    avatarUrl: 'https://example.com/avatar.png',
    email: email,
    phone: phone,
    joiningDate: DateTime(2024, 1, 1),
    performance: 4.4,
    location: 'Jakarta',
    manager: manager,
    status: EmployeeDirectoryStatus.active,
  );
}
