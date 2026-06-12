import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/inventory_stock_record.dart';
import '../states/inventory_projection_provider.dart';
import '../states/product_provider.dart';
import '../states/warehouse_provider.dart';
import '../widgets/inventory_low_stock_alert_dialog.dart';
import '../widgets/inventory_navigation_drawer.dart';
import '../widgets/inventory_navigation_scaffold.dart';
import '../widgets/inventory_stock_workspace.dart';
import '../widgets/inventory_stock_workspace_actions.dart';
import '../widgets/inventory_stock_workspace_state.dart';

class InventoryPage extends ConsumerStatefulWidget {
  const InventoryPage({
    super.key,
    this.initialBranch,
    this.initialWarehouseId,
    this.initialQuery = '',
    this.initialFilter = InventoryStockFilter.all,
  });

  final String? initialBranch;
  final String? initialWarehouseId;
  final String initialQuery;
  final InventoryStockFilter initialFilter;

  @override
  ConsumerState<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends ConsumerState<InventoryPage>
    with InventoryStockWorkspaceActions<InventoryPage> {
  late final TextEditingController _searchController;
  late InventoryStockWorkspaceFilterState _filters;

  @override
  void initState() {
    super.initState();
    _filters = InventoryStockWorkspaceFilterState.initial(
      branch: widget.initialBranch,
      warehouseId: widget.initialWarehouseId,
      query: widget.initialQuery,
      filter: widget.initialFilter,
    );
    _searchController = TextEditingController(text: _filters.query);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final warehouses = ref.watch(warehousesProvider);
    final products = ref.watch(productsProvider);
    final records = ref.watch(inventoryStockRecordsProvider);
    final movementRecords = ref.watch(inventoryMovementRecordsProvider);
    final replenishmentPlans = ref.watch(inventoryReplenishmentPlansProvider);
    final selection = resolveInventoryStockWorkspaceSelection(
      warehouses: warehouses,
      filters: _filters,
    );
    final visibleRecords = filterInventoryStockWorkspaceRecords(
      records: records,
      filters: _filters,
      selection: selection,
    );

    return InventoryNavigationScaffold(
      currentDestination: InventoryNavigationDestination.inventory,
      appBar: AppBar(
        leading: Navigator.of(context).canPop() ? const BackButton() : null,
        title: const Text('Inventory Management'),
        actions: [
          IconButton(
            tooltip:
                replenishmentPlans.isEmpty
                    ? 'Low stock alerts'
                    : replenishmentPlans.length == 1
                    ? '1 low stock alert'
                    : '${replenishmentPlans.length} low stock alerts',
            icon: InventoryLowStockAlertIcon(count: replenishmentPlans.length),
            onPressed: () {
              showInventoryLowStockDialog(replenishmentPlans);
            },
          ),
          IconButton(
            tooltip: 'Add stock line',
            icon: const Icon(Icons.add),
            onPressed:
                () => showInventoryStockCreateDialog(
                  products: products,
                  warehouses: warehouses,
                  records: records,
                ),
          ),
        ],
      ),
      body: InventoryStockWorkspace(
        searchController: _searchController,
        records: records,
        visibleRecords: visibleRecords,
        warehouses: warehouses,
        branchLabels: selection.branchLabels,
        branchOptions: selection.branchOptions,
        warehouseOptions: selection.warehouseOptions,
        selectedBranch: selection.selectedBranch,
        selectedWarehouseId: selection.selectedWarehouseId,
        filter: _filters.filter,
        onSearchChanged: _setQuery,
        onBranchChanged: _setBranch,
        onWarehouseChanged: _setWarehouse,
        onFilterChanged: _setFilter,
        onCopyLink: () {
          copyInventoryStockFilteredLink(_filters.deepLink(selection));
        },
        onResetFilters: _resetFilters,
        onViewDetails:
            (record) => showInventoryStockDetailDialog(
              record: record,
              relatedMovements: inventoryStockWorkspaceRelatedMovements(
                record: record,
                movementRecords: movementRecords,
              ),
              warehouses: warehouses,
              records: records,
            ),
        onIncreaseStock: showInventoryStockIncreaseDialog,
        onDecreaseStock: showInventoryStockDecreaseDialog,
        onTransferStock:
            (record) => showInventoryStockTransferDialog(
              record: record,
              warehouses: warehouses,
              records: records,
            ),
      ),
    );
  }

  void _setQuery(String value) {
    setState(() {
      _filters = _filters.withQuery(value);
    });
  }

  void _setBranch(String? branchName) {
    setState(() {
      _filters = _filters.withBranch(branchName);
    });
  }

  void _setWarehouse(String? warehouseId) {
    setState(() {
      _filters = _filters.withWarehouse(warehouseId);
    });
  }

  void _setFilter(InventoryStockFilter filter) {
    setState(() {
      _filters = _filters.withFilter(filter);
    });
  }

  void _resetFilters() {
    setState(() {
      _filters = _filters.reset();
      _searchController.clear();
    });
  }
}
