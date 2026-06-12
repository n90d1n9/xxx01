import 'package:flutter/material.dart';

import '../utils/billing_business_domain_pack_remediation.dart';
import 'billing_business_domain_pack_remediation_components.dart';
import 'billing_domain_module_readiness_frame.dart';
import 'billing_domain_module_readiness_metric_strip.dart';
import 'billing_empty_state.dart';
import 'billing_navigation_destination.dart';

class BillingBusinessDomainPackRemediationPanel extends StatelessWidget {
  final BillingBusinessDomainPackRegistryRemediationPlan plan;
  final int maxVisibleActions;
  final ValueChanged<BillingNavigationDestinationId>? onDestinationSelected;

  const BillingBusinessDomainPackRemediationPanel({
    super.key,
    required this.plan,
    this.maxVisibleActions = 6,
    this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final visuals = _PackRemediationVisuals.fromPlan(plan);
    final visibleActions = plan.actions.take(maxVisibleActions).toList();

    return BillingReadinessFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BillingReadinessStatusIcon(
                icon: visuals.icon,
                color: visuals.color,
                backgroundColor: visuals.backgroundColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pack remediation plan',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      visuals.headline,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      plan.summaryLabel,
                      style: const TextStyle(
                        color: Color(0xFF475569),
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          BillingReadinessMetricStrip(metrics: _remediationMetrics(plan)),
          const SizedBox(height: 14),
          if (visibleActions.isEmpty)
            const _RemediationEmptyState()
          else
            BillingBusinessDomainPackRemediationActionList(
              actions: visibleActions,
              onDestinationSelected: onDestinationSelected,
            ),
          if (plan.actions.length > visibleActions.length) ...[
            const SizedBox(height: 10),
            Text(
              '${plan.actions.length - visibleActions.length} more '
              'remediation actions hidden',
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RemediationEmptyState extends StatelessWidget {
  const _RemediationEmptyState();

  @override
  Widget build(BuildContext context) {
    return const BillingEmptyState(
      message: 'No pack remediation actions are required.',
      padding: EdgeInsets.all(14),
    );
  }
}

class _PackRemediationVisuals {
  final String headline;
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  const _PackRemediationVisuals({
    required this.headline,
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });

  factory _PackRemediationVisuals.fromPlan(
    BillingBusinessDomainPackRegistryRemediationPlan plan,
  ) {
    if (plan.blockerActionCount > 0) {
      return const _PackRemediationVisuals(
        headline: 'Clear blockers first',
        icon: Icons.report_outlined,
        color: Color(0xFFB91C1C),
        backgroundColor: Color(0xFFFEE2E2),
      );
    }
    if (plan.warningActionCount > 0) {
      return const _PackRemediationVisuals(
        headline: 'Hardening recommended',
        icon: Icons.rule_folder_outlined,
        color: Color(0xFFB45309),
        backgroundColor: Color(0xFFFEF3C7),
      );
    }

    return const _PackRemediationVisuals(
      headline: 'No actions required',
      icon: Icons.verified_outlined,
      color: Color(0xFF047857),
      backgroundColor: Color(0xFFD1FAE5),
    );
  }
}

List<BillingReadinessMetric> _remediationMetrics(
  BillingBusinessDomainPackRegistryRemediationPlan plan,
) {
  return [
    BillingReadinessMetric(
      label: 'Actions',
      value: '${plan.actionCount}',
      icon: Icons.task_alt_outlined,
      color: const Color(0xFF2563EB),
    ),
    BillingReadinessMetric(
      label: 'Blockers',
      value: '${plan.blockerActionCount}',
      icon: Icons.error_outline,
      color: const Color(0xFFDC2626),
    ),
    BillingReadinessMetric(
      label: 'Warnings',
      value: '${plan.warningActionCount}',
      icon: Icons.info_outline_rounded,
      color: const Color(0xFFD97706),
    ),
    BillingReadinessMetric(
      label: 'Domains',
      value: '${plan.affectedDomainKeys.length}',
      icon: Icons.business_center_outlined,
      color: const Color(0xFF7C3AED),
    ),
  ];
}
