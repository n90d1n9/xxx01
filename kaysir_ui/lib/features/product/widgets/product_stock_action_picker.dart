import 'package:flutter/material.dart';

import '../models/product.dart';
import '../utils/product_stock_action_view.dart';

typedef ProductStockActionCallback = void Function(Product product);

class ProductStockActionPicker extends StatefulWidget {
  const ProductStockActionPicker({
    super.key,
    required this.products,
    required this.onAddStock,
    required this.onRemoveStock,
    this.isLoading = false,
    this.errorMessage,
    this.onRefresh,
  });

  final List<Product> products;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRefresh;
  final ProductStockActionCallback onAddStock;
  final ProductStockActionCallback onRemoveStock;

  @override
  State<ProductStockActionPicker> createState() =>
      _ProductStockActionPickerState();
}

class _ProductStockActionPickerState extends State<ProductStockActionPicker> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final view = buildProductStockActionView(
      products: widget.products,
      query: _query,
    );
    final hasProducts = widget.products.isNotEmpty;
    final errorMessage = widget.errorMessage?.trim();

    if (widget.isLoading && !hasProducts) {
      return _ProductStockActionState(
        icon: Icons.inventory_2_outlined,
        title: 'Loading products',
        message: 'Preparing the product stock action list.',
        showProgress: true,
        onRefresh: widget.onRefresh,
      );
    }

    if (!hasProducts && errorMessage != null && errorMessage.isNotEmpty) {
      return _ProductStockActionState(
        icon: Icons.cloud_off_rounded,
        title: 'Products unavailable',
        message: errorMessage,
        onRefresh: widget.onRefresh,
      );
    }

    if (!hasProducts) {
      return _ProductStockActionState(
        icon: Icons.inventory_2_outlined,
        title: 'No products available',
        message: 'Add products before recording stock movement.',
        onRefresh: widget.onRefresh,
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ProductStockActionHeader(
          summary: view.summary,
          isLoading: widget.isLoading,
          onRefresh: widget.onRefresh,
        ),
        const SizedBox(height: 16),
        if (errorMessage != null && errorMessage.isNotEmpty) ...[
          _ProductStockActionNotice(
            message: errorMessage,
            onRefresh: widget.onRefresh,
          ),
          const SizedBox(height: 16),
        ],
        _ProductStockActionSearchField(
          controller: _searchController,
          query: _query,
          onChanged: (query) => setState(() => _query = query),
        ),
        const SizedBox(height: 16),
        if (view.entries.isEmpty)
          _ProductStockActionState(
            icon: Icons.manage_search_rounded,
            title: 'No products match this search',
            message: 'Try another product name, SKU, category, or barcode.',
            compact: true,
          )
        else
          _ProductStockActionList(
            entries: view.entries,
            onAddStock: widget.onAddStock,
            onRemoveStock: widget.onRemoveStock,
          ),
      ],
    );
  }
}

class _ProductStockActionHeader extends StatelessWidget {
  const _ProductStockActionHeader({
    required this.summary,
    required this.isLoading,
    this.onRefresh,
  });

  final ProductStockActionSummary summary;
  final bool isLoading;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.55,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primary.withValues(
                    alpha: 0.12,
                  ),
                  child: Icon(
                    Icons.inventory_2_rounded,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Stock Action Picker',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isLoading
                            ? 'Refreshing product stock availability.'
                            : 'Choose a product to add or remove stock.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onRefresh != null)
                  IconButton(
                    tooltip: 'Refresh products',
                    icon: const Icon(Icons.refresh_rounded),
                    onPressed: onRefresh,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 620;
                final metrics = [
                  _StockActionMetric(
                    label: 'Products',
                    value: '${summary.totalProducts}',
                    color: theme.colorScheme.primary,
                  ),
                  _StockActionMetric(
                    label: 'In stock',
                    value: '${summary.stockedProducts}',
                    color: Colors.green,
                  ),
                  _StockActionMetric(
                    label: 'Out',
                    value: '${summary.outOfStockProducts}',
                    color: Colors.red,
                  ),
                  _StockActionMetric(
                    label: 'Units',
                    value: '${summary.totalUnits}',
                    color: Colors.orange,
                  ),
                ];

                if (compact) {
                  return Column(
                    children:
                        metrics
                            .map(
                              (metric) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: _StockActionMetricTile(metric: metric),
                              ),
                            )
                            .toList(),
                  );
                }

                return Row(
                  children:
                      metrics
                          .map(
                            (metric) => Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: _StockActionMetricTile(metric: metric),
                              ),
                            ),
                          )
                          .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductStockActionSearchField extends StatelessWidget {
  const _ProductStockActionSearchField({
    required this.controller,
    required this.query,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String query;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search_rounded),
        hintText: 'Search products, SKU, category, or barcode',
        border: const OutlineInputBorder(),
        suffixIcon:
            query.trim().isEmpty
                ? null
                : IconButton(
                  tooltip: 'Clear search',
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                ),
      ),
    );
  }
}

class _ProductStockActionList extends StatelessWidget {
  const _ProductStockActionList({
    required this.entries,
    required this.onAddStock,
    required this.onRemoveStock,
  });

  final List<ProductStockActionEntry> entries;
  final ProductStockActionCallback onAddStock;
  final ProductStockActionCallback onRemoveStock;

  @override
  Widget build(BuildContext context) {
    return Column(
      children:
          entries
              .map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ProductStockActionTile(
                    entry: entry,
                    onAddStock: onAddStock,
                    onRemoveStock: onRemoveStock,
                  ),
                ),
              )
              .toList(),
    );
  }
}

class _ProductStockActionTile extends StatelessWidget {
  const _ProductStockActionTile({
    required this.entry,
    required this.onAddStock,
    required this.onRemoveStock,
  });

  final ProductStockActionEntry entry;
  final ProductStockActionCallback onAddStock;
  final ProductStockActionCallback onRemoveStock;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 560;
            final details = _ProductStockActionDetails(entry: entry);
            final actions = _ProductStockActionButtons(
              entry: entry,
              onAddStock: onAddStock,
              onRemoveStock: onRemoveStock,
            );

            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [details, const SizedBox(height: 12), actions],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: details),
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

class _ProductStockActionDetails extends StatelessWidget {
  const _ProductStockActionDetails({required this.entry});

  final ProductStockActionEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stockColor =
        entry.canRemoveStock ? Colors.green : theme.colorScheme.error;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
          child: Icon(
            Icons.inventory_2_rounded,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.nameLabel,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${entry.skuLabel} | ${entry.categoryLabel}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 10),
              _StockActionStatusPill(
                label: entry.stockLabel,
                color: stockColor,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProductStockActionButtons extends StatelessWidget {
  const _ProductStockActionButtons({
    required this.entry,
    required this.onAddStock,
    required this.onRemoveStock,
  });

  final ProductStockActionEntry entry;
  final ProductStockActionCallback onAddStock;
  final ProductStockActionCallback onRemoveStock;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.end,
      children: [
        IconButton.filledTonal(
          tooltip: 'Add stock for ${entry.nameLabel}',
          icon: const Icon(Icons.add_rounded),
          onPressed: () => onAddStock(entry.product),
        ),
        IconButton.outlined(
          tooltip: 'Remove stock for ${entry.nameLabel}',
          icon: const Icon(Icons.remove_rounded),
          onPressed:
              entry.canRemoveStock ? () => onRemoveStock(entry.product) : null,
        ),
      ],
    );
  }
}

class _ProductStockActionNotice extends StatelessWidget {
  const _ProductStockActionNotice({required this.message, this.onRefresh});

  final String message;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
            ),
            if (onRefresh != null)
              TextButton.icon(
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
                onPressed: onRefresh,
              ),
          ],
        ),
      ),
    );
  }
}

class _ProductStockActionState extends StatelessWidget {
  const _ProductStockActionState({
    required this.icon,
    required this.title,
    required this.message,
    this.compact = false,
    this.showProgress = false,
    this.onRefresh,
  });

  final IconData icon;
  final String title;
  final String message;
  final bool compact;
  final bool showProgress;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(compact ? 24 : 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showProgress)
              const CircularProgressIndicator()
            else
              Icon(icon, size: 42, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 14),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRefresh != null) ...[
              const SizedBox(height: 16),
              FilledButton.tonalIcon(
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Refresh'),
                onPressed: onRefresh,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StockActionMetricTile extends StatelessWidget {
  const _StockActionMetricTile({required this.metric});

  final _StockActionMetric metric;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              metric.label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              metric.value,
              style: theme.textTheme.titleLarge?.copyWith(
                color: metric.color,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StockActionStatusPill extends StatelessWidget {
  const _StockActionStatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _StockActionMetric {
  const _StockActionMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;
}
