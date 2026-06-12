import 'package:flutter/material.dart';

import '../utils/billing_product_release_edition.dart';
import 'billing_product_release_edition_visuals.dart';

class BillingProductReleaseEditionGrid extends StatelessWidget {
  final BillingProductReleaseEditionCatalog catalog;

  const BillingProductReleaseEditionGrid({super.key, required this.catalog});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 920;
        final itemWidth =
            isWide ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children:
              catalog.plans
                  .map(
                    (plan) => SizedBox(
                      width: itemWidth,
                      child: BillingProductReleaseEditionCard(plan: plan),
                    ),
                  )
                  .toList(),
        );
      },
    );
  }
}

class BillingProductReleaseEditionCard extends StatelessWidget {
  final BillingProductReleaseEditionPlan plan;

  const BillingProductReleaseEditionCard({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 250),
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
              BillingProductReleaseEditionStateIcon(state: plan.state),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.label,
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
                      '${plan.audienceLabel} - ${plan.id}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              BillingProductReleaseEditionStateBadge(plan: plan),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            plan.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF475569),
              fontSize: 12,
              height: 1.35,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _EditionPackageGroups(plan: plan),
          const SizedBox(height: 12),
          _EditionActionBlock(plan: plan),
        ],
      ),
    );
  }
}

class _EditionPackageGroups extends StatelessWidget {
  final BillingProductReleaseEditionPlan plan;

  const _EditionPackageGroups({required this.plan});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ReleaseKeyGroup(
          label: 'Core packages',
          values: plan.requiredReleaseKeys,
          fallbackValues: plan.missingRequiredPackageKeys,
          fallbackPrefix: 'missing',
          color: const Color(0xFFEFF6FF),
          border: const Color(0xFFBFDBFE),
          foreground: const Color(0xFF1D4ED8),
        ),
        if (plan.optionalReleaseKeys.isNotEmpty) ...[
          const SizedBox(height: 8),
          _ReleaseKeyGroup(
            label: 'Add-ons',
            values: plan.optionalReleaseKeys,
            color: const Color(0xFFF0FDF4),
            border: const Color(0xFFBBF7D0),
            foreground: const Color(0xFF15803D),
          ),
        ],
      ],
    );
  }
}

class _ReleaseKeyGroup extends StatelessWidget {
  final String label;
  final List<String> values;
  final List<String> fallbackValues;
  final String fallbackPrefix;
  final Color color;
  final Color border;
  final Color foreground;

  const _ReleaseKeyGroup({
    required this.label,
    required this.values,
    required this.color,
    required this.border,
    required this.foreground,
    this.fallbackValues = const [],
    this.fallbackPrefix = '',
  });

  @override
  Widget build(BuildContext context) {
    final chipLabels = [
      ...values,
      ...fallbackValues.map(
        (value) => fallbackPrefix.isEmpty ? value : '$fallbackPrefix:$value',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children:
              chipLabels
                  .take(4)
                  .map(
                    (chipLabel) => _ReleaseKeyChip(
                      label: chipLabel,
                      color: color,
                      border: border,
                      foreground: foreground,
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }
}

class _ReleaseKeyChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color border;
  final Color foreground;

  const _ReleaseKeyChip({
    required this.label,
    required this.color,
    required this.border,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: foreground,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _EditionActionBlock extends StatelessWidget {
  final BillingProductReleaseEditionPlan plan;

  const _EditionActionBlock({required this.plan});

  @override
  Widget build(BuildContext context) {
    final colors = billingProductReleaseEditionStateColors(plan.state);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.arrow_forward_outlined,
            size: 17,
            color: colors.foreground,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.actionLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  plan.actionDetail,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 12,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
