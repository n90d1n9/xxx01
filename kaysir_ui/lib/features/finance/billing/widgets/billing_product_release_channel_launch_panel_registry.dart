import 'package:flutter/material.dart';

import 'billing_empty_state.dart';
import 'billing_product_release_channel_launch_metric_provider_registry.dart';
import 'billing_product_release_channel_launch_panel_sources.dart';
import 'billing_product_release_channel_launch_plan_components.dart';
import 'billing_product_release_channel_launch_queue_components.dart';
import 'billing_product_release_channel_launch_runbook.dart';
import 'billing_product_release_channel_launch_runbook_components.dart';
import 'billing_readiness_panel_descriptor.dart';

const billingProductReleaseChannelLaunchPlanPanelId =
    'product-release.channel-launch-plan.panel';
const billingProductReleaseChannelLaunchRunbookPanelId =
    'product-release.channel-launch-runbook.panel';
const billingProductReleaseChannelLaunchQueuePanelId =
    'product-release.channel-launch-queue.panel';

final billingProductReleaseChannelLaunchPlanPanelDescriptor =
    BillingReadinessMetricProviderPanelDescriptor<
      BillingProductReleaseChannelLaunchPlanPanelSource
    >(
      id: billingProductReleaseChannelLaunchPlanPanelId,
      priority: 100,
      metricProvider: billingProductReleaseChannelLaunchPlanMetricProvider,
      title: 'Channel launch plan',
      summaryResolver: (source) => source.launchPlan.summaryLabel,
      icon: Icons.checklist_rtl_outlined,
      iconColor: const Color(0xFF059669),
      iconBackgroundColor: const Color(0xFFECFDF5),
      childBuilder: _buildLaunchPlanChild,
    );

final billingProductReleaseChannelLaunchRunbookPanelDescriptor =
    BillingReadinessMetricProviderPanelDescriptor<
      BillingProductReleaseChannelLaunchRunbook
    >(
      id: billingProductReleaseChannelLaunchRunbookPanelId,
      priority: 200,
      metricProvider: billingProductReleaseChannelLaunchRunbookMetricProvider,
      title: 'Channel launch runbook',
      summaryResolver: (runbook) => runbook.summaryLabel,
      icon: Icons.fact_check_outlined,
      iconColor: const Color(0xFF7C3AED),
      iconBackgroundColor: const Color(0xFFF5F3FF),
      childBuilder: _buildRunbookChild,
    );

final billingProductReleaseChannelLaunchQueuePanelDescriptor =
    BillingReadinessMetricProviderPanelDescriptor<
      BillingProductReleaseChannelLaunchQueuePanelSource
    >(
      id: billingProductReleaseChannelLaunchQueuePanelId,
      priority: 300,
      metricProvider: billingProductReleaseChannelLaunchQueueMetricProvider,
      title: 'Channel launch queue',
      summaryResolver: (source) => source.queue.summaryLabel,
      icon: Icons.queue_outlined,
      iconColor: const Color(0xFF2563EB),
      iconBackgroundColor: const Color(0xFFEFF6FF),
      childBuilder: _buildQueueChild,
    );

BillingReadinessPanelDescriptorRegistry
standardBillingProductReleaseChannelLaunchPanelRegistry({
  Iterable<BillingReadinessPanelDescriptorBase> extensions = const [],
  Set<String> hiddenPanelIds = const {},
}) {
  return BillingReadinessPanelDescriptorRegistry(
    descriptors: [
      for (final descriptor
          in standardBillingProductReleaseChannelLaunchPanelDescriptors())
        if (!hiddenPanelIds.contains(descriptor.id)) descriptor,
      ...extensions,
    ],
  );
}

List<BillingReadinessPanelDescriptorBase>
standardBillingProductReleaseChannelLaunchPanelDescriptors() {
  return List.unmodifiable([
    billingProductReleaseChannelLaunchPlanPanelDescriptor,
    billingProductReleaseChannelLaunchRunbookPanelDescriptor,
    billingProductReleaseChannelLaunchQueuePanelDescriptor,
  ]);
}

Widget _buildLaunchPlanChild(
  BillingProductReleaseChannelLaunchPlanPanelSource source,
) {
  return source.launchPlan.isEmpty
      ? const BillingEmptyState(
        message: 'No channel launch actions are available yet.',
      )
      : BillingProductReleaseChannelLaunchActionGrid(
        launchPlan: source.launchPlan,
        dispatchPlan: source.dispatchPlan,
        onDestinationSelected: source.onDestinationSelected,
      );
}

Widget _buildRunbookChild(BillingProductReleaseChannelLaunchRunbook runbook) {
  return runbook.isEmpty
      ? const BillingProductReleaseChannelLaunchRunbookEmptyState()
      : BillingProductReleaseChannelLaunchRunbookGroupList(runbook: runbook);
}

Widget _buildQueueChild(
  BillingProductReleaseChannelLaunchQueuePanelSource source,
) {
  return source.queue.isEmpty
      ? const BillingProductReleaseChannelLaunchQueueEmptyState()
      : BillingProductReleaseChannelLaunchQueueLaneList(
        queue: source.queue,
        onDestinationSelected: source.onDestinationSelected,
      );
}
