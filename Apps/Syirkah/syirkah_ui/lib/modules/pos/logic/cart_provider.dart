import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>(
  (ref) => CartNotifier(),
);

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addItem(CartItem item) {
  final existingItem = state.firstWhereOrNull((element) => element.name == item.name);
    if (existingItem != null) {
      state = state.map((element) => element.name == item.name ? item : element).toList();
    } else {
      state = [...state, item];
    }
  }

  void removeItem(CartItem item) {
    state = state.where((element) => element.name != item.name).toList();
  }

  void updateQuantity(CartItem item, int quantity) {
    state = state.map((element) => element.name == item.name ? item.copyWith(quantity: quantity) : element).toList();
  }
}


class CartItem {
  final String name;
  final double price;
  final int quantity;

  CartItem({
    required this.name,
    required this.price,
    required this.quantity,
  });

  CartItem copyWith({
    String? name,
    double? price,
    int? quantity,
  }) {
    return CartItem(
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
    );
  }
}
