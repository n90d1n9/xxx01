import 'package:flutter_riverpod/legacy.dart';

import '../../../hardware/receipt/models/receipt.dart';
import '../../../product/models/product.dart';

class POSState {
  final List<Product> cart;
  final String lastAction;
  final bool isPaymentMode;
  final String searchQuery;
  final double customAmount;
  final bool isDiscountMode;
  final double discountAmount;
  final double taxRate;
  final List<Product> searchResults;
  final List<Receipt> recentTransactions;
  final Product? selectedProduct;
  final int selectedIndex;

  POSState({
    this.cart = const [],
    this.lastAction = '',
    this.isPaymentMode = false,
    this.searchQuery = '',
    this.customAmount = 0.0,
    this.isDiscountMode = false,
    this.discountAmount = 0.0,
    this.taxRate = 0.1, // 10% tax rate
    this.searchResults = const [],
    this.recentTransactions = const [],
    this.selectedProduct,
    this.selectedIndex = -1,
  });

  double get subtotal => cart.fold(0, (sum, item) => sum + item.total);
  double get tax => subtotal * taxRate;
  double get total => subtotal + tax - discountAmount;

  POSState copyWith({
    List<Product>? cart,
    String? lastAction,
    bool? isPaymentMode,
    String? searchQuery,
    double? customAmount,
    bool? isDiscountMode,
    double? discountAmount,
    double? taxRate,
    List<Product>? searchResults,
    List<Receipt>? recentTransactions,
    Product? selectedProduct,
    int? selectedIndex,
  }) {
    return POSState(
      cart: cart ?? this.cart,
      lastAction: lastAction ?? this.lastAction,
      isPaymentMode: isPaymentMode ?? this.isPaymentMode,
      searchQuery: searchQuery ?? this.searchQuery,
      customAmount: customAmount ?? this.customAmount,
      isDiscountMode: isDiscountMode ?? this.isDiscountMode,
      discountAmount: discountAmount ?? this.discountAmount,
      taxRate: taxRate ?? this.taxRate,
      searchResults: searchResults ?? this.searchResults,
      recentTransactions: recentTransactions ?? this.recentTransactions,
      selectedProduct: selectedProduct ?? this.selectedProduct,
      selectedIndex: selectedIndex ?? this.selectedIndex,
    );
  }
}

class POSNotifier extends StateNotifier<POSState> {
  POSNotifier() : super(POSState());

  // ... Previous methods remain the same ...

  void search(String query) {
    // Implement product search logic
    final results = _searchProducts(query);
    state = state.copyWith(
      searchQuery: query,
      searchResults: results,
      selectedIndex: results.isNotEmpty ? 0 : -1,
    );
  }

  List<Product> _searchProducts(String query) {
    // Implement actual product search from your database
    // This is a dummy implementation
    return [
      Product(
        id: 1,
        name: 'Test Product 1',
        barcode: '123456',
        price: 9.99,
        category: 'Test',
        stockQuantity: 100,
        shortcutKey: 'A', actualStock: 0, systemStock: 0,
      ),
      // Add more products...
    ].where((product) {
      return product.name!.toLowerCase().contains(query.toLowerCase()) ||
          product.barcode!.contains(query);
    }).toList();
  }

  void selectNextProduct() {
    if (state.searchResults.isEmpty) return;
    final newIndex = (state.selectedIndex + 1) % state.searchResults.length;
    state = state.copyWith(
      selectedIndex: newIndex,
      selectedProduct: state.searchResults[newIndex],
    );
  }

  void selectPreviousProduct() {
    if (state.searchResults.isEmpty) return;
    final newIndex = state.selectedIndex <= 0
        ? state.searchResults.length - 1
        : state.selectedIndex - 1;
    state = state.copyWith(
      selectedIndex: newIndex,
      selectedProduct: state.searchResults[newIndex],
    );
  }

  Future<void> completeTransaction(PaymentMethod paymentMethod) async {
    if (state.cart.isEmpty) return;

    final receipt = Receipt(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      items: [...state.cart],
      subtotal: state.subtotal,
      tax: state.tax,
      discount: state.discountAmount,
      total: state.total,
      dateTime: DateTime.now(),
      cashierName: 'Current Cashier', // Implement actual cashier management
      paymentMethod: paymentMethod,
    );
  }
}