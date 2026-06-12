import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_content_panel.dart';
import '../../../widgets/ui/app_status_pill.dart';
import '../models/management_pack.dart';
import '../models/management_pack_preset.dart';
import '../models/sales_channel_profile.dart';

/// Responsive picker for applying reusable product-line workspace presets.
class ProductManagementPackPresetPanel extends StatelessWidget {
  const ProductManagementPackPresetPanel({
    super.key,
    required this.presets,
    required this.activePreset,
    required this.onSelected,
  });

  final List<ProductManagementPackPreset> presets;
  final ProductManagementPackPreset? activePreset;
  final ValueChanged<ProductManagementPackPreset> onSelected;

  @override
  Widget build(BuildContext context) {
    if (presets.isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    return AppContentPanel(
      title: 'Product-line presets',
      subtitle:
          activePreset?.subtitle ??
          'Reusable pack and channel recipes for productized workspaces',
      leadingIcon: Icons.auto_awesome_motion_rounded,
      trailing: AppStatusPill(
        label: '${presets.length} presets',
        color: colorScheme.primary,
        icon: Icons.bookmarks_rounded,
        maxWidth: 124,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columnCount =
              constraints.maxWidth >= 1020
                  ? 4
                  : constraints.maxWidth >= 720
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
                  key: ValueKey('management-pack-preset-${preset.id}'),
                  width: cardWidth,
                  child: _ProductManagementPackPresetCard(
                    preset: preset,
                    isActive: activePreset?.id == preset.id,
                    onSelected: () => onSelected(preset),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

@Preview(name: 'Management pack presets')
Widget productManagementPackPresetPanelPreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ProductManagementPackPresetPanel(
          presets: defaultProductManagementPackPresets,
          activePreset: defaultProductManagementPackPresets.first,
          onSelected: (_) {},
        ),
      ),
    ),
  );
}

/// Selectable preset card that explains pack, channel, and scope.
class _ProductManagementPackPresetCard extends StatelessWidget {
  const _ProductManagementPackPresetCard({
    required this.preset,
    required this.isActive,
    required this.onSelected,
  });

  final ProductManagementPackPreset preset;
  final bool isActive;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = _accentColor(preset);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isActive ? accent.withValues(alpha: 0.06) : colorScheme.surface,
        border: Border.all(
          color:
              isActive
                  ? accent.withValues(alpha: 0.32)
                  : colorScheme.outlineVariant,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: isActive ? null : onSelected,
        child: SizedBox(
          height: 270,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                        child: Icon(_presetIcon(preset), color: accent),
                      ),
                    ),
                    const Spacer(),
                    AppStatusPill(
                      label: isActive ? 'Active' : 'Apply',
                      color: accent,
                      maxWidth: 92,
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
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    AppStatusPill(
                      label: _packLabel(preset.packId),
                      color: accent,
                      showDot: true,
                      maxWidth: 150,
                    ),
                    AppStatusPill(
                      label: _channelLabel(preset.channelProfileId),
                      color: Colors.blueGrey.shade700,
                      showDot: true,
                      maxWidth: 154,
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  preset.scopeLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  preset.highlights.take(3).join(' / '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

IconData _presetIcon(ProductManagementPackPreset preset) {
  if (preset.packId == ProductManagementPackId.groceryFreshGoods) {
    return Icons.local_grocery_store_rounded;
  }
  if (preset.channelProfileId == ProductSalesChannelProfileId.digitalCommerce) {
    return Icons.storefront_rounded;
  }
  if (preset.channelProfileId == ProductSalesChannelProfileId.counterService) {
    return Icons.point_of_sale_rounded;
  }

  return Icons.hub_rounded;
}

Color _accentColor(ProductManagementPackPreset preset) {
  if (preset.packId == ProductManagementPackId.groceryFreshGoods) {
    return Colors.green.shade700;
  }
  if (preset.channelProfileId == ProductSalesChannelProfileId.digitalCommerce) {
    return Colors.indigo.shade700;
  }
  if (preset.channelProfileId == ProductSalesChannelProfileId.counterService) {
    return Colors.teal.shade700;
  }

  return Colors.blue.shade700;
}

String _packLabel(ProductManagementPackId id) {
  if (id == ProductManagementPackId.groceryFreshGoods) {
    return 'Grocery Fresh Goods';
  }

  return 'Core Catalog';
}

String _channelLabel(ProductSalesChannelProfileId id) {
  if (id == ProductSalesChannelProfileId.counterService) {
    return 'Counter Service';
  }
  if (id == ProductSalesChannelProfileId.digitalCommerce) {
    return 'Digital Commerce';
  }
  if (id == groceryFreshGoodsProfileId) {
    return 'Fresh Goods Grocery';
  }

  return 'Omni Retail';
}
