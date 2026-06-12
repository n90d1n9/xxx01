import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/employee/models/employee_performance_support_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_performance_support_provider.dart';

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

  test('employee performance support highlights blocked milestones', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final plan = container.read(employeePerformanceSupportPlanProvider('4'));

    expect(plan, isNotNull);
    expect(plan!.employeeName, 'David Kim');
    expect(plan.status, EmployeePerformanceSupportStatus.active);
    expect(plan.blockedCount, 1);
    expect(plan.overdueCount, 1);
    expect(plan.openCount, 2);
    expect(plan.highRiskOpenCount, 2);
    expect(plan.attentionCount, 2);
    expect(plan.progressRatio, 0);
    expect(plan.nextAction, 'Clear 1 blocked support milestone.');
  });

  test('employee performance support draft validates and adds milestone', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final draftNotifier = container.read(
      employeePerformanceSupportMilestoneDraftProvider('4').notifier,
    );
    draftNotifier.setType(EmployeePerformanceMilestoneType.training);
    draftNotifier.setTitle('Complete product discovery coaching');
    draftNotifier.setOwner('HR Business Partner');
    draftNotifier.setDueDate(DateTime(2026, 6, 10));
    draftNotifier.setRisk(EmployeePerformanceSupportRisk.high);
    draftNotifier.setSuccessMetric('Discovery plan reviewed by manager');
    draftNotifier.setNotes('Attach coaching evidence and manager notes.');

    final draft =
        container.read(employeePerformanceSupportMilestoneDraftProvider('4'))!;
    expect(draft.isReadyToAdd, isTrue);
    expect(draft.completionRatio, 1);

    final notifier = container.read(
      employeePerformanceSupportPlanProvider('4').notifier,
    );
    final milestone = notifier.addMilestone(draft);

    expect(milestone.id, 'EPS-4-004');
    expect(milestone.status, EmployeePerformanceMilestoneStatus.open);

    notifier.completeMilestone(milestone.id);
    var plan = container.read(employeePerformanceSupportPlanProvider('4'))!;

    expect(
      plan.milestones.singleWhere((entry) => entry.id == milestone.id).status,
      EmployeePerformanceMilestoneStatus.completed,
    );

    notifier.waiveMilestone('4-support-feedback');
    plan = container.read(employeePerformanceSupportPlanProvider('4'))!;

    expect(
      plan.milestones
          .singleWhere((entry) => entry.id == '4-support-feedback')
          .status,
      EmployeePerformanceMilestoneStatus.waived,
    );
  });

  test('employee performance support returns null for missing employee', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    expect(
      container.read(employeePerformanceSupportPlanProvider('missing')),
      isNull,
    );
    expect(
      container.read(
        employeePerformanceSupportMilestoneDraftProvider('missing'),
      ),
      isNull,
    );
  });
}
