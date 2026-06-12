import 'package:flutter/material.dart';

import '../../../widgets/ui/app_filter_bar.dart';
import '../../../widgets/ui/app_icon_action_button.dart';
import '../models/inventory_branch_filter.dart';
import '../models/inventory_stock_record.dart';
import '../models/warehouse.dart';
import 'inventory_search_field.dart';
import 'inventory_stock_filter_chips.dart';
import 'inventory_stock_location_filters.dart';
import 'inventory_stock_toolbar_state.dart';

class InventoryStockToolbar extends StatelessWidget {
  const InventoryStockToolbar({
    super.key,
    required this.searchController,
    required this.records,
    required this.branchLabels,
    this.branchOptions,
    required this.warehouses,
    required this.selectedBranch,
    required this.selectedWarehouseId,
    required this.filter,
    required this.onSearchChanged,
    required this.onBranchChanged,
    required this.onWarehouseChanged,
    required this.onFilterChanged,
    this.onCopyLink,
  });

  final TextEditingController searchController;
  final List<InventoryStockRecord> records;
  final List<String> branchLabels;
  final List<InventoryBranchFilterOption>? branchOptions;
  final List<Warehouse> warehouses;
  final String? selectedBranch;
  final String? selectedWarehouseId;
  final InventoryStockFilter filter;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onBranchChanged;
  final ValueChanged<String?> onWarehouseChanged;
  final ValueChanged<InventoryStockFilter> onFilterChanged;
  final VoidCallback? onCopyLink;

  @override
  Widget build(BuildContext context) {
    final counts = inventoryStockToolbarCounts(records);

    return AppFilterBar(
      search: InventorySearchField(
        controller: searchController,
        hintText: 'Search product, SKU, category, or warehouse',
        onChanged: onSearchChanged,
      ),
      filters: [
        InventoryStockFilterChips(
          value: filter,
          counts: counts,
          onChanged: onFilterChanged,
        ),
        AppIconActionButton(
          icon: Icons.link_rounded,
          tooltip: 'Copy filtered link',
          variant: AppIconActionButtonVariant.outlined,
          onPressed: onCopyLink,
        ),
      ],
      trailing: [
        InventoryStockBranchFilter(
          branchLabels: branchLabels,
          branchOptions: branchOptions,
          selectedBranch: selectedBranch,
          onChanged: onBranchChanged,
        ),
        InventoryStockWarehouseFilter(
          warehouses: warehouses,
          selectedWarehouseId: selectedWarehouseId,
          onChanged: onWarehouseChanged,
        ),
      ],
    );
  }
}
