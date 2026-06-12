import 'package:flutter/material.dart';

import '../utils/billing_product_package_launch_playbook.dart';
import '../utils/billing_product_package_plan.dart';
import '../utils/billing_product_package_release_bundle.dart';
import '../utils/billing_product_package_release_manifest.dart';
import 'billing_empty_state.dart';
import 'billing_product_package_components.dart';
import 'billing_product_package_launch_playbook_components.dart';
import 'billing_product_package_metric_provider_registry.dart';
import 'billing_product_package_release_bundle_components.dart';
import 'billing_product_package_release_manifest_components.dart';
import 'billing_readiness_panel_descriptor.dart';

const billingProductPackagePortfolioPanelId = 'product-package.portfolio.panel';
const billingProductPackageReleaseManifestPanelId =
    'product-package.release-manifest.panel';
const billingProductPackageReleaseBundlePanelId =
    'product-package.release-bundle.panel';
const billingProductPackageLaunchPlaybookPanelId =
    'product-package.launch-playbook.panel';

final billingProductPackagePortfolioPanelDescriptor =
    BillingReadinessMetricProviderPanelDescriptor<
      BillingProductPackagePortfolio
    >(
      id: billingProductPackagePortfolioPanelId,
      priority: 100,
      metricProvider: billingProductPackagePortfolioMetricProvider,
      title: 'Product packages',
      summaryResolver: (portfolio) => portfolio.summaryLabel,
      icon: Icons.inventory_2_outlined,
      iconColor: const Color(0xFF2563EB),
      iconBackgroundColor: const Color(0xFFEFF6FF),
      childBuilder: _buildProductPackagePortfolioChild,
    );

final billingProductPackageReleaseManifestPanelDescriptor =
    BillingReadinessMetricProviderPanelDescriptor<
      BillingProductPackageReleaseManifestCatalog
    >(
      id: billingProductPackageReleaseManifestPanelId,
      priority: 200,
      metricProvider: billingProductPackageReleaseManifestMetricProvider,
      title: 'Package release manifests',
      summaryResolver: (catalog) => catalog.summaryLabel,
      icon: Icons.assignment_outlined,
      iconColor: const Color(0xFF2563EB),
      iconBackgroundColor: const Color(0xFFEFF6FF),
      childBuilder: _buildReleaseManifestChild,
    );

final billingProductPackageReleaseBundlePanelDescriptor =
    BillingReadinessMetricProviderPanelDescriptor<
      BillingProductPackageReleaseBundleCatalog
    >(
      id: billingProductPackageReleaseBundlePanelId,
      priority: 300,
      metricProvider: billingProductPackageReleaseBundleMetricProvider,
      title: 'Package release bundles',
      summaryResolver: (catalog) => catalog.summaryLabel,
      icon: Icons.all_inbox_outlined,
      iconColor: const Color(0xFF2563EB),
      iconBackgroundColor: const Color(0xFFEFF6FF),
      childBuilder: _buildReleaseBundleChild,
    );

final billingProductPackageLaunchPlaybookPanelDescriptor =
    BillingReadinessMetricProviderPanelDescriptor<
      BillingProductPackageLaunchPlaybook
    >(
      id: billingProductPackageLaunchPlaybookPanelId,
      priority: 400,
      metricProvider: billingProductPackageLaunchPlaybookMetricProvider,
      title: 'Package launch playbook',
      summaryResolver: (playbook) => playbook.summaryLabel,
      icon: Icons.fact_check_outlined,
      iconColor: const Color(0xFF059669),
      iconBackgroundColor: const Color(0xFFECFDF5),
      childBuilder: _buildLaunchPlaybookChild,
    );

BillingReadinessPanelDescriptorRegistry
standardBillingProductPackagePanelRegistry({
  Iterable<BillingReadinessPanelDescriptorBase> extensions = const [],
  Set<String> hiddenPanelIds = const {},
}) {
  return BillingReadinessPanelDescriptorRegistry(
    descriptors: [
      for (final descriptor in standardBillingProductPackagePanelDescriptors())
        if (!hiddenPanelIds.contains(descriptor.id)) descriptor,
      ...extensions,
    ],
  );
}

List<BillingReadinessPanelDescriptorBase>
standardBillingProductPackagePanelDescriptors() {
  return List.unmodifiable([
    billingProductPackagePortfolioPanelDescriptor,
    billingProductPackageReleaseManifestPanelDescriptor,
    billingProductPackageReleaseBundlePanelDescriptor,
    billingProductPackageLaunchPlaybookPanelDescriptor,
  ]);
}

Widget _buildProductPackagePortfolioChild(
  BillingProductPackagePortfolio portfolio,
) {
  return portfolio.isEmpty
      ? const BillingEmptyState(
        message: 'No billing product packages are registered yet.',
      )
      : BillingProductPackageGrid(portfolio: portfolio);
}

Widget _buildReleaseManifestChild(
  BillingProductPackageReleaseManifestCatalog catalog,
) {
  return catalog.isEmpty
      ? const BillingEmptyState(
        message: 'No package release manifests are available yet.',
      )
      : BillingProductPackageReleaseManifestGrid(catalog: catalog);
}

Widget _buildReleaseBundleChild(
  BillingProductPackageReleaseBundleCatalog catalog,
) {
  return catalog.isEmpty
      ? const BillingEmptyState(
        message: 'No package release bundles are available yet.',
      )
      : BillingProductPackageReleaseBundleGrid(catalog: catalog);
}

Widget _buildLaunchPlaybookChild(BillingProductPackageLaunchPlaybook playbook) {
  return playbook.isEmpty
      ? const BillingEmptyState(
        message: 'No package launch actions are available yet.',
      )
      : BillingProductPackageLaunchActionList(playbook: playbook);
}
