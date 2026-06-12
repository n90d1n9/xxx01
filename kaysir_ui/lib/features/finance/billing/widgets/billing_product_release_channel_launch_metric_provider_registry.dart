import 'billing_product_release_channel_launch_metrics.dart';
import 'billing_product_release_channel_launch_panel_sources.dart';
import 'billing_product_release_channel_launch_queue_metrics.dart';
import 'billing_product_release_channel_launch_runbook.dart';
import 'billing_product_release_channel_launch_runbook_metrics.dart';
import 'billing_readiness_metric_provider.dart';

const billingProductReleaseChannelLaunchPlanMetricProviderId =
    'product-release.channel-launch-plan';
const billingProductReleaseChannelLaunchRunbookMetricProviderId =
    'product-release.channel-launch-runbook';
const billingProductReleaseChannelLaunchQueueMetricProviderId =
    'product-release.channel-launch-queue';

final billingProductReleaseChannelLaunchPlanMetricProvider =
    BillingReadinessMetricProvider<
      BillingProductReleaseChannelLaunchPlanPanelSource
    >(
      id: billingProductReleaseChannelLaunchPlanMetricProviderId,
      priority: 100,
      resolver: (source) {
        return BillingProductReleaseChannelLaunchMetrics.fromPlan(
          launchPlan: source.launchPlan,
          dispatchPlan: source.dispatchPlan,
        );
      },
    );

final billingProductReleaseChannelLaunchRunbookMetricProvider =
    BillingReadinessMetricProvider<BillingProductReleaseChannelLaunchRunbook>(
      id: billingProductReleaseChannelLaunchRunbookMetricProviderId,
      priority: 200,
      resolver: BillingProductReleaseChannelLaunchRunbookMetrics.fromRunbook,
    );

final billingProductReleaseChannelLaunchQueueMetricProvider =
    BillingReadinessMetricProvider<
      BillingProductReleaseChannelLaunchQueuePanelSource
    >(
      id: billingProductReleaseChannelLaunchQueueMetricProviderId,
      priority: 300,
      resolver: (source) {
        return BillingProductReleaseChannelLaunchQueueMetrics.fromQueue(
          source.queue,
        );
      },
    );

BillingReadinessMetricProviderRegistry
standardBillingProductReleaseChannelLaunchMetricProviderRegistry({
  Iterable<BillingReadinessMetricProviderBase> extensions = const [],
  Set<String> hiddenProviderIds = const {},
}) {
  return BillingReadinessMetricProviderRegistry(
    providers: [
      for (final provider
          in standardBillingProductReleaseChannelLaunchMetricProviders())
        if (!hiddenProviderIds.contains(provider.id)) provider,
      ...extensions,
    ],
  );
}

List<BillingReadinessMetricProviderBase>
standardBillingProductReleaseChannelLaunchMetricProviders() {
  return List.unmodifiable([
    billingProductReleaseChannelLaunchPlanMetricProvider,
    billingProductReleaseChannelLaunchRunbookMetricProvider,
    billingProductReleaseChannelLaunchQueueMetricProvider,
  ]);
}
