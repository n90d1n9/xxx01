import 'package:flutter_riverpod/legacy.dart';

import '../models/order.dart';

class OrderNotifier extends StateNotifier<List<Order>> {
  OrderNotifier()
    : super([
        // Some initial dummy data
        Order(
          id: '1',
          orderTime: DateTime.now().subtract(const Duration(hours: 2)),
          items: [
            OrderItem(
              recipeId: '1',
              name: 'Tomato Soup',
              quantity: 2,
              price: 8.0,
            ),
          ],
          status: OrderStatus.processing,
          customerName: 'John Doe',
          totalAmount: 16.0,
          notes: 'Extra hot',
        ),
      ]);

  void addOrder(Order order) {
    state = [...state, order];
  }

  void updateOrderStatus(String id, OrderStatus newStatus) {
    state = state.map((order) {
      if (order.id == id) {
        return order.copyWith(status: newStatus);
      }
      return order;
    }).toList();
  }

  void deleteOrder(String id) {
    state = state.where((order) => order.id != id).toList();
  }

  List<Order> getOrdersByStatus(OrderStatus status) {
    return state.where((order) => order.status == status).toList();
  }

  double getTotalSalesForDay(DateTime day) {
    return state
        .where(
          (order) =>
              order.orderTime.year == day.year &&
              order.orderTime.month == day.month &&
              order.orderTime.day == day.day &&
              order.status != OrderStatus.cancelled,
        )
        .fold(0, (total, order) => total + order.totalAmount);
  }
}

final orderProvider = StateNotifierProvider<OrderNotifier, List<Order>>(
  (ref) => OrderNotifier(),
);
