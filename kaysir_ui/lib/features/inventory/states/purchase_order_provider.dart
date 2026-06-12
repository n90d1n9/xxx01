// Providers
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/features/ecommerce/order/order.dart';

import '../models/inventory_purchase_order_workspace.dart';
import '../models/purchase_order.dart';
import '../models/purchase_order_item.dart';

final purchaseOrdersProvider =
    StateNotifierProvider<PurchaseOrdersNotifier, List<PurchaseOrder>>((ref) {
      return PurchaseOrdersNotifier();
    });

final filteredPurchaseOrdersProvider = Provider<List<PurchaseOrder>>((ref) {
  final filter = ref.watch(purchaseOrderFilterProvider);
  final orders = ref.watch(purchaseOrdersProvider);

  if (filter.isEmpty) return orders;

  return orders.where((order) {
    final record =
        buildInventoryPurchaseOrderRecords(
          orders: [order],
          asOfDate: DateTime.now(),
        ).single;
    return filterInventoryPurchaseOrderRecords(
      records: [record],
      query: filter,
      filter: InventoryPurchaseOrderFilter.all,
    ).isNotEmpty;
  }).toList();
});

final purchaseOrderFilterProvider = StateProvider<String>((ref) => '');

final selectedOrderProvider = StateProvider<PurchaseOrder?>((ref) => null);

// Notifier
class PurchaseOrdersNotifier extends StateNotifier<List<PurchaseOrder>> {
  PurchaseOrdersNotifier()
    : super([
        // Sample data
        PurchaseOrder(
          id: 'PO-2025-001',
          vendorName: 'Tech Supplies Inc.',
          orderDate: DateTime.now().subtract(const Duration(days: 5)),
          totalAmount: 12750.00,
          status: OrderStatus.pending,
          expectedDeliveryDate: DateTime.now().add(const Duration(days: 10)),
          items: [
            PurchaseOrderItem(
              id: 'ITEM-001',
              name: 'Laptop Pro X1',
              quantity: 5,
              unitPrice: 1200.00,
              sku: 'LP-X1-2025',
            ),
            PurchaseOrderItem(
              id: 'ITEM-002',
              name: 'Monitor 32" 4K',
              quantity: 10,
              unitPrice: 375.00,
              sku: 'MON-4K-32',
            ),
          ],
        ),
        PurchaseOrder(
          id: 'PO-2025-002',
          vendorName: 'Office Essentials Co.',
          orderDate: DateTime.now().subtract(const Duration(days: 15)),
          totalAmount: 5480.75,
          status: OrderStatus.completed,
          expectedDeliveryDate: DateTime.now().subtract(
            const Duration(days: 2),
          ),
          items: [
            PurchaseOrderItem(
              id: 'ITEM-003',
              name: 'Ergonomic Chair',
              quantity: 15,
              unitPrice: 249.99,
              sku: 'CH-ERG-PRO',
            ),
            PurchaseOrderItem(
              id: 'ITEM-004',
              name: 'Standing Desk',
              quantity: 5,
              unitPrice: 349.99,
              sku: 'DSK-STD-01',
            ),
          ],
        ),
        PurchaseOrder(
          id: 'PO-2025-003',
          vendorName: 'Network Solutions Ltd.',
          orderDate: DateTime.now().subtract(const Duration(days: 3)),
          totalAmount: 8945.25,
          status: OrderStatus.received,
          expectedDeliveryDate: DateTime.now().add(const Duration(days: 7)),
          items: [
            PurchaseOrderItem(
              id: 'ITEM-005',
              name: 'Enterprise Router',
              quantity: 3,
              unitPrice: 1299.99,
              sku: 'NET-RTR-ENT',
            ),
            PurchaseOrderItem(
              id: 'ITEM-006',
              name: 'Network Switch 24-Port',
              quantity: 5,
              unitPrice: 789.45,
              sku: 'NET-SW-24P',
            ),
          ],
        ),
      ]);

  void addPurchaseOrder(PurchaseOrder order) {
    state = [...state, order];
  }

  void updatePurchaseOrder(PurchaseOrder updatedOrder) {
    state =
        state
            .map((order) => order.id == updatedOrder.id ? updatedOrder : order)
            .toList();
  }

  void deletePurchaseOrder(String id) {
    state = state.where((order) => order.id != id).toList();
  }

  void updateOrderStatus(String id, OrderStatus status) {
    state =
        state.map((order) {
          if (order.id != id) return order;
          return order.copyWith(status: status);
        }).toList();
  }
}
