import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/widgets/ui/app_filter_bar.dart';
import 'package:kaysir/widgets/ui/app_list_surface.dart';
import 'package:kaysir/widgets/ui/app_text_cluster.dart';

import '../models/inventory_branch_filter.dart';
import '../models/inventory_branch.dart';
import '../models/inventory_filter_deep_link.dart';
import '../models/inventory_warehouse_draft.dart';
import '../models/warehouse.dart';
import '../states/inventory_branch_provider.dart';
import '../states/warehouse_provider.dart';
import '../widgets/inventory_branch_filter.dart';
import '../widgets/inventory_dialog.dart';
import '../widgets/inventory_navigation_drawer.dart';
import '../widgets/inventory_navigation_scaffold.dart';
import '../widgets/inventory_warehouse_components.dart';
import '../widgets/inventory_warehouse_dialog.dart';

class WarehousePage extends ConsumerStatefulWidget {
  const WarehousePage({super.key});

  @override
  ConsumerState<WarehousePage> createState() => _WarehousePageState();
}

class _WarehousePageState extends ConsumerState<WarehousePage> {
  String? _selectedBranch;

  @override
  Widget build(BuildContext context) {
    final warehouses = ref.watch(warehousesProvider);
    final branches = ref.watch(inventoryBranchesProvider);
    final branchOptions = inventoryBranchOptionsForWarehouses(warehouses);
    final branchLabels = [
      for (final branchOption in branchOptions) branchOption.label,
    ];
    final selectedBranch = inventoryValidBranchFilterValue(
      _selectedBranch,
      branchOptions,
    );
    final visibleWarehouses = filterInventoryWarehousesByBranch(
      warehouses,
      selectedBranch: selectedBranch,
    );

    return InventoryNavigationScaffold(
      currentDestination: InventoryNavigationDestination.warehouses,
      appBar: AppBar(
        title: const Text('Warehouses'),
        actions: [
          IconButton(
            tooltip: 'Add warehouse',
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showWarehouseDialog(context, ref, branches),
          ),
        ],
      ),
      body: AppListSurface(
        padding: const EdgeInsets.all(20),
        sectionSpacing: 20,
        header: AppTextCluster(
          eyebrow: 'Inventory',
          title: 'Warehouses',
          subtitle:
              '${visibleWarehouses.length} of ${warehouses.length} storage locations across ${branchLabels.length} branches',
          titleStyle: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        metrics: InventoryWarehouseSummary(warehouses: visibleWarehouses),
        filters: AppFilterBar(
          trailing: [
            InventoryBranchSelectField(
              branchLabels: branchLabels,
              branchOptions: branchOptions,
              selectedBranch: selectedBranch,
              onChanged: (value) => setState(() => _selectedBranch = value),
            ),
          ],
        ),
        children: [
          InventoryWarehousePanel(
            warehouses: visibleWarehouses,
            totalCount: warehouses.length,
            onResetFilters: _resetFilters,
            onAddWarehouse: () => _showWarehouseDialog(context, ref, branches),
            onOpenWarehouse:
                (warehouse) => _openRoute(
                  context,
                  inventoryWarehouseDetailDeepLink(warehouseId: warehouse.id),
                ),
            onEditWarehouse:
                (warehouse) =>
                    _showWarehouseDialog(context, ref, branches, warehouse),
            onDeleteWarehouse:
                (warehouse) => _showDeleteConfirmation(context, ref, warehouse),
          ),
        ],
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      _selectedBranch = null;
    });
  }

  void _openRoute(BuildContext context, String route) {
    Navigator.of(context).pushReplacementNamed(route);
  }

  void _showWarehouseDialog(
    BuildContext context,
    WidgetRef ref,
    List<InventoryBranch> branches, [
    Warehouse? warehouse,
  ]) {
    final isEditing = warehouse != null;

    showInventoryDialog<void>(
      context: context,
      builder: (dialogContext) {
        return InventoryWarehouseDialog(
          branches: branches,
          warehouse: warehouse,
          onCancel: () => Navigator.of(dialogContext).pop(),
          onSubmit: (draft) {
            _saveWarehouse(ref, draft, warehouse);
            Navigator.of(dialogContext).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isEditing
                      ? '${draft.name.trim()} updated'
                      : '${draft.name.trim()} added',
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _saveWarehouse(
    WidgetRef ref,
    InventoryWarehouseDraft draft,
    Warehouse? warehouse,
  ) {
    final id =
        warehouse?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    final savedWarehouse = draft.toWarehouse(id: id);
    final notifier = ref.read(warehousesProvider.notifier);

    if (warehouse == null) {
      notifier.addWarehouse(savedWarehouse);
    } else {
      notifier.updateWarehouse(savedWarehouse);
    }
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    Warehouse warehouse,
  ) {
    showInventoryDialog<void>(
      context: context,
      builder: (dialogContext) {
        return InventoryWarehouseDeleteDialog(
          warehouse: warehouse,
          onCancel: () => Navigator.of(dialogContext).pop(),
          onConfirm: () {
            ref.read(warehousesProvider.notifier).deleteWarehouse(warehouse.id);
            Navigator.of(dialogContext).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${warehouse.name} deleted')),
            );
          },
        );
      },
    );
  }
}
