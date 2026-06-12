import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_list_surface.dart';
import 'package:kaysir/widgets/ui/app_text_cluster.dart';

import '../models/inventory_branch_filter.dart';
import '../models/inventory_stock_record.dart';
import '../models/warehouse.dart';
import 'inventory_stock_list_panel.dart';
import 'inventory_stock_summary.dart';
import 'inventory_stock_toolbar.dart';

class InventoryStockWorkspace extends StatelessWidget {
  const InventoryStockWorkspace({
    super.key,
    required this.searchController,
    required this.records,
    required this.visibleRecords,
    required this.warehouses,
    required this.branchLabels,
    required this.branchOptions,
    required this.warehouseOptions,
    required this.selectedBranch,
    required this.selectedWarehouseId,
    required this.filter,
    required this.onSearchChanged,
    required this.onBranchChanged,
    required this.onWarehouseChanged,
    required this.onFilterChanged,
    required this.onCopyLink,
    required this.onResetFilters,
    required this.onViewDetails,
    required this.onIncreaseStock,
    required this.onDecreaseStock,
    required this.onTransferStock,
  });

  final TextEditingController searchController;
  final List<InventoryStockRecord> records;
  final List<InventoryStockRecord> visibleRecords;
  final List<Warehouse> warehouses;
  final List<String> branchLabels;
  final List<InventoryBranchFilterOption> branchOptions;
  final List<Warehouse> warehouseOptions;
  final String? selectedBranch;
  final String? selectedWarehouseId;
  final InventoryStockFilter filter;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onBranchChanged;
  final ValueChanged<String?> onWarehouseChanged;
  final ValueChanged<InventoryStockFilter> onFilterChanged;
  final VoidCallback onCopyLink;
  final VoidCallback onResetFilters;
  final ValueChanged<InventoryStockRecord> onViewDetails;
  final ValueChanged<InventoryStockRecord> onIncreaseStock;
  final ValueChanged<InventoryStockRecord> onDecreaseStock;
  final ValueChanged<InventoryStockRecord> onTransferStock;

  @override
  Widget build(BuildContext context) {
    return AppListSurface(
      padding: const EdgeInsets.all(20),
      sectionSpacing: 20,
      header: AppTextCluster(
        eyebrow: 'Inventory',
        title: 'Stock Workspace',
        subtitle:
            '${records.length} stock lines across ${warehouses.length} warehouses',
        titleStyle: Theme.of(
          context,
        ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
      ),
      metrics: InventoryStockSummary(records: records),
      filters: InventoryStockToolbar(
        searchController: searchController,
        records: records,
        branchLabels: branchLabels,
        branchOptions: branchOptions,
        warehouses: warehouseOptions,
        selectedBranch: selectedBranch,
        selectedWarehouseId: selectedWarehouseId,
        filter: filter,
        onSearchChanged: onSearchChanged,
        onBranchChanged: onBranchChanged,
        onWarehouseChanged: onWarehouseChanged,
        onFilterChanged: onFilterChanged,
        onCopyLink: onCopyLink,
      ),
      children: [
        InventoryStockListPanel(
          records: visibleRecords,
          totalCount: records.length,
          onResetFilters: onResetFilters,
          onViewDetails: onViewDetails,
          onIncreaseStock: onIncreaseStock,
          onDecreaseStock: onDecreaseStock,
          onTransferStock: onTransferStock,
        ),
      ],
    );
  }
}
