import '../utils/billing_product_release_channel.dart';
import '../utils/billing_product_release_edition.dart';
import 'billing_product_release_channel_matrix_metrics.dart';
import 'billing_product_release_edition_metrics.dart';
import 'billing_readiness_metric_provider.dart';

const billingProductReleaseEditionMetricProviderId = 'product-release.edition';
const billingProductReleaseChannelMatrixMetricProviderId =
    'product-release.channel-matrix';

final billingProductReleaseEditionMetricProvider =
    BillingReadinessMetricProvider<BillingProductReleaseEditionCatalog>(
      id: billingProductReleaseEditionMetricProviderId,
      priority: 100,
      resolver: BillingProductReleaseEditionMetrics.fromCatalog,
    );

final billingProductReleaseChannelMatrixMetricProvider =
    BillingReadinessMetricProvider<BillingProductReleaseChannelMatrix>(
      id: billingProductReleaseChannelMatrixMetricProviderId,
      priority: 200,
      resolver: BillingProductReleaseChannelMatrixMetrics.fromMatrix,
    );

BillingReadinessMetricProviderRegistry
standardBillingProductReleaseMetricProviderRegistry({
  Iterable<BillingReadinessMetricProviderBase> extensions = const [],
  Set<String> hiddenProviderIds = const {},
}) {
  return BillingReadinessMetricProviderRegistry(
    providers: [
      for (final provider in standardBillingProductReleaseMetricProviders())
        if (!hiddenProviderIds.contains(provider.id)) provider,
      ...extensions,
    ],
  );
}

List<BillingReadinessMetricProviderBase>
standardBillingProductReleaseMetricProviders() {
  return List.unmodifiable([
    billingProductReleaseEditionMetricProvider,
    billingProductReleaseChannelMatrixMetricProvider,
  ]);
}
