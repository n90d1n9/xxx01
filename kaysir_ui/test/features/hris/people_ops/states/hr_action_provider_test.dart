import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/people_ops/models/hr_action_models.dart';
import 'package:kaysir/features/hris/people_ops/states/hr_action_provider.dart';
import 'package:kaysir/features/hris/people_ops/states/people_ops_provider.dart';

void main() {
  test('HR action draft validates required lifecycle fields', () {
    final draft = HrActionFormDraft.empty(DateTime(2026, 5, 30));

    expect(draft.isReadyToSubmit, isFalse);
    expect(draft.completionRatio, 0);
    expect(draft.validationErrors, [
      'Please enter an employee name',
      'Please enter a department',
      'Please enter a role or target change',
      'Please select an effective date',
      'Please enter a manager',
      'Please enter an HR owner',
      'Please enter a reason',
    ]);

    final ready = draft.copyWith(
      employeeName: '  Fajar Nugroho ',
      department: 'Engineering',
      actionType: HrActionType.promotion,
      targetRole: ' Senior Flutter Engineer ',
      effectiveDate: DateTime(2026, 6, 5),
      managerName: ' Sarah Johnson ',
      ownerName: ' People Partner ',
      reason: ' Promotion approved after calibration review. ',
      payrollReviewRequired: true,
      priority: HrActionPriority.urgent,
    );

    final request = ready.toRequest(
      id: 'HR-2000',
      createdAt: DateTime(2026, 5, 30),
    );

    expect(ready.isReadyToSubmit, isTrue);
    expect(ready.completionRatio, 1);
    expect(request.employeeName, 'Fajar Nugroho');
    expect(request.targetRole, 'Senior Flutter Engineer');
    expect(request.reason, 'Promotion approved after calibration review.');
    expect(request.payrollReviewRequired, isTrue);
    expect(request.status, HrActionStatus.submitted);
  });

  test('HR action queue summarizes seeded management actions', () {
    final container = ProviderContainer(
      overrides: [
        peopleOpsAsOfDateProvider.overrideWithValue(DateTime(2026, 5, 30)),
      ],
    );
    addTearDown(container.dispose);

    final summary = container.read(peopleOpsHrActionQueueSummaryProvider);
    final requests = container.read(filteredPeopleOpsHrActionRequestsProvider);

    expect(requests.map((request) => request.id), [
      'HR-1001',
      'HR-1002',
      'HR-1003',
    ]);
    expect(summary.totalCount, 3);
    expect(summary.openCount, 3);
    expect(summary.blockedCount, 1);
    expect(summary.payrollReviewCount, 2);
    expect(summary.urgentCount, 2);
    expect(summary.dueThisWeekCount, 2);
    expect(
      summary.nextAction,
      'Resolve blocked HR action before payroll cutoff.',
    );
  });

  test('HR action queue submits validated draft and advances statuses', () {
    final container = ProviderContainer(
      overrides: [
        peopleOpsAsOfDateProvider.overrideWithValue(DateTime(2026, 5, 30)),
      ],
    );
    addTearDown(container.dispose);

    final draftNotifier = container.read(
      peopleOpsHrActionDraftProvider.notifier,
    );
    draftNotifier.setEmployeeName('Fajar Nugroho');
    draftNotifier.setDepartment('Engineering');
    draftNotifier.setActionType(HrActionType.promotion);
    draftNotifier.setTargetRole('Senior Flutter Engineer');
    draftNotifier.setEffectiveDate(DateTime(2026, 6, 5));
    draftNotifier.setManagerName('Sarah Johnson');
    draftNotifier.setOwnerName('People Partner');
    draftNotifier.setReason('Promotion approved after calibration review.');
    draftNotifier.setPayrollReviewRequired(true);
    draftNotifier.setPriority(HrActionPriority.urgent);

    final queue = container.read(peopleOpsHrActionRequestsProvider.notifier);
    final request = queue.submitDraft(
      container.read(peopleOpsHrActionDraftProvider),
    );

    expect(request.id, 'HR-1004');
    expect(
      container.read(peopleOpsHrActionRequestsProvider).first.employeeName,
      'Fajar Nugroho',
    );

    queue.advanceStatus(request.id);
    expect(
      container.read(peopleOpsHrActionRequestsProvider).first.status,
      HrActionStatus.inReview,
    );

    queue.advanceStatus(request.id);
    expect(
      container.read(peopleOpsHrActionRequestsProvider).first.status,
      HrActionStatus.approved,
    );
  });

  test('HR action risk filter follows people ops workspace filters', () {
    final container = ProviderContainer(
      overrides: [
        peopleOpsAsOfDateProvider.overrideWithValue(DateTime(2026, 5, 30)),
      ],
    );
    addTearDown(container.dispose);

    container.read(peopleOpsDepartmentProvider.notifier).state = 'Operations';
    container.read(peopleOpsRiskOnlyProvider.notifier).state = true;

    final requests = container.read(filteredPeopleOpsHrActionRequestsProvider);
    final summary = container.read(peopleOpsHrActionQueueSummaryProvider);

    expect(requests.map((request) => request.employeeName), ['Rizky Pratama']);
    expect(summary.totalCount, 1);
    expect(summary.payrollReviewCount, 1);
    expect(summary.urgentCount, 1);
    expect(summary.dueThisWeekCount, 1);
  });
}
