import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../ecommerce/order/cart_item.dart';
import '../../../ecommerce/order/order.dart';

import '../../../product/models/product.dart';
import '../../../product/states/product_provider.dart';

final categoriesProvider = Provider<List<String>>((ref) {
  final products = ref.watch(productsProvider).products ?? const <Product>[];
  return products
      .map((product) => product.category ?? 'Uncategorized')
      .toSet()
      .toList();
});

final filteredProductsProvider =
    StateNotifierProvider<FilteredProductsNotifier, List<Product>>((ref) {
      return FilteredProductsNotifier(
        ref.watch(productsProvider).products ?? const <Product>[],
      );
    });

class FilteredProductsNotifier extends StateNotifier<List<Product>> {
  final List<Product> allProducts;
  String _searchQuery = '';
  String? _selectedCategory;

  FilteredProductsNotifier(this.allProducts) : super(allProducts);

  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    _filterProducts();
  }

  void setCategory(String? category) {
    _selectedCategory = category;
    _filterProducts();
  }

  void _filterProducts() {
    state =
        allProducts.where((product) {
          final matchesSearch = product.name.toLowerCase().contains(
            _searchQuery,
          );
          final matchesCategory =
              _selectedCategory == null ||
              product.category == _selectedCategory;
          return matchesSearch && matchesCategory;
        }).toList();
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addProduct(Product product) {
    final existingIndex = state.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex >= 0) {
      final updatedCart = [...state];
      updatedCart[existingIndex].quantity += 1;
      state = updatedCart;
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
        state.map((item) {
          if (item.product.id == productId) {
            return CartItem(product: item.product, quantity: quantity);
          }
          return item;
        }).toList();
  }

  void clearCart() {
    state = [];
  }

  double get total => state.fold(0, (sum, item) => sum + item.total);
}

final recentOrdersProvider = StateNotifierProvider<OrdersNotifier, List<Order>>(
  (ref) {
    return OrdersNotifier();
  },
);

class OrdersNotifier extends StateNotifier<List<Order>> {
  OrdersNotifier() : super([]);

  void addOrder(
    List<CartItem> cartItems,
    double total,
    PaymentMethod paymentMethod,
  ) {
    final newOrder = Order(
      id: 'ORD${DateTime.now().millisecondsSinceEpoch}',
      items: cartItems,
      total: total,
      dateTime: DateTime.now(),
      paymentMethod: paymentMethod,
    );

    state = [newOrder, ...state];
  }

  void updateOrderStatus(String orderId, OrderStatus status) {
    state =
        state.map((order) {
          if (order.id == orderId) {
            return Order(
              id: order.id,
              items: order.items,
              total: order.total,
              dateTime: order.dateTime,
              paymentMethod: order.paymentMethod,
              status: status,
            );
          }
          return order;
        }).toList();
  }
}
