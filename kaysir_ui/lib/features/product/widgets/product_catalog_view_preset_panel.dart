import 'package:flutter/material.dart';

import '../../../widgets/ui/app_content_panel.dart';
import '../../../widgets/ui/app_status_pill.dart';
import '../../inventory/models/inventory_product_catalog.dart';
import '../models/product_catalog_view_preset.dart';

class ProductCatalogViewPresetPanel extends StatelessWidget {
  const ProductCatalogViewPresetPanel({
    super.key,
    required this.summary,
    required this.onSelected,
  });

  final InventoryProductCatalogSummary summary;
  final ValueChanged<ProductCatalogViewPreset> onSelected;

  @override
  Widget build(BuildContext context) {
    final presets = buildProductCatalogViewPresets(summary);

    return AppContentPanel(
      title: 'Catalog views',
      subtitle: 'Curated product health queues for daily operations',
      leadingIcon: Icons.dashboard_customize_rounded,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columnCount =
              constraints.maxWidth >= 980
                  ? 4
                  : constraints.maxWidth >= 620
                  ? 2
                  : 1;
          const gap = 12.0;
          final cardWidth =
              (constraints.maxWidth - (gap * (columnCount - 1))) / columnCount;

          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [
              for (final preset in presets)
                SizedBox(
                  width: cardWidth,
                  child: _ProductCatalogViewPresetCard(
                    preset: preset,
                    onPressed: () => onSelected(preset),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ProductCatalogViewPresetCard extends StatelessWidget {
  const _ProductCatalogViewPresetCard({
    required this.preset,
    required this.onPressed,
  });

  final ProductCatalogViewPreset preset;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = _accentColor(preset.id);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: accent.withValues(alpha: 0.24)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onPressed,
        child: SizedBox(
          height: 154,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Icon(_icon(preset.id), color: accent, size: 20),
                      ),
                    ),
                    const Spacer(),
                    AppStatusPill(
                      label: preset.countLabel,
                      color: accent,
                      maxWidth: 104,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  preset.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Text(
                  preset.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        preset.intentLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(
                          context,
                        ).textTheme.labelMedium?.copyWith(
                          color: accent,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

IconData _icon(ProductCatalogViewPresetId id) {
  switch (id) {
    case ProductCatalogViewPresetId.allProducts:
      return Icons.inventory_2_rounded;
    case ProductCatalogViewPresetId.attentionQueue:
      return Icons.warning_amber_rounded;
    case ProductCatalogViewPresetId.inStock:
      return Icons.check_circle_rounded;
    case ProductCatalogViewPresetId.untrackedSetup:
      return Icons.add_business_rounded;
  }
}

Color _accentColor(ProductCatalogViewPresetId id) {
  switch (id) {
    case ProductCatalogViewPresetId.allProducts:
      return Colors.blue.shade700;
    case ProductCatalogViewPresetId.attentionQueue:
      return Colors.red.shade700;
    case ProductCatalogViewPresetId.inStock:
      return Colors.green.shade700;
    case ProductCatalogViewPresetId.untrackedSetup:
      return Colors.blueGrey.shade700;
  }
}
