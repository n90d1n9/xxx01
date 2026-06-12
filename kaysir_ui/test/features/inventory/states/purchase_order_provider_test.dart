import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/ecommerce/order/order.dart';
import 'package:kaysir/features/inventory/models/purchase_order.dart';
import 'package:kaysir/features/inventory/models/purchase_order_item.dart';
import 'package:kaysir/features/inventory/states/purchase_order_provider.dart';

void main() {
  test('purchase order notifier updates order status', () {
    final container = _container();
    addTearDown(container.dispose);

    container
        .read(purchaseOrdersProvider.notifier)
        .updateOrderStatus('PO-1', OrderStatus.received);

    expect(
      container.read(purchaseOrdersProvider).single.status,
      OrderStatus.received,
    );
  });

  test('filtered purchase orders search safe vendor and item labels', () {
    final container = _container();
    addTearDown(container.dispose);

    container.read(purchaseOrderFilterProvider.notifier).state = 'adapter';

    expect(container.read(filteredPurchaseOrdersProvider).single.id, 'PO-1');

    container.read(purchaseOrderFilterProvider.notifier).state = 'jakarta';

    expect(container.read(filteredPurchaseOrdersProvider).single.id, 'PO-1');
  });
}

ProviderContainer _container() {
  return ProviderContainer(
    overrides: [
      purchaseOrdersProvider.overrideWith((ref) => _SeededPurchaseOrders()),
    ],
  );
}

class _SeededPurchaseOrders extends PurchaseOrdersNotifier {
  _SeededPurchaseOrders() : super() {
    state = [
      PurchaseOrder(
        id: 'PO-1',
        vendorName: 'Jakarta Supply',
        orderDate: DateTime(2026, 5, 31),
        totalAmount: 20,
        status: OrderStatus.pending,
        items: [
          PurchaseOrderItem(
            id: 'i1',
            name: 'Adapter',
            quantity: 2,
            unitPrice: 10,
            sku: 'AD-001',
          ),
        ],
      ),
    ];
  }
}
