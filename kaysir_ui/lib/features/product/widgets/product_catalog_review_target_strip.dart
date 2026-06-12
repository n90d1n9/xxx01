import 'package:flutter/material.dart';

import '../../../widgets/ui/app_status_pill.dart';
import '../../inventory/models/inventory_product_catalog.dart';
import '../utils/product_catalog_review_target.dart';

class ProductCatalogReviewTargetStrip extends StatelessWidget {
  const ProductCatalogReviewTargetStrip({
    super.key,
    required this.target,
    required this.visibleCount,
    required this.totalCount,
    required this.onClear,
  });

  final ProductCatalogReviewTarget target;
  final int visibleCount;
  final int totalCount;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    if (!target.hasCatalogState) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final accent = _accentColor(target);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.46),
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 640;
            final summary = _ReviewTargetSummary(
              target: target,
              accent: accent,
            );
            final actions = _ReviewTargetActions(
              target: target,
              visibleCount: visibleCount,
              totalCount: totalCount,
              accent: accent,
              onClear: onClear,
            );

            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [summary, const SizedBox(height: 10), actions],
              );
            }

            return Row(
              children: [
                Expanded(child: summary),
                const SizedBox(width: 12),
                actions,
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ReviewTargetSummary extends StatelessWidget {
  const _ReviewTargetSummary({required this.target, required this.accent});

  final ProductCatalogReviewTarget target;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SizedBox(
            width: 36,
            height: 36,
            child: Icon(Icons.manage_search_rounded, color: accent, size: 20),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                target.summaryLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 2),
              Text(
                'Focused catalog review',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReviewTargetActions extends StatelessWidget {
  const _ReviewTargetActions({
    required this.target,
    required this.visibleCount,
    required this.totalCount,
    required this.accent,
    required this.onClear,
  });

  final ProductCatalogReviewTarget target;
  final int visibleCount;
  final int totalCount;
  final Color accent;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.end,
      children: [
        if (target.hasFilter)
          AppStatusPill(
            label: inventoryProductCatalogFilterLabel(target.filter),
            color: accent,
            icon: Icons.filter_alt_rounded,
            maxWidth: 132,
          ),
        if (target.hasQuery)
          AppStatusPill(
            label: 'Search "${target.normalizedQuery}"',
            color: Colors.blue.shade700,
            icon: Icons.search_rounded,
            maxWidth: 190,
          ),
        AppStatusPill(
          label: _countLabel(visibleCount, totalCount),
          color: Colors.teal.shade700,
          icon: Icons.inventory_2_rounded,
          maxWidth: 136,
        ),
        SizedBox(
          width: 36,
          height: 36,
          child: IconButton(
            tooltip: 'Clear review target',
            padding: EdgeInsets.zero,
            iconSize: 20,
            color: colorScheme.onSurfaceVariant,
            onPressed: onClear,
            icon: const Icon(Icons.close_rounded),
          ),
        ),
      ],
    );
  }
}

Color _accentColor(ProductCatalogReviewTarget target) {
  if (target.hasFilter && target.hasQuery) return Colors.deepPurple.shade600;
  if (target.hasQuery) return Colors.blue.shade700;

  switch (target.filter) {
    case InventoryProductCatalogFilter.all:
      return Colors.blueGrey.shade700;
    case InventoryProductCatalogFilter.attention:
      return Colors.orange.shade700;
    case InventoryProductCatalogFilter.inStock:
      return Colors.green.shade700;
    case InventoryProductCatalogFilter.untracked:
      return Colors.indigo.shade700;
  }
}

String _countLabel(int visibleCount, int totalCount) {
  final productLabel = totalCount == 1 ? 'product' : 'products';
  return '$visibleCount of $totalCount $productLabel';
}
