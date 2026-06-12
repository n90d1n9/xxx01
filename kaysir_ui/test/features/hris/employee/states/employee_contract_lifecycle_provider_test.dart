import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/employee/models/employee_contract_lifecycle_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_contract_lifecycle_provider.dart';
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

  test('employee contract lifecycle highlights renewal risk', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final profile = container.read(
      employeeContractLifecycleProfileProvider('4'),
    );

    expect(profile, isNotNull);
    expect(profile!.employeeName, 'David Kim');
    expect(profile.contract.type, EmployeeContractType.fixedTerm);
    expect(profile.renewalDueCount, 1);
    expect(profile.submittedChangeCount, 1);
    expect(profile.attentionCount, 2);
    expect(profile.nextAction, 'Renew fixed-term contract.');
  });

  test('employee contract change draft submits a custom change request', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final draftNotifier = container.read(
      employeeContractChangeDraftProvider('3').notifier,
    );
    draftNotifier.setType(EmployeeContractChangeType.conversion);
    draftNotifier.setTitle('Convert to permanent contract');
    draftNotifier.setDetail(
      'Move employee to permanent contract after HR review.',
    );

    final draft = container.read(employeeContractChangeDraftProvider('3'))!;
    expect(draft.isReadyToSubmit, isTrue);
    expect(draft.completionRatio, 1);

    final profileNotifier = container.read(
      employeeContractLifecycleProfileProvider('3').notifier,
    );
    final request = profileNotifier.submitDraft(draft);

    expect(request.id, 'ECL-3-001');
    expect(request.status, EmployeeContractChangeStatus.submitted);

    final profile =
        container.read(employeeContractLifecycleProfileProvider('3'))!;
    expect(profile.submittedChangeCount, 1);
    expect(profile.changes.first.title, 'Convert to permanent contract');
  });

  test(
    'employee contract lifecycle actions progress probation and renewal',
    () {
      final container = buildContainer();
      addTearDown(container.dispose);

      final onboardingNotifier = container.read(
        employeeContractLifecycleProfileProvider('5').notifier,
      );
      expect(
        container
            .read(employeeContractLifecycleProfileProvider('5'))!
            .probationDueCount,
        1,
      );

      onboardingNotifier.completeProbation();
      final onboarding =
          container.read(employeeContractLifecycleProfileProvider('5'))!;
      expect(onboarding.probationDueCount, 0);
      expect(onboarding.contract.status, EmployeeContractStatus.active);
      expect(onboarding.contract.type, EmployeeContractType.permanent);

      final renewalNotifier = container.read(
        employeeContractLifecycleProfileProvider('4').notifier,
      );
      renewalNotifier.approveChange('ECL-4-001');
      renewalNotifier.signChange('ECL-4-001');
      renewalNotifier.activateChange('ECL-4-001');

      final renewal =
          container.read(employeeContractLifecycleProfileProvider('4'))!;
      expect(renewal.submittedChangeCount, 0);
      expect(renewal.approvedChangeCount, 0);
      expect(renewal.signedChangeCount, 0);
      expect(renewal.renewalDueCount, 0);
      expect(renewal.contract.status, EmployeeContractStatus.active);
      expect(renewal.contract.version, 3);
      expect(
        renewal.changes.singleWhere((item) => item.id == 'ECL-4-001').status,
        EmployeeContractChangeStatus.activated,
      );
    },
  );
}
