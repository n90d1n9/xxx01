import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_blueprint.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_blueprint_fit_matrix.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_blueprint_launch_plan.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_modules.dart';
import 'package:kaysir/features/finance/billing/utils/billing_product_package.dart';
import 'package:kaysir/features/finance/billing/utils/billing_product_package_launch_playbook.dart';
import 'package:kaysir/features/finance/billing/utils/billing_product_package_plan.dart';

void main() {
  test('product package launch playbook maps primary release actions', () {
    final playbook = _standardPlaybook();

    expect(playbook.packageCount, 5);
    expect(playbook.packageNowCount, 2);
    expect(playbook.hardenCount, 3);
    expect(playbook.blockedCount, 0);
    expect(playbook.unavailableCount, 0);
    expect(
      playbook.summaryLabel,
      '2 packages can launch now; 3 need hardening.',
    );

    final commerce = playbook.requirePrimaryActionForPackage(
      'commerce_checkout',
    );
    expect(commerce.kind, BillingProductPackageLaunchActionKind.package);
    expect(commerce.lane, BillingProductPackageLane.packageNow);
    expect(commerce.label, 'Package Commerce checkout');
    expect(commerce.domainLabel, 'Commerce');
    expect(commerce.isActionable, isTrue);

    final project = playbook.requirePrimaryActionForPackage('project_billing');
    expect(project.kind, BillingProductPackageLaunchActionKind.harden);
    expect(project.lane, BillingProductPackageLane.harden);
    expect(project.label, 'Harden Construction');
    expect(project.domainLabel, 'Construction');
  });

  test('product package launch playbook exposes package action chains', () {
    final playbook = _standardPlaybook();
    final actions = playbook.actionsForPackage('service_operations');

    expect(actions.length, greaterThanOrEqualTo(2));
    expect(actions.first.isPrimary, isTrue);
    expect(actions.first.kind, BillingProductPackageLaunchActionKind.harden);
    expect(
      actions.map((action) => action.kind),
      contains(BillingProductPackageLaunchActionKind.package),
    );
  });

  test('product package launch playbook reports blockers and fit gaps', () {
    final blockedPlaybook = _standardPlaybook(hasTenant: false);

    expect(blockedPlaybook.packageNowCount, 0);
    expect(blockedPlaybook.blockedCount, 5);
    expect(
      blockedPlaybook.summaryLabel,
      '5 packages need blockers or fit signals cleared.',
    );
    expect(
      blockedPlaybook.requirePrimaryActionForPackage('commerce_checkout').kind,
      BillingProductPackageLaunchActionKind.unblock,
    );

    final unavailablePlaybook = _standardPlaybook(
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
    final unavailable = unavailablePlaybook.requirePrimaryActionForPackage(
      'construction_checkout',
    );

    expect(unavailable.lane, BillingProductPackageLane.unavailable);
    expect(unavailable.kind, BillingProductPackageLaunchActionKind.fitSignals);
    expect(unavailable.isActionable, isFalse);
    expect(unavailable.domainLabel, 'No matching domains');
  });
}

BillingProductPackageLaunchPlaybook _standardPlaybook({
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
  final packagePortfolio = BillingProductPackagePortfolio.forLaunchPortfolio(
    registry: registry ?? standardBillingProductPackageRegistry(),
    launchPortfolio: launchPortfolio,
    columns: matrix.columns,
  );

  return BillingProductPackageLaunchPlaybook.forPortfolio(packagePortfolio);
}
