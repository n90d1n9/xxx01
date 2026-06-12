import 'package:flutter/material.dart';

import '../utils/billing_business_domain_blueprint.dart';
import 'billing_business_domain_blueprint_card_styles.dart';

class BillingBlueprintDefaultRouteRow extends StatelessWidget {
  final BillingBusinessDomainBlueprint blueprint;

  const BillingBlueprintDefaultRouteRow({super.key, required this.blueprint});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.near_me_outlined,
            size: 18,
            color: Color(0xFF475569),
          ),
          const SizedBox(width: 8),
          const Text(
            'Default route',
            style: TextStyle(
              color: Color(0xFF475569),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              billingBlueprintDestinationLabel(
                blueprint.defaultDestinationId.name,
              ),
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BillingBlueprintContractRow extends StatelessWidget {
  final BillingBusinessDomainBlueprintContract contract;

  const BillingBlueprintContractRow({super.key, required this.contract});

  @override
  Widget build(BuildContext context) {
    final style = BillingBlueprintContractStateStyle.forContract(contract);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: style.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(style.icon, size: 16, color: style.color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              contract.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF334155),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            contract.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: style.color,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class BillingBlueprintStatusPill extends StatelessWidget {
  final BillingBlueprintStatusStyle status;

  const BillingBlueprintStatusPill({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: status.background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: status.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(status.icon, color: status.color, size: 15),
            const SizedBox(width: 5),
            Text(
              status.label,
              style: TextStyle(
                color: status.color,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BillingBlueprintFactPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const BillingBlueprintFactPill({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 15),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
