import 'package:flutter/material.dart';

import 'report_visuals.dart';

/// Decorated icon badge for a report catalog card.
class InventoryReportIconBadge extends StatelessWidget {
  const InventoryReportIconBadge({super.key, required this.style});

  final InventoryReportVisuals style;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: style.color.withValues(alpha: 0.12),
        border: Border.all(color: style.color.withValues(alpha: 0.24)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Icon(style.icon, color: style.color, size: 22),
      ),
    );
  }
}
