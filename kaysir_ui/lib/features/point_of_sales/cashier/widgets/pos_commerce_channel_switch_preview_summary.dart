import 'package:flutter/material.dart';

import '../experiences/pos_commerce_channel_switch_preview.dart';
import 'pos_switch_preview_pill.dart';

class POSCommerceChannelSwitchPreviewSummary extends StatelessWidget {
  final POSCommerceChannelSwitchPreview preview;
  final bool includeAvailability;

  const POSCommerceChannelSwitchPreviewSummary({
    super.key,
    required this.preview,
    this.includeAvailability = false,
  });

  @override
  Widget build(BuildContext context) {
    final items = preview.compactItems(
      includeAvailability: includeAvailability,
    );
    if (items.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final item in items)
          POSSwitchPreviewPill(
            icon: _icon(item),
            label: item.label,
            tone: _tone(item.tone),
          ),
      ],
    );
  }

  IconData _icon(POSCommerceChannelSwitchPreviewItem item) {
    switch (item.role) {
      case POSCommerceChannelSwitchPreviewItemRole.availability:
        switch (item.tone) {
          case POSCommerceChannelSwitchPreviewItemTone.positive:
            return Icons.check_circle_outline;
          case POSCommerceChannelSwitchPreviewItemTone.warning:
            return Icons.info_outline;
          case POSCommerceChannelSwitchPreviewItemTone.danger:
            return Icons.block;
          case POSCommerceChannelSwitchPreviewItemTone.neutral:
            return Icons.radio_button_checked;
        }
      case POSCommerceChannelSwitchPreviewItemRole.order:
        return Icons.receipt_long_outlined;
      case POSCommerceChannelSwitchPreviewItemRole.layout:
        return Icons.splitscreen_outlined;
      case POSCommerceChannelSwitchPreviewItemRole.fulfillment:
        return Icons.local_shipping_outlined;
      case POSCommerceChannelSwitchPreviewItemRole.fulfillmentIssue:
        return Icons.assignment_late_outlined;
      case POSCommerceChannelSwitchPreviewItemRole.capabilityScope:
        return Icons.tune_outlined;
    }
  }

  POSSwitchPreviewTone _tone(POSCommerceChannelSwitchPreviewItemTone tone) {
    switch (tone) {
      case POSCommerceChannelSwitchPreviewItemTone.positive:
        return POSSwitchPreviewTone.positive;
      case POSCommerceChannelSwitchPreviewItemTone.warning:
        return POSSwitchPreviewTone.warning;
      case POSCommerceChannelSwitchPreviewItemTone.danger:
        return POSSwitchPreviewTone.danger;
      case POSCommerceChannelSwitchPreviewItemTone.neutral:
        return POSSwitchPreviewTone.neutral;
    }
  }
}
