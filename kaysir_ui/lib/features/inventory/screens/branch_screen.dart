import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/inventory_branch.dart';
import '../models/inventory_branch_warehouse_counts.dart';
import '../models/inventory_branch_draft.dart';
import '../models/company_branch_governance.dart';
import '../states/inventory_branch_provider.dart';
import '../states/warehouse_provider.dart';
import '../widgets/inventory_branch_components.dart';
import '../widgets/inventory_branch_dialog.dart';
import '../widgets/inventory_dialog.dart';
import '../widgets/inventory_navigation_drawer.dart';
import '../widgets/inventory_navigation_scaffold.dart';

/// Branch management page for company branches and warehouse assignments.
class BranchPage extends ConsumerWidget {
  const BranchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final branches = ref.watch(inventoryBranchesProvider);
    final warehouses = ref.watch(warehousesProvider);
    final warehouseCountByBranchId = countInventoryWarehousesByBranchId(
      branches: branches,
      warehouses: warehouses,
    );
    final governanceSummary = CompanyBranchGovernanceSummary.fromBranches(
      branches: branches,
      warehouseCountByBranchId: warehouseCountByBranchId,
    );

    return InventoryNavigationScaffold(
      currentDestination: InventoryNavigationDestination.branches,
      appBar: AppBar(
        title: const Text('Branches'),
        actions: [
          IconButton(
            tooltip: 'Add branch',
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showBranchDialog(context, ref),
          ),
        ],
      ),
      body: InventoryBranchWorkspace(
        branches: branches,
        warehouseCount: warehouses.length,
        warehouseCountByBranchId: warehouseCountByBranchId,
        governanceSummary: governanceSummary,
        actions: InventoryBranchWorkspaceActions(
          onAddBranch: () => _showBranchDialog(context, ref),
          onEditBranch: (branch) => _showBranchDialog(context, ref, branch),
          onDeleteBranch:
              (branch) => _showDeleteConfirmation(
                context,
                ref,
                branch,
                warehouseCountByBranchId[branch.id] ?? 0,
              ),
        ),
      ),
    );
  }

  void _showBranchDialog(
    BuildContext context,
    WidgetRef ref, [
    InventoryBranch? branch,
  ]) {
    final isEditing = branch != null;

    showInventoryDialog<void>(
      context: context,
      builder: (dialogContext) {
        return InventoryBranchDialog(
          branch: branch,
          onCancel: () => Navigator.of(dialogContext).pop(),
          onSubmit: (draft) {
            _saveBranch(ref, draft, branch);
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

  void _saveBranch(
    WidgetRef ref,
    InventoryBranchDraft draft,
    InventoryBranch? branch,
  ) {
    final id = branch?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    final savedBranch = draft.toBranch(id: id);
    final notifier = ref.read(inventoryBranchesProvider.notifier);

    if (branch == null) {
      notifier.addBranch(savedBranch);
    } else {
      notifier.updateBranch(savedBranch);
      ref
          .read(warehousesProvider.notifier)
          .updateBranchLabel(
            branchId: savedBranch.id,
            branchName: savedBranch.nameLabel,
          );
    }
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    InventoryBranch branch,
    int assignedWarehouseCount,
  ) {
    showInventoryDialog<void>(
      context: context,
      builder: (dialogContext) {
        return InventoryBranchDeleteDialog(
          branch: branch,
          assignedWarehouseCount: assignedWarehouseCount,
          onCancel: () => Navigator.of(dialogContext).pop(),
          onConfirm: () {
            ref
                .read(inventoryBranchesProvider.notifier)
                .deleteBranch(branch.id);
            Navigator.of(dialogContext).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${branch.nameLabel} deleted')),
            );
          },
        );
      },
    );
  }
}
