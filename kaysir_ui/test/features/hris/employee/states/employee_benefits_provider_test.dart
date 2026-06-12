import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/employee/models/employee_benefits_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_benefits_provider.dart';
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

  test('employee benefits profile highlights onboarding actions', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final profile = container.read(employeeBenefitsProfileProvider('5'));

    expect(profile, isNotNull);
    expect(profile!.employeeName, 'Olivia Wilson');
    expect(profile.activeEnrollmentCount, 1);
    expect(profile.actionRequiredCount, 2);
    expect(profile.pendingDependentCount, 1);
    expect(profile.nextAction, 'Resolve 2 benefit actions.');
  });

  test('employee dependent draft validates and appends dependent', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final draftNotifier = container.read(
      employeeDependentDraftProvider('1').notifier,
    );
    draftNotifier.setFullName('Mira Johnson');
    draftNotifier.setRelationship(EmployeeDependentRelationship.child);
    draftNotifier.setBirthDate(DateTime(2018, 10, 2));

    final draft = container.read(employeeDependentDraftProvider('1'))!;
    expect(draft.isReadyToAdd, isTrue);
    expect(draft.completionRatio, 1);

    final profileNotifier = container.read(
      employeeBenefitsProfileProvider('1').notifier,
    );
    final dependent = profileNotifier.addDependent(draft);

    expect(dependent.id, 'DEP-1-002');
    expect(dependent.fullName, 'Mira Johnson');
    expect(
      container
          .read(employeeBenefitsProfileProvider('1'))!
          .pendingDependentCount,
      1,
    );
  });

  test('employee benefits actions resolve enrollment and dependent work', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final notifier = container.read(
      employeeBenefitsProfileProvider('5').notifier,
    );

    notifier.updateEnrollmentStatus(
      '5-benefit-medical',
      EmployeeBenefitEnrollmentStatus.active,
    );
    notifier.updateEnrollmentStatus(
      '5-benefit-retirement',
      EmployeeBenefitEnrollmentStatus.active,
    );
    notifier.verifyDependent('5-dependent-child');

    final updatedProfile =
        container.read(employeeBenefitsProfileProvider('5'))!;

    expect(updatedProfile.actionRequiredCount, 0);
    expect(updatedProfile.pendingDependentCount, 0);
    expect(updatedProfile.nextAction, 'Benefits profile is current.');
  });
}
