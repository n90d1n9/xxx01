import 'package:flutter/material.dart';

import '../utils/billing_product_package_release_bundle.dart';
import 'billing_domain_module_readiness_metric_strip.dart';
import 'billing_readiness_metric_collection.dart';

class BillingProductPackageReleaseBundleMetrics
    extends BillingReadinessMetricCollection {
  BillingProductPackageReleaseBundleMetrics({super.items});

  factory BillingProductPackageReleaseBundleMetrics.fromCatalog(
    BillingProductPackageReleaseBundleCatalog catalog,
  ) {
    return BillingProductPackageReleaseBundleMetrics(
      items: [
        BillingReadinessMetric(
          label: 'Bundles',
          value: '${catalog.bundleCount}',
          icon: Icons.all_inbox_outlined,
          color: const Color(0xFF2563EB),
        ),
        BillingReadinessMetric(
          label: 'Publish',
          value: '${catalog.publishNowManifestCount}',
          icon: Icons.publish_outlined,
          color: const Color(0xFF059669),
        ),
        BillingReadinessMetric(
          label: 'Review',
          value: '${catalog.reviewManifestCount}',
          icon: Icons.fact_check_outlined,
          color: const Color(0xFFD97706),
        ),
        BillingReadinessMetric(
          label: 'Blocked',
          value: '${catalog.blockedManifestCount}',
          icon: Icons.report_outlined,
          color: const Color(0xFFDC2626),
        ),
      ],
    );
  }
}
