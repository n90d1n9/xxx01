import 'package:flutter/material.dart';

import 'billing_empty_state.dart';
import 'billing_navigation_destination.dart';
import 'billing_product_release_channel_launch_queue.dart';
import 'billing_product_release_channel_launch_queue_atoms.dart';

class BillingProductReleaseChannelLaunchQueueLaneList extends StatelessWidget {
  final BillingProductReleaseChannelLaunchQueue queue;
  final ValueChanged<BillingNavigationDestinationId>? onDestinationSelected;

  const BillingProductReleaseChannelLaunchQueueLaneList({
    super.key,
    required this.queue,
    this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 980;
        final itemWidth =
            isWide ? (constraints.maxWidth - 24) / 3 : constraints.maxWidth;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: queue.lanes
              .map((lane) {
                return SizedBox(
                  width: itemWidth,
                  child: _QueueLaneSection(
                    lane: lane,
                    onDestinationSelected: onDestinationSelected,
                  ),
                );
              })
              .toList(growable: false),
        );
      },
    );
  }
}

class BillingProductReleaseChannelLaunchQueueEmptyState
    extends StatelessWidget {
  const BillingProductReleaseChannelLaunchQueueEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const BillingEmptyState(
      message: 'No channel launch tasks are queued yet.',
    );
  }
}

class _QueueLaneSection extends StatelessWidget {
  final BillingProductReleaseChannelLaunchQueueLaneGroup lane;
  final ValueChanged<BillingNavigationDestinationId>? onDestinationSelected;

  const _QueueLaneSection({required this.lane, this.onDestinationSelected});

  @override
  Widget build(BuildContext context) {
    final visibleItems = lane.items.take(4).toList(growable: false);
    final hiddenCount = lane.itemCount - visibleItems.length;
    final tone = billingProductReleaseChannelLaunchQueueToneForLane(lane.lane);

    return Container(
      constraints: const BoxConstraints(minHeight: 220),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tone.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: tone.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: tone.iconSurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(tone.icon, color: tone.iconColor, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lane.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      lane.summaryLabel,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 11,
                        height: 1.25,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              BillingProductReleaseChannelLaunchQueueCountPill(
                count: lane.itemCount,
                tone: tone,
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (visibleItems.isEmpty)
            BillingProductReleaseChannelLaunchQueueLaneEmptyText(
              lane.emptyLabel,
            )
          else ...[
            ...visibleItems.map(
              (item) => _QueueItemTile(
                item: item,
                tone: tone,
                onDestinationSelected: onDestinationSelected,
              ),
            ),
            if (hiddenCount > 0)
              BillingProductReleaseChannelLaunchQueueOverflowText(hiddenCount),
          ],
        ],
      ),
    );
  }
}

class _QueueItemTile extends StatelessWidget {
  final BillingProductReleaseChannelLaunchQueueItem item;
  final BillingProductReleaseChannelLaunchQueueLaneTone tone;
  final ValueChanged<BillingNavigationDestinationId>? onDestinationSelected;

  const _QueueItemTile({
    required this.item,
    required this.tone,
    this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final checklistItems = item.checklistItems.take(2).toList(growable: false);

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
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
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 12,
                        height: 1.25,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.destinationLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: tone.iconColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.detail,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 11,
                        height: 1.3,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              BillingProductReleaseChannelLaunchQueueStatusPill(
                label: item.statusLabel,
                tone: tone,
              ),
            ],
          ),
          if (checklistItems.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...checklistItems.map(
              BillingProductReleaseChannelLaunchQueueChecklistItem.new,
            ),
          ],
          if (item.isReady && onDestinationSelected != null) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed:
                    () => onDestinationSelected?.call(item.destinationId),
                icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                label: Text(item.callToActionLabel),
                style: TextButton.styleFrom(
                  foregroundColor: tone.iconColor,
                  minimumSize: const Size(0, 34),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
