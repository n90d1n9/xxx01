import '../utils/billing_product_package_launch_playbook.dart';
import '../utils/billing_product_package_plan.dart';
import '../utils/billing_product_package_release_bundle.dart';
import '../utils/billing_product_package_release_manifest.dart';
import 'billing_product_package_launch_playbook_metrics.dart';
import 'billing_product_package_metrics.dart';
import 'billing_product_package_release_bundle_metrics.dart';
import 'billing_product_package_release_manifest_metrics.dart';
import 'billing_readiness_metric_provider.dart';

const billingProductPackagePortfolioMetricProviderId =
    'product-package.portfolio';
const billingProductPackageReleaseManifestMetricProviderId =
    'product-package.release-manifest';
const billingProductPackageReleaseBundleMetricProviderId =
    'product-package.release-bundle';
const billingProductPackageLaunchPlaybookMetricProviderId =
    'product-package.launch-playbook';

final billingProductPackagePortfolioMetricProvider =
    BillingReadinessMetricProvider<BillingProductPackagePortfolio>(
      id: billingProductPackagePortfolioMetricProviderId,
      priority: 100,
      resolver: BillingProductPackageMetrics.fromPortfolio,
    );

final billingProductPackageReleaseManifestMetricProvider =
    BillingReadinessMetricProvider<BillingProductPackageReleaseManifestCatalog>(
      id: billingProductPackageReleaseManifestMetricProviderId,
      priority: 200,
      resolver: BillingProductPackageReleaseManifestMetrics.fromCatalog,
    );

final billingProductPackageReleaseBundleMetricProvider =
    BillingReadinessMetricProvider<BillingProductPackageReleaseBundleCatalog>(
      id: billingProductPackageReleaseBundleMetricProviderId,
      priority: 300,
      resolver: BillingProductPackageReleaseBundleMetrics.fromCatalog,
    );

final billingProductPackageLaunchPlaybookMetricProvider =
    BillingReadinessMetricProvider<BillingProductPackageLaunchPlaybook>(
      id: billingProductPackageLaunchPlaybookMetricProviderId,
      priority: 400,
      resolver: BillingProductPackageLaunchPlaybookMetrics.fromPlaybook,
    );

BillingReadinessMetricProviderRegistry
standardBillingProductPackageMetricProviderRegistry({
  Iterable<BillingReadinessMetricProviderBase> extensions = const [],
  Set<String> hiddenProviderIds = const {},
}) {
  return BillingReadinessMetricProviderRegistry(
    providers: [
      for (final provider in standardBillingProductPackageMetricProviders())
        if (!hiddenProviderIds.contains(provider.id)) provider,
      ...extensions,
    ],
  );
}

List<BillingReadinessMetricProviderBase>
standardBillingProductPackageMetricProviders() {
  return List.unmodifiable([
    billingProductPackagePortfolioMetricProvider,
    billingProductPackageReleaseManifestMetricProvider,
    billingProductPackageReleaseBundleMetricProvider,
    billingProductPackageLaunchPlaybookMetricProvider,
  ]);
}
