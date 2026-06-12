import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import '../models/order_active_filter_summary.dart';

class OrderActiveFilterSummary extends StatelessWidget {
  final List<OrderActiveFilterSummaryItem> items;
  final ValueChanged<OrderActiveFilterSummaryType>? onClear;
  final VoidCallback? onClearAll;

  const OrderActiveFilterSummary({
    super.key,
    required this.items,
    this.onClear,
    this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    final visibleItems = items
        .where((item) => item.value.trim().isNotEmpty)
        .toList(growable: false);
    if (visibleItems.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Wrap(
      key: const ValueKey('order_active_filter_summary'),
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final item in visibleItems)
          _ActiveFilterChip(
            key: ValueKey('order_active_filter_${item.id}'),
            item: item,
            colorScheme: theme.colorScheme,
            textStyle: theme.textTheme.labelSmall,
            onClear: onClear,
          ),
        if (onClearAll != null)
          _ClearAllChip(
            onPressed: onClearAll!,
            colorScheme: theme.colorScheme,
            textStyle: theme.textTheme.labelSmall,
          ),
      ],
    );
  }
}

class _ActiveFilterChip extends StatelessWidget {
  final OrderActiveFilterSummaryItem item;
  final ColorScheme colorScheme;
  final TextStyle? textStyle;
  final ValueChanged<OrderActiveFilterSummaryType>? onClear;

  const _ActiveFilterChip({
    super.key,
    required this.item,
    required this.colorScheme,
    required this.textStyle,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final clear = onClear;

    return Tooltip(
      message: item.displayLabel,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 240),
        padding: EdgeInsets.only(
          left: 9,
          right: clear == null ? 9 : 3,
          top: 5,
          bottom: 5,
        ),
        decoration: BoxDecoration(
          color: colorScheme.secondaryContainer.withValues(alpha: 0.54),
          borderRadius: BorderRadius.circular(POSUiTokens.radius),
          border: Border.all(
            color: colorScheme.secondary.withValues(alpha: 0.18),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                item.displayLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textStyle?.copyWith(
                  color: colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (clear != null) ...[
              const SizedBox(width: 4),
              IconButton(
                key: ValueKey('order_active_filter_clear_${item.id}'),
                tooltip: 'Clear ${item.label.toLowerCase()}',
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints.tightFor(
                  width: 22,
                  height: 22,
                ),
                padding: EdgeInsets.zero,
                iconSize: 14,
                onPressed: () => clear(item.type),
                icon: Icon(
                  Icons.close_rounded,
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ClearAllChip extends StatelessWidget {
  final VoidCallback onPressed;
  final ColorScheme colorScheme;
  final TextStyle? textStyle;

  const _ClearAllChip({
    required this.onPressed,
    required this.colorScheme,
    required this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      key: const ValueKey('order_active_filter_clear_all'),
      onPressed: onPressed,
      icon: const Icon(Icons.clear_all_rounded, size: 15),
      label: const Text('Clear all'),
      style: TextButton.styleFrom(
        visualDensity: VisualDensity.compact,
        minimumSize: const Size(0, 28),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        foregroundColor: colorScheme.primary,
        textStyle: textStyle?.copyWith(fontWeight: FontWeight.w900),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(POSUiTokens.radius),
        ),
      ),
    );
  }
}
