import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_blueprint.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_blueprint_fit_matrix.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_blueprint_launch_plan.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_modules.dart';
import 'package:kaysir/features/finance/billing/utils/billing_product_package.dart';
import 'package:kaysir/features/finance/billing/utils/billing_product_package_launch_playbook.dart';
import 'package:kaysir/features/finance/billing/utils/billing_product_package_plan.dart';
import 'package:kaysir/features/finance/billing/utils/billing_product_package_release_manifest.dart';

void main() {
  test('release manifest catalog maps package release states', () {
    final catalog = _standardCatalog();

    expect(catalog.manifestCount, 5);
    expect(catalog.releaseReadyCount, 2);
    expect(catalog.hardeningCount, 3);
    expect(catalog.blockedCount, 0);
    expect(catalog.fitGapCount, 0);
    expect(catalog.stageableCount, 5);
    expect(catalog.summaryLabel, '2 manifests ready; 3 need hardening.');

    final commerce = catalog.requireManifestForPackage('commerce_checkout');
    expect(commerce.releaseKey, 'commerce_checkout:commerce');
    expect(commerce.state, BillingProductPackageReleaseState.releaseReady);
    expect(commerce.stageLabel, 'Ready to publish');
    expect(commerce.requiredSignalLabels, ['Checkout']);
    expect(commerce.actions, isNotEmpty);
    expect(commerce.payload['releaseKey'], 'commerce_checkout:commerce');
    expect(commerce.payload['state'], 'releaseReady');

    final project = catalog.requireManifestForPackage('project_billing');
    expect(project.state, BillingProductPackageReleaseState.needsHardening);
    expect(project.stageLabel, 'Stage with review');
    expect(project.domainLabel, 'Construction');
  });

  test('release manifest catalog reports blockers and fit gaps', () {
    final blockedCatalog = _standardCatalog(hasTenant: false);

    expect(blockedCatalog.releaseReadyCount, 0);
    expect(blockedCatalog.blockedCount, 5);
    expect(
      blockedCatalog.summaryLabel,
      '5 manifests need blockers or fit gaps cleared.',
    );
    expect(
      blockedCatalog.requireManifestForPackage('commerce_checkout').state,
      BillingProductPackageReleaseState.blocked,
    );

    final fitGapCatalog = _standardCatalog(
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
    final manifest = fitGapCatalog.requireManifestForPackage(
      'construction_checkout',
    );

    expect(manifest.state, BillingProductPackageReleaseState.needsFit);
    expect(manifest.releaseKey, 'construction_checkout:unassigned');
    expect(manifest.canStageRelease, isFalse);
    expect(manifest.blockingActionCount, 1);
  });
}

BillingProductPackageReleaseManifestCatalog _standardCatalog({
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
  final playbook = BillingProductPackageLaunchPlaybook.forPortfolio(
    packagePortfolio,
  );

  return BillingProductPackageReleaseManifestCatalog.forPortfolio(
    portfolio: packagePortfolio,
    playbook: playbook,
  );
}
