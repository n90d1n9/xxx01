import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/employee/models/employee_skill_inventory_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_skill_inventory_provider.dart';

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

  test('employee skill inventory highlights critical verification gaps', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final profile = container.read(employeeSkillInventoryProvider('4'));

    expect(profile, isNotNull);
    expect(profile!.employeeName, 'David Kim');
    expect(profile.records.length, 3);
    expect(profile.verifiedCount, 1);
    expect(profile.criticalGapCount, 1);
    expect(profile.evidenceDueCount, 1);
    expect(profile.reviewDueCount, 1);
    expect(profile.attentionCount, 2);
    expect(profile.coverageRatio, closeTo(0.75, 0.0001));
    expect(profile.nextAction, 'Close 1 critical skill gap.');
    expect(profile.priorityRecords.first.skillName, 'Roadmap analytics');
  });

  test('employee skill evidence draft validates and adds record', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final draftNotifier = container.read(
      employeeSkillEvidenceDraftProvider('2').notifier,
    );
    draftNotifier.setSkillName('Incident response readiness');
    draftNotifier.setVerifier('Engineering Guild');
    draftNotifier.setEvidenceSummary(
      'Led incident practice and completed readiness review.',
    );
    draftNotifier.setObservedLevel(4);
    draftNotifier.setRequiredLevel(4);
    draftNotifier.setCriticality(EmployeeSkillCriticality.core);

    final draft = container.read(employeeSkillEvidenceDraftProvider('2'))!;
    expect(draft.isReadyToAdd, isTrue);
    expect(draft.completionRatio, 1);

    final notifier = container.read(
      employeeSkillInventoryProvider('2').notifier,
    );
    final record = notifier.addEvidence(draft);

    expect(record.id, 'ESI-2-003');
    expect(record.status, EmployeeSkillVerificationStatus.inReview);

    notifier.verifySkill(record.id);
    var profile = container.read(employeeSkillInventoryProvider('2'))!;
    var stored = profile.records.singleWhere((item) => item.id == record.id);
    expect(stored.status, EmployeeSkillVerificationStatus.verified);
    expect(stored.lastVerifiedDate, DateTime(2026, 5, 30));

    notifier.requestEvidence(record.id);
    profile = container.read(employeeSkillInventoryProvider('2'))!;
    stored = profile.records.singleWhere((item) => item.id == record.id);
    expect(stored.status, EmployeeSkillVerificationStatus.evidenceDue);

    notifier.waiveSkill(record.id);
    profile = container.read(employeeSkillInventoryProvider('2'))!;
    stored = profile.records.singleWhere((item) => item.id == record.id);
    expect(stored.status, EmployeeSkillVerificationStatus.waived);

    notifier.removeRecord(record.id);
    profile = container.read(employeeSkillInventoryProvider('2'))!;
    expect(profile.records.any((item) => item.id == record.id), isFalse);
  });

  test('employee skill inventory returns null for missing employee', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    expect(container.read(employeeSkillInventoryProvider('missing')), isNull);
    expect(
      container.read(employeeSkillEvidenceDraftProvider('missing')),
      isNull,
    );
  });
}
