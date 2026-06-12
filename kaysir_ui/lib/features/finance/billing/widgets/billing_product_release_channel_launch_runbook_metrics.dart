import 'package:flutter/material.dart';

import 'billing_domain_module_readiness_metric_strip.dart';
import 'billing_product_release_channel_launch_runbook.dart';
import 'billing_readiness_metric_collection.dart';

class BillingProductReleaseChannelLaunchRunbookMetrics
    extends BillingReadinessMetricCollection {
  BillingProductReleaseChannelLaunchRunbookMetrics({super.items});

  factory BillingProductReleaseChannelLaunchRunbookMetrics.fromRunbook(
    BillingProductReleaseChannelLaunchRunbook runbook,
  ) {
    return BillingProductReleaseChannelLaunchRunbookMetrics(
      items: [
        BillingReadinessMetric(
          label: 'Destinations',
          value: '${runbook.destinationCount}',
          icon: Icons.route_outlined,
          color: const Color(0xFF2563EB),
        ),
        BillingReadinessMetric(
          label: 'Steps',
          value: '${runbook.stepCount}',
          icon: Icons.fact_check_outlined,
          color: const Color(0xFF7C3AED),
        ),
        BillingReadinessMetric(
          label: 'Ready',
          value: '${runbook.actionableStepCount}',
          icon: Icons.check_circle_outline,
          color: const Color(0xFF059669),
        ),
        BillingReadinessMetric(
          label: 'Needs work',
          value: '${runbook.needsWorkStepCount}',
          icon: Icons.report_outlined,
          color: const Color(0xFFDC2626),
        ),
      ],
    );
  }
}
