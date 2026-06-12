import 'package:flutter/material.dart';

import '../experiences/pos_mode_switch_preview.dart';
import 'pos_switch_preview_pill.dart';

class POSModeSwitchPreviewSummary extends StatelessWidget {
  final POSModeSwitchPreview preview;
  final int featureChangeLimit;

  const POSModeSwitchPreviewSummary({
    super.key,
    required this.preview,
    this.featureChangeLimit = 3,
  });

  @override
  Widget build(BuildContext context) {
    final items = preview.compactItems(featureChangeLimit: featureChangeLimit);
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

  IconData _icon(POSModeSwitchPreviewItem item) {
    switch (item.role) {
      case POSModeSwitchPreviewItemRole.availability:
        switch (item.tone) {
          case POSModeSwitchPreviewItemTone.positive:
            return Icons.check_circle_outline;
          case POSModeSwitchPreviewItemTone.warning:
            return Icons.info_outline;
          case POSModeSwitchPreviewItemTone.danger:
            return Icons.block;
          case POSModeSwitchPreviewItemTone.neutral:
            return Icons.radio_button_checked;
        }
      case POSModeSwitchPreviewItemRole.order:
        if (item.tone == POSModeSwitchPreviewItemTone.danger) {
          return Icons.lock_outline;
        }
        return Icons.receipt_long_outlined;
      case POSModeSwitchPreviewItemRole.layout:
        return Icons.splitscreen_outlined;
      case POSModeSwitchPreviewItemRole.featureSummary:
        return Icons.compare_arrows_outlined;
      case POSModeSwitchPreviewItemRole.featureChange:
        return item.tone == POSModeSwitchPreviewItemTone.positive
            ? Icons.add_circle_outline
            : Icons.remove_circle_outline;
    }
  }

  POSSwitchPreviewTone _tone(POSModeSwitchPreviewItemTone tone) {
    switch (tone) {
      case POSModeSwitchPreviewItemTone.positive:
        return POSSwitchPreviewTone.positive;
      case POSModeSwitchPreviewItemTone.warning:
        return POSSwitchPreviewTone.warning;
      case POSModeSwitchPreviewItemTone.danger:
        return POSSwitchPreviewTone.danger;
      case POSModeSwitchPreviewItemTone.neutral:
        return POSSwitchPreviewTone.neutral;
    }
  }
}
