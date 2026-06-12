import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_filter_deep_link.dart';
import 'package:kaysir/features/inventory/models/inventory_movement_record.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_record.dart';

void main() {
  test('inventoryStockDeepLink builds compact stock filter URLs', () {
    expect(
      inventoryStockDeepLink(
        branch: 'branch-jakarta',
        warehouseId: 'w1',
        filter: InventoryStockFilter.needsAttention,
      ),
      '/inventory/stock?branch=branch-jakarta&warehouse=w1&filter=attention',
    );

    expect(inventoryStockDeepLink(), '/inventory/stock');
  });

  test('inventoryMovementsDeepLink builds movement filter URLs', () {
    expect(
      inventoryMovementsDeepLink(
        branch: 'branch-jakarta',
        query: 'PO-001',
        filter: InventoryMovementFilter.inbound,
      ),
      '/inventory/movements?branch=branch-jakarta&q=PO-001&filter=inbound',
    );

    expect(inventoryMovementsDeepLink(), '/inventory/movements');
  });

  test('inventoryPurchaseOrdersDeepLink builds search URLs', () {
    expect(
      inventoryPurchaseOrdersDeepLink(query: 'PO-123'),
      '/inventory/purchase-orders?q=PO-123',
    );

    expect(inventoryPurchaseOrdersDeepLink(), '/inventory/purchase-orders');
  });

  test('warehouse deep links preserve branch scope', () {
    expect(
      inventoryWarehouseBranchDetailDeepLink(branchKey: 'branch-jakarta'),
      '/inventory/warehouses/branch?branch=branch-jakarta',
    );
    expect(
      inventoryWarehouseDetailDeepLink(warehouseId: 'w1'),
      '/inventory/warehouses/detail?warehouse=w1',
    );
    expect(
      inventoryWarehouseCapacityDeepLink(
        branch: 'branch-jakarta',
        warehouseId: 'w1',
      ),
      '/inventory/warehouses/capacity?branch=branch-jakarta&warehouse=w1',
    );
  });

  test('inventoryBrowserDeepLink builds static-host friendly hash URLs', () {
    expect(
      inventoryBrowserDeepLink(
        '/inventory/stock?branch=branch-jakarta',
        baseUri: Uri.parse('https://kaysir.test/app/'),
      ),
      'https://kaysir.test/app/#/inventory/stock?branch=branch-jakarta',
    );

    expect(
      inventoryBrowserDeepLink(
        '/inventory/movements?filter=inbound',
        baseUri: Uri.parse('https://kaysir.test/inventory/stock'),
      ),
      'https://kaysir.test/#/inventory/movements?filter=inbound',
    );
  });

  test('inventory filter query parsers accept stable aliases', () {
    expect(
      inventoryStockFilterFromQuery('needs_attention'),
      InventoryStockFilter.needsAttention,
    );
    expect(
      inventoryStockFilterFromQuery('in_stock'),
      InventoryStockFilter.inStock,
    );
    expect(inventoryStockFilterFromQuery('unknown'), InventoryStockFilter.all);

    expect(
      inventoryMovementFilterFromQuery('stock-opname'),
      InventoryMovementFilter.stockOpname,
    );
    expect(
      inventoryMovementFilterFromQuery('adjust'),
      InventoryMovementFilter.adjustment,
    );
    expect(
      inventoryMovementFilterFromQuery('unknown'),
      InventoryMovementFilter.all,
    );
  });
}
