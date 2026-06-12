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
import 'package:kaysir/features/finance/billing/widgets/billing_product_package_launch_playbook_metrics.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_product_package_metrics.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_product_package_release_bundle_metrics.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_product_package_release_manifest_metrics.dart';

void main() {
  test('product package metrics summarize package portfolio lanes', () {
    final metrics = BillingProductPackageMetrics.fromPortfolio(
      _standardPortfolio(),
    );

    expect(metrics.count, 4);
    expect(metrics.metricForLabel('Packages')?.value, '5');
    expect(metrics.metricForLabel('Package')?.value, '2');
    expect(metrics.metricForLabel('Harden')?.value, '3');
    expect(metrics.metricForLabel('Blocked')?.value, '0');
    expect(
      metrics.metricForLabel('Packages')?.icon,
      Icons.inventory_2_outlined,
    );
  });

  test('product package manifest metrics summarize release readiness', () {
    final metrics = BillingProductPackageReleaseManifestMetrics.fromCatalog(
      _standardManifestCatalog(),
    );

    expect(metrics.count, 4);
    expect(metrics.metricForLabel('Manifests')?.value, '5');
    expect(metrics.metricForLabel('Ready')?.value, '2');
    expect(metrics.metricForLabel('Harden')?.value, '3');
    expect(metrics.metricForLabel('Gaps')?.value, '0');
  });

  test('product package bundle metrics summarize release batches', () {
    final metrics = BillingProductPackageReleaseBundleMetrics.fromCatalog(
      _standardBundleCatalog(),
    );

    expect(metrics.count, 4);
    expect(metrics.metricForLabel('Bundles')?.value, '2');
    expect(metrics.metricForLabel('Publish')?.value, '2');
    expect(metrics.metricForLabel('Review')?.value, '3');
    expect(metrics.metricForLabel('Blocked')?.value, '0');
  });

  test('product package playbook metrics summarize launch actions', () {
    final metrics = BillingProductPackageLaunchPlaybookMetrics.fromPlaybook(
      _standardPlaybook(),
    );

    expect(metrics.count, 4);
    expect(metrics.metricForLabel('Launch')?.value, '2');
    expect(metrics.metricForLabel('Harden')?.value, '3');
    expect(metrics.metricForLabel('Blocked')?.value, '0');
    expect(metrics.metricForLabel('Fit')?.value, '0');
    expect(
      metrics.metricForLabel('Launch')?.icon,
      Icons.rocket_launch_outlined,
    );
  });

  test('product package metrics keep empty catalogs measurable', () {
    final portfolioMetrics = BillingProductPackageMetrics.fromPortfolio(
      BillingProductPackagePortfolio(),
    );
    final manifestMetrics =
        BillingProductPackageReleaseManifestMetrics.fromCatalog(
          BillingProductPackageReleaseManifestCatalog(),
        );
    final bundleMetrics = BillingProductPackageReleaseBundleMetrics.fromCatalog(
      BillingProductPackageReleaseBundleCatalog(),
    );
    final playbookMetrics =
        BillingProductPackageLaunchPlaybookMetrics.fromPlaybook(
          BillingProductPackageLaunchPlaybook(),
        );

    expect(portfolioMetrics.metricForLabel('Packages')?.value, '0');
    expect(manifestMetrics.metricForLabel('Manifests')?.value, '0');
    expect(bundleMetrics.metricForLabel('Bundles')?.value, '0');
    expect(playbookMetrics.metricForLabel('Launch')?.value, '0');
    expect(
      playbookMetrics.metricForLabel('Fit')?.color,
      const Color(0xFF475569),
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
