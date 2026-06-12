import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_blueprint.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_blueprint_fit_matrix.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_blueprint_launch_plan.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_modules.dart';

void main() {
  test('standard launch portfolio prioritizes package and harden lanes', () {
    final registry = BillingBusinessDomainBlueprintRegistry.forRegistry(
      standardBillingDomainModuleRegistry(),
    );
    final matrix = BillingBusinessDomainBlueprintFitMatrix.forRegistry(
      registry,
    );
    final portfolio = BillingBusinessDomainBlueprintLaunchPortfolio.fromMatrix(
      matrix,
    );

    expect(portfolio.domainKeys, ['commerce', 'construction', 'digital']);
    expect(portfolio.domainCount, 3);
    expect(portfolio.packageCount, 1);
    expect(portfolio.hardenCount, 2);
    expect(portfolio.blockedCount, 0);
    expect(portfolio.omniChannelCount, 2);
    expect(
      portfolio.summaryLabel,
      '2 of 3 billing product domains need hardening before packaging.',
    );

    final commerce = portfolio.requirePlanForDomain('commerce');
    expect(commerce.lane, BillingBusinessDomainBlueprintLaunchLane.packageNow);
    expect(commerce.laneLabel, 'Package now');
    expect(commerce.supportedSignalLabels, ['Checkout', 'Omni-channel']);
    expect(
      commerce.requirePrimaryStep().label,
      'Package checkout-led commerce',
    );
    expect(
      commerce.requirePrimaryStep().detail,
      'Use Checkout and Omni-channel as the reusable behavior set for '
      'Commerce.',
    );

    final construction = portfolio.requirePlanForDomain('construction');
    expect(construction.needsHardening, isTrue);
    expect(construction.supportedSignalLabels, ['Projects', 'Service']);
    expect(construction.requirePrimaryStep().label, 'Harden warning');
    expect(
      construction.requirePrimaryStep().detail,
      'Construction has no line item adapter for milestone.',
    );
    expect(construction.steps.last.label, 'Package project billing');
  });

  test('launch portfolio reports tenant gated blockers', () {
    final registry = BillingBusinessDomainBlueprintRegistry.forRegistry(
      standardBillingDomainModuleRegistry(),
      hasTenant: false,
    );
    final matrix = BillingBusinessDomainBlueprintFitMatrix.forRegistry(
      registry,
    );
    final portfolio = BillingBusinessDomainBlueprintLaunchPortfolio.fromMatrix(
      matrix,
    );

    expect(portfolio.packageCount, 0);
    expect(portfolio.hardenCount, 0);
    expect(portfolio.blockedCount, 3);
    expect(
      portfolio.summaryLabel,
      '3 of 3 billing product domains need blockers resolved before '
      'packaging.',
    );

    final commerce = portfolio.requirePlanForDomain(' COMMERCE ');
    expect(commerce.isBlocked, isTrue);
    expect(commerce.requirePrimaryStep().label, 'Resolve blocker');
    expect(
      commerce.steps.map((step) => step.id),
      contains('package_supported_signals'),
    );
    expect(() => portfolio.requirePlanForDomain('unknown'), throwsStateError);
  });
}
