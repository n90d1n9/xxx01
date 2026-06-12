import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/widgets/ui/app_list_surface.dart';
import 'package:kaysir/widgets/ui/app_text_cluster.dart';

import '../../ecommerce/order/order.dart';
import '../models/inventory_filter_deep_link.dart';
import '../models/inventory_purchase_order_create.dart';
import '../models/inventory_replenishment_plan.dart';
import '../models/inventory_restock_draft.dart';
import '../services/inventory_restock_service.dart';
import '../states/inventory_item_provider.dart';
import '../states/inventory_movement_provider.dart';
import '../states/inventory_projection_provider.dart';
import '../states/purchase_order_provider.dart';
import '../states/warehouse_provider.dart';
import '../widgets/inventory_dialog.dart';
import '../widgets/inventory_navigation_drawer.dart';
import '../widgets/inventory_navigation_scaffold.dart';
import '../widgets/low_stock_replenishment_components.dart';
import '../widgets/low_stock_restock_dialog.dart';

/// Low-stock replenishment workflow with queue triage and restock actions.
class LowStockPage extends ConsumerStatefulWidget {
  const LowStockPage({super.key});

  @override
  ConsumerState<LowStockPage> createState() => _LowStockPageState();
}

/// Holds transient replenishment queue filters while providers own stock data.
class _LowStockPageState extends ConsumerState<LowStockPage> {
  InventoryReplenishmentPlanFilter _filter =
      InventoryReplenishmentPlanFilter.all;
  InventoryReplenishmentPlanSort _sort =
      InventoryReplenishmentPlanSort.priority;
  String? _selectedWarehouseId;

  @override
  Widget build(BuildContext context) {
    final warehouses = ref.watch(warehousesProvider);
    final plans = ref.watch(inventoryReplenishmentPlansProvider);

    return InventoryNavigationScaffold(
      currentDestination: InventoryNavigationDestination.lowStock,
      appBar: AppBar(title: const Text('Low Stock Alerts')),
      body: AppListSurface(
        padding: const EdgeInsets.all(20),
        sectionSpacing: 20,
        header: AppTextCluster(
          eyebrow: 'Inventory',
          title: 'Low Stock Alerts',
          subtitle:
              '${plans.length} stock lines need replenishment across ${warehouses.length} warehouses',
          titleStyle: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        metrics: LowStockReplenishmentSummary(plans: plans),
        children: [
          LowStockReplenishmentPanel(
            plans: plans,
            filter: _filter,
            sort: _sort,
            selectedWarehouseId: _selectedWarehouseId,
            onFilterChanged: (filter) => setState(() => _filter = filter),
            onSortChanged: (sort) => setState(() => _sort = sort),
            onWarehouseChanged:
                (warehouseId) =>
                    setState(() => _selectedWarehouseId = warehouseId),
            onCreatePurchaseOrderDraft:
                (draft) => _createPurchaseOrderDraft(context, ref, draft),
            onRestock: (plan) => _showRestockDialog(context, ref, plan),
          ),
        ],
      ),
    );
  }

  void _showRestockDialog(
    BuildContext context,
    WidgetRef ref,
    InventoryReplenishmentPlan plan,
  ) {
    showInventoryDialog<void>(
      context: context,
      builder: (dialogContext) {
        return LowStockRestockDialog(
          plan: plan,
          onCancel: () => Navigator.of(dialogContext).pop(),
          onSubmit: (draft) {
            _applyRestock(ref, plan, draft);
            Navigator.of(dialogContext).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${plan.record.productName} restocked successfully',
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _applyRestock(
    WidgetRef ref,
    InventoryReplenishmentPlan plan,
    InventoryRestockDraft draft,
  ) {
    final application = buildInventoryRestockApplication(
      plan: plan,
      draft: draft,
    );

    ref
        .read(inventoryItemsProvider.notifier)
        .updateQuantity(application.itemId, application.updatedQuantity);

    ref
        .read(inventoryMovementsProvider.notifier)
        .addMovement(application.movement);
  }

  void _createPurchaseOrderDraft(
    BuildContext context,
    WidgetRef ref,
    InventoryPurchaseOrderCreateDraft draft,
  ) {
    final issue = validateInventoryPurchaseOrderCreateDraft(draft);
    if (issue != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(inventoryPurchaseOrderCreateIssueLabel(issue))),
      );
      return;
    }

    final now = DateTime.now();
    final order = draft.toPurchaseOrder(
      id: inventoryPurchaseOrderIdForDate(now),
      orderDate: now,
      status: OrderStatus.draft,
    );

    ref.read(purchaseOrdersProvider.notifier).addPurchaseOrder(order);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${draft.itemCount} PO lines saved as draft'),
        action: SnackBarAction(
          label: 'View draft',
          onPressed: () => _openGeneratedPurchaseOrder(context, ref, order.id),
        ),
      ),
    );
  }

  void _openGeneratedPurchaseOrder(
    BuildContext context,
    WidgetRef ref,
    String orderId,
  ) {
    ref.read(purchaseOrderFilterProvider.notifier).state = orderId;
    Navigator.of(
      context,
    ).pushNamed(inventoryPurchaseOrdersDeepLink(query: orderId));
  }
}
