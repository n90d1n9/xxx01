import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../inventory/models/movement_type.dart';
import '../../inventory/models/stock_movement.dart';
import '../models/product.dart';
import '../utils/product_stock_movement_display.dart';
import '../utils/product_stock_movement_timeline.dart';

class StockMovementLedger extends StatefulWidget {
  const StockMovementLedger({
    super.key,
    required this.movements,
    required this.products,
  });

  final List<StockMovement> movements;
  final List<Product> products;

  @override
  State<StockMovementLedger> createState() => _StockMovementLedgerState();
}

class _StockMovementLedgerState extends State<StockMovementLedger> {
  final _searchController = TextEditingController();

  String _query = '';
  MovementType? _selectedType;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timeline = buildProductStockMovementTimeline(
      movements: widget.movements,
      products: widget.products,
      query: _query,
      type: _selectedType,
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _StockMovementLedgerHeader(summary: timeline.summary),
        const SizedBox(height: 16),
        _StockMovementLedgerControls(
          searchController: _searchController,
          query: _query,
          selectedType: _selectedType,
          onQueryChanged: (query) => setState(() => _query = query),
          onTypeChanged: (type) => setState(() => _selectedType = type),
        ),
        const SizedBox(height: 16),
        if (timeline.entries.isEmpty)
          _StockMovementEmptyState(
            hasFilters: _query.trim().isNotEmpty || _selectedType != null,
          )
        else
          _StockMovementEntryList(entries: timeline.entries),
      ],
    );
  }
}

class _StockMovementLedgerHeader extends StatelessWidget {
  const _StockMovementLedgerHeader({required this.summary});

  final ProductStockMovementSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final latest = summary.latestMovementAt;

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
                    Icons.timeline_rounded,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Stock Movement Ledger',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        latest == null
                            ? 'No movement activity has been recorded yet.'
                            : 'Latest activity ${DateFormat('MMM d, yyyy').format(latest)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 620;
                final metrics = [
                  _MovementMetric(
                    label: 'Movements',
                    value: '${summary.totalMovements}',
                    color: theme.colorScheme.primary,
                  ),
                  _MovementMetric(
                    label: 'Inbound',
                    value: '+${summary.inboundUnits}',
                    color: Colors.green,
                  ),
                  _MovementMetric(
                    label: 'Outbound',
                    value: '-${summary.outboundUnits}',
                    color: Colors.red,
                  ),
                  _MovementMetric(
                    label: 'Neutral',
                    value: '${summary.neutralMovements}',
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
                                child: _StockMovementMetricTile(metric: metric),
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
                                child: _StockMovementMetricTile(metric: metric),
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

class _StockMovementLedgerControls extends StatelessWidget {
  const _StockMovementLedgerControls({
    required this.searchController,
    required this.query,
    required this.selectedType,
    required this.onQueryChanged,
    required this.onTypeChanged,
  });

  final TextEditingController searchController;
  final String query;
  final MovementType? selectedType;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<MovementType?> onTypeChanged;

  @override
  Widget build(BuildContext context) {
    final typeOptions = <MovementType?>[null, ...MovementType.values];

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 700;
        final searchField = TextField(
          controller: searchController,
          onChanged: onQueryChanged,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search_rounded),
            hintText: 'Search product, SKU, reference, or notes',
            border: const OutlineInputBorder(),
            suffixIcon:
                query.trim().isEmpty
                    ? null
                    : IconButton(
                      tooltip: 'Clear search',
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () {
                        searchController.clear();
                        onQueryChanged('');
                      },
                    ),
          ),
        );

        final typeFilter = DropdownButtonFormField<MovementType?>(
          initialValue: selectedType,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Movement type',
            prefixIcon: Icon(Icons.tune_rounded),
            border: OutlineInputBorder(),
          ),
          items:
              typeOptions
                  .map(
                    (type) => DropdownMenuItem<MovementType?>(
                      value: type,
                      child: Text(
                        type == null
                            ? 'All movement types'
                            : productStockMovementTypeLabel(type),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
          onChanged: onTypeChanged,
        );

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [searchField, const SizedBox(height: 12), typeFilter],
          );
        }

        return Row(
          children: [
            Expanded(flex: 3, child: searchField),
            const SizedBox(width: 12),
            Expanded(flex: 2, child: typeFilter),
          ],
        );
      },
    );
  }
}

class _StockMovementEntryList extends StatelessWidget {
  const _StockMovementEntryList({required this.entries});

  final List<ProductStockMovementTimelineEntry> entries;

  @override
  Widget build(BuildContext context) {
    return Column(
      children:
          entries
              .map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _StockMovementEntryCard(entry: entry),
                ),
              )
              .toList(),
    );
  }
}

class _StockMovementEntryCard extends StatelessWidget {
  const _StockMovementEntryCard({required this.entry});

  final ProductStockMovementTimelineEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final movement = entry.movement;
    final display = entry.display;
    final notes = movement.notes.trim();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: display.color.withValues(alpha: 0.16),
              child: Icon(display.icon, color: display.color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        entry.productName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      _StockMovementChip(
                        label: display.typeLabel,
                        color: display.color,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${entry.skuLabel} | ${entry.categoryLabel}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 12,
                    runSpacing: 6,
                    children: [
                      _MovementMeta(
                        icon: Icons.receipt_long_rounded,
                        label: entry.referenceLabel,
                      ),
                      _MovementMeta(
                        icon: Icons.event_rounded,
                        label: DateFormat('MMM d, yyyy').format(movement.date),
                      ),
                    ],
                  ),
                  if (notes.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      notes,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              display.quantityLabel,
              style: theme.textTheme.titleMedium?.copyWith(
                color: display.color,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StockMovementEmptyState extends StatelessWidget {
  const _StockMovementEmptyState({required this.hasFilters});

  final bool hasFilters;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          children: [
            Icon(
              hasFilters
                  ? Icons.manage_search_rounded
                  : Icons.inventory_2_outlined,
              size: 42,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              hasFilters
                  ? 'No stock movements match this view'
                  : 'No stock movements recorded',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              hasFilters
                  ? 'Try another search term or movement type.'
                  : 'New stock activity will appear here automatically.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StockMovementMetricTile extends StatelessWidget {
  const _StockMovementMetricTile({required this.metric});

  final _MovementMetric metric;

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

class _StockMovementChip extends StatelessWidget {
  const _StockMovementChip({required this.label, required this.color});

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

class _MovementMeta extends StatelessWidget {
  const _MovementMeta({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _MovementMetric {
  const _MovementMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;
}
