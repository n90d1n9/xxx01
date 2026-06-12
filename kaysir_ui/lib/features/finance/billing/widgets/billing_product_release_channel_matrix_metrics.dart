import 'package:flutter/material.dart';

import '../utils/billing_product_release_channel.dart';
import 'billing_domain_module_readiness_metric_strip.dart';
import 'billing_readiness_metric_collection.dart';

class BillingProductReleaseChannelMatrixMetrics
    extends BillingReadinessMetricCollection {
  BillingProductReleaseChannelMatrixMetrics({super.items});

  factory BillingProductReleaseChannelMatrixMetrics.fromMatrix(
    BillingProductReleaseChannelMatrix matrix,
  ) {
    return BillingProductReleaseChannelMatrixMetrics(
      items: [
        BillingReadinessMetric(
          label: 'Channels',
          value: '${matrix.channelCount}',
          icon: Icons.hub_outlined,
          color: const Color(0xFF2563EB),
        ),
        BillingReadinessMetric(
          label: 'Publish',
          value: '${matrix.publishNowCellCount}',
          icon: Icons.rocket_launch_outlined,
          color: const Color(0xFF059669),
        ),
        BillingReadinessMetric(
          label: 'Review',
          value: '${matrix.reviewCellCount}',
          icon: Icons.rule_folder_outlined,
          color: const Color(0xFFD97706),
        ),
        BillingReadinessMetric(
          label: 'Blocked',
          value: '${matrix.blockedCellCount}',
          icon: Icons.report_outlined,
          color: const Color(0xFFDC2626),
        ),
      ],
    );
  }
}
