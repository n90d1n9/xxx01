import 'package:flutter_riverpod/legacy.dart';

import '../../../hardware/printer/services/printer_service.dart';
import '../../../hardware/receipt/models/receipt.dart';
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
  final double discountAmount;
  final double taxRate;
  final List<Product> searchResults;
  final List<Receipt> recentTransactions;
  final Product? selectedProduct;
  final int selectedIndex;
  final bool isScannerActive;
  final String lastScannedCode;

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
    this.isScannerActive = false,
    this.lastScannedCode = '',
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
    bool? isScannerActive,
    String? lastScannedCode,
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
      isScannerActive: isScannerActive ?? this.isScannerActive,
      lastScannedCode: lastScannedCode ?? this.lastScannedCode,
    );
  }
} */

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

    // Print receipt
    await PrinterService.printReceipt(receipt);

    // Update state
    state = state.copyWith(
      cart: [],
      lastAction: 'Transaction completed',
      isPaymentMode: false,
      recentTransactions: [receipt, ...state.recentTransactions],
    );
  }

  void applyPercentageDiscount(double percentage) {
    if (percentage < 0 || percentage > 100) return;
    final discount = state.subtotal * (percentage / 100);
    state = state.copyWith(
      discountAmount: discount,
      lastAction: 'Applied ${percentage.toStringAsFixed(0)}% discount',
    );
  }

  void applyFlatDiscount(double amount) {
    if (amount < 0 || amount > state.subtotal) return;
    state = state.copyWith(
      discountAmount: amount,
      lastAction: 'Applied \$${amount.toStringAsFixed(2)} discount',
    );
  }

  void toggleScanner() {
    state = state.copyWith(isScannerActive: !state.isScannerActive);
  }

  Future<void> handleScannedCode(String code) async {
    state = state.copyWith(lastScannedCode: code);

    // Look up product by barcode
    final product = await _findProductByBarcode(code);
    if (product != null) {
      addToCart(product);
    } else {
      // Handle unknown barcode
      state = state.copyWith(
        lastAction: 'Product not found for barcode: $code',
      );
    }
  }

  Future<Product?> _findProductByBarcode(String barcode) async {
    // Implement product lookup by barcode
    // This is a dummy implementation
    return Product(
      id: 2,
      name: 'Test Product',
      barcode: barcode,
      price: 9.99,
      category: 'Test',
      stockQuantity: 100, actualStock: 0, systemStock: 0,
    );
  }

  Future<void> generateProductLabel(Product product) async {
    // Generate and print product label
    // Implement actual label printing logic here
  }

  void addToCart(Product product) {
    final existingIndex =
        state.cart.indexWhere((item) => item.id == product.id);
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
      lastAction:
          state.isPaymentMode ? 'Exited payment mode' : 'Entered payment mode',
    );
  }

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void toggleDiscountMode() {
    state = state.copyWith(
      isDiscountMode: !state.isDiscountMode,
      lastAction: state.isDiscountMode
          ? 'Exited discount mode'
          : 'Entered discount mode',
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
