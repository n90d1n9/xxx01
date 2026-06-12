import 'package:flutter/material.dart';

import '../utils/billing_product_package_plan.dart';

class BillingProductPackageGrid extends StatelessWidget {
  final BillingProductPackagePortfolio portfolio;

  const BillingProductPackageGrid({super.key, required this.portfolio});

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
              portfolio.plans
                  .map(
                    (plan) => SizedBox(
                      width: itemWidth,
                      child: BillingProductPackageCard(plan: plan),
                    ),
                  )
                  .toList(),
        );
      },
    );
  }
}

class BillingProductPackageCard extends StatelessWidget {
  final BillingProductPackagePlan plan;

  const BillingProductPackageCard({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 254),
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
              _PackageIcon(lane: plan.lane),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.package.label,
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
                      plan.package.audienceLabel,
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
              BillingProductPackageLaneBadge(plan: plan),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            plan.package.description,
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
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children:
                plan.requiredSignalLabels
                    .map((label) => _SignalChip(label: label))
                    .toList(),
          ),
          const SizedBox(height: 12),
          _PackageDomainRow(plan: plan),
          const SizedBox(height: 10),
          _PackageActionBlock(plan: plan),
        ],
      ),
    );
  }
}

class BillingProductPackageLaneBadge extends StatelessWidget {
  final BillingProductPackagePlan plan;

  const BillingProductPackageLaneBadge({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    final colors = _laneColors(plan.lane);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        child: Text(
          plan.laneLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: colors.foreground,
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _PackageIcon extends StatelessWidget {
  final BillingProductPackageLane lane;

  const _PackageIcon({required this.lane});

  @override
  Widget build(BuildContext context) {
    final colors = _laneColors(lane);
    final icon = switch (lane) {
      BillingProductPackageLane.packageNow => Icons.inventory_2_outlined,
      BillingProductPackageLane.harden => Icons.build_circle_outlined,
      BillingProductPackageLane.unblock => Icons.report_outlined,
      BillingProductPackageLane.unavailable => Icons.extension_off_outlined,
    };

    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: colors.foreground, size: 21),
    );
  }
}

class _SignalChip extends StatelessWidget {
  final String label;

  const _SignalChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF1D4ED8),
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _PackageDomainRow extends StatelessWidget {
  final BillingProductPackagePlan plan;

  const _PackageDomainRow({required this.plan});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.account_tree_outlined,
          color: Color(0xFF64748B),
          size: 16,
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            '${plan.domainSummary} · ${plan.package.channelLabel}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _PackageActionBlock extends StatelessWidget {
  final BillingProductPackagePlan plan;

  const _PackageActionBlock({required this.plan});

  @override
  Widget build(BuildContext context) {
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
          const Icon(
            Icons.arrow_forward_outlined,
            color: Color(0xFF2563EB),
            size: 17,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.primaryActionLabel,
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
                  plan.primaryActionDetail,
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

class _LaneColors {
  final Color foreground;
  final Color background;
  final Color border;

  const _LaneColors({
    required this.foreground,
    required this.background,
    required this.border,
  });
}

_LaneColors _laneColors(BillingProductPackageLane lane) {
  return switch (lane) {
    BillingProductPackageLane.packageNow => const _LaneColors(
      foreground: Color(0xFF047857),
      background: Color(0xFFD1FAE5),
      border: Color(0xFFA7F3D0),
    ),
    BillingProductPackageLane.harden => const _LaneColors(
      foreground: Color(0xFFB45309),
      background: Color(0xFFFEF3C7),
      border: Color(0xFFFDE68A),
    ),
    BillingProductPackageLane.unblock => const _LaneColors(
      foreground: Color(0xFFB91C1C),
      background: Color(0xFFFEE2E2),
      border: Color(0xFFFECACA),
    ),
    BillingProductPackageLane.unavailable => const _LaneColors(
      foreground: Color(0xFF475569),
      background: Color(0xFFF1F5F9),
      border: Color(0xFFCBD5E1),
    ),
  };
}
