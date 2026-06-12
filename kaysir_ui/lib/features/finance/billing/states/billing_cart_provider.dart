import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/billing_cart_item.dart';
import '../models/billing_product.dart';
import '../utils/billing_cart_summary.dart';

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

final cartItemsForTenantProvider = Provider.family<List<CartItem>, String>((
  ref,
  tenantId,
) {
  return ref
      .watch(cartProvider)
      .where((item) => item.tenantId == tenantId)
      .toList(growable: false);
});

final cartSummaryForTenantProvider =
    Provider.family<BillingCartSummary, String>((ref, tenantId) {
      return summarizeBillingCart(
        ref
            .watch(cartItemsForTenantProvider(tenantId))
            .map(
              (item) => BillingCartSummaryLine(
                id: item.product.id,
                name: item.product.name,
                unitPrice: item.product.price,
                quantity: item.quantity,
              ),
            ),
      );
    });

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super(const []);

  void addToCart(Product product, String tenantId) {
    final existingIndex = state.indexWhere(
      (item) => item.product.id == product.id && item.tenantId == tenantId,
    );

    if (existingIndex >= 0) {
      final updatedState = [...state];
      final existingItem = updatedState[existingIndex];
      updatedState[existingIndex] = CartItem(
        product: existingItem.product,
        quantity: existingItem.quantity + 1,
        tenantId: existingItem.tenantId,
      );
      state = updatedState;
      return;
    }

    state = [...state, CartItem(product: product, tenantId: tenantId)];
  }

  void removeFromCart(String productId, String tenantId) {
    state =
        state
            .where(
              (item) =>
                  !(item.product.id == productId && item.tenantId == tenantId),
            )
            .toList();
  }

  void updateQuantity(String productId, String tenantId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(productId, tenantId);
      return;
    }

    final updatedState = [...state];
    final index = updatedState.indexWhere(
      (item) => item.product.id == productId && item.tenantId == tenantId,
    );

    if (index >= 0) {
      final existingItem = updatedState[index];
      updatedState[index] = CartItem(
        product: existingItem.product,
        quantity: quantity,
        tenantId: existingItem.tenantId,
      );
      state = updatedState;
    }
  }

  void clearCart() {
    state = const [];
  }

  void clearTenantCart(String tenantId) {
    state = state.where((item) => item.tenantId != tenantId).toList();
  }

  BillingCartSummary getSummary({
    BillingPricingPolicy policy = const BillingPricingPolicy(),
  }) {
    return summarizeBillingCart(
      state.map(
        (item) => BillingCartSummaryLine(
          id: item.product.id,
          name: item.product.name,
          unitPrice: item.product.price,
          quantity: item.quantity,
        ),
      ),
      policy: policy,
    );
  }

  double getTotal() {
    return getSummary().total;
  }

  int getItemCount() {
    return getSummary().itemCount;
  }
}
