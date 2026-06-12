import 'package:flutter/material.dart';

import '../utils/billing_business_domain_blueprint.dart';
import 'billing_business_domain_blueprint_card_components.dart';
import 'billing_business_domain_blueprint_card_styles.dart';

class BillingBusinessDomainBlueprintCard extends StatelessWidget {
  final BillingBusinessDomainBlueprint blueprint;

  const BillingBusinessDomainBlueprintCard({
    super.key,
    required this.blueprint,
  });

  @override
  Widget build(BuildContext context) {
    final status = BillingBlueprintStatusStyle.forBlueprint(blueprint);

    return Container(
      constraints: const BoxConstraints(minHeight: 292),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      blueprint.domainLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      blueprint.productModeLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              BillingBlueprintStatusPill(status: status),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              BillingBlueprintFactPill(
                icon: Icons.hub_outlined,
                label: blueprint.channelLabel,
                color: const Color(0xFF0F766E),
              ),
              BillingBlueprintFactPill(
                icon: Icons.route_outlined,
                label: billingBlueprintDestinationCountLabel(
                  blueprint.destinationCount,
                ),
                color: const Color(0xFF2563EB),
              ),
              BillingBlueprintFactPill(
                icon: Icons.bolt_outlined,
                label: billingBlueprintQuickActionCountLabel(
                  blueprint.quickActionCount,
                ),
                color: const Color(0xFF7C3AED),
              ),
            ],
          ),
          const SizedBox(height: 14),
          BillingBlueprintDefaultRouteRow(blueprint: blueprint),
          const SizedBox(height: 12),
          Column(
            children:
                blueprint.contracts
                    .map(
                      (contract) =>
                          BillingBlueprintContractRow(contract: contract),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }
}
