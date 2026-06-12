import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/experiences/pos_commerce_channel.dart';
import 'chip_tone.dart';
import 'icon_label_chip.dart';
import 'text_badge.dart';
import 'tone.dart';

class ChannelChips extends StatelessWidget {
  final List<POSCommerceChannel> channels;
  final int? maxVisible;

  const ChannelChips({super.key, required this.channels, this.maxVisible});

  @override
  Widget build(BuildContext context) {
    if (channels.isEmpty) return const SizedBox.shrink();

    final visibleCount =
        maxVisible == null
            ? channels.length
            : maxVisible!.clamp(0, channels.length);
    final hiddenCount = channels.length - visibleCount;

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        ...channels
            .take(visibleCount)
            .map((channel) => ChannelChip(channel: channel)),
        if (hiddenCount > 0) _ChannelOverflowChip(hiddenCount: hiddenCount),
      ],
    );
  }
}

class ChannelChip extends StatelessWidget {
  final POSCommerceChannel channel;

  const ChannelChip({super.key, required this.channel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = tonalChipColors(
      theme.colorScheme,
      VisualTone.secondary,
      backgroundAlpha: 0.3,
      borderAlpha: 0.18,
    );

    return IconLabelChip(
      key: ValueKey('channel_${channel.id}'),
      icon: _iconForChannel(channel.kind),
      label: channel.label,
      colors: colors,
    );
  }
}

class _ChannelOverflowChip extends StatelessWidget {
  final int hiddenCount;

  const _ChannelOverflowChip({required this.hiddenCount});

  @override
  Widget build(BuildContext context) {
    final colors = mutedChipColors(Theme.of(context));

    return TextBadge(
      label: '+$hiddenCount channels',
      colors: colors,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    );
  }
}

IconData _iconForChannel(POSCommerceChannelKind kind) {
  return switch (kind) {
    POSCommerceChannelKind.inStore => Icons.storefront_outlined,
    POSCommerceChannelKind.kiosk => Icons.touch_app_outlined,
    POSCommerceChannelKind.mobilePOS => Icons.phone_iphone_outlined,
    POSCommerceChannelKind.webStore => Icons.language_outlined,
    POSCommerceChannelKind.marketplace => Icons.store_mall_directory_outlined,
    POSCommerceChannelKind.socialOrder => Icons.chat_bubble_outline,
    POSCommerceChannelKind.deliveryApp => Icons.delivery_dining_outlined,
    POSCommerceChannelKind.wholesale => Icons.business_center_outlined,
    POSCommerceChannelKind.fieldSales => Icons.badge_outlined,
    POSCommerceChannelKind.phoneOrder => Icons.call_outlined,
    POSCommerceChannelKind.tableService => Icons.table_restaurant_outlined,
  };
}
