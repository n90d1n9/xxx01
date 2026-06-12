import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/employee/models/employee_data_correction_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_data_correction_provider.dart';
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

  test(
    'employee data correction seeds request from urgent data quality issue',
    () {
      final container = buildContainer();
      addTearDown(container.dispose);

      final profile = container.read(employeeDataCorrectionProvider('4'));

      expect(profile, isNotNull);
      expect(profile!.employeeName, 'David Kim');
      expect(profile.issues, isNotEmpty);
      expect(profile.requests, isNotEmpty);
      expect(profile.openCount, greaterThan(0));
      expect(
        profile.nextAction,
        isNot('No employee data corrections pending.'),
      );
    },
  );

  test('employee data correction draft submits and progresses lifecycle', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final draftNotifier = container.read(
      employeeDataCorrectionDraftProvider('4').notifier,
    );
    draftNotifier.setProposedValue('Verified reporting manager: Olivia Wilson');
    draftNotifier.setRationale('Correct manager value after HR validation.');

    final draft = container.read(employeeDataCorrectionDraftProvider('4'))!;
    expect(draft.isReadyToSubmit, isTrue);
    expect(draft.completionRatio, 1);

    final notifier = container.read(
      employeeDataCorrectionProvider('4').notifier,
    );
    final request = notifier.addDraft(draft);

    var profile = container.read(employeeDataCorrectionProvider('4'))!;
    expect(profile.requests.first.id, request.id);
    expect(request.status, EmployeeDataCorrectionStatus.submitted);

    notifier.startReview(request.id);
    profile = container.read(employeeDataCorrectionProvider('4'))!;
    expect(
      profile.requests.singleWhere((item) => item.id == request.id).status,
      EmployeeDataCorrectionStatus.inReview,
    );

    notifier.approve(request.id);
    profile = container.read(employeeDataCorrectionProvider('4'))!;
    expect(
      profile.requests.singleWhere((item) => item.id == request.id).status,
      EmployeeDataCorrectionStatus.approved,
    );

    notifier.apply(request.id);
    profile = container.read(employeeDataCorrectionProvider('4'))!;
    expect(
      profile.requests.singleWhere((item) => item.id == request.id).status,
      EmployeeDataCorrectionStatus.applied,
    );
    expect(profile.appliedCount, greaterThan(0));
  });

  test('employee data correction rejects cancels and reopens requests', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final notifier = container.read(
      employeeDataCorrectionProvider('4').notifier,
    );
    final request =
        container
            .read(employeeDataCorrectionProvider('4'))!
            .sortedRequests
            .first;

    notifier.reject(request.id);
    var profile = container.read(employeeDataCorrectionProvider('4'))!;
    expect(
      profile.requests.singleWhere((item) => item.id == request.id).status,
      EmployeeDataCorrectionStatus.rejected,
    );

    notifier.reopen(request.id);
    notifier.cancel(request.id);
    profile = container.read(employeeDataCorrectionProvider('4'))!;
    expect(
      profile.requests.singleWhere((item) => item.id == request.id).status,
      EmployeeDataCorrectionStatus.cancelled,
    );
  });

  test('employee data correction returns null for missing employee', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    expect(container.read(employeeDataCorrectionProvider('missing')), isNull);
    expect(
      container.read(employeeDataCorrectionDraftProvider('missing')),
      isNull,
    );
  });
}
