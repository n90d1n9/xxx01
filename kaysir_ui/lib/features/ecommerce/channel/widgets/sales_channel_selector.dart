import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/experiences/pos_commerce_channel.dart';
import '../../../point_of_sales/cashier/widgets/pos_ui.dart';

class SalesChannelSelector extends StatelessWidget {
  final POSCommerceChannel selectedChannel;
  final List<POSCommerceChannel> channels;
  final ValueChanged<POSCommerceChannel> onChannelSelected;
  final bool compact;

  const SalesChannelSelector({
    super.key,
    required this.selectedChannel,
    required this.channels,
    required this.onChannelSelected,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (var index = 0; index < channels.length; index++) ...[
              if (index > 0) const SizedBox(width: POSUiTokens.gap),
              _ChannelPill(
                channel: channels[index],
                selected: channels[index].id == selectedChannel.id,
                onSelected: onChannelSelected,
              ),
            ],
          ],
        ),
      );
    }

    return Wrap(
      spacing: POSUiTokens.gap,
      runSpacing: POSUiTokens.gap,
      children:
          channels.map((channel) {
            return _ChannelPill(
              channel: channel,
              selected: channel.id == selectedChannel.id,
              onSelected: onChannelSelected,
            );
          }).toList(),
    );
  }
}

class _ChannelPill extends StatelessWidget {
  final POSCommerceChannel channel;
  final bool selected;
  final ValueChanged<POSCommerceChannel> onSelected;

  const _ChannelPill({
    required this.channel,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: ValueKey('channel_${channel.id}'),
      child: POSChoicePill(
        label: channel.label,
        selected: selected,
        onSelected: (_) => onSelected(channel),
      ),
    );
  }
}
