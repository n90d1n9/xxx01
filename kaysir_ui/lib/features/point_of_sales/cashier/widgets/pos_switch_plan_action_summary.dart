import 'package:flutter/material.dart';

import 'pos_switch_preview_pill.dart';

class POSSwitchPlanActionSummaryItem {
  final IconData icon;
  final String label;
  final POSSwitchPreviewTone tone;

  const POSSwitchPlanActionSummaryItem({
    required this.icon,
    required this.label,
    this.tone = POSSwitchPreviewTone.neutral,
  });
}

class POSSwitchPlanActionSummary extends StatelessWidget {
  final List<POSSwitchPlanActionSummaryItem> items;

  const POSSwitchPlanActionSummary({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final item in items)
          POSSwitchPreviewPill(
            icon: item.icon,
            label: item.label,
            tone: item.tone,
          ),
      ],
    );
  }
}
