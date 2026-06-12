import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../models/product.dart';
import '../utils/product_stock_count_view.dart';
import 'product_stock_count_visuals.dart';

class ProductStockCountTile extends StatelessWidget {
  const ProductStockCountTile({
    super.key,
    required this.entry,
    required this.onOpenProduct,
    this.onCaptureCount,
  });

  final ProductStockCountEntry entry;
  final ValueChanged<Product> onOpenProduct;
  final ValueChanged<Product>? onCaptureCount;

  @override
  Widget build(BuildContext context) {
    final color = productStockCountStatusColor(context, entry.status);
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => onOpenProduct(entry.product),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 680;
              final details = _StockCountDetails(entry: entry, color: color);
              final facts = _StockCountFacts(entry: entry);
              final actions = _StockCountActions(
                entry: entry,
                onOpenProduct: onOpenProduct,
                onCaptureCount: onCaptureCount,
              );

              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    details,
                    const SizedBox(height: 12),
                    facts,
                    const SizedBox(height: 12),
                    Align(alignment: Alignment.centerRight, child: actions),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: details),
                  const SizedBox(width: 12),
                  facts,
                  const SizedBox(width: 12),
                  actions,
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _StockCountActions extends StatelessWidget {
  const _StockCountActions({
    required this.entry,
    required this.onOpenProduct,
    required this.onCaptureCount,
  });

  final ProductStockCountEntry entry;
  final ValueChanged<Product> onOpenProduct;
  final ValueChanged<Product>? onCaptureCount;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.end,
      children: [
        if (onCaptureCount != null)
          IconButton.filledTonal(
            tooltip: 'Capture count for ${entry.nameLabel}',
            icon: const Icon(Icons.document_scanner_rounded),
            onPressed: () => onCaptureCount!(entry.product),
          ),
        IconButton.outlined(
          tooltip: 'Open ${entry.nameLabel}',
          icon: const Icon(Icons.open_in_new_rounded),
          onPressed: () => onOpenProduct(entry.product),
        ),
      ],
    );
  }
}

class _StockCountDetails extends StatelessWidget {
  const _StockCountDetails({required this.entry, required this.color});

  final ProductStockCountEntry entry;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(productStockCountStatusIcon(entry.status), color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                entry.nameLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${entry.skuLabel} | ${entry.categoryLabel}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 10),
              AppStatusPill(
                label: entry.statusLabel,
                color: color,
                icon: productStockCountStatusIcon(entry.status),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StockCountFacts extends StatelessWidget {
  const _StockCountFacts({required this.entry});

  final ProductStockCountEntry entry;

  @override
  Widget build(BuildContext context) {
    final facts = [
      _StockCountFact(label: 'System', value: '${entry.systemStock}'),
      _StockCountFact(label: 'Actual', value: entry.actualStockLabel),
      _StockCountFact(label: 'Diff', value: entry.varianceLabel),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.end,
      children: [for (final fact in facts) _StockCountFactTile(fact: fact)],
    );
  }
}

class _StockCountFactTile extends StatelessWidget {
  const _StockCountFactTile({required this.fact});

  final _StockCountFact fact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              fact.label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              fact.value,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StockCountFact {
  const _StockCountFact({required this.label, required this.value});

  final String label;
  final String value;
}
