import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/employee/models/employee_leave_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_leave_provider.dart';

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

  test('employee leave profile highlights blackout and low balance risks', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final profile = container.read(employeeLeaveProfileProvider('4'));

    expect(profile, isNotNull);
    expect(profile!.employeeName, 'David Kim');
    expect(profile.pendingRequestCount, 1);
    expect(profile.blackoutConflictCount, 1);
    expect(profile.lowBalanceCount, 2);
    expect(profile.attentionCount, 4);
    expect(profile.nextAction, 'Resolve 1 blackout leave conflict.');
  });

  test('employee leave request draft validates and reserves balance', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final draftNotifier = container.read(
      employeeLeaveRequestDraftProvider('3').notifier,
    );
    draftNotifier.setReason('Family coverage for school appointment.');

    final draft = container.read(employeeLeaveRequestDraftProvider('3'))!;
    expect(draft.isReadyToSubmit, isTrue);
    expect(draft.durationDays, 2);

    final profileNotifier = container.read(
      employeeLeaveProfileProvider('3').notifier,
    );
    final request = profileNotifier.addDraft(draft);
    final profile = container.read(employeeLeaveProfileProvider('3'))!;

    expect(request.id, 'ELR-3-001');
    expect(request.status, EmployeeLeaveRequestStatus.pending);
    expect(profile.pendingRequestCount, 1);
    expect(profile.balanceFor(EmployeeLeaveType.vacation)!.pendingDays, 2);
  });

  test(
    'employee leave actions approve reject and cancel balance reservations',
    () {
      final container = buildContainer();
      addTearDown(container.dispose);

      final notifier = container.read(
        employeeLeaveProfileProvider('3').notifier,
      );
      final draftNotifier = container.read(
        employeeLeaveRequestDraftProvider('3').notifier,
      );
      draftNotifier.setReason('Family coverage for school appointment.');
      final request = notifier.addDraft(
        container.read(employeeLeaveRequestDraftProvider('3'))!,
      );

      notifier.approveRequest(request.id);

      var profile = container.read(employeeLeaveProfileProvider('3'))!;
      var balance = profile.balanceFor(EmployeeLeaveType.vacation)!;
      expect(profile.pendingRequestCount, 0);
      expect(profile.approvedUpcomingCount, 1);
      expect(balance.pendingDays, 0);
      expect(balance.approvedUpcomingDays, 2);

      notifier.cancelRequest(request.id);

      profile = container.read(employeeLeaveProfileProvider('3'))!;
      balance = profile.balanceFor(EmployeeLeaveType.vacation)!;
      expect(profile.approvedUpcomingCount, 0);
      expect(balance.approvedUpcomingDays, 0);

      draftNotifier.setReason('Backup coverage for HR operations.');
      final rejected = notifier.addDraft(
        container.read(employeeLeaveRequestDraftProvider('3'))!,
      );
      notifier.rejectRequest(rejected.id);

      profile = container.read(employeeLeaveProfileProvider('3'))!;
      expect(profile.pendingRequestCount, 0);
      expect(profile.balanceFor(EmployeeLeaveType.vacation)!.pendingDays, 0);
    },
  );
}
