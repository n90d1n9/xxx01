import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_business_domain_profile.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_blueprint.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_modules.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_destination.dart';

void main() {
  test('standard blueprints summarize reusable product behavior', () {
    final registry = BillingBusinessDomainBlueprintRegistry.forRegistry(
      standardBillingDomainModuleRegistry(),
    );

    final commerce = registry.requireBlueprintForDomain('commerce');
    final construction = registry.requireBlueprintForDomain('construction');
    final digital = registry.requireBlueprintForDomain('digital');

    expect(registry.domainKeys, ['commerce', 'construction', 'digital']);
    expect(registry.isLaunchReady, isTrue);
    expect(registry.warningContractCount, 2);
    expect(
      registry.summaryLabel,
      '3 billing blueprints are launch-ready with 2 contract warnings.',
    );

    expect(commerce.productModeLabel, 'Checkout-led commerce');
    expect(commerce.channelLabel, 'Omni-channel ready');
    expect(
      commerce.defaultDestinationId,
      BillingNavigationDestinationId.productWorkspace,
    );
    expect(
      commerce.destinationIds,
      contains(BillingNavigationDestinationId.cartCheckout),
    );
    expect(commerce.requireContract('line_items').isReady, isTrue);

    expect(construction.productModeLabel, 'Project billing');
    expect(construction.channelLabel, 'Single-channel ready');
    expect(
      construction.destinationIds,
      isNot(contains(BillingNavigationDestinationId.cartCheckout)),
    );
    expect(
      construction.requireContract('line_items').state,
      BillingBusinessDomainBlueprintContractState.warning,
    );

    expect(digital.productModeLabel, 'Subscription billing');
    expect(digital.channelLabel, 'Omni-channel ready');
    expect(
      digital.capabilities,
      contains(BillingBusinessDomainCapability.recurringSubscriptions),
    );
  });

  test('blueprints expose custom module configuration gaps', () {
    final serviceModule = profileOnlyBillingDomainModule(
      BillingBusinessDomainProfile(
        domain: 'service',
        label: 'Service operations',
        defaultSourceType: 'work_order',
        capabilities: const {BillingBusinessDomainCapability.servicePeriods},
      ),
    );
    final blueprint = BillingBusinessDomainBlueprint.forModule(serviceModule);

    expect(blueprint.productModeLabel, 'Service billing');
    expect(blueprint.releaseStatusLabel, 'Needs configuration');
    expect(blueprint.isLaunchReady, isFalse);
    expect(blueprint.blockerContractCount, 1);
    expect(blueprint.warningContractCount, 2);
    expect(
      blueprint.requireContract('screens').state,
      BillingBusinessDomainBlueprintContractState.blocker,
    );
    expect(
      blueprint.requireContract('navigation').state,
      BillingBusinessDomainBlueprintContractState.warning,
    );
    expect(
      blueprint.requireContract('line_items').state,
      BillingBusinessDomainBlueprintContractState.warning,
    );
  });

  test('blueprint registry reports tenant-gated launch blockers', () {
    final registry = BillingBusinessDomainBlueprintRegistry.forRegistry(
      standardBillingDomainModuleRegistry(),
      hasTenant: false,
    );
    final commerce = registry.requireBlueprintForDomain('commerce');

    expect(registry.isLaunchReady, isFalse);
    expect(registry.blockedBlueprints.map((blueprint) => blueprint.domainKey), [
      'commerce',
      'construction',
      'digital',
    ]);
    expect(commerce.releaseStatusLabel, 'Needs configuration');
    expect(
      commerce.requireContract('navigation').state,
      BillingBusinessDomainBlueprintContractState.blocker,
    );
    expect(
      registry.summaryLabel,
      '3 of 3 billing blueprints need configuration.',
    );
  });
}
