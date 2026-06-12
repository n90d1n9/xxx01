import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/experiences/pos_commerce_channel.dart';
import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import 'detail_row.dart';
import 'empty_state.dart';
import 'profile_detail_line.dart';
import 'tone.dart';

class ProductProfileChannelList extends StatelessWidget {
  const ProductProfileChannelList({required this.channels, super.key});

  final List<POSCommerceChannel> channels;

  @override
  Widget build(BuildContext context) {
    if (channels.isEmpty) {
      return const EmptyState(
        message: 'No sales channels are registered for this profile.',
        prominent: true,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < channels.length; index++) ...[
          if (index > 0) const SizedBox(height: POSUiTokens.gapLarge),
          _ProductProfileChannelRow(channel: channels[index]),
        ],
      ],
    );
  }
}

class _ProductProfileChannelRow extends StatelessWidget {
  const _ProductProfileChannelRow({required this.channel});

  final POSCommerceChannel channel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = toneColors(
      theme.colorScheme,
      VisualTone.secondary,
      backgroundAlpha: 0.32,
    );

    return DetailRow(
      icon: _iconForChannel(channel.kind),
      title: channel.label,
      description: channel.description,
      iconColors: colors,
      iconBackgroundSource: ToneBackgroundSource.container,
      titleScale: DetailRowTitleScale.standard,
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ProfileDetailLine(
            label: 'Fulfillment',
            value: channel.fulfillmentSummary,
          ),
          ProfileDetailLine(
            label: 'Capabilities',
            value: channel.capabilitySummary,
          ),
          if (channel.traits.isNotEmpty)
            ProfileDetailLine(label: 'Traits', value: channel.traitSummary),
        ],
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
