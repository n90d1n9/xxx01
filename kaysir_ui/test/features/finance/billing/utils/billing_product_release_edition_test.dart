import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_blueprint.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_blueprint_fit_matrix.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_blueprint_launch_plan.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_modules.dart';
import 'package:kaysir/features/finance/billing/utils/billing_product_package.dart';
import 'package:kaysir/features/finance/billing/utils/billing_product_package_launch_playbook.dart';
import 'package:kaysir/features/finance/billing/utils/billing_product_package_plan.dart';
import 'package:kaysir/features/finance/billing/utils/billing_product_package_release_manifest.dart';
import 'package:kaysir/features/finance/billing/utils/billing_product_release_edition.dart';

void main() {
  test('release edition catalog groups packages into sellable editions', () {
    final catalog = _standardEditionCatalog();

    expect(catalog.editionCount, 5);
    expect(catalog.publishNowCount, 1);
    expect(catalog.reviewCount, 4);
    expect(catalog.blockedCount, 0);
    expect(catalog.incompleteCount, 0);
    expect(catalog.summaryLabel, '1 edition can publish; 4 need review.');

    final commerce = catalog.requirePlanForEdition('commerce_essentials');
    expect(commerce.canPublish, isTrue);
    expect(commerce.actionLabel, 'Publish edition');
    expect(commerce.requiredReleaseKeys, ['commerce_checkout:commerce']);
    expect(commerce.optionalReleaseKeys, ['omni_channel_billing:commerce']);
    expect(commerce.payload['state'], 'publishNow');

    final omni = catalog.requirePlanForEdition('omni_business');
    expect(omni.needsReview, isTrue);
    expect(omni.hardeningRequiredManifestCount, 1);
    expect(omni.actionLabel, 'Review hardening');
  });

  test('release edition catalog reports blocked and incomplete editions', () {
    final blockedCatalog = _standardEditionCatalog(hasTenant: false);

    expect(blockedCatalog.publishNowCount, 0);
    expect(blockedCatalog.blockedCount, 5);
    expect(
      blockedCatalog.summaryLabel,
      '5 editions need blockers cleared before release.',
    );
    expect(
      blockedCatalog.requirePlanForEdition('commerce_essentials').isBlocked,
      isTrue,
    );

    final incompleteCatalog =
        BillingProductReleaseEditionCatalog.forManifestCatalog(
          registry: BillingProductReleaseEditionRegistry(
            editions: [
              BillingProductReleaseEditionBlueprint(
                id: 'future_services',
                label: 'Future services',
                description: 'A placeholder future billing product.',
                audienceLabel: 'Future operators',
                requiredPackageKeys: const ['future_package'],
              ),
            ],
          ),
          manifestCatalog: _standardManifestCatalog(),
        );

    final incomplete = incompleteCatalog.requirePlanForEdition(
      'future_services',
    );
    expect(incompleteCatalog.incompleteCount, 1);
    expect(incomplete.isIncomplete, isTrue);
    expect(incomplete.missingRequiredPackageKeys, ['future_package']);
    expect(incomplete.actionLabel, 'Add required packages');
  });
}

BillingProductReleaseEditionCatalog _standardEditionCatalog({
  bool hasTenant = true,
}) {
  return BillingProductReleaseEditionCatalog.forManifestCatalog(
    registry: standardBillingProductReleaseEditionRegistry(),
    manifestCatalog: _standardManifestCatalog(hasTenant: hasTenant),
  );
}

BillingProductPackageReleaseManifestCatalog _standardManifestCatalog({
  bool hasTenant = true,
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
    registry: standardBillingProductPackageRegistry(),
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
