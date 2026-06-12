import 'package:flutter/material.dart';

import '../utils/billing_product_release_channel.dart';
import '../utils/billing_product_release_edition.dart';
import 'billing_empty_state.dart';
import 'billing_product_release_channel_components.dart';
import 'billing_product_release_edition_components.dart';
import 'billing_product_release_metric_provider_registry.dart';
import 'billing_readiness_panel_descriptor.dart';

const billingProductReleaseEditionPanelId = 'product-release.edition.panel';
const billingProductReleaseChannelMatrixPanelId =
    'product-release.channel-matrix.panel';

final billingProductReleaseEditionPanelDescriptor =
    BillingReadinessMetricProviderPanelDescriptor<
      BillingProductReleaseEditionCatalog
    >(
      id: billingProductReleaseEditionPanelId,
      priority: 100,
      metricProvider: billingProductReleaseEditionMetricProvider,
      title: 'Product release editions',
      summaryResolver: (catalog) => catalog.summaryLabel,
      icon: Icons.view_carousel_outlined,
      iconColor: const Color(0xFF2563EB),
      iconBackgroundColor: const Color(0xFFEFF6FF),
      childBuilder: _buildReleaseEditionChild,
    );

final billingProductReleaseChannelMatrixPanelDescriptor =
    BillingReadinessMetricProviderPanelDescriptor<
      BillingProductReleaseChannelMatrix
    >(
      id: billingProductReleaseChannelMatrixPanelId,
      priority: 200,
      metricProvider: billingProductReleaseChannelMatrixMetricProvider,
      title: 'Edition channel matrix',
      summaryResolver: (matrix) => matrix.summaryLabel,
      icon: Icons.hub_outlined,
      iconColor: const Color(0xFF2563EB),
      iconBackgroundColor: const Color(0xFFEFF6FF),
      childBuilder: _buildChannelMatrixChild,
    );

BillingReadinessPanelDescriptorRegistry
standardBillingProductReleasePanelRegistry({
  Iterable<BillingReadinessPanelDescriptorBase> extensions = const [],
  Set<String> hiddenPanelIds = const {},
}) {
  return BillingReadinessPanelDescriptorRegistry(
    descriptors: [
      for (final descriptor in standardBillingProductReleasePanelDescriptors())
        if (!hiddenPanelIds.contains(descriptor.id)) descriptor,
      ...extensions,
    ],
  );
}

List<BillingReadinessPanelDescriptorBase>
standardBillingProductReleasePanelDescriptors() {
  return List.unmodifiable([
    billingProductReleaseEditionPanelDescriptor,
    billingProductReleaseChannelMatrixPanelDescriptor,
  ]);
}

Widget _buildReleaseEditionChild(BillingProductReleaseEditionCatalog catalog) {
  return catalog.isEmpty
      ? const BillingEmptyState(
        message: 'No product release editions are available yet.',
      )
      : BillingProductReleaseEditionGrid(catalog: catalog);
}

Widget _buildChannelMatrixChild(BillingProductReleaseChannelMatrix matrix) {
  return matrix.isEmpty
      ? const BillingEmptyState(
        message: 'No edition release channels are available yet.',
      )
      : BillingProductReleaseChannelMatrixGrid(matrix: matrix);
}
