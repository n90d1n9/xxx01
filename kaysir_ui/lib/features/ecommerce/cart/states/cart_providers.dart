import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../product/models/product.dart';
import '../../order/cart_item.dart';

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addProduct(Product product) {
    final existingIndex = state.indexWhere(
      (cartItem) => cartItem.product.id == product.id,
    );

    if (existingIndex >= 0) {
      state =
          state.map((cartItem) {
            if (cartItem.product.id != product.id) return cartItem;
            return CartItem(
              product: cartItem.product,
              quantity: cartItem.quantity + 1,
            );
          }).toList();
    } else {
      state = [...state, CartItem(product: product)];
    }
  }

  void removeProduct(String productId) {
    state = state.where((item) => item.product.id != productId).toList();
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeProduct(productId);
      return;
    }

    state =
        state.map((cartItem) {
          if (cartItem.product.id != productId) return cartItem;
          return CartItem(product: cartItem.product, quantity: quantity);
        }).toList();
  }

  void clearCart() {
    state = const [];
  }

  double get total => state.fold(0, (sum, item) => sum + item.total);
}
