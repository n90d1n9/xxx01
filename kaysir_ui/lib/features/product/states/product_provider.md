import 'package:flutter_riverpod/legacy.dart';

import '../models/product.dart';
import '../services/product_database.dart';

/* final productListProvider = StateNotifierProvider<ProductNotifier, List<Product>>((ref) {
  return ProductNotifier();
});
 */
final productListProvider =
    StateNotifierProvider<ProductNotifier, AsyncValue<List<Product>>>((ref) {
      return ProductNotifier(ref.read(databaseServiceProvider));
    });

final databaseServiceProvider = Provider((ref) => DatabaseService());

final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredProductsProvider = Provider<List<Product>>((ref) {
  final productsAsync = ref.watch(productListProvider);
  final searchQuery = ref.watch(searchQueryProvider);

  return productsAsync.when(
    data: (products) {
      if (searchQuery.isEmpty) return products;
      return products
          .where(
            (product) => product.name!.toLowerCase().contains(
              searchQuery.toLowerCase(),
            ), // ||
            //product.id!.toLowerCase().contains(searchQuery.toLowerCase())
          )
          .toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

class ProductNotifier extends StateNotifier<List<Product>> {
  final DatabaseService _databaseService;

  ProductNotifier(this._databaseService) : super(const AsyncValue.loading()) {
    loadProducts();
  }

/*   Future<void> loadProducts() async {
    try {
      final products = await _databaseService.getAllProducts();
      state = AsyncValue.data(products);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  } */

}
