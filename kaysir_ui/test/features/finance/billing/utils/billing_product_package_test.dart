import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_blueprint.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_blueprint_fit_matrix.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_blueprint_launch_plan.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_modules.dart';
import 'package:kaysir/features/finance/billing/utils/billing_product_package.dart';
import 'package:kaysir/features/finance/billing/utils/billing_product_package_plan.dart';

void main() {
  test('standard product package registry exposes releasable packages', () {
    final registry = standardBillingProductPackageRegistry();

    expect(registry.packageKeys, [
      'commerce_checkout',
      'project_billing',
      'digital_subscriptions',
      'service_operations',
      'omni_channel_billing',
    ]);
    expect(
      registry.requirePackage('Commerce Checkout').label,
      'Commerce checkout',
    );
    expect(
      () => BillingProductPackageRegistry(
        packages: [
          registry.requirePackage('commerce_checkout'),
          registry.requirePackage('Commerce Checkout'),
        ],
      ),
      throwsStateError,
    );
  });

  test('product package portfolio maps standard launch decisions', () {
    final portfolio = _standardPortfolio();

    expect(portfolio.packageCount, 5);
    expect(portfolio.packageNowCount, 2);
    expect(portfolio.hardenCount, 3);
    expect(portfolio.blockedCount, 0);
    expect(portfolio.unavailableCount, 0);
    expect(
      portfolio.summaryLabel,
      '5 billing product packages are mapped with 3 hardening actions.',
    );

    final commerce = portfolio.requirePlanForPackage('commerce_checkout');
    expect(commerce.lane, BillingProductPackageLane.packageNow);
    expect(commerce.requiredSignalLabels, ['Checkout']);
    expect(commerce.domainSummary, 'Commerce');
    expect(commerce.primaryActionLabel, 'Package Commerce checkout');

    final service = portfolio.requirePlanForPackage('service_operations');
    expect(service.lane, BillingProductPackageLane.harden);
    expect(service.domainSummary, 'Construction');
    expect(service.requiredSignalLabels, ['Service']);

    final omni = portfolio.requirePlanForPackage('omni-channel-billing');
    expect(omni.lane, BillingProductPackageLane.packageNow);
    expect(omni.domainSummary, 'Commerce');
    expect(omni.requiredSignalLabels, ['Omni-channel']);
  });

  test('product package portfolio reports blockers and unavailable fits', () {
    final blockedPortfolio = _standardPortfolio(hasTenant: false);

    expect(blockedPortfolio.packageNowCount, 0);
    expect(blockedPortfolio.blockedCount, 5);
    expect(
      blockedPortfolio.summaryLabel,
      '5 of 5 billing product packages need blockers resolved.',
    );

    final unavailablePortfolio = _standardPortfolio(
      registry: BillingProductPackageRegistry(
        packages: [
          BillingProductPackage(
            id: 'construction_checkout',
            label: 'Construction checkout',
            description: 'Checkout behavior for construction.',
            audienceLabel: 'Construction operators',
            channelLabel: 'Back office',
            domainKeys: const ['construction'],
            requiredSignals: const [
              BillingBusinessDomainBlueprintFitSignal.checkout,
            ],
          ),
        ],
      ),
    );
    final unavailable = unavailablePortfolio.requirePlanForPackage(
      'construction_checkout',
    );

    expect(unavailable.lane, BillingProductPackageLane.unavailable);
    expect(unavailable.missingSignalLabels, ['Checkout']);
    expect(unavailable.primaryActionLabel, 'Add package fit signals');
    expect(
      unavailable.primaryActionDetail,
      'No registered billing domain currently supports Checkout for '
      'Construction checkout.',
    );
  });
}

BillingProductPackagePortfolio _standardPortfolio({
  bool hasTenant = true,
  BillingProductPackageRegistry? registry,
}) {
  final blueprintRegistry = BillingBusinessDomainBlueprintRegistry.forRegistry(
    standardBillingDomainModuleRegistry(),
    hasTenant: hasTenant,
  );
  final matrix = BillingBusinessDomainBlueprintFitMatrix.forRegistry(
    blueprintRegistry,
  );
  final launchPortfolio =
      BillingBusinessDomainBlueprintLaunchPortfolio.fromMatrix(matrix);

  return BillingProductPackagePortfolio.forLaunchPortfolio(
    registry: registry ?? standardBillingProductPackageRegistry(),
    launchPortfolio: launchPortfolio,
    columns: matrix.columns,
  );
}
