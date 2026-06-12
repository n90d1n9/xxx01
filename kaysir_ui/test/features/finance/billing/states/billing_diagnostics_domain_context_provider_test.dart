import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/finance/billing/states/billing_diagnostics_domain_context_provider.dart';

void main() {
  test('diagnostics domain context resolves launch-ready registry state', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final context = container.read(
      billingDiagnosticsDomainContextProvider(true),
    );

    expect(context.hasTenant, isTrue);
    expect(context.isLaunchReady, isTrue);
    expect(context.isPackReady, isTrue);
    expect(context.moduleCount, 3);
    expect(context.packCount, 3);
    expect(context.blueprintCount, 3);
    expect(context.fitRowCount, 3);
    expect(context.launchPlanCount, 3);
    expect(context.registryReadiness.warningIssueCount, 2);
    expect(context.packReadiness.warningIssueCount, 4);
    expect(context.isPackContractReleaseReady, isTrue);
    expect(context.packContractOpenRequirementCount, 4);
    expect(context.packContractBlockedRequirementCount, 0);
    expect(context.packContractWarningRequirementCount, 4);
    expect(context.packRemediationPlan.actionCount, 4);
    expect(context.packRemediationPlan.warningActionCount, 4);
  });

  test('diagnostics domain context preserves tenant-gated blockers', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final context = container.read(
      billingDiagnosticsDomainContextProvider(false),
    );

    expect(context.hasTenant, isFalse);
    expect(context.isLaunchReady, isFalse);
    expect(context.isPackReady, isFalse);
    expect(context.moduleCount, 3);
    expect(context.packCount, 3);
    expect(context.blueprintCount, 3);
    expect(context.registryReadiness.blockedDomainKeys, [
      'commerce',
      'construction',
      'digital',
    ]);
    expect(context.packReadiness.blockedDomainKeys, [
      'commerce',
      'construction',
      'digital',
    ]);
    expect(context.isPackContractReleaseReady, isFalse);
    expect(context.packContractOpenRequirementCount, 5);
    expect(context.packContractBlockedRequirementCount, 3);
    expect(context.packContractWarningRequirementCount, 2);
    expect(context.packRemediationPlan.blockerActionCount, 3);
    expect(context.packRemediationPlan.warningActionCount, 4);
  });
}
