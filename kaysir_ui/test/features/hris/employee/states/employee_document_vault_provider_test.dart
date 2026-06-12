import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/employee/models/employee_document_vault_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_document_vault_provider.dart';

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

  test('employee document vault highlights expiring restricted documents', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final profile = container.read(employeeDocumentVaultProfileProvider('4'));

    expect(profile, isNotNull);
    expect(profile!.employeeName, 'David Kim');
    expect(profile.verifiedCount, 2);
    expect(profile.expiringSoonCount, 1);
    expect(profile.restrictedCount, 1);
    expect(profile.attentionCount, 1);
    expect(profile.nextAction, 'Renew 1 document before expiry.');
  });

  test('employee document vault draft adds pending review document', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final draftNotifier = container.read(
      employeeDocumentVaultDraftProvider('3').notifier,
    );
    draftNotifier.setCategory(EmployeeDocumentVaultCategory.training);
    draftNotifier.setAccess(EmployeeDocumentVaultAccess.restricted);
    draftNotifier.setTitle('Training certificate');
    draftNotifier.setSummary(
      'Certificate uploaded for HR review and restricted manager access.',
    );

    final draft = container.read(employeeDocumentVaultDraftProvider('3'))!;
    expect(draft.isReadyToAdd, isTrue);
    expect(draft.completionRatio, 1);

    final profileNotifier = container.read(
      employeeDocumentVaultProfileProvider('3').notifier,
    );
    final record = profileNotifier.submitDraft(draft);

    expect(record.id, 'EDV-3-003');
    expect(record.status, EmployeeDocumentVaultStatus.pendingReview);
    expect(record.access, EmployeeDocumentVaultAccess.restricted);

    final profile = container.read(employeeDocumentVaultProfileProvider('3'))!;
    expect(profile.pendingReviewCount, 1);
    expect(profile.attentionCount, 1);
    expect(profile.records.first.title, 'Training certificate');
  });

  test('employee document vault actions resolve onboarding document gaps', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final notifier = container.read(
      employeeDocumentVaultProfileProvider('5').notifier,
    );

    final initial = container.read(employeeDocumentVaultProfileProvider('5'))!;
    expect(initial.uploadNeededCount, 1);
    expect(initial.pendingReviewCount, 1);
    expect(initial.attentionCount, 2);

    notifier.verify('EDV-5-001');
    notifier.verify('EDV-5-002');

    final profile = container.read(employeeDocumentVaultProfileProvider('5'))!;
    expect(profile.uploadNeededCount, 0);
    expect(profile.pendingReviewCount, 0);
    expect(profile.attentionCount, 0);
    expect(
      profile.records.every(
        (record) => record.status == EmployeeDocumentVaultStatus.verified,
      ),
      isTrue,
    );
  });
}
