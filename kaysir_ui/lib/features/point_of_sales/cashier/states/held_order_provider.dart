import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../order/models/order.dart';

final heldOrdersProvider =
    StateNotifierProvider<HeldOrdersNotifier, List<HeldOrder>>((ref) {
      return HeldOrdersNotifier();
    });

final heldOrderCountProvider = Provider<int>((ref) {
  return ref.watch(heldOrdersProvider).length;
});

class HeldOrder {
  final String id;
  final Order order;
  final DateTime heldAt;
  final String? note;

  const HeldOrder({
    required this.id,
    required this.order,
    required this.heldAt,
    this.note,
  });

  int get itemCount {
    return order.items.fold(0, (sum, item) => sum + item.quantity);
  }

  String get shortOrderId {
    final normalized =
        order.id.startsWith('temp_') ? order.id.substring(5) : order.id;
    if (normalized.length <= 6) return normalized;
    return normalized.substring(normalized.length - 6);
  }
}

class HeldOrdersNotifier extends StateNotifier<List<HeldOrder>> {
  HeldOrdersNotifier() : super(const []);

  HeldOrder hold(Order order, {String? note}) {
    final heldOrder = HeldOrder(
      id: 'hold_${DateTime.now().millisecondsSinceEpoch}',
      order: order,
      heldAt: DateTime.now(),
      note: note?.trim().isEmpty == true ? null : note?.trim(),
    );

    state = [heldOrder, ...state];
    return heldOrder;
  }

  HeldOrder? take(String holdId) {
    HeldOrder? heldOrder;
    final remainingOrders = <HeldOrder>[];

    for (final order in state) {
      if (order.id == holdId) {
        heldOrder = order;
      } else {
        remainingOrders.add(order);
      }
    }

    state = remainingOrders;
    return heldOrder;
  }

  void remove(String holdId) {
    state = state.where((order) => order.id != holdId).toList();
  }

  void clear() {
    state = const [];
  }
}
