import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import 'inventory_tile_surface.dart';

/// Reusable value-bar row for inventory analytics breakdown panels.
class InventoryAnalyticsValueBarRow extends StatelessWidget {
  const InventoryAnalyticsValueBarRow({
    super.key,
    required this.label,
    required this.valueLabel,
    required this.helper,
    required this.percent,
    required this.color,
  });

  final String label;
  final String valueLabel;
  final String helper;
  final double percent;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InventoryTileSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                valueLabel,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: percent.clamp(0, 1),
              minHeight: 9,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            helper,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Returns the standard analytics breakdown color for an ordered row.
Color inventoryAnalyticsValuePaletteColor(BuildContext context, int index) {
  final colorScheme = Theme.of(context).colorScheme;
  final colors = [
    colorScheme.primary,
    Colors.teal.shade700,
    Colors.indigo.shade700,
    Colors.orange.shade700,
    Colors.pink.shade700,
    Colors.blueGrey.shade700,
  ];
  return colors[index % colors.length];
}

@Preview(name: 'Inventory analytics value bar row')
Widget inventoryAnalyticsValueBarRowPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Builder(
          builder: (context) {
            return InventoryAnalyticsValueBarRow(
              label: 'Electronics',
              valueLabel: r'$12,500.00',
              helper: '32 units | 8 products',
              percent: 0.72,
              color: inventoryAnalyticsValuePaletteColor(context, 0),
            );
          },
        ),
      ),
    ),
  );
}
