import 'package:flutter/material.dart';

import '../experiences/pos_product_runtime_pack_switch_preview.dart';
import 'pos_switch_preview_pill.dart';

class POSRuntimePackSwitchPreviewSummary extends StatelessWidget {
  final POSProductRuntimePackSwitchPreview preview;
  final bool includeAvailability;

  const POSRuntimePackSwitchPreviewSummary({
    super.key,
    required this.preview,
    this.includeAvailability = false,
  });

  @override
  Widget build(BuildContext context) {
    final items = preview
        .compactItems()
        .where(
          (item) =>
              includeAvailability ||
              item.role !=
                  POSProductRuntimePackSwitchPreviewItemRole.availability,
        )
        .toList(growable: false);
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

  IconData _icon(POSProductRuntimePackSwitchPreviewItem item) {
    switch (item.role) {
      case POSProductRuntimePackSwitchPreviewItemRole.availability:
        switch (item.tone) {
          case POSProductRuntimePackSwitchPreviewItemTone.positive:
            return Icons.check_circle_outline;
          case POSProductRuntimePackSwitchPreviewItemTone.warning:
            return Icons.info_outline;
          case POSProductRuntimePackSwitchPreviewItemTone.danger:
            return Icons.block;
          case POSProductRuntimePackSwitchPreviewItemTone.neutral:
            return Icons.radio_button_checked;
        }
      case POSProductRuntimePackSwitchPreviewItemRole.order:
        if (item.tone == POSProductRuntimePackSwitchPreviewItemTone.danger) {
          return Icons.lock_outline;
        }
        return Icons.receipt_long_outlined;
      case POSProductRuntimePackSwitchPreviewItemRole.productLine:
        return Icons.inventory_2_outlined;
      case POSProductRuntimePackSwitchPreviewItemRole.layout:
        return Icons.splitscreen_outlined;
      case POSProductRuntimePackSwitchPreviewItemRole.selection:
        return Icons.compare_arrows_outlined;
      case POSProductRuntimePackSwitchPreviewItemRole.catalogScope:
        return Icons.apps_outlined;
    }
  }

  POSSwitchPreviewTone _tone(POSProductRuntimePackSwitchPreviewItemTone tone) {
    switch (tone) {
      case POSProductRuntimePackSwitchPreviewItemTone.positive:
        return POSSwitchPreviewTone.positive;
      case POSProductRuntimePackSwitchPreviewItemTone.warning:
        return POSSwitchPreviewTone.warning;
      case POSProductRuntimePackSwitchPreviewItemTone.danger:
        return POSSwitchPreviewTone.danger;
      case POSProductRuntimePackSwitchPreviewItemTone.neutral:
        return POSSwitchPreviewTone.neutral;
    }
  }
}
