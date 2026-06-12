import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/compliance/states/compliance_provider.dart';

void main() {
  test('compliance summary aggregates open risk signals', () {
    final container = ProviderContainer(
      overrides: [
        complianceAsOfDateProvider.overrideWithValue(DateTime(2026, 5, 30)),
      ],
    );
    addTearDown(container.dispose);

    final summary = container.read(complianceSummaryProvider);

    expect(summary.controlsDue, 3);
    expect(summary.overdueControls, 1);
    expect(summary.pendingAcknowledgements, 98);
    expect(summary.documentRisks, 3);
    expect(summary.openFindings, 3);
    expect(summary.criticalFindings, 1);
  });

  test('compliance filters include global policies for departments', () {
    final container = ProviderContainer(
      overrides: [
        complianceAsOfDateProvider.overrideWithValue(DateTime(2026, 5, 30)),
      ],
    );
    addTearDown(container.dispose);

    container.read(complianceDepartmentProvider.notifier).state = 'Operations';
    container.read(complianceAttentionOnlyProvider.notifier).state = true;

    final summary = container.read(complianceSummaryProvider);
    final policies = container.read(filteredPolicyAcknowledgementsProvider);

    expect(policies.map((item) => item.policyName), [
      'Anti-harassment refresh',
      'Shift safety procedures',
    ]);
    expect(summary.controlsDue, 1);
    expect(summary.pendingAcknowledgements, 65);
    expect(summary.documentRisks, 1);
    expect(summary.openFindings, 1);
    expect(summary.criticalFindings, 1);
  });

  test('compliance escalation summary highlights concentrated risks', () {
    final container = ProviderContainer(
      overrides: [
        complianceAsOfDateProvider.overrideWithValue(DateTime(2026, 5, 30)),
      ],
    );
    addTearDown(container.dispose);

    final escalations = container.read(complianceEscalationSummaryProvider);

    expect(escalations.blockedControls, 1);
    expect(escalations.escalatedPolicies, 1);
    expect(escalations.highRiskDocuments, 1);
    expect(escalations.criticalFindings, 1);
    expect(escalations.dueWithinSevenDays, 7);
    expect(escalations.totalEscalations, 4);
  });

  test('compliance date override drives generated due dates', () {
    final container = ProviderContainer(
      overrides: [
        complianceAsOfDateProvider.overrideWithValue(DateTime(2026, 7, 10)),
      ],
    );
    addTearDown(container.dispose);

    final controls = container.read(complianceControlsProvider);
    final policies = container.read(policyAcknowledgementsProvider);

    expect(controls.first.dueDate, DateTime(2026, 7, 15));
    expect(policies.first.deadline, DateTime(2026, 7, 17));
  });
}
