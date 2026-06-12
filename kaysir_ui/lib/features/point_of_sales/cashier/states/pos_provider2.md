import 'package:riverpod/riverpod.dart';

import '../../../product/models/product.dart';
import '../../../cashier/states/pos_states.dart'/pos_states.dart';
/* 
class POSState {
  final List<Product> cart;
  final String lastAction;
  final bool isPaymentMode;
  final String searchQuery;
  final double customAmount;
  final bool isDiscountMode;

  POSState({
    this.cart = const [],
    this.lastAction = '',
    this.isPaymentMode = false,
    this.searchQuery = '',
    this.customAmount = 0.0,
    this.isDiscountMode = false,
  });

  double get total => cart.fold(0, (sum, item) => sum + item.total!);

  POSState copyWith({
    List<Product>? cart,
    String? lastAction,
    bool? isPaymentMode,
    String? searchQuery,
    double? customAmount,
    bool? isDiscountMode,
  }) {
    return POSState(
      cart: cart ?? this.cart,
      lastAction: lastAction ?? this.lastAction,
      isPaymentMode: isPaymentMode ?? this.isPaymentMode,
      searchQuery: searchQuery ?? this.searchQuery,
      customAmount: customAmount ?? this.customAmount,
      isDiscountMode: isDiscountMode ?? this.isDiscountMode,
    );
  }
} */

class POSNotifier extends StateNotifier<POSState> {
  POSNotifier() : super(POSState());

  void addToCart(Product product) {
    final existingIndex = state.cart.indexWhere((item) => item.id == product.id);
    if (existingIndex >= 0) {
      final updatedCart = [...state.cart];
      updatedCart[existingIndex] = updatedCart[existingIndex].copyWith(
        quantity: updatedCart[existingIndex].quantity! + 1,
      );
      state = state.copyWith(
        cart: updatedCart,
        lastAction: 'Added ${product.name} to cart',
      );
    } else {
      state = state.copyWith(
        cart: [...state.cart, product],
        lastAction: 'Added ${product.name} to cart',
      );
    }
  }

  void removeFromCart(String productId) {
    state = state.copyWith(
      cart: state.cart.where((item) => item.id != productId).toList(),
      lastAction: 'Removed item from cart',
    );
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }

    final updatedCart = state.cart.map((item) {
      if (item.id == productId) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();

    state = state.copyWith(
      cart: updatedCart,
      lastAction: 'Updated quantity',
    );
  }

  void togglePaymentMode() {
    state = state.copyWith(
      isPaymentMode: !state.isPaymentMode,
      lastAction: state.isPaymentMode ? 'Exited payment mode' : 'Entered payment mode',
    );
  }

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void toggleDiscountMode() {
    state = state.copyWith(
      isDiscountMode: !state.isDiscountMode,
      lastAction: state.isDiscountMode ? 'Exited discount mode' : 'Entered discount mode',
    );
  }

  void clearCart() {
    state = state.copyWith(
      cart: [],
      lastAction: 'Cleared cart',
      isPaymentMode: false,
      isDiscountMode: false,
    );
  }

  void processPayment() {
    // Implement actual payment processing here
    clearCart();
  }
}

final posProvider = StateNotifierProvider<POSNotifier, POSState>((ref) => POSNotifier());
