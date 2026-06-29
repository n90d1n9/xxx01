import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product.dart';

final productsProvider = StateNotifierProvider<ProductsNotifier, List<Product>>(
  (ref) {
    return ProductsNotifier();
  },
);

class ProductsNotifier extends StateNotifier<List<Product>> {
  ProductsNotifier()
    : super([
        Product(
          id: '1',
          name: 'Laptop',
          sku: 'LT-001',
          category: 'Electronics',
          price: 1200,
        ),
        Product(
          id: '2',
          name: 'Smartphone',
          sku: 'SP-001',
          category: 'Electronics',
          price: 800,
        ),
        Product(
          id: '3',
          name: 'Desk Chair',
          sku: 'DC-001',
          category: 'Furniture',
          price: 150,
        ),
      ]);

  void addProduct(Product product) {
    state = [...state, product];
  }

  void updateProduct(Product product) {
    state = state.map((p) => p.id == product.id ? product : p).toList();
  }

  void deleteProduct(String id) {
    state = state.where((p) => p.id != id).toList();
  }
}
