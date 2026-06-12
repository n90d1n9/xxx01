import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/widgets/ui/app_list_surface.dart';
import 'package:kaysir/widgets/ui/app_text_cluster.dart';

import '../models/inventory_report_catalog.dart';
import '../states/inventory_item_provider.dart';
import '../states/inventory_movement_provider.dart';
import '../states/low_stock_items_provider.dart';
import '../states/product_provider.dart';
import '../states/warehouse_provider.dart';
import '../widgets/inventory_navigation_drawer.dart';
import '../widgets/inventory_navigation_scaffold.dart';
import '../widgets/inventory_report_hub_components.dart';
import 'inventory_valuation_screen.dart';
import 'low_stock_report_screen.dart';
import 'stock_movement_report_page.dart';
import 'warehouse_capacity_screen.dart';

class ReportsPage extends ConsumerWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);
    final inventoryItems = ref.watch(inventoryItemsProvider);
    final movements = ref.watch(inventoryMovementsProvider);
    final lowStockItems = ref.watch(lowStockItemsProvider);
    final warehouses = ref.watch(warehousesProvider);
    final stats = buildInventoryReportHubStats(
      productCount: products.length,
      stockLineCount: inventoryItems.length,
      movementCount: movements.length,
      lowStockCount: lowStockItems.length,
      warehouseCount: warehouses.length,
    );

    return InventoryNavigationScaffold(
      currentDestination: InventoryNavigationDestination.reports,
      appBar: AppBar(title: const Text('Reports')),
      body: AppListSurface(
        padding: const EdgeInsets.all(20),
        sectionSpacing: 20,
        header: AppTextCluster(
          eyebrow: 'Inventory Intelligence',
          title: 'Report Hub',
          subtitle:
              '${stats.readyReportCount} reports ready from ${stats.stockLineCount} stock lines',
          titleStyle: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        metrics: InventoryReportHubSummary(stats: stats),
        children: [
          InventoryReportCatalogPanel(
            stats: stats,
            onGenerate: (type) => _openReport(context, ref, type),
          ),
        ],
      ),
    );
  }

  void _openReport(
    BuildContext context,
    WidgetRef ref,
    InventoryReportType type,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => _pageForReportType(ref, type),
      ),
    );
  }

  Widget _pageForReportType(WidgetRef ref, InventoryReportType type) {
    switch (type) {
      case InventoryReportType.valuation:
        return InventoryValuationReportPage(
          products: ref.read(productsProvider),
          inventoryItems: ref.read(inventoryItemsProvider),
          warehouses: ref.read(warehousesProvider),
        );
      case InventoryReportType.movementHistory:
        return StockMovementReportPage(
          products: ref.read(productsProvider),
          movements: ref.read(inventoryMovementsProvider),
          warehouses: ref.read(warehousesProvider),
        );
      case InventoryReportType.lowStock:
        return LowStockReportPage(
          products: ref.read(productsProvider),
          lowStockItems: ref.read(lowStockItemsProvider),
          warehouses: ref.read(warehousesProvider),
        );
      case InventoryReportType.warehouseCapacity:
        return WarehouseCapacityReportPage(
          warehouses: ref.read(warehousesProvider),
          inventoryItems: ref.read(inventoryItemsProvider),
        );
    }
  }
}
