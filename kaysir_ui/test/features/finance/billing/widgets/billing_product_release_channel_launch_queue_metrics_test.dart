import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_destination.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_product_release_channel_launch_queue.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_product_release_channel_launch_queue_metrics.dart';

void main() {
  test('queue metrics summarize launch queue lanes', () {
    final metrics = BillingProductReleaseChannelLaunchQueueMetrics.fromQueue(
      BillingProductReleaseChannelLaunchQueue(
        lanes: [
          BillingProductReleaseChannelLaunchQueueLaneGroup(
            lane: BillingProductReleaseChannelLaunchQueueLane.readyNow,
            items: [
              _item(
                'ready',
                BillingProductReleaseChannelLaunchQueueLane.readyNow,
              ),
            ],
          ),
          BillingProductReleaseChannelLaunchQueueLaneGroup(
            lane: BillingProductReleaseChannelLaunchQueueLane.needsRouting,
            items: [
              _item(
                'routing',
                BillingProductReleaseChannelLaunchQueueLane.needsRouting,
              ),
            ],
          ),
          BillingProductReleaseChannelLaunchQueueLaneGroup(
            lane: BillingProductReleaseChannelLaunchQueueLane.blocked,
            items: [
              _item(
                'blocked',
                BillingProductReleaseChannelLaunchQueueLane.blocked,
              ),
            ],
          ),
        ],
      ),
    );

    expect(metrics.count, 4);
    expect(metrics.metricForLabel('Ready now')?.value, '1');
    expect(metrics.metricForLabel('Needs routing')?.value, '1');
    expect(metrics.metricForLabel('Blocked')?.value, '1');
    expect(metrics.metricForLabel('Total')?.value, '3');
    expect(metrics.metricForLabel('Total')?.icon, Icons.queue_outlined);
  });

  test('queue metrics keep empty queues measurable', () {
    final metrics = BillingProductReleaseChannelLaunchQueueMetrics.fromQueue(
      BillingProductReleaseChannelLaunchQueue(),
    );

    expect(metrics.count, 4);
    expect(metrics.metricForLabel('Ready now')?.value, '0');
    expect(metrics.metricForLabel('Needs routing')?.value, '0');
    expect(metrics.metricForLabel('Blocked')?.value, '0');
    expect(metrics.metricForLabel('Total')?.value, '0');
  });
}

BillingProductReleaseChannelLaunchQueueItem _item(
  String id,
  BillingProductReleaseChannelLaunchQueueLane lane,
) {
  return BillingProductReleaseChannelLaunchQueueItem(
    id: id,
    title: 'Launch $id',
    detail: 'Fixture queue item.',
    destinationLabel: 'Invoices',
    callToActionLabel: 'Open invoices',
    statusLabel: _laneLabel(lane),
    destinationId: BillingNavigationDestinationId.invoices,
    lane: lane,
  );
}

String _laneLabel(BillingProductReleaseChannelLaunchQueueLane lane) {
  return switch (lane) {
    BillingProductReleaseChannelLaunchQueueLane.readyNow => 'Ready now',
    BillingProductReleaseChannelLaunchQueueLane.needsRouting => 'Needs routing',
    BillingProductReleaseChannelLaunchQueueLane.blocked => 'Blocked',
  };
}
