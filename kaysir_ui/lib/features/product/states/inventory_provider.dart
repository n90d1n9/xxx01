import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product.dart'; // Assuming you have a Product model
import '../services/inventory_service.dart'; // Assuming you have an inventory service
import '../utils/product_filtering.dart';

// Base inventory provider that fetches all products
final inventoryProvider = FutureProvider<List<Product>>((ref) async {
  final inventoryService = ref.watch(inventoryServiceProvider);
  return inventoryService.fetchAllProducts();
});

// Service provider (you should have something like this already)
final inventoryServiceProvider = Provider<InventoryService>((ref) {
  return InventoryService();
});

// Filtered inventory provider that depends on the category selection
final filteredInventoryProvider = FutureProvider.family<List<Product>, String>((
  ref,
  category,
) async {
  final allProducts = await ref.watch(inventoryProvider.future);

  return filterProductsForManagement(products: allProducts, category: category);
});

// Optional: If you also want to implement the search functionality at the provider level
final searchFilteredInventoryProvider =
    FutureProvider.family<List<Product>, ({String category, String query})>((
      ref,
      filters,
    ) async {
      final products = await ref.watch(inventoryProvider.future);

      return filterProductsForManagement(
        products: products,
        category: filters.category,
        query: filters.query,
      );
    });
