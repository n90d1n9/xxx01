import 'package:flutter/material.dart';

import '../utils/billing_product_release_edition.dart';
import 'billing_domain_module_readiness_metric_strip.dart';
import 'billing_readiness_metric_collection.dart';

class BillingProductReleaseEditionMetrics
    extends BillingReadinessMetricCollection {
  BillingProductReleaseEditionMetrics({super.items});

  factory BillingProductReleaseEditionMetrics.fromCatalog(
    BillingProductReleaseEditionCatalog catalog,
  ) {
    return BillingProductReleaseEditionMetrics(
      items: [
        BillingReadinessMetric(
          label: 'Editions',
          value: '${catalog.editionCount}',
          icon: Icons.view_carousel_outlined,
          color: const Color(0xFF2563EB),
        ),
        BillingReadinessMetric(
          label: 'Publish',
          value: '${catalog.publishNowCount}',
          icon: Icons.rocket_launch_outlined,
          color: const Color(0xFF059669),
        ),
        BillingReadinessMetric(
          label: 'Review',
          value: '${catalog.reviewCount}',
          icon: Icons.rule_folder_outlined,
          color: const Color(0xFFD97706),
        ),
        BillingReadinessMetric(
          label: 'Blocked',
          value: '${catalog.blockedOrIncompleteCount}',
          icon: Icons.report_outlined,
          color: const Color(0xFFDC2626),
        ),
      ],
    );
  }
}
