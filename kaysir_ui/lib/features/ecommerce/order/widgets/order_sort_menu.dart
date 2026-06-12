import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import '../models/order_sort.dart';

class OrderSortMenu extends StatelessWidget {
  final OrderSortMode sortMode;
  final ValueChanged<OrderSortMode> onChanged;

  const OrderSortMenu({
    super.key,
    required this.sortMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopupMenuButton<OrderSortMode>(
      key: const ValueKey('order_sort_menu'),
      tooltip: 'Sort orders',
      initialValue: sortMode,
      onSelected: onChanged,
      itemBuilder:
          (context) => OrderSortMode.values
              .map(
                (mode) => CheckedPopupMenuItem<OrderSortMode>(
                  value: mode,
                  checked: mode == sortMode,
                  child: Text(mode.label),
                ),
              )
              .toList(growable: false),
      child: Container(
        height: POSUiTokens.controlHeight,
        padding: POSUiTokens.controlPadding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(POSUiTokens.radius),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sort_outlined,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: POSUiTokens.gap),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 104),
              child: Text(
                sortMode.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.expand_more,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
