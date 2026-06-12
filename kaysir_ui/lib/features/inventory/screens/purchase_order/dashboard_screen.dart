import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/widgets/ui/app_list_surface.dart';
import 'package:kaysir/widgets/ui/app_text_cluster.dart';

import '../../../product/screens/product_detail_screen.dart';
import '../../../product/states/stock_movement_provider.dart';
import '../../models/inventory_purchase_order_dashboard.dart';
import '../../models/inventory_purchase_order_workspace.dart';
import '../../states/product_provider.dart';
import '../../states/purchase_order_provider.dart';
import '../../widgets/inventory_navigation_drawer.dart';
import '../../widgets/inventory_navigation_scaffold.dart';
import '../../widgets/inventory_purchase_order_dashboard_components.dart';
import 'purchase_order_detail_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canPop = Navigator.of(context).canPop();
    final dashboard = buildInventoryPurchaseOrderDashboard(
      products: ref.watch(productsProvider),
      stockMovements: ref.watch(stockMovementsProvider),
      purchaseOrders: ref.watch(purchaseOrdersProvider),
      asOfDate: DateTime.now(),
    );

    return InventoryNavigationScaffold(
      currentDestination: InventoryNavigationDestination.purchaseOrders,
      isCanonicalDestination: false,
      appBar: AppBar(
        leading: canPop ? const BackButton() : null,
        title: const Text('Purchase Order Dashboard'),
        actions: const [
          InventoryNavigationDrawerAction(onlyWhenRouteCanPop: true),
        ],
      ),
      body: AppListSurface(
        padding: const EdgeInsets.all(20),
        sectionSpacing: 20,
        header: AppTextCluster(
          eyebrow: 'Inventory Buying',
          title: 'Purchase Order Dashboard',
          subtitle:
              '${dashboard.summary.receivingOrderCount} orders waiting, ${dashboard.summary.lowStockProductCount} low-stock products, ${dashboard.summary.recentMovementCount} recent stock moves',
          titleStyle: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        metrics: InventoryPurchaseOrderDashboardSummaryGrid(
          summary: dashboard.summary,
        ),
        children: [
          InventoryPurchaseOrderDashboardGrid(
            dashboard: dashboard,
            onOpenProduct:
                (record) => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder:
                        (context) =>
                            ProductDetailScreen(productId: record.product.id),
                  ),
                ),
            onOpenOrder: (record) => _openPurchaseOrderDetail(context, record),
          ),
        ],
      ),
    );
  }

  void _openPurchaseOrderDetail(
    BuildContext context,
    InventoryPurchaseOrderRecord record,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => PurchaseOrderDetailScreen(order: record.order),
      ),
    );
  }
}
