import 'package:flutter/material.dart';

import '../utils/billing_product_package_launch_playbook.dart';
import 'billing_domain_module_readiness_metric_strip.dart';
import 'billing_readiness_metric_collection.dart';

class BillingProductPackageLaunchPlaybookMetrics
    extends BillingReadinessMetricCollection {
  BillingProductPackageLaunchPlaybookMetrics({super.items});

  factory BillingProductPackageLaunchPlaybookMetrics.fromPlaybook(
    BillingProductPackageLaunchPlaybook playbook,
  ) {
    return BillingProductPackageLaunchPlaybookMetrics(
      items: [
        BillingReadinessMetric(
          label: 'Launch',
          value: '${playbook.packageNowCount}',
          icon: Icons.rocket_launch_outlined,
          color: const Color(0xFF059669),
        ),
        BillingReadinessMetric(
          label: 'Harden',
          value: '${playbook.hardenCount}',
          icon: Icons.build_circle_outlined,
          color: const Color(0xFFD97706),
        ),
        BillingReadinessMetric(
          label: 'Blocked',
          value: '${playbook.blockedCount}',
          icon: Icons.report_outlined,
          color: const Color(0xFFDC2626),
        ),
        BillingReadinessMetric(
          label: 'Fit',
          value: '${playbook.unavailableCount}',
          icon: Icons.rule_folder_outlined,
          color: const Color(0xFF475569),
        ),
      ],
    );
  }
}
