import 'package:flutter/material.dart';

import '../utils/billing_product_package_plan.dart';
import 'billing_domain_module_readiness_metric_strip.dart';
import 'billing_readiness_metric_collection.dart';

class BillingProductPackageMetrics extends BillingReadinessMetricCollection {
  BillingProductPackageMetrics({super.items});

  factory BillingProductPackageMetrics.fromPortfolio(
    BillingProductPackagePortfolio portfolio,
  ) {
    return BillingProductPackageMetrics(
      items: [
        BillingReadinessMetric(
          label: 'Packages',
          value: '${portfolio.packageCount}',
          icon: Icons.inventory_2_outlined,
          color: const Color(0xFF2563EB),
        ),
        BillingReadinessMetric(
          label: 'Package',
          value: '${portfolio.packageNowCount}',
          icon: Icons.rocket_launch_outlined,
          color: const Color(0xFF059669),
        ),
        BillingReadinessMetric(
          label: 'Harden',
          value: '${portfolio.hardenCount}',
          icon: Icons.build_circle_outlined,
          color: const Color(0xFFD97706),
        ),
        BillingReadinessMetric(
          label: 'Blocked',
          value: '${portfolio.blockedCount}',
          icon: Icons.report_outlined,
          color: const Color(0xFFDC2626),
        ),
      ],
    );
  }
}
