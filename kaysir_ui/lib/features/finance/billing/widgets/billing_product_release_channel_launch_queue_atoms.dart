import 'package:flutter/material.dart';

import 'billing_product_release_channel_launch_queue.dart';

class BillingProductReleaseChannelLaunchQueueCountPill extends StatelessWidget {
  final int count;
  final BillingProductReleaseChannelLaunchQueueLaneTone tone;

  const BillingProductReleaseChannelLaunchQueueCountPill({
    super.key,
    required this.count,
    required this.tone,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tone.pillSurface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: tone.pillBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        child: Text(
          '$count',
          style: TextStyle(
            color: tone.iconColor,
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class BillingProductReleaseChannelLaunchQueueStatusPill
    extends StatelessWidget {
  final String label;
  final BillingProductReleaseChannelLaunchQueueLaneTone tone;

  const BillingProductReleaseChannelLaunchQueueStatusPill({
    super.key,
    required this.label,
    required this.tone,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tone.pillSurface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: tone.pillBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: tone.iconColor,
            fontSize: 10,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class BillingProductReleaseChannelLaunchQueueChecklistItem
    extends StatelessWidget {
  final String label;

  const BillingProductReleaseChannelLaunchQueueChecklistItem(
    this.label, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.task_alt_outlined,
            size: 14,
            color: Color(0xFF64748B),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF475569),
                fontSize: 11,
                height: 1.25,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BillingProductReleaseChannelLaunchQueueLaneEmptyText
    extends StatelessWidget {
  final String label;

  const BillingProductReleaseChannelLaunchQueueLaneEmptyText(
    this.label, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF64748B),
          fontSize: 12,
          height: 1.3,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class BillingProductReleaseChannelLaunchQueueOverflowText
    extends StatelessWidget {
  final int hiddenCount;

  const BillingProductReleaseChannelLaunchQueueOverflowText(
    this.hiddenCount, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Text(
        '$hiddenCount more ${hiddenCount == 1 ? 'task' : 'tasks'} queued.',
        style: const TextStyle(
          color: Color(0xFF64748B),
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class BillingProductReleaseChannelLaunchQueueLaneTone {
  final Color surface;
  final Color border;
  final Color iconSurface;
  final Color iconColor;
  final Color pillSurface;
  final Color pillBorder;
  final IconData icon;

  const BillingProductReleaseChannelLaunchQueueLaneTone({
    required this.surface,
    required this.border,
    required this.iconSurface,
    required this.iconColor,
    required this.pillSurface,
    required this.pillBorder,
    required this.icon,
  });
}

BillingProductReleaseChannelLaunchQueueLaneTone
billingProductReleaseChannelLaunchQueueToneForLane(
  BillingProductReleaseChannelLaunchQueueLane lane,
) {
  return switch (lane) {
    BillingProductReleaseChannelLaunchQueueLane.readyNow =>
      const BillingProductReleaseChannelLaunchQueueLaneTone(
        surface: Color(0xFFF0FDF4),
        border: Color(0xFFBBF7D0),
        iconSurface: Color(0xFFDCFCE7),
        iconColor: Color(0xFF047857),
        pillSurface: Color(0xFFD1FAE5),
        pillBorder: Color(0xFFA7F3D0),
        icon: Icons.play_circle_outline,
      ),
    BillingProductReleaseChannelLaunchQueueLane.needsRouting =>
      const BillingProductReleaseChannelLaunchQueueLaneTone(
        surface: Color(0xFFFFFBEB),
        border: Color(0xFFFDE68A),
        iconSurface: Color(0xFFFEF3C7),
        iconColor: Color(0xFFD97706),
        pillSurface: Color(0xFFFEF3C7),
        pillBorder: Color(0xFFFDE68A),
        icon: Icons.route_outlined,
      ),
    BillingProductReleaseChannelLaunchQueueLane.blocked =>
      const BillingProductReleaseChannelLaunchQueueLaneTone(
        surface: Color(0xFFFEF2F2),
        border: Color(0xFFFECACA),
        iconSurface: Color(0xFFFEE2E2),
        iconColor: Color(0xFFB91C1C),
        pillSurface: Color(0xFFFEE2E2),
        pillBorder: Color(0xFFFECACA),
        icon: Icons.lock_clock_outlined,
      ),
  };
}
