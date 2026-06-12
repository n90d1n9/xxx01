import 'package:flutter/material.dart';

import '../utils/billing_product_package_launch_playbook.dart';
import '../utils/billing_product_package_plan.dart';

class BillingProductPackageLaunchActionList extends StatelessWidget {
  final BillingProductPackageLaunchPlaybook playbook;
  final int maxVisibleActions;

  const BillingProductPackageLaunchActionList({
    super.key,
    required this.playbook,
    this.maxVisibleActions = 6,
  });

  @override
  Widget build(BuildContext context) {
    final actions = playbook.primaryActions
        .take(maxVisibleActions)
        .toList(growable: false);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        final itemWidth =
            isWide ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children:
              actions
                  .map(
                    (action) => SizedBox(
                      width: itemWidth,
                      child: BillingProductPackageLaunchActionTile(
                        action: action,
                      ),
                    ),
                  )
                  .toList(),
        );
      },
    );
  }
}

class BillingProductPackageLaunchActionTile extends StatelessWidget {
  final BillingProductPackageLaunchAction action;

  const BillingProductPackageLaunchActionTile({
    super.key,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 128),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LaunchActionIcon(action: action),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        action.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    BillingProductPackageLaunchLaneBadge(action: action),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${action.packageLabel} · ${action.domainLabel}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  action.detail,
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

class BillingProductPackageLaunchLaneBadge extends StatelessWidget {
  final BillingProductPackageLaunchAction action;

  const BillingProductPackageLaunchLaneBadge({super.key, required this.action});

  @override
  Widget build(BuildContext context) {
    final colors = _laneColors(action.lane);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Text(
          action.laneLabel,
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

class _LaunchActionIcon extends StatelessWidget {
  final BillingProductPackageLaunchAction action;

  const _LaunchActionIcon({required this.action});

  @override
  Widget build(BuildContext context) {
    final colors = _laneColors(action.lane);
    final icon = switch (action.kind) {
      BillingProductPackageLaunchActionKind.package =>
        Icons.rocket_launch_outlined,
      BillingProductPackageLaunchActionKind.harden =>
        Icons.build_circle_outlined,
      BillingProductPackageLaunchActionKind.unblock => Icons.report_outlined,
      BillingProductPackageLaunchActionKind.fitSignals =>
        Icons.rule_folder_outlined,
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
