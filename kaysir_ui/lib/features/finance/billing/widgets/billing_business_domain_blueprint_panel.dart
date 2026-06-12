import 'package:flutter/material.dart';

import '../utils/billing_business_domain_blueprint.dart';
import 'billing_business_domain_blueprint_card.dart';
import 'billing_domain_module_readiness_frame.dart';
import 'billing_domain_module_readiness_metric_strip.dart';
import 'billing_empty_state.dart';

class BillingBusinessDomainBlueprintPanel extends StatelessWidget {
  final BillingBusinessDomainBlueprintRegistry registry;

  const BillingBusinessDomainBlueprintPanel({
    super.key,
    required this.registry,
  });

  @override
  Widget build(BuildContext context) {
    final blueprints = registry.blueprints;

    return BillingReadinessPanelScaffold(
      title: 'Product blueprints',
      summary:
          'Domain-ready product modes, channels, routes, and release contracts.',
      icon: Icons.view_quilt_outlined,
      iconColor: const Color(0xFF0F766E),
      iconBackgroundColor: const Color(0xFFF0FDFA),
      metrics: [
        BillingReadinessMetric(
          label: 'Blueprints',
          value: '${blueprints.length}',
          icon: Icons.account_tree_outlined,
          color: const Color(0xFF2563EB),
        ),
        BillingReadinessMetric(
          label: 'Ready',
          value: '${registry.launchReadyBlueprints.length}',
          icon: Icons.verified_outlined,
          color: const Color(0xFF059669),
        ),
        BillingReadinessMetric(
          label: 'Warnings',
          value: '${registry.warningContractCount}',
          icon: Icons.warning_amber_outlined,
          color: const Color(0xFFD97706),
        ),
        BillingReadinessMetric(
          label: 'Blockers',
          value: '${registry.blockerContractCount}',
          icon: Icons.report_outlined,
          color: const Color(0xFFDC2626),
        ),
      ],
      child:
          blueprints.isEmpty
              ? const _BlueprintEmptyState()
              : LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 920;
                  final itemWidth =
                      isWide
                          ? (constraints.maxWidth - 12) / 2
                          : constraints.maxWidth;

                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children:
                        blueprints
                            .map(
                              (blueprint) => SizedBox(
                                width: itemWidth,
                                child: BillingBusinessDomainBlueprintCard(
                                  blueprint: blueprint,
                                ),
                              ),
                            )
                            .toList(),
                  );
                },
              ),
    );
  }
}

class _BlueprintEmptyState extends StatelessWidget {
  const _BlueprintEmptyState();

  @override
  Widget build(BuildContext context) {
    return const BillingEmptyState(
      message: 'No billing product blueprints are registered yet.',
    );
  }
}
