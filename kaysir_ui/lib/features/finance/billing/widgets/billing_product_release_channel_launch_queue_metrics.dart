import 'package:flutter/material.dart';

import 'billing_domain_module_readiness_metric_strip.dart';
import 'billing_product_release_channel_launch_queue.dart';
import 'billing_readiness_metric_collection.dart';

class BillingProductReleaseChannelLaunchQueueMetrics
    extends BillingReadinessMetricCollection {
  BillingProductReleaseChannelLaunchQueueMetrics({super.items});

  factory BillingProductReleaseChannelLaunchQueueMetrics.fromQueue(
    BillingProductReleaseChannelLaunchQueue queue,
  ) {
    return BillingProductReleaseChannelLaunchQueueMetrics(
      items: [
        BillingReadinessMetric(
          label: 'Ready now',
          value: '${queue.readyNowCount}',
          icon: Icons.play_circle_outline,
          color: const Color(0xFF059669),
        ),
        BillingReadinessMetric(
          label: 'Needs routing',
          value: '${queue.needsRoutingCount}',
          icon: Icons.route_outlined,
          color: const Color(0xFFD97706),
        ),
        BillingReadinessMetric(
          label: 'Blocked',
          value: '${queue.blockedCount}',
          icon: Icons.lock_clock_outlined,
          color: const Color(0xFFDC2626),
        ),
        BillingReadinessMetric(
          label: 'Total',
          value: '${queue.itemCount}',
          icon: Icons.queue_outlined,
          color: const Color(0xFF2563EB),
        ),
      ],
    );
  }
}
