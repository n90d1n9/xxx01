import 'package:flutter/material.dart';

import '../utils/billing_business_domain_blueprint_launch_plan.dart';
import 'billing_business_domain_blueprint_launch_plan_components.dart';
import 'billing_domain_module_readiness_frame.dart';
import 'billing_domain_module_readiness_metric_strip.dart';
import 'billing_empty_state.dart';

class BillingBusinessDomainBlueprintLaunchPlanPanel extends StatelessWidget {
  final BillingBusinessDomainBlueprintLaunchPortfolio portfolio;

  const BillingBusinessDomainBlueprintLaunchPlanPanel({
    super.key,
    required this.portfolio,
  });

  @override
  Widget build(BuildContext context) {
    return BillingReadinessPanelScaffold(
      title: 'Product launch plan',
      summary: portfolio.summaryLabel,
      icon: Icons.rocket_launch_outlined,
      iconColor: const Color(0xFF059669),
      iconBackgroundColor: const Color(0xFFECFDF5),
      metrics: [
        BillingReadinessMetric(
          label: 'Domains',
          value: '${portfolio.domainCount}',
          icon: Icons.account_tree_outlined,
          color: const Color(0xFF2563EB),
        ),
        BillingReadinessMetric(
          label: 'Package',
          value: '${portfolio.packageCount}',
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
      child:
          portfolio.isEmpty
              ? const _LaunchPlanEmptyState()
              : BillingBlueprintLaunchPlanGrid(portfolio: portfolio),
    );
  }
}

class _LaunchPlanEmptyState extends StatelessWidget {
  const _LaunchPlanEmptyState();

  @override
  Widget build(BuildContext context) {
    return const BillingEmptyState(
      message: 'No billing product launch plans are available yet.',
    );
  }
}
