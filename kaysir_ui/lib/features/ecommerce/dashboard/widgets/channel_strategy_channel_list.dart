import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/experiences/pos_commerce_channel.dart';
import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import 'detail_row.dart';
import 'empty_state.dart';

class ChannelStrategyChannelList extends StatelessWidget {
  const ChannelStrategyChannelList({required this.channels, super.key});

  final Iterable<POSCommerceChannel> channels;

  @override
  Widget build(BuildContext context) {
    final channelList = channels.toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (channelList.isEmpty)
          const EmptyChannelStrategy()
        else
          ...channelList.map((channel) => ChannelStrategyRow(channel: channel)),
      ],
    );
  }
}

class ChannelStrategyRow extends StatelessWidget {
  const ChannelStrategyRow({required this.channel, super.key});

  final POSCommerceChannel channel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DetailRow(
      padding: const EdgeInsets.only(bottom: POSUiTokens.gapLarge),
      icon: _iconForChannel(channel.kind),
      title: channel.label,
      description: channel.description,
      iconBackgroundColor: theme.colorScheme.surfaceContainerHighest,
      iconForegroundColor: theme.colorScheme.onSurfaceVariant,
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _ChannelDetailLine(
            label: 'Fulfillment',
            value: channel.fulfillmentSummary,
          ),
          _ChannelDetailLine(
            label: 'Capabilities',
            value: channel.capabilitySummary,
          ),
          if (channel.traits.isNotEmpty)
            _ChannelDetailLine(label: 'Traits', value: channel.traitSummary),
        ],
      ),
    );
  }
}

class EmptyChannelStrategy extends StatelessWidget {
  const EmptyChannelStrategy({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      message: 'No sales channels are registered for this profile.',
      prominent: true,
    );
  }
}

class _ChannelDetailLine extends StatelessWidget {
  const _ChannelDetailLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Text(
        '$label: $value',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w700,
        ),
      ),
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
