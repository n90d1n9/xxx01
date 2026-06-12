import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_blueprint.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_blueprint_fit_matrix.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_blueprint_launch_plan.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_modules.dart';
import 'package:kaysir/features/finance/billing/utils/billing_product_package.dart';
import 'package:kaysir/features/finance/billing/utils/billing_product_package_launch_playbook.dart';
import 'package:kaysir/features/finance/billing/utils/billing_product_package_plan.dart';
import 'package:kaysir/features/finance/billing/utils/billing_product_package_release_bundle.dart';
import 'package:kaysir/features/finance/billing/utils/billing_product_package_release_manifest.dart';

void main() {
  test('release bundle catalog groups standard manifests by rollout state', () {
    final catalog = _standardBundleCatalog();

    expect(catalog.bundleIds, ['publish_now', 'review_before_release']);
    expect(catalog.bundleCount, 2);
    expect(catalog.manifestCount, 5);
    expect(catalog.publishNowManifestCount, 2);
    expect(catalog.reviewManifestCount, 3);
    expect(catalog.blockedManifestCount, 0);
    expect(catalog.stageableManifestCount, 5);
    expect(catalog.summaryLabel, '2 manifests can publish; 3 need review.');

    final publishBundle = catalog.requireBundleForState(
      BillingProductPackageReleaseBundleState.publishNow,
    );
    expect(publishBundle.canPublish, isTrue);
    expect(publishBundle.manifestCount, 2);
    expect(publishBundle.actionLabel, 'Publish bundle');
    expect(publishBundle.releaseKeys, [
      'commerce_checkout:commerce',
      'omni_channel_billing:commerce',
    ]);
    expect(publishBundle.payload['state'], 'publishNow');

    final reviewBundle = catalog.requireBundleForState(
      BillingProductPackageReleaseBundleState.review,
    );
    expect(reviewBundle.needsReview, isTrue);
    expect(reviewBundle.manifestCount, 3);
    expect(reviewBundle.actionLabel, 'Review hardening');
  });

  test('release bundle catalog reports blocked and empty bundles', () {
    final blockedCatalog = _standardBundleCatalog(hasTenant: false);

    expect(blockedCatalog.bundleIds, ['blocked_release']);
    expect(blockedCatalog.publishNowManifestCount, 0);
    expect(blockedCatalog.blockedManifestCount, 5);
    expect(
      blockedCatalog.summaryLabel,
      '5 manifests need blockers cleared before release.',
    );
    expect(
      blockedCatalog
          .requireBundleForState(
            BillingProductPackageReleaseBundleState.blocked,
          )
          .isBlocked,
      isTrue,
    );

    final emptyCatalog =
        BillingProductPackageReleaseBundleCatalog.forManifestCatalog(
          BillingProductPackageReleaseManifestCatalog(),
        );

    expect(emptyCatalog.isEmpty, isTrue);
    expect(
      emptyCatalog.summaryLabel,
      'No billing product package release bundles are available.',
    );
  });
}

BillingProductPackageReleaseBundleCatalog _standardBundleCatalog({
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
  final manifestCatalog =
      BillingProductPackageReleaseManifestCatalog.forPortfolio(
        portfolio: packagePortfolio,
        playbook: playbook,
      );

  return BillingProductPackageReleaseBundleCatalog.forManifestCatalog(
    manifestCatalog,
  );
}
