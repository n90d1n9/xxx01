import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/widgets/ui/app_list_surface.dart';
import 'package:kaysir/widgets/ui/app_text_cluster.dart';

import '../models/inventory_branch_filter.dart';
import '../models/inventory_filter_deep_link.dart';
import '../models/inventory_movement_record.dart';
import '../states/inventory_projection_provider.dart';
import '../states/warehouse_provider.dart';
import '../widgets/inventory_movement_history_components.dart';
import '../widgets/inventory_navigation_drawer.dart';
import '../widgets/inventory_navigation_scaffold.dart';

class InventoryMovementsPage extends ConsumerStatefulWidget {
  const InventoryMovementsPage({
    super.key,
    this.initialBranch,
    this.initialWarehouseId,
    this.initialQuery = '',
    this.initialFilter = InventoryMovementFilter.all,
  });

  final String? initialBranch;
  final String? initialWarehouseId;
  final String initialQuery;
  final InventoryMovementFilter initialFilter;

  @override
  ConsumerState<InventoryMovementsPage> createState() =>
      _InventoryMovementsPageState();
}

class _InventoryMovementsPageState
    extends ConsumerState<InventoryMovementsPage> {
  late final TextEditingController _searchController;
  late String _query;
  String? _selectedBranch;
  String? _selectedWarehouseId;
  late InventoryMovementFilter _filter;

  @override
  void initState() {
    super.initState();
    _query = widget.initialQuery.trim();
    _selectedBranch = widget.initialBranch;
    _selectedWarehouseId = widget.initialWarehouseId;
    _filter = widget.initialFilter;
    _searchController = TextEditingController(text: _query);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final warehouses = ref.watch(warehousesProvider);
    final records = ref.watch(inventoryMovementRecordsProvider);
    final branchOptions = inventoryBranchOptionsForWarehouses(warehouses);
    final branchLabels = [
      for (final branchOption in branchOptions) branchOption.label,
    ];
    final selectedBranch = inventoryValidBranchFilterValue(
      _selectedBranch,
      branchOptions,
    );
    final warehouseOptions = filterInventoryWarehousesByBranch(
      warehouses,
      selectedBranch: selectedBranch,
    );
    final selectedWarehouseId =
        warehouseOptions.any(
              (warehouse) => warehouse.id == _selectedWarehouseId,
            )
            ? _selectedWarehouseId
            : null;
    final visibleRecords = filterInventoryMovementRecords(
      records,
      query: _query,
      warehouseId: selectedWarehouseId,
      branchName: selectedBranch,
      filter: _filter,
    );

    return InventoryNavigationScaffold(
      currentDestination: InventoryNavigationDestination.movements,
      appBar: AppBar(
        leading: Navigator.of(context).canPop() ? const BackButton() : null,
        title: const Text('Inventory Movements'),
      ),
      body: AppListSurface(
        padding: const EdgeInsets.all(20),
        sectionSpacing: 20,
        header: AppTextCluster(
          eyebrow: 'Inventory',
          title: 'Movement History',
          subtitle: '${records.length} stock events across movement types',
          titleStyle: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        metrics: InventoryMovementHistorySummary(records: records),
        filters: InventoryMovementHistoryToolbar(
          searchController: _searchController,
          records: records,
          branchLabels: branchLabels,
          branchOptions: branchOptions,
          warehouses: warehouseOptions,
          selectedBranch: selectedBranch,
          selectedWarehouseId: selectedWarehouseId,
          filter: _filter,
          onSearchChanged: (value) {
            setState(() {
              _query = value;
            });
          },
          onBranchChanged: (branchName) {
            setState(() {
              _selectedBranch = branchName;
              _selectedWarehouseId = null;
            });
          },
          onWarehouseChanged: (warehouseId) {
            setState(() {
              _selectedWarehouseId = warehouseId;
            });
          },
          onFilterChanged: (filter) {
            setState(() {
              _filter = filter;
            });
          },
          onCopyLink:
              () => _copyFilteredLink(
                inventoryMovementsDeepLink(
                  branch: selectedBranch,
                  warehouseId: selectedWarehouseId,
                  query: _query,
                  filter: _filter,
                ),
              ),
        ),
        children: [
          InventoryMovementHistoryPanel(
            records: visibleRecords,
            totalCount: records.length,
            onResetFilters: _resetFilters,
          ),
        ],
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      _query = '';
      _selectedBranch = null;
      _selectedWarehouseId = null;
      _filter = InventoryMovementFilter.all;
      _searchController.clear();
    });
  }

  Future<void> _copyFilteredLink(String route) async {
    await Clipboard.setData(
      ClipboardData(text: inventoryBrowserDeepLink(route)),
    );
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Filtered movement link copied')),
    );
  }
}
