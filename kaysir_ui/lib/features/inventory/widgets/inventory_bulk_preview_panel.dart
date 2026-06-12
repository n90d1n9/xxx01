import 'package:flutter/material.dart';

import '../utils/inventory_formatters.dart';
import 'inventory_separated_list.dart';
import 'inventory_tile_surface.dart';

typedef InventoryBulkPreviewItemBuilder<T> =
    Widget Function(BuildContext context, T item, int index);

typedef InventoryBulkPreviewMoreLabelBuilder = String Function(int hiddenCount);

class InventoryBulkPreviewPanel<T> extends StatelessWidget {
  const InventoryBulkPreviewPanel({
    super.key,
    required this.title,
    required this.items,
    required this.itemBuilder,
    this.headerTrailing = const [],
    this.maxVisibleItems = 5,
    this.itemSpacing = 8,
    this.hiddenItemNoun = 'products',
    this.moreLabelBuilder,
  });

  final String title;
  final List<T> items;
  final InventoryBulkPreviewItemBuilder<T> itemBuilder;
  final List<Widget> headerTrailing;
  final int maxVisibleItems;
  final double itemSpacing;
  final String hiddenItemNoun;
  final InventoryBulkPreviewMoreLabelBuilder? moreLabelBuilder;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final visibleItems = items.take(maxVisibleItems).toList(growable: false);
    final hiddenCount = items.length - visibleItems.length;

    return InventoryTileSurface(
      backgroundColor: colorScheme.surfaceContainerHighest.withValues(
        alpha: 0.42,
      ),
      borderColor: colorScheme.outlineVariant,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
              ),
              ...headerTrailing,
            ],
          ),
          if (visibleItems.isNotEmpty) ...[
            const SizedBox(height: 12),
            InventorySeparatedList<T>(
              items: visibleItems,
              spacing: itemSpacing,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              itemBuilder: itemBuilder,
            ),
          ],
          if (hiddenCount > 0) ...[
            const SizedBox(height: 10),
            Text(
              _moreLabel(hiddenCount),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _moreLabel(int hiddenCount) {
    final customLabel = moreLabelBuilder;
    if (customLabel != null) return customLabel(hiddenCount);

    return '+${formatInventoryNumber(hiddenCount)} more $hiddenItemNoun';
  }
}
