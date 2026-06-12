import 'package:flutter/material.dart';

import '../utils/billing_product_package_release_manifest.dart';
import 'billing_domain_module_readiness_metric_strip.dart';
import 'billing_readiness_metric_collection.dart';

class BillingProductPackageReleaseManifestMetrics
    extends BillingReadinessMetricCollection {
  BillingProductPackageReleaseManifestMetrics({super.items});

  factory BillingProductPackageReleaseManifestMetrics.fromCatalog(
    BillingProductPackageReleaseManifestCatalog catalog,
  ) {
    return BillingProductPackageReleaseManifestMetrics(
      items: [
        BillingReadinessMetric(
          label: 'Manifests',
          value: '${catalog.manifestCount}',
          icon: Icons.assignment_outlined,
          color: const Color(0xFF2563EB),
        ),
        BillingReadinessMetric(
          label: 'Ready',
          value: '${catalog.releaseReadyCount}',
          icon: Icons.assignment_turned_in_outlined,
          color: const Color(0xFF059669),
        ),
        BillingReadinessMetric(
          label: 'Harden',
          value: '${catalog.hardeningCount}',
          icon: Icons.build_circle_outlined,
          color: const Color(0xFFD97706),
        ),
        BillingReadinessMetric(
          label: 'Gaps',
          value: '${catalog.blockedCount + catalog.fitGapCount}',
          icon: Icons.report_outlined,
          color: const Color(0xFFDC2626),
        ),
      ],
    );
  }
}
