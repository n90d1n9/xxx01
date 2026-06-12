import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/employee/models/employee_access_governance_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_access_governance_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';

void main() {
  ProviderContainer buildContainer() {
    return ProviderContainer(
      overrides: [
        employeeDirectoryAsOfDateProvider.overrideWithValue(
          DateTime(2026, 5, 30),
        ),
      ],
    );
  }

  test('employee access governance highlights revoke and overdue reviews', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final profile = container.read(
      employeeAccessGovernanceProfileProvider('4'),
    );

    expect(profile, isNotNull);
    expect(profile!.employeeName, 'David Kim');
    expect(profile.dueReviewCount, 1);
    expect(profile.revokeRequestedCount, 1);
    expect(profile.privilegedCount, 1);
    expect(profile.overdueCount, 1);
    expect(profile.attentionCount, 2);
    expect(profile.nextAction, 'Complete 1 access revoke request.');
  });

  test('employee access governance draft validates and submits review', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final draftNotifier = container.read(
      employeeAccessGovernanceDraftProvider('3').notifier,
    );
    draftNotifier
      ..setSystemName('People Analytics')
      ..setRoleName('Report viewer')
      ..setBusinessJustification('Quarterly workforce analytics access.');

    final draft = container.read(employeeAccessGovernanceDraftProvider('3'))!;
    expect(draft.isReadyToSubmit, isTrue);

    final profileNotifier = container.read(
      employeeAccessGovernanceProfileProvider('3').notifier,
    );
    final review = profileNotifier.submitDraft(draft);
    final profile =
        container.read(employeeAccessGovernanceProfileProvider('3'))!;

    expect(review.id, 'EAG-3-001');
    expect(review.status, EmployeeAccessGovernanceStatus.dueReview);
    expect(profile.dueReviewCount, 1);
  });

  test('employee access governance actions approve revoke and exception', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final watchlistNotifier = container.read(
      employeeAccessGovernanceProfileProvider('4').notifier,
    );

    watchlistNotifier.completeRevoke('EAG-4-002');
    var profile = container.read(employeeAccessGovernanceProfileProvider('4'))!;
    expect(profile.revokeRequestedCount, 0);
    expect(
      profile.reviews.singleWhere((review) => review.id == 'EAG-4-002').status,
      EmployeeAccessGovernanceStatus.revoked,
    );

    watchlistNotifier.markException('EAG-4-001');
    profile = container.read(employeeAccessGovernanceProfileProvider('4'))!;
    expect(profile.exceptionCount, 1);

    watchlistNotifier.approveReview('EAG-4-001');
    profile = container.read(employeeAccessGovernanceProfileProvider('4'))!;
    expect(profile.attentionCount, 0);
    expect(profile.nextAction, 'Access governance is current.');
  });
}
