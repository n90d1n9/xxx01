import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../product/models/product.dart';
import '../models/inventory_movement_record.dart';
import '../models/inventory_replenishment_plan.dart';
import '../models/inventory_stock_adjustment_draft.dart';
import '../models/inventory_stock_record.dart';
import '../models/warehouse.dart';
import '../services/inventory_stock_mutation_service.dart';
import '../states/inventory_item_provider.dart';
import 'inventory_stock_workspace_adjustment_actions.dart';
import 'inventory_stock_workspace_create_actions.dart';
import 'inventory_stock_workspace_detail_actions.dart';
import 'inventory_stock_workspace_link_actions.dart';
import 'inventory_stock_workspace_mutation_actions.dart';
import 'inventory_stock_workspace_restock_actions.dart';
import 'inventory_stock_workspace_transfer_actions.dart';

mixin InventoryStockWorkspaceActions<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  Future<void> copyInventoryStockFilteredLink(String route) async {
    await copyInventoryStockWorkspaceFilteredLink(
      context: context,
      route: route,
      isMounted: () => mounted,
    );
  }

  void showInventoryStockDetailDialog({
    required InventoryStockRecord record,
    required List<InventoryMovementRecord> relatedMovements,
    required List<Warehouse> warehouses,
    required List<InventoryStockRecord> records,
  }) {
    showInventoryStockDetailDialogAction(
      context: context,
      record: record,
      relatedMovements: relatedMovements,
      onIncreaseStock: () => showInventoryStockIncreaseDialog(record),
      onDecreaseStock: () => showInventoryStockDecreaseDialog(record),
      onTransferStock: () {
        showInventoryStockTransferDialog(
          record: record,
          warehouses: warehouses,
          records: records,
        );
      },
    );
  }

  void showInventoryStockCreateDialog({
    required List<Product> products,
    required List<Warehouse> warehouses,
    required List<InventoryStockRecord> records,
  }) {
    showInventoryStockCreateDialogAction(
      context: context,
      products: products,
      warehouses: warehouses,
      records: records,
      onApplyMutation: _applyInventoryStockMutation,
    );
  }

  void showInventoryLowStockDialog(List<InventoryReplenishmentPlan> plans) {
    showInventoryLowStockDialogAction(
      context: context,
      plans: plans,
      onRestock: showInventoryRestockDialog,
    );
  }

  void showInventoryRestockDialog(InventoryReplenishmentPlan plan) {
    showInventoryRestockDialogAction(
      context: context,
      plan: plan,
      onApplyMutation: _applyInventoryStockMutation,
    );
  }

  void showInventoryStockIncreaseDialog(InventoryStockRecord record) {
    showInventoryStockAdjustmentDialog(
      record: record,
      direction: InventoryStockAdjustmentDirection.increase,
    );
  }

  void showInventoryStockDecreaseDialog(InventoryStockRecord record) {
    showInventoryStockAdjustmentDialog(
      record: record,
      direction: InventoryStockAdjustmentDirection.decrease,
    );
  }

  void showInventoryStockAdjustmentDialog({
    required InventoryStockRecord record,
    required InventoryStockAdjustmentDirection direction,
  }) {
    showInventoryStockAdjustmentDialogAction(
      context: context,
      record: record,
      direction: direction,
      onApplyMutation: _applyInventoryStockMutation,
    );
  }

  void showInventoryStockTransferDialog({
    required InventoryStockRecord record,
    required List<Warehouse> warehouses,
    required List<InventoryStockRecord> records,
  }) {
    showInventoryStockTransferDialogAction(
      context: context,
      record: record,
      warehouses: warehouses,
      records: records,
      inventoryItems: ref.read(inventoryItemsProvider),
      onApplyMutation: _applyInventoryStockMutation,
    );
  }

  void _applyInventoryStockMutation(InventoryStockMutation mutation) {
    applyInventoryStockWorkspaceMutation(ref: ref, mutation: mutation);
  }
}
