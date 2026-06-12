import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/employee/models/employee_work_authorization_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_work_authorization_provider.dart';

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

  test('employee work authorization profile highlights renewal evidence', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final profile = container.read(
      employeeWorkAuthorizationProfileProvider('4'),
    );

    expect(profile, isNotNull);
    expect(profile!.employeeName, 'David Kim');
    expect(profile.renewalDueCount, 1);
    expect(profile.evidenceIssueCount, 1);
    expect(profile.reviewDueCount, 1);
    expect(profile.attentionCount, 1);
    expect(profile.nextAction, 'Collect 1 right-to-work evidence item.');
  });

  test('employee work authorization draft submits pending review record', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final draftNotifier = container.read(
      employeeWorkAuthorizationDraftProvider('3').notifier,
    );
    draftNotifier.setType(EmployeeWorkAuthorizationType.workVisa);
    draftNotifier.setTitle('Work visa sponsorship');
    draftNotifier.setNotes(
      'Collect right-to-work evidence before the next payroll close.',
    );

    final draft = container.read(employeeWorkAuthorizationDraftProvider('3'))!;
    expect(draft.isReadyToSubmit, isTrue);
    expect(draft.completionRatio, 1);

    final profileNotifier = container.read(
      employeeWorkAuthorizationProfileProvider('3').notifier,
    );
    final record = profileNotifier.submitDraft(draft);

    expect(record.id, 'EWA-3-002');
    expect(record.status, EmployeeWorkAuthorizationStatus.pendingReview);
    expect(
      record.evidenceStatus,
      EmployeeWorkAuthorizationEvidenceStatus.pendingUpload,
    );

    final profile =
        container.read(employeeWorkAuthorizationProfileProvider('3'))!;
    expect(profile.attentionCount, 1);
    expect(profile.records.first.title, 'Work visa sponsorship');
  });

  test('employee work authorization actions verify and complete renewals', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final onboardingNotifier = container.read(
      employeeWorkAuthorizationProfileProvider('5').notifier,
    );
    onboardingNotifier.verifyEvidence('EWA-5-001');
    final onboarding =
        container.read(employeeWorkAuthorizationProfileProvider('5'))!;
    final onboardingRecord = onboarding.records.single;

    expect(onboardingRecord.status, EmployeeWorkAuthorizationStatus.valid);
    expect(
      onboardingRecord.evidenceStatus,
      EmployeeWorkAuthorizationEvidenceStatus.verified,
    );
    expect(onboarding.attentionCount, 0);

    final watchlistNotifier = container.read(
      employeeWorkAuthorizationProfileProvider('4').notifier,
    );
    watchlistNotifier.markValid('EWA-4-001');
    final watchlist =
        container.read(employeeWorkAuthorizationProfileProvider('4'))!;
    final watchlistRecord = watchlist.records.single;

    expect(watchlistRecord.status, EmployeeWorkAuthorizationStatus.valid);
    expect(
      watchlistRecord.evidenceStatus,
      EmployeeWorkAuthorizationEvidenceStatus.verified,
    );
    expect(watchlist.renewalDueCount, 0);
    expect(watchlist.evidenceIssueCount, 0);
    expect(watchlist.attentionCount, 0);
    expect(
      watchlistRecord.expiryDate.isAfter(
        DateTime(2026, 5, 30).add(const Duration(days: 60)),
      ),
      isTrue,
    );
  });
}
