import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/utils/billing_product_release_channel.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_product_release_channel_launch_dispatch_plan.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_product_release_channel_launch_metrics.dart';

void main() {
  test('launch metrics summarize launch plan lanes', () {
    final metrics = BillingProductReleaseChannelLaunchMetrics.fromPlan(
      launchPlan: BillingProductReleaseChannelLaunchPlan(
        actions: [
          _action('publish', BillingProductReleaseChannelLaunchLane.publishNow),
          _action('review', BillingProductReleaseChannelLaunchLane.review),
          _action('blocked', BillingProductReleaseChannelLaunchLane.blocked),
        ],
      ),
    );

    expect(metrics.count, 4);
    expect(metrics.metricForLabel('Actions')?.value, '3');
    expect(metrics.metricForLabel('Launch')?.value, '1');
    expect(metrics.metricForLabel('Review')?.value, '1');
    expect(metrics.metricForLabel('Blocked')?.value, '1');
    expect(metrics.metricForLabel('Routes'), isNull);
    expect(
      metrics.metricForLabel('Actions')?.icon,
      Icons.checklist_rtl_outlined,
    );
  });

  test('launch metrics include route readiness when dispatch is attached', () {
    final metrics = BillingProductReleaseChannelLaunchMetrics.fromPlan(
      launchPlan: BillingProductReleaseChannelLaunchPlan(
        actions: [
          _action('publish', BillingProductReleaseChannelLaunchLane.publishNow),
        ],
      ),
      dispatchPlan: BillingProductReleaseChannelLaunchDispatchPlan(),
    );

    expect(metrics.count, 5);
    expect(metrics.metricForLabel('Routes')?.value, '0');
    expect(metrics.metricForLabel('Routes')?.color, const Color(0xFF7C3AED));
  });
}

BillingProductReleaseChannelLaunchAction _action(
  String id,
  BillingProductReleaseChannelLaunchLane lane,
) {
  return BillingProductReleaseChannelLaunchAction(
    id: id,
    channelKey: 'pos_counter',
    channelLabel: 'POS Counter',
    editionKey: 'commerce_essentials',
    editionLabel: 'Commerce Essentials',
    label: 'Launch $id',
    detail: 'Release lane fixture',
    lane: lane,
    priority: 1,
  );
}
