import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/widgets/ui/app_list_surface.dart';
import 'package:kaysir/widgets/ui/app_text_cluster.dart';

import '../../../ecommerce/order/order.dart';
import '../../models/inventory_purchase_order_detail.dart';
import '../../models/purchase_order.dart';
import '../../states/purchase_order_provider.dart';
import '../../widgets/inventory_navigation_drawer.dart';
import '../../widgets/inventory_navigation_scaffold.dart';
import '../../widgets/inventory_purchase_order_detail_components.dart';

class PurchaseOrderDetailScreen extends ConsumerWidget {
  const PurchaseOrderDetailScreen({super.key, required this.order});

  final PurchaseOrder order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canPop = Navigator.of(context).canPop();
    final currentOrder = _currentOrder(ref.watch(purchaseOrdersProvider));
    final detail = buildInventoryPurchaseOrderDetail(
      order: currentOrder,
      asOfDate: DateTime.now(),
    );

    return InventoryNavigationScaffold(
      currentDestination: InventoryNavigationDestination.purchaseOrders,
      isCanonicalDestination: false,
      appBar: AppBar(
        leading: canPop ? const BackButton() : null,
        title: const Text('Purchase Order Details'),
        actions: const [
          InventoryNavigationDrawerAction(onlyWhenRouteCanPop: true),
        ],
      ),
      body: AppListSurface(
        padding: const EdgeInsets.all(20),
        sectionSpacing: 20,
        header: AppTextCluster(
          eyebrow: 'Receiving Detail',
          title: detail.id,
          subtitle:
              '${detail.supplierLabel} | ${detail.statusLabel} | ${detail.totalUnits} units',
          titleStyle: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        metrics: InventoryPurchaseOrderDetailSummaryGrid(detail: detail),
        children: [
          InventoryPurchaseOrderOverviewPanel(detail: detail),
          InventoryPurchaseOrderItemsPanel(detail: detail),
          InventoryPurchaseOrderActionsPanel(
            detail: detail,
            onReceive:
                () => _updateStatus(context, ref, detail, OrderStatus.received),
            onCancel:
                () =>
                    _updateStatus(context, ref, detail, OrderStatus.cancelled),
          ),
        ],
      ),
    );
  }

  PurchaseOrder _currentOrder(List<PurchaseOrder> orders) {
    for (final candidate in orders) {
      if (candidate.id == order.id) {
        return candidate;
      }
    }

    return order;
  }

  void _updateStatus(
    BuildContext context,
    WidgetRef ref,
    InventoryPurchaseOrderDetail detail,
    OrderStatus status,
  ) {
    ref
        .read(purchaseOrdersProvider.notifier)
        .updateOrderStatus(detail.id, status);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${detail.id} updated to ${status.name}')),
    );
  }
}
