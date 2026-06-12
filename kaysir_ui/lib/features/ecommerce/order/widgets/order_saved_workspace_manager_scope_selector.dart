import 'package:flutter/material.dart';

import '../models/order_saved_workspace_manager_view.dart';

class OrderSavedWorkspaceManagerScopeSelector extends StatelessWidget {
  final OrderSavedWorkspaceManagerView managerView;
  final OrderSavedWorkspaceManagerScope scope;
  final ValueChanged<OrderSavedWorkspaceManagerScope> onChanged;

  const OrderSavedWorkspaceManagerScopeSelector({
    super.key,
    required this.managerView,
    required this.scope,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<OrderSavedWorkspaceManagerScope>(
      key: const ValueKey('order_saved_workspace_manager_scope'),
      showSelectedIcon: false,
      selected: {scope},
      onSelectionChanged: (selection) => onChanged(selection.single),
      segments: [
        _scopeSegment(
          scope: OrderSavedWorkspaceManagerScope.all,
          icon: Icons.bookmark_border_rounded,
          label: 'All (${managerView.workspaceCount})',
        ),
        _scopeSegment(
          scope: OrderSavedWorkspaceManagerScope.pinned,
          icon: Icons.push_pin_outlined,
          label: 'Pinned (${managerView.pinnedCount})',
        ),
        _scopeSegment(
          scope: OrderSavedWorkspaceManagerScope.notes,
          icon: Icons.sticky_note_2_outlined,
          label: 'Notes (${managerView.noteCount})',
        ),
      ],
    );
  }
}

ButtonSegment<OrderSavedWorkspaceManagerScope> _scopeSegment({
  required OrderSavedWorkspaceManagerScope scope,
  required IconData icon,
  required String label,
}) {
  return ButtonSegment<OrderSavedWorkspaceManagerScope>(
    value: scope,
    icon: Icon(icon, size: 16),
    label: Text(
      label,
      key: ValueKey('order_saved_workspace_manager_scope_${scope.name}'),
    ),
  );
}
