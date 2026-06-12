import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/employee/models/employee_personal_records_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_personal_records_provider.dart';

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

  test('employee personal records highlight onboarding verification work', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final profile = container.read(employeePersonalRecordsProfileProvider('5'));

    expect(profile, isNotNull);
    expect(profile!.employeeName, 'Olivia Wilson');
    expect(profile.addressAttentionCount, 2);
    expect(profile.contactAttentionCount, 1);
    expect(profile.nextAction, 'Verify 2 address records.');
  });

  test('employee emergency contact draft validates and appends contact', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final draftNotifier = container.read(
      employeeEmergencyContactDraftProvider('1').notifier,
    );
    draftNotifier.setFullName('Mira Johnson');
    draftNotifier.setRelationship(EmployeeEmergencyContactRelationship.sibling);
    draftNotifier.setPhone('+62 812 5555 0199');
    draftNotifier.setEmail('mira.johnson@example.com');

    final draft = container.read(employeeEmergencyContactDraftProvider('1'))!;
    expect(draft.isReadyToAdd, isTrue);
    expect(draft.completionRatio, 1);

    final profileNotifier = container.read(
      employeePersonalRecordsProfileProvider('1').notifier,
    );
    final contact = profileNotifier.addContact(draft);

    expect(contact.id, 'EMC-1-002');
    expect(contact.priority, 2);
    expect(contact.status, EmployeePersonalRecordStatus.pending);
    expect(
      container
          .read(employeePersonalRecordsProfileProvider('1'))!
          .contactAttentionCount,
      1,
    );
  });

  test('employee personal record actions verify profile records', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final notifier = container.read(
      employeePersonalRecordsProfileProvider('5').notifier,
    );

    notifier.verifyAddress('5-address-home');
    notifier.verifyAddress('5-address-mailing');
    notifier.verifyContact('5-contact-primary');

    final updatedProfile =
        container.read(employeePersonalRecordsProfileProvider('5'))!;

    expect(updatedProfile.addressAttentionCount, 0);
    expect(updatedProfile.contactAttentionCount, 0);
    expect(updatedProfile.nextAction, 'Personal records are current.');
  });
}
