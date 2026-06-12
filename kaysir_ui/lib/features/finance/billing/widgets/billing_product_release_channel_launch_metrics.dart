import 'package:flutter/material.dart';

import '../utils/billing_product_release_channel.dart';
import 'billing_domain_module_readiness_metric_strip.dart';
import 'billing_product_release_channel_launch_dispatch_plan.dart';
import 'billing_readiness_metric_collection.dart';

class BillingProductReleaseChannelLaunchMetrics
    extends BillingReadinessMetricCollection {
  BillingProductReleaseChannelLaunchMetrics({super.items});

  factory BillingProductReleaseChannelLaunchMetrics.fromPlan({
    required BillingProductReleaseChannelLaunchPlan launchPlan,
    BillingProductReleaseChannelLaunchDispatchPlan? dispatchPlan,
  }) {
    return BillingProductReleaseChannelLaunchMetrics(
      items: [
        BillingReadinessMetric(
          label: 'Actions',
          value: '${launchPlan.actionCount}',
          icon: Icons.checklist_rtl_outlined,
          color: const Color(0xFF2563EB),
        ),
        BillingReadinessMetric(
          label: 'Launch',
          value: '${launchPlan.publishNowCount}',
          icon: Icons.rocket_launch_outlined,
          color: const Color(0xFF059669),
        ),
        BillingReadinessMetric(
          label: 'Review',
          value: '${launchPlan.reviewCount}',
          icon: Icons.rule_folder_outlined,
          color: const Color(0xFFD97706),
        ),
        BillingReadinessMetric(
          label: 'Blocked',
          value: '${launchPlan.blockedCount}',
          icon: Icons.report_outlined,
          color: const Color(0xFFDC2626),
        ),
        if (dispatchPlan != null)
          BillingReadinessMetric(
            label: 'Routes',
            value: '${dispatchPlan.actionableCount}',
            icon: Icons.near_me_outlined,
            color: const Color(0xFF7C3AED),
          ),
      ],
    );
  }
}
