import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/order/models/order_workspace_sla.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('workspace SLA summary buckets active order ages', () {
    final now = DateTime(2026, 5, 31, 12);
    final summary = OrderWorkspaceSlaSummary.fromOrders(
      now: now,
      orders: [
        _order(
          id: 'fresh',
          createdAt: now.subtract(const Duration(minutes: 8)),
        ),
        _order(
          id: 'watch',
          createdAt: now.subtract(const Duration(minutes: 45)),
        ),
        _order(id: 'stale', createdAt: now.subtract(const Duration(hours: 3))),
        _order(id: 'late', createdAt: now.subtract(const Duration(hours: 8))),
        _order(
          id: 'done',
          status: 'completed',
          createdAt: now.subtract(const Duration(hours: 9)),
        ),
      ],
    );

    expect(summary.orderCount, 5);
    expect(summary.activeOrderCount, 4);
    expect(summary.terminalOrderCount, 1);
    expect(summary.title, 'Aging queue needs escalation');
    expect(summary.badgeLabel, '4 active');
    expect(summary.oldestActiveAgeLabel, '8h');
    expect(summary.tone, OrderWorkspaceSlaTone.danger);
    expect(summary.bands.map((band) => band.id), [
      'fresh',
      'watch',
      'stale',
      'escalate',
    ]);
    expect(summary.bands.map((band) => band.count), [1, 1, 1, 1]);
  });

  test('workspace SLA summary treats completed and cancelled as closed', () {
    final now = DateTime(2026, 5, 31, 12);
    final summary = OrderWorkspaceSlaSummary.fromOrders(
      now: now,
      orders: [
        _order(
          id: 'done',
          status: 'completed',
          createdAt: now.subtract(const Duration(hours: 8)),
        ),
        _order(
          id: 'void',
          status: 'cancelled',
          createdAt: now.subtract(const Duration(hours: 9)),
        ),
      ],
    );

    expect(summary.activeOrderCount, 0);
    expect(summary.terminalOrderCount, 2);
    expect(summary.title, 'No active aging risk');
    expect(summary.summary, contains('2 visible orders'));
    expect(summary.oldestActiveAgeLabel, '0m');
    expect(summary.tone, OrderWorkspaceSlaTone.success);
    expect(summary.bands.map((band) => band.count), [0, 0, 0, 0]);
  });

  test('workspace SLA summary clamps future timestamps into fresh work', () {
    final now = DateTime(2026, 5, 31, 12);
    final summary = OrderWorkspaceSlaSummary.fromOrders(
      now: now,
      orders: [
        _order(id: 'future', createdAt: now.add(const Duration(hours: 1))),
      ],
    );

    expect(summary.title, 'Queue age is fresh');
    expect(summary.oldestActiveAgeLabel, '0m');
    expect(summary.bands.first.count, 1);
  });
}

Order _order({
  required String id,
  required DateTime createdAt,
  String status = 'processing',
}) {
  final product = Product(id: '$id-product', name: 'Coffee', price: 50000);

  return Order(
    id: id,
    items: [
      OrderItem(
        id: '$id-line',
        product: product,
        quantity: 1,
        unitPrice: product.price,
        discount: 0,
      ),
    ],
    payments: const [],
    terminal: Terminal(
      id: 'terminal',
      name: 'Terminal',
      location: 'Online',
      isActive: true,
    ),
    appliedPromotions: const [],
    createdAt: createdAt,
    status: status,
  );
}
