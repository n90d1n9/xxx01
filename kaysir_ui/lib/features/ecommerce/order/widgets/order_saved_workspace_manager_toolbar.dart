import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import '../models/order_saved_workspace_manager_view.dart';
import 'order_saved_workspace_manager_scope_selector.dart';
import 'order_saved_workspace_manager_sort_menu.dart';

class OrderSavedWorkspaceManagerToolbar extends StatelessWidget {
  final OrderSavedWorkspaceManagerView managerView;
  final TextEditingController searchController;
  final OrderSavedWorkspaceManagerScope scope;
  final OrderSavedWorkspaceManagerSort sortMode;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<OrderSavedWorkspaceManagerScope> onScopeChanged;
  final ValueChanged<OrderSavedWorkspaceManagerSort> onSortChanged;

  const OrderSavedWorkspaceManagerToolbar({
    super.key,
    required this.managerView,
    required this.searchController,
    required this.scope,
    required this.sortMode,
    required this.onQueryChanged,
    required this.onScopeChanged,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          key: const ValueKey('order_saved_workspace_manager_search'),
          controller: searchController,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search_rounded),
            labelText: 'Search workspaces',
          ),
          onChanged: onQueryChanged,
        ),
        const SizedBox(height: POSUiTokens.gapLarge),
        Wrap(
          spacing: POSUiTokens.gap,
          runSpacing: POSUiTokens.gap,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            OrderSavedWorkspaceManagerScopeSelector(
              managerView: managerView,
              scope: scope,
              onChanged: onScopeChanged,
            ),
            OrderSavedWorkspaceManagerSortMenu(
              sortMode: sortMode,
              onChanged: onSortChanged,
            ),
          ],
        ),
      ],
    );
  }
}
