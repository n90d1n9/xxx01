import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/employee/models/employee_approval_policy_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_approval_policy_provider.dart';
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

  test('employee approval policy highlights suspended routing', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final profile = container.read(employeeApprovalPolicyProfileProvider('4'));

    expect(profile, isNotNull);
    expect(profile!.employeeName, 'David Kim');
    expect(profile.suspendedCount, 1);
    expect(profile.expiredCount, 1);
    expect(profile.reviewRequiredCount, 1);
    expect(profile.attentionCount, 2);
    expect(
      profile.nextAction,
      'Reinstate or replace 1 suspended approval policy rule.',
    );
  });

  test('employee approval policy submits activates and renews rule', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final draftNotifier = container.read(
      employeeApprovalPolicyDraftProvider('2').notifier,
    );
    draftNotifier.setArea(EmployeeApprovalPolicyArea.access);
    draftNotifier.setName('Privileged access routing');
    draftNotifier.setPrimaryRoute(EmployeeApprovalRoute.securityOwner);
    draftNotifier.setFallbackRoute(EmployeeApprovalRoute.hrBusinessPartner);
    draftNotifier.setOwner('IT Security');
    draftNotifier.setThresholdLabel('Privileged access requests');
    draftNotifier.setEscalationHours(8);
    draftNotifier.setEscalationMode(EmployeeApprovalEscalationMode.holdQueue);
    draftNotifier.setExpiresOn(DateTime(2026, 8, 1));
    draftNotifier.setRisk(EmployeeApprovalPolicyRisk.high);
    draftNotifier.setNotes('Route privileged access through security lead.');

    final draft = container.read(employeeApprovalPolicyDraftProvider('2'))!;
    expect(draft.isReadyToSubmit, isTrue);
    expect(draft.completionRatio, 1);

    final notifier = container.read(
      employeeApprovalPolicyProfileProvider('2').notifier,
    );
    final rule = notifier.submitDraft(draft);

    expect(rule.id, 'APR-2-004');
    expect(rule.status, EmployeeApprovalPolicyStatus.draft);

    notifier.activate(rule.id);
    var profile = container.read(employeeApprovalPolicyProfileProvider('2'))!;

    expect(
      profile.rules.singleWhere((item) => item.id == rule.id).status,
      EmployeeApprovalPolicyStatus.active,
    );

    notifier.renew(rule.id, expiresOn: DateTime(2026, 9, 1));
    profile = container.read(employeeApprovalPolicyProfileProvider('2'))!;

    final renewed = profile.rules.singleWhere((item) => item.id == rule.id);
    expect(renewed.expiresOn, DateTime(2026, 9, 1));
    expect(renewed.status, EmployeeApprovalPolicyStatus.active);
  });

  test('employee approval policy returns null for missing employee', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    expect(
      container.read(employeeApprovalPolicyProfileProvider('missing')),
      isNull,
    );
    expect(
      container.read(employeeApprovalPolicyDraftProvider('missing')),
      isNull,
    );
  });
}
