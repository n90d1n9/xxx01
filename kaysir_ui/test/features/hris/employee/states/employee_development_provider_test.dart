import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/employee/states/employee_development_provider.dart';
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

  test('employee development plan highlights watchlist growth risks', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final plan = container.read(employeeDevelopmentPlanProvider('4'));

    expect(plan, isNotNull);
    expect(plan!.employeeName, 'David Kim');
    expect(plan.skillGapCount, 2);
    expect(plan.learningDueCount, 1);
    expect(plan.certificationRiskCount, 1);
    expect(plan.nextAction, 'Resolve 1 certification risk.');
  });

  test('employee learning draft validates and appends assignment', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final draftNotifier = container.read(
      employeeLearningAssignmentDraftProvider('1').notifier,
    );
    draftNotifier.setTitle('Advanced design systems');
    draftNotifier.setProvider('People Academy');
    draftNotifier.setSkillFocus('Design systems');
    draftNotifier.setDueDate(DateTime(2026, 6, 20));

    final draft = container.read(employeeLearningAssignmentDraftProvider('1'))!;
    expect(draft.isReadyToAdd, isTrue);
    expect(draft.completionRatio, 1);

    final planNotifier = container.read(
      employeeDevelopmentPlanProvider('1').notifier,
    );
    final assignment = planNotifier.addLearning(draft);

    expect(assignment.id, 'EDL-1-003');
    expect(assignment.title, 'Advanced design systems');
    expect(
      container.read(employeeDevelopmentPlanProvider('1'))!.activeLearningCount,
      2,
    );
  });

  test(
    'employee development actions resolve skill and certification risks',
    () {
      final container = buildContainer();
      addTearDown(container.dispose);

      final notifier = container.read(
        employeeDevelopmentPlanProvider('4').notifier,
      );
      final plan = container.read(employeeDevelopmentPlanProvider('4'))!;

      expect(plan.skillGapCount, 2);
      expect(plan.certificationRiskCount, 1);

      notifier.updateSkillLevel('4-skill-primary', 4);
      notifier.renewCertification('4-cert-primary', DateTime(2027, 5, 30));

      final updatedPlan = container.read(employeeDevelopmentPlanProvider('4'))!;

      expect(updatedPlan.skillGapCount, 1);
      expect(updatedPlan.certificationRiskCount, 0);
      expect(updatedPlan.nextAction, 'Follow up on 1 overdue learning item.');
    },
  );
}
