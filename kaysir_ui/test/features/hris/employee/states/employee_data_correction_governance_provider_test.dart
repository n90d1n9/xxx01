import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/employee/models/employee_data_correction_governance_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_data_correction_governance_provider.dart';
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

  test('employee correction governance evaluates open correction rules', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final profile = container.read(
      employeeDataCorrectionGovernanceProvider('4'),
    );

    expect(profile, isNotNull);
    expect(profile!.employeeName, 'David Kim');
    expect(profile.rules, isNotEmpty);
    expect(profile.blockedCount, greaterThan(0));
    expect(profile.warningCount, greaterThan(0));
    expect(profile.nextAction, contains('blocked correction governance'));
  });

  test('employee correction governance adds evidence and waives rules', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final draftNotifier = container.read(
      employeeDataCorrectionEvidenceDraftProvider('4').notifier,
    );
    draftNotifier.setSummary('Verified manager value using signed HR record.');

    final draft =
        container.read(employeeDataCorrectionEvidenceDraftProvider('4'))!;
    expect(draft.isReadyToAdd, isTrue);

    final notifier = container.read(
      employeeDataCorrectionGovernanceProvider('4').notifier,
    );
    final evidence = notifier.addEvidence(draft);

    var profile =
        container.read(employeeDataCorrectionGovernanceProvider('4'))!;
    expect(evidence.summary, 'Verified manager value using signed HR record.');
    expect(profile.evidenceCount, 1);
    expect(
      profile.rules
          .where(
            (rule) =>
                rule.requestId == evidence.requestId &&
                rule.type == EmployeeDataCorrectionGovernanceRuleType.evidence,
          )
          .single
          .status,
      EmployeeDataCorrectionGovernanceStatus.passed,
    );

    final blockedRule = profile.sortedRules.firstWhere(
      (rule) => rule.isBlocked,
    );
    notifier.waiveRule(blockedRule.id);
    profile = container.read(employeeDataCorrectionGovernanceProvider('4'))!;
    expect(
      profile.rules.singleWhere((rule) => rule.id == blockedRule.id).status,
      EmployeeDataCorrectionGovernanceStatus.waived,
    );

    notifier.reinstateRule(blockedRule.id);
    profile = container.read(employeeDataCorrectionGovernanceProvider('4'))!;
    expect(
      profile.rules.singleWhere((rule) => rule.id == blockedRule.id).status,
      isNot(EmployeeDataCorrectionGovernanceStatus.waived),
    );
  });

  test('employee correction governance returns null for missing employee', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    expect(
      container.read(employeeDataCorrectionGovernanceProvider('missing')),
      isNull,
    );
    expect(
      container.read(employeeDataCorrectionEvidenceDraftProvider('missing')),
      isNull,
    );
  });
}
