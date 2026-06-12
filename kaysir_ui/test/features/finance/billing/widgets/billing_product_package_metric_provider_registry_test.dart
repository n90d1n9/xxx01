import 'package:flutter/material.dart';
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
import 'package:kaysir/features/finance/billing/widgets/billing_domain_module_readiness_metric_strip.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_product_package_metric_provider_registry.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_readiness_metric_collection.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_readiness_metric_provider.dart';

void main() {
  test('standard product package metric registry keeps launch order', () {
    final registry = standardBillingProductPackageMetricProviderRegistry();

    expect(registry.providerIds, [
      billingProductPackagePortfolioMetricProviderId,
      billingProductPackageReleaseManifestMetricProviderId,
      billingProductPackageReleaseBundleMetricProviderId,
      billingProductPackageLaunchPlaybookMetricProviderId,
    ]);
  });

  test('standard product package metric registry resolves typed sources', () {
    final registry = standardBillingProductPackageMetricProviderRegistry();

    final portfolioMetrics = registry.resolve(
      billingProductPackagePortfolioMetricProviderId,
      _standardPortfolio(),
    );
    final manifestMetrics = registry.resolve(
      billingProductPackageReleaseManifestMetricProviderId,
      _standardManifestCatalog(),
    );
    final bundleMetrics = registry.resolve(
      billingProductPackageReleaseBundleMetricProviderId,
      _standardBundleCatalog(),
    );
    final playbookMetrics = registry.resolve(
      billingProductPackageLaunchPlaybookMetricProviderId,
      _standardPlaybook(),
    );

    expect(portfolioMetrics.metricForLabel('Packages')?.value, '5');
    expect(manifestMetrics.metricForLabel('Ready')?.value, '2');
    expect(bundleMetrics.metricForLabel('Publish')?.value, '2');
    expect(playbookMetrics.metricForLabel('Launch')?.value, '2');
  });

  test('product package metric registry filters providers by source type', () {
    final registry = standardBillingProductPackageMetricProviderRegistry();

    final providers = registry.providersForSource(_standardPortfolio());

    expect(providers.map((provider) => provider.id), [
      billingProductPackagePortfolioMetricProviderId,
    ]);
  });

  test(
    'product package metric registry supports hidden providers and extensions',
    () {
      final registry = standardBillingProductPackageMetricProviderRegistry(
        hiddenProviderIds: {billingProductPackagePortfolioMetricProviderId},
        extensions: [
          BillingReadinessMetricProvider<BillingProductPackagePortfolio>(
            id: 'product-package.custom-risk',
            priority: 50,
            resolver: (portfolio) {
              return BillingReadinessMetricCollection(
                items: [
                  BillingReadinessMetric(
                    label: 'Custom',
                    value: '${portfolio.packageCount}',
                    icon: Icons.auto_graph_outlined,
                    color: const Color(0xFF7C3AED),
                  ),
                ],
              );
            },
          ),
        ],
      );

      expect(registry.providerIds.first, 'product-package.custom-risk');
      expect(
        registry.contains(billingProductPackagePortfolioMetricProviderId),
        isFalse,
      );
      expect(
        registry
            .resolve('product-package.custom-risk', _standardPortfolio())
            .metricForLabel('Custom')
            ?.value,
        '5',
      );
    },
  );

  test('metric provider registry rejects duplicate and blank ids', () {
    expect(
      () => BillingReadinessMetricProviderRegistry(
        providers: [
          billingProductPackagePortfolioMetricProvider,
          billingProductPackagePortfolioMetricProvider,
        ],
      ),
      throwsA(isA<ArgumentError>()),
    );

    expect(
      () => BillingReadinessMetricProviderRegistry(
        providers: [
          BillingReadinessMetricProvider<BillingProductPackagePortfolio>(
            id: ' ',
            resolver: (_) => BillingReadinessMetricCollection(),
          ),
        ],
      ),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('metric provider registry rejects unsupported source models', () {
    final registry = standardBillingProductPackageMetricProviderRegistry();

    expect(
      () => registry.resolve(
        billingProductPackageReleaseManifestMetricProviderId,
        _standardPortfolio(),
      ),
      throwsA(isA<ArgumentError>()),
    );
  });
}

BillingProductPackagePortfolio _standardPortfolio() {
  final blueprintRegistry = BillingBusinessDomainBlueprintRegistry.forRegistry(
    standardBillingDomainModuleRegistry(),
  );
  final matrix = BillingBusinessDomainBlueprintFitMatrix.forRegistry(
    blueprintRegistry,
  );
  final launchPortfolio =
      BillingBusinessDomainBlueprintLaunchPortfolio.fromMatrix(matrix);

  return BillingProductPackagePortfolio.forLaunchPortfolio(
    registry: standardBillingProductPackageRegistry(),
    launchPortfolio: launchPortfolio,
    columns: matrix.columns,
  );
}

BillingProductPackageLaunchPlaybook _standardPlaybook() {
  return BillingProductPackageLaunchPlaybook.forPortfolio(_standardPortfolio());
}

BillingProductPackageReleaseManifestCatalog _standardManifestCatalog() {
  return BillingProductPackageReleaseManifestCatalog.forPortfolio(
    portfolio: _standardPortfolio(),
    playbook: _standardPlaybook(),
  );
}

BillingProductPackageReleaseBundleCatalog _standardBundleCatalog() {
  return BillingProductPackageReleaseBundleCatalog.forManifestCatalog(
    _standardManifestCatalog(),
  );
}
