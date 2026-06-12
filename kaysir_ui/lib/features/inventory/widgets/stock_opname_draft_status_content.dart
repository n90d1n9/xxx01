import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_status_pill.dart';
import 'inventory_stock_opname_draft_status_details.dart';
import 'stock_opname_draft_status_preview_data.dart';
import 'stock_opname_draft_status_visuals.dart';

/// Text, icon, and badge cluster used inside the stock opname draft banner.
class InventoryStockOpnameDraftStatusContent extends StatelessWidget {
  const InventoryStockOpnameDraftStatusContent({
    super.key,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.badges,
  });

  final String title;
  final String subtitle;
  final Color accentColor;
  final List<InventoryStockOpnameDraftStatusBadgeDetails> badges;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.edit_note_rounded, color: accentColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final badge in badges)
                    AppStatusPill(
                      label: badge.label,
                      icon: inventoryStockOpnameDraftBadgeIcon(badge.tone),
                      color: inventoryStockOpnameDraftBadgeColor(
                        colorScheme,
                        badge.tone,
                      ),
                      maxWidth: 180,
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

@Preview(name: 'Inventory stock opname draft status content')
Widget inventoryStockOpnameDraftStatusContentPreview() {
  return inventoryStockOpnameDraftStatusPreviewScaffold(
    Builder(
      builder: (context) {
        final details = inventoryStockOpnameDraftStatusPreviewDetails();
        final colorScheme = Theme.of(context).colorScheme;

        return InventoryStockOpnameDraftStatusContent(
          title: details.title,
          subtitle: details.subtitle,
          accentColor: inventoryStockOpnameDraftAccentColor(
            colorScheme,
            details,
          ),
          badges: details.badges,
        );
      },
    ),
  );
}
