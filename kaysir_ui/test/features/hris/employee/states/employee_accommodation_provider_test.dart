import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/employee/models/employee_accommodation_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_accommodation_provider.dart';
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

  test('employee accommodation profile highlights review due support', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final profile = container.read(employeeAccommodationProfileProvider('4'));

    expect(profile, isNotNull);
    expect(profile!.employeeName, 'David Kim');
    expect(profile.reviewDueCount, 1);
    expect(profile.attentionCount, 1);
    expect(profile.nextAction, 'Review 1 workplace support plan.');
  });

  test('employee accommodation draft submits request', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final draftNotifier = container.read(
      employeeAccommodationDraftProvider('3').notifier,
    );
    draftNotifier.setType(EmployeeAccommodationType.medical);
    draftNotifier.setTitle('Medical schedule support');
    draftNotifier.setSummary(
      'Temporary schedule support while employee completes care plan.',
    );

    final draft = container.read(employeeAccommodationDraftProvider('3'))!;
    expect(draft.isReadyToSubmit, isTrue);
    expect(draft.completionRatio, 1);

    final profileNotifier = container.read(
      employeeAccommodationProfileProvider('3').notifier,
    );
    final record = profileNotifier.submitDraft(draft);

    expect(record.id, 'EAC-3-001');
    expect(record.status, EmployeeAccommodationStatus.requested);

    final profile = container.read(employeeAccommodationProfileProvider('3'))!;
    expect(profile.requestedCount, 1);
    expect(profile.attentionCount, 1);
    expect(profile.records.first.title, 'Medical schedule support');
  });

  test('employee accommodation actions activate and complete review', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final onboardingNotifier = container.read(
      employeeAccommodationProfileProvider('5').notifier,
    );
    expect(
      container.read(employeeAccommodationProfileProvider('5'))!.approvedCount,
      1,
    );

    onboardingNotifier.activateAccommodation('EAC-5-001');
    final onboarding =
        container.read(employeeAccommodationProfileProvider('5'))!;
    expect(onboarding.approvedCount, 0);
    expect(onboarding.activeCount, 1);
    expect(onboarding.attentionCount, 0);

    final watchlistNotifier = container.read(
      employeeAccommodationProfileProvider('4').notifier,
    );
    watchlistNotifier.completeReview('EAC-4-001');
    final watchlist =
        container.read(employeeAccommodationProfileProvider('4'))!;

    expect(watchlist.reviewDueCount, 0);
    expect(watchlist.attentionCount, 0);
    expect(
      watchlist.records
          .singleWhere((record) => record.id == 'EAC-4-001')
          .status,
      EmployeeAccommodationStatus.active,
    );
  });
}
