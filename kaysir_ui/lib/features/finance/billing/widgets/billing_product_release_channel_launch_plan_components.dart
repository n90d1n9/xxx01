import 'package:flutter/material.dart';

import '../utils/billing_product_release_channel.dart';
import 'billing_navigation_destination.dart';
import 'billing_product_release_channel_launch_action_feed.dart';
import 'billing_product_release_channel_launch_dispatch_plan.dart';
import 'billing_product_release_channel_launch_dispatch_presentation.dart';

class BillingProductReleaseChannelLaunchActionGrid extends StatelessWidget {
  final BillingProductReleaseChannelLaunchPlan launchPlan;
  final BillingProductReleaseChannelLaunchDispatchPlan? dispatchPlan;
  final ValueChanged<BillingNavigationDestinationId>? onDestinationSelected;

  const BillingProductReleaseChannelLaunchActionGrid({
    super.key,
    required this.launchPlan,
    this.dispatchPlan,
    this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final actionFeed = BillingProductReleaseChannelLaunchActionFeed.fromPlan(
      launchPlan: launchPlan,
      dispatchPlan: dispatchPlan,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 920;
        final itemWidth =
            isWide ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children:
              actionFeed.items
                  .map(
                    (item) => SizedBox(
                      width: itemWidth,
                      child: BillingProductReleaseChannelLaunchActionCard(
                        action: item.action,
                        dispatchEntry: item.dispatchEntry,
                        onDestinationSelected: onDestinationSelected,
                      ),
                    ),
                  )
                  .toList(),
        );
      },
    );
  }
}

class BillingProductReleaseChannelLaunchActionCard extends StatelessWidget {
  final BillingProductReleaseChannelLaunchAction action;
  final BillingProductReleaseChannelLaunchDispatchEntry? dispatchEntry;
  final ValueChanged<BillingNavigationDestinationId>? onDestinationSelected;

  const BillingProductReleaseChannelLaunchActionCard({
    super.key,
    required this.action,
    this.dispatchEntry,
    this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _laneColors(action.lane);

    return Container(
      constraints: const BoxConstraints(minHeight: 156),
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
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_laneIcon(action.lane), color: colors.foreground),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action.label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 14,
                        height: 1.2,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${action.channelLabel} - ${action.editionLabel}',
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
              _LaunchLaneBadge(action: action),
            ],
          ),
          const SizedBox(height: 12),
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
          if (dispatchEntry != null) ...[
            const SizedBox(height: 12),
            _LaunchDispatchFooter(
              entry: dispatchEntry!,
              onDestinationSelected: onDestinationSelected,
            ),
          ],
        ],
      ),
    );
  }
}

class _LaunchDispatchFooter extends StatelessWidget {
  final BillingProductReleaseChannelLaunchDispatchEntry entry;
  final ValueChanged<BillingNavigationDestinationId>? onDestinationSelected;

  const _LaunchDispatchFooter({
    required this.entry,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 360;
          final summary = _LaunchDispatchSummary(entry: entry);
          final button = _LaunchDispatchButton(
            entry: entry,
            onDestinationSelected: onDestinationSelected,
          );

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                summary,
                const SizedBox(height: 8),
                Align(alignment: Alignment.centerLeft, child: button),
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: summary),
              const SizedBox(width: 8),
              button,
            ],
          );
        },
      ),
    );
  }
}

class _LaunchDispatchSummary extends StatelessWidget {
  final BillingProductReleaseChannelLaunchDispatchEntry entry;

  const _LaunchDispatchSummary({required this.entry});

  @override
  Widget build(BuildContext context) {
    final presentation =
        BillingProductReleaseChannelLaunchDispatchPresentation.fromEntry(entry);

    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: presentation.backgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            presentation.icon,
            color: presentation.foregroundColor,
            size: 18,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                presentation.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                presentation.detail,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LaunchDispatchButton extends StatelessWidget {
  final BillingProductReleaseChannelLaunchDispatchEntry entry;
  final ValueChanged<BillingNavigationDestinationId>? onDestinationSelected;

  const _LaunchDispatchButton({
    required this.entry,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isActionable = entry.isActionable && onDestinationSelected != null;

    return TextButton.icon(
      onPressed:
          isActionable
              ? () => onDestinationSelected!(entry.destinationId)
              : null,
      icon: const Icon(Icons.open_in_new_outlined, size: 16),
      label: Text(entry.callToActionLabel, maxLines: 1),
      style: TextButton.styleFrom(
        minimumSize: const Size(0, 34),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _LaunchLaneBadge extends StatelessWidget {
  final BillingProductReleaseChannelLaunchAction action;

  const _LaunchLaneBadge({required this.action});

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
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
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

_LaneColors _laneColors(BillingProductReleaseChannelLaunchLane lane) {
  return switch (lane) {
    BillingProductReleaseChannelLaunchLane.publishNow => const _LaneColors(
      foreground: Color(0xFF047857),
      background: Color(0xFFD1FAE5),
      border: Color(0xFFA7F3D0),
    ),
    BillingProductReleaseChannelLaunchLane.review => const _LaneColors(
      foreground: Color(0xFFB45309),
      background: Color(0xFFFEF3C7),
      border: Color(0xFFFDE68A),
    ),
    BillingProductReleaseChannelLaunchLane.blocked => const _LaneColors(
      foreground: Color(0xFFB91C1C),
      background: Color(0xFFFEE2E2),
      border: Color(0xFFFECACA),
    ),
  };
}

IconData _laneIcon(BillingProductReleaseChannelLaunchLane lane) {
  return switch (lane) {
    BillingProductReleaseChannelLaunchLane.publishNow =>
      Icons.rocket_launch_outlined,
    BillingProductReleaseChannelLaunchLane.review => Icons.rule_folder_outlined,
    BillingProductReleaseChannelLaunchLane.blocked => Icons.report_outlined,
  };
}
