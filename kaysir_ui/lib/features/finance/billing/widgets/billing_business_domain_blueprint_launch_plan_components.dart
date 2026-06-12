import 'package:flutter/material.dart';

import '../utils/billing_business_domain_blueprint_launch_plan.dart';

class BillingBlueprintLaunchPlanGrid extends StatelessWidget {
  final BillingBusinessDomainBlueprintLaunchPortfolio portfolio;

  const BillingBlueprintLaunchPlanGrid({super.key, required this.portfolio});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
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
                      child: BillingBlueprintLaunchPlanCard(plan: plan),
                    ),
                  )
                  .toList(),
        );
      },
    );
  }
}

class BillingBlueprintLaunchPlanCard extends StatelessWidget {
  final BillingBusinessDomainBlueprintLaunchPlan plan;

  const BillingBlueprintLaunchPlanCard({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    final primaryStep = plan.primaryStep;

    return Container(
      constraints: const BoxConstraints(minHeight: 246),
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
              _LaneIcon(lane: plan.lane),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.domainLabel,
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
                      '${plan.productModeLabel} · ${plan.channelLabel}',
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
              BillingBlueprintLaunchLaneBadge(plan: plan),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children:
                plan.supportedSignalLabels.isEmpty
                    ? [const _SignalChip(label: 'No fit signals')]
                    : plan.supportedSignalLabels
                        .map((label) => _SignalChip(label: label))
                        .toList(),
          ),
          const SizedBox(height: 14),
          if (primaryStep != null) _PrimaryStep(step: primaryStep),
          if (plan.steps.length > 1) ...[
            const SizedBox(height: 10),
            _SecondaryStepStrip(steps: plan.steps.skip(1).toList()),
          ],
        ],
      ),
    );
  }
}

class BillingBlueprintLaunchLaneBadge extends StatelessWidget {
  final BillingBusinessDomainBlueprintLaunchPlan plan;

  const BillingBlueprintLaunchLaneBadge({super.key, required this.plan});

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

class _LaneIcon extends StatelessWidget {
  final BillingBusinessDomainBlueprintLaunchLane lane;

  const _LaneIcon({required this.lane});

  @override
  Widget build(BuildContext context) {
    final colors = _laneColors(lane);
    final icon = switch (lane) {
      BillingBusinessDomainBlueprintLaunchLane.packageNow =>
        Icons.rocket_launch_outlined,
      BillingBusinessDomainBlueprintLaunchLane.harden =>
        Icons.build_circle_outlined,
      BillingBusinessDomainBlueprintLaunchLane.unblock => Icons.report_outlined,
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

class _PrimaryStep extends StatelessWidget {
  final BillingBusinessDomainBlueprintLaunchStep step;

  const _PrimaryStep({required this.step});

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
            size: 17,
            color: Color(0xFF2563EB),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.label,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  step.detail,
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

class _SecondaryStepStrip extends StatelessWidget {
  final List<BillingBusinessDomainBlueprintLaunchStep> steps;

  const _SecondaryStepStrip({required this.steps});

  @override
  Widget build(BuildContext context) {
    return Column(
      children:
          steps
              .take(2)
              .map(
                (step) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        size: 15,
                        color: Color(0xFF64748B),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          step.label,
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
                  ),
                ),
              )
              .toList(),
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

_LaneColors _laneColors(BillingBusinessDomainBlueprintLaunchLane lane) {
  return switch (lane) {
    BillingBusinessDomainBlueprintLaunchLane.packageNow => const _LaneColors(
      foreground: Color(0xFF047857),
      background: Color(0xFFD1FAE5),
      border: Color(0xFFA7F3D0),
    ),
    BillingBusinessDomainBlueprintLaunchLane.harden => const _LaneColors(
      foreground: Color(0xFFB45309),
      background: Color(0xFFFEF3C7),
      border: Color(0xFFFDE68A),
    ),
    BillingBusinessDomainBlueprintLaunchLane.unblock => const _LaneColors(
      foreground: Color(0xFFB91C1C),
      background: Color(0xFFFEE2E2),
      border: Color(0xFFFECACA),
    ),
  };
}
