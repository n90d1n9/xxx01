import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import '../models/order_saved_workspace_manager_view.dart';

class OrderSavedWorkspaceManagerSortMenu extends StatelessWidget {
  final OrderSavedWorkspaceManagerSort sortMode;
  final ValueChanged<OrderSavedWorkspaceManagerSort> onChanged;

  const OrderSavedWorkspaceManagerSortMenu({
    super.key,
    required this.sortMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopupMenuButton<OrderSavedWorkspaceManagerSort>(
      key: const ValueKey('order_saved_workspace_manager_sort'),
      tooltip: 'Sort workspaces',
      initialValue: sortMode,
      onSelected: onChanged,
      itemBuilder:
          (context) => [
            for (final option in OrderSavedWorkspaceManagerSort.values)
              CheckedPopupMenuItem<OrderSavedWorkspaceManagerSort>(
                key: ValueKey(
                  'order_saved_workspace_manager_sort_${option.name}',
                ),
                value: option,
                checked: option == sortMode,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_sortIcon(option), size: 18),
                    const SizedBox(width: 10),
                    Text(_sortLabel(option)),
                  ],
                ),
              ),
          ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(POSUiTokens.radius),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sort_rounded,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              _sortLabel(sortMode),
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down_rounded,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

String _sortLabel(OrderSavedWorkspaceManagerSort sortMode) {
  return switch (sortMode) {
    OrderSavedWorkspaceManagerSort.defaultOrder => 'Default order',
    OrderSavedWorkspaceManagerSort.labelAscending => 'Label A-Z',
    OrderSavedWorkspaceManagerSort.pinnedFirst => 'Pinned first',
    OrderSavedWorkspaceManagerSort.notesFirst => 'Notes first',
  };
}

IconData _sortIcon(OrderSavedWorkspaceManagerSort sortMode) {
  return switch (sortMode) {
    OrderSavedWorkspaceManagerSort.defaultOrder => Icons.sort_rounded,
    OrderSavedWorkspaceManagerSort.labelAscending =>
      Icons.sort_by_alpha_rounded,
    OrderSavedWorkspaceManagerSort.pinnedFirst => Icons.push_pin_outlined,
    OrderSavedWorkspaceManagerSort.notesFirst => Icons.sticky_note_2_outlined,
  };
}
