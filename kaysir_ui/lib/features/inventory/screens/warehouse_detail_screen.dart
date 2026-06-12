import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/widgets/ui/app_action_button.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_list_surface.dart';
import 'package:kaysir/widgets/ui/app_text_cluster.dart';

import '../inventory_routes.dart';
import '../models/inventory_filter_deep_link.dart';
import '../models/inventory_stock_record.dart';
import '../models/inventory_warehouse_detail.dart';
import '../states/inventory_item_provider.dart';
import '../states/inventory_projection_provider.dart';
import '../states/warehouse_provider.dart';
import '../widgets/inventory_navigation_drawer.dart';
import '../widgets/inventory_navigation_scaffold.dart';
import '../widgets/inventory_warehouse_detail_components.dart';

class WarehouseDetailPage extends ConsumerWidget {
  const WarehouseDetailPage({super.key, this.warehouseId});

  final String? warehouseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = buildInventoryWarehouseDetail(
      warehouseId: warehouseId,
      warehouses: ref.watch(warehousesProvider),
      inventoryItems: ref.watch(inventoryItemsProvider),
      stockRecords: ref.watch(inventoryStockRecordsProvider),
      movementRecords: ref.watch(inventoryMovementRecordsProvider),
    );

    return InventoryNavigationScaffold(
      currentDestination: InventoryNavigationDestination.warehouses,
      isCanonicalDestination: false,
      appBar: AppBar(
        title: const Text('Warehouse Detail'),
        actions: [
          IconButton(
            tooltip: 'Open warehouse directory',
            icon: const Icon(Icons.list_alt_rounded),
            onPressed: () => _openDirectory(context),
          ),
        ],
      ),
      body:
          detail == null
              ? _WarehouseDetailNotFound(
                onOpenDirectory: () => _openDirectory(context),
              )
              : AppListSurface(
                padding: const EdgeInsets.all(20),
                sectionSpacing: 20,
                header: AppTextCluster(
                  eyebrow: 'Warehouse Management',
                  title: detail.warehouse.name,
                  subtitle:
                      '${detail.warehouse.branchLabel} | ${detail.warehouse.location} | ${detail.stockLineCount} stock lines',
                  titleStyle: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
                metrics: InventoryWarehouseDetailSummaryGrid(detail: detail),
                children: [
                  InventoryWarehouseDetailActionPanel(
                    warehouseName: detail.warehouse.name,
                    onOpenStock:
                        () => _openRoute(
                          context,
                          inventoryStockDeepLink(
                            branch: detail.branchFilterValue,
                            warehouseId: detail.warehouse.id,
                          ),
                        ),
                    onOpenMovements:
                        () => _openRoute(
                          context,
                          inventoryMovementsDeepLink(
                            branch: detail.branchFilterValue,
                            warehouseId: detail.warehouse.id,
                          ),
                        ),
                    onOpenCapacity:
                        () => _openRoute(
                          context,
                          inventoryWarehouseCapacityDeepLink(
                            branch: detail.branchFilterValue,
                            warehouseId: detail.warehouse.id,
                          ),
                        ),
                    onOpenBranch:
                        () => _openRoute(
                          context,
                          inventoryWarehouseBranchDetailDeepLink(
                            branchKey: detail.branchFilterValue,
                          ),
                        ),
                    onOpenDirectory: () => _openDirectory(context),
                  ),
                  InventoryWarehouseDetailCapacityPanel(detail: detail),
                  InventoryWarehouseDetailStockHealthPanel(detail: detail),
                  InventoryWarehouseDetailReplenishmentPanel(
                    detail: detail,
                    onOpenStockQueue:
                        () => _openRoute(
                          context,
                          inventoryStockDeepLink(
                            branch: detail.branchFilterValue,
                            warehouseId: detail.warehouse.id,
                            filter: InventoryStockFilter.needsAttention,
                          ),
                        ),
                  ),
                  InventoryWarehouseDetailCategoryMixPanel(detail: detail),
                  InventoryWarehouseDetailStockPanel(
                    detail: detail,
                    onOpenStock:
                        () => _openRoute(
                          context,
                          inventoryStockDeepLink(
                            branch: detail.branchFilterValue,
                            warehouseId: detail.warehouse.id,
                          ),
                        ),
                    onOpenAttentionStock:
                        () => _openRoute(
                          context,
                          inventoryStockDeepLink(
                            branch: detail.branchFilterValue,
                            warehouseId: detail.warehouse.id,
                            filter: InventoryStockFilter.needsAttention,
                          ),
                        ),
                  ),
                  InventoryWarehouseDetailMovementFlowPanel(
                    detail: detail,
                    onOpenMovementFilter:
                        (filter) => _openRoute(
                          context,
                          inventoryMovementsDeepLink(
                            branch: detail.branchFilterValue,
                            warehouseId: detail.warehouse.id,
                            filter: filter,
                          ),
                        ),
                  ),
                  InventoryWarehouseDetailMovementPanel(
                    detail: detail,
                    onOpenMovements:
                        () => _openRoute(
                          context,
                          inventoryMovementsDeepLink(
                            branch: detail.branchFilterValue,
                            warehouseId: detail.warehouse.id,
                          ),
                        ),
                  ),
                ],
              ),
    );
  }

  void _openDirectory(BuildContext context) {
    _openRoute(context, InventoryRoutes.warehouses);
  }

  void _openRoute(BuildContext context, String route) {
    Navigator.of(context).pushReplacementNamed(route);
  }
}

class _WarehouseDetailNotFound extends StatelessWidget {
  const _WarehouseDetailNotFound({required this.onOpenDirectory});

  final VoidCallback onOpenDirectory;

  @override
  Widget build(BuildContext context) {
    return AppListSurface(
      padding: const EdgeInsets.all(20),
      emptyState: AppEmptyState(
        title: 'Warehouse not found',
        message:
            'Choose a warehouse from the directory or branch drilldown to inspect location-level operations.',
        icon: Icons.warehouse_outlined,
        action: AppActionButton(
          label: 'Open warehouse directory',
          icon: Icons.list_alt_rounded,
          onPressed: onOpenDirectory,
        ),
      ),
      children: const [],
    );
  }
}
