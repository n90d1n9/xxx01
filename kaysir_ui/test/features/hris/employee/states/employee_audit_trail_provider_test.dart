import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/employee/models/employee_audit_trail_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_audit_trail_provider.dart';
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

  test('employee audit trail highlights escalated governance work', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final profile = container.read(employeeAuditTrailProfileProvider('4'));

    expect(profile, isNotNull);
    expect(profile!.employeeName, 'David Kim');
    expect(profile.escalatedCount, 1);
    expect(profile.reviewRequiredCount, 1);
    expect(profile.attentionCount, 2);
    expect(profile.sensitiveCount, 3);
    expect(profile.nextAction, 'Resolve 1 escalated audit event.');
  });

  test('employee audit trail draft adds review-required sensitive note', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final draftNotifier = container.read(
      employeeAuditTrailDraftProvider('3').notifier,
    );
    draftNotifier.setSource(EmployeeAuditTrailSource.pay);
    draftNotifier.setSeverity(EmployeeAuditTrailSeverity.warning);
    draftNotifier.setTitle('Manual payroll audit');
    draftNotifier.setDetail(
      'Payroll setup was reviewed manually before the next cutoff.',
    );
    draftNotifier.setContainsSensitiveData(true);

    final draft = container.read(employeeAuditTrailDraftProvider('3'))!;
    expect(draft.isReadyToAdd, isTrue);
    expect(draft.completionRatio, 1);

    final profileNotifier = container.read(
      employeeAuditTrailProfileProvider('3').notifier,
    );
    final entry = profileNotifier.addDraft(draft);

    expect(entry.id, 'EAT-3-003');
    expect(entry.reviewStatus, EmployeeAuditTrailReviewStatus.reviewRequired);
    expect(entry.containsSensitiveData, isTrue);

    final profile = container.read(employeeAuditTrailProfileProvider('3'))!;
    expect(profile.reviewRequiredCount, 1);
    expect(profile.attentionCount, 1);
    expect(profile.entries.first.title, 'Manual payroll audit');
  });

  test('employee audit trail actions review escalate and archive events', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final notifier = container.read(
      employeeAuditTrailProfileProvider('5').notifier,
    );

    final initial = container.read(employeeAuditTrailProfileProvider('5'))!;
    expect(initial.reviewRequiredCount, 1);
    expect(initial.attentionCount, 1);

    notifier.markReviewed('EAT-5-003');
    final reviewed = container.read(employeeAuditTrailProfileProvider('5'))!;
    expect(reviewed.reviewRequiredCount, 0);
    expect(reviewed.attentionCount, 0);

    notifier.escalate('EAT-5-002');
    final escalated = container.read(employeeAuditTrailProfileProvider('5'))!;
    expect(escalated.escalatedCount, 1);
    expect(escalated.attentionCount, 1);

    notifier.archive('EAT-5-002');
    final archived = container.read(employeeAuditTrailProfileProvider('5'))!;
    expect(archived.escalatedCount, 0);
    expect(archived.attentionCount, 0);
  });
}
