import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/employee/models/employee_compensation_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_compensation_provider.dart';
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

  test('employee compensation package resolves band health', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final package = container.read(employeeCompensationPackageProvider('2'));

    expect(package, isNotNull);
    expect(package!.employeeName, 'Michael Chen');
    expect(package.currencyCode, 'SGD');
    expect(package.baseSalary, 132000);
    expect(package.compaRatio, closeTo(0.9565, 0.001));
    expect(package.isReviewDue(DateTime(2026, 5, 30)), isFalse);
  });

  test(
    'employee compensation review submits approves and applies pay change',
    () {
      final container = buildContainer();
      addTearDown(container.dispose);

      final draftNotifier = container.read(
        employeeCompensationReviewDraftProvider('1').notifier,
      );
      draftNotifier.setReviewType(EmployeeCompensationReviewType.meritIncrease);
      draftNotifier.setProposedBaseSalary(302000000);
      draftNotifier.setEffectiveDate(DateTime(2026, 7, 1));
      draftNotifier.setJustification('Annual merit review after calibration.');

      final draft =
          container.read(employeeCompensationReviewDraftProvider('1'))!;

      expect(draft.isReadyToSubmit, isTrue);
      expect(draft.impact.increaseAmount, 18000000);
      expect(draft.impact.proposedCompaRatio, closeTo(1.0066, 0.001));

      final queue = container.read(
        employeeCompensationReviewRequestsProvider.notifier,
      );
      final request = queue.submitDraft(draft);

      expect(request.id, 'ECR-001');
      expect(request.status, EmployeeCompensationReviewStatus.submitted);

      queue.approve(request.id);
      final approved = container
          .read(employeeCompensationReviewRequestsProvider)
          .singleWhere((item) => item.id == request.id);
      expect(approved.status, EmployeeCompensationReviewStatus.approved);

      final package = container.read(employeeCompensationPackageProvider('1'))!;
      container
          .read(employeeCompensationPackagesProvider.notifier)
          .updatePackage(approved.applyTo(package));
      queue.markApplied(approved.id);

      final updatedPackage =
          container.read(employeeCompensationPackageProvider('1'))!;
      final summary = container.read(
        employeeCompensationReviewSummaryProvider('1'),
      );

      expect(updatedPackage.baseSalary, 302000000);
      expect(updatedPackage.lastReviewDate, DateTime(2026, 7, 1));
      expect(updatedPackage.nextReviewDate, DateTime(2027, 7, 1));
      expect(summary.appliedCount, 1);
      expect(summary.nextAction, 'No compensation reviews are waiting.');
    },
  );

  test('employee compensation review blocks guardrail breaches', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final notifier = container.read(
      employeeCompensationReviewDraftProvider('5').notifier,
    );
    notifier.setProposedBaseSalary(400000000);
    notifier.setJustification('Retention adjustment after market review.');

    final draft = container.read(employeeCompensationReviewDraftProvider('5'))!;

    expect(draft.isReadyToSubmit, isFalse);
    expect(
      draft.validationErrors,
      contains('Proposed salary exceeds review guardrail'),
    );
  });
}
