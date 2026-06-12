import 'package:flutter/material.dart';

import '../../../widgets/ui/app_empty_state.dart';
import 'inventory_reset_filters_button.dart';

class InventoryFilteredEmptyState extends StatelessWidget {
  const InventoryFilteredEmptyState({
    super.key,
    required this.totalCount,
    required this.emptyTitle,
    required this.emptyMessage,
    required this.filteredTitle,
    required this.filteredMessage,
    required this.icon,
    this.emptyAction,
    this.onResetFilters,
    this.showResetWhenEmpty = true,
  });

  final int totalCount;
  final String emptyTitle;
  final String emptyMessage;
  final String filteredTitle;
  final String filteredMessage;
  final IconData icon;
  final Widget? emptyAction;
  final VoidCallback? onResetFilters;
  final bool showResetWhenEmpty;

  @override
  Widget build(BuildContext context) {
    final hasSourceRows = totalCount > 0;
    final resetAction =
        onResetFilters == null
            ? null
            : InventoryResetFiltersButton(onPressed: onResetFilters!);

    return AppEmptyState(
      title: hasSourceRows ? filteredTitle : emptyTitle,
      message: hasSourceRows ? filteredMessage : emptyMessage,
      icon: icon,
      action: hasSourceRows ? resetAction : emptyAction ?? _emptyResetAction,
    );
  }

  Widget? get _emptyResetAction {
    if (!showResetWhenEmpty || onResetFilters == null) return null;
    return InventoryResetFiltersButton(onPressed: onResetFilters!);
  }
}
