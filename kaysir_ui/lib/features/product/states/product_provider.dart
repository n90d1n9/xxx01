import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/features/product/states/product_state.dart';
import 'package:kaysir/services/network/rest/rest_error_util.dart';
import 'package:kaysir/services/network/rest/rest_services.dart';

import '../../inventory/models/movement_type.dart';
import '../models/product.dart';
import '../utils/product_lookup.dart';
import '../utils/product_stock_adjustment.dart';
import '../utils/product_state_mutations.dart';

final productsProvider = StateNotifierProvider<ProductsNotifier, ProductState>((
  ref,
) {
  return ProductsNotifier(ref);
});

// State notifiers and providers
class ProductsNotifier extends StateNotifier<ProductState> {
  final Ref ref;

  ProductsNotifier(
    this.ref, {
    List<Product>? initialProducts,
    bool loadOnStart = true,
  }) : super(
         initialProducts == null
             ? ProductState.initial()
             : ProductState(
               products: initialProducts,
               isEmpty: initialProducts.isEmpty,
             ),
       ) {
    if (loadOnStart && initialProducts == null) {
      loadProducts();
    }
  }

  Future<void> loadProducts() async {
    state = state.copyWith(isLoading: true, isError: false);
    try {
      final products = await RestClientService.post('/products');
      state = state.copyWith(
        products: _parseProducts(products),
        isLoading: false,
        isError: false,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isError: true,
        errorMessage: DioErrorUtil.safeMessage(
          e,
          fallbackMessage: 'Products could not be loaded.',
        ),
      );
    }
  }

  Future<void> searchProducts(String query) async {
    if (query.trim().isEmpty) {
      await loadProducts();
      return;
    }

    state = state.copyWith(isLoading: true, isError: false);
    try {
      final products = await RestClientService.post(query);
      state = state.copyWith(
        products: _parseProducts(products),
        isLoading: false,
        isError: false,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isError: true,
        errorMessage: DioErrorUtil.safeMessage(
          e,
          fallbackMessage: 'Products could not be searched.',
        ),
      );
    }
  }

  void addProduct(Product product) {
    state = state.copyWith(
      products: upsertProductInList(state.products, product),
      isLoading: false,
      isError: false,
      errorMessage: null,
    );
  }

  void updateProductStock(String productId, int actualStock, String? notes) {
    state = state.copyWith(
      products:
          (state.products ?? []).map((product) {
            if (product.id == productId) {
              return product.copyWith(
                actualStock: actualStock,
                notes: notes,
                lastChecked: DateTime.now(),
              );
            }
            return product;
          }).toList(),
    );
  }

  void applyStockMovement({
    required String productId,
    required MovementType type,
    required int quantity,
    String? notes,
  }) {
    state = state.copyWith(
      products:
          (state.products ?? const <Product>[])
              .map(
                (product) =>
                    product.id == productId
                        ? applyProductStockMovement(
                          product: product,
                          type: type,
                          quantity: quantity,
                          notes: notes,
                          checkedAt: DateTime.now(),
                        )
                        : product,
              )
              .toList(),
      isLoading: false,
      isError: false,
      errorMessage: null,
    );
  }

  List<Product> getDiscrepancyProducts() {
    return (state.products ?? [])
        .where((product) => product.actualStock != product.systemStock)
        .toList();
  }

  Future<void> getProductsByCategory(String category) async {
    state = state.copyWith(isLoading: true, isError: false);
    try {
      final products = await RestClientService.post(
        '/getProductsByCategory/$category',
      );
      state = state.copyWith(
        products: _parseProducts(products),
        isLoading: false,
        isError: false,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isError: true,
        errorMessage: DioErrorUtil.safeMessage(
          e,
          fallbackMessage: 'Products could not be loaded for this category.',
        ),
      );
    }
  }

  List<Product> filterProduct(String filter) {
    if (filter.isEmpty) return state.products ?? [];

    return (state.products ?? [])
        .where(
          (product) =>
              product.name.toLowerCase().contains(filter.toLowerCase()) ||
              (product.sku ?? '').toLowerCase().contains(
                filter.toLowerCase(),
              ) ||
              (product.category ?? '').toLowerCase().contains(
                filter.toLowerCase(),
              ),
        )
        .toList();
  }

  void updateProduct(Product updatedProduct) {
    state = state.copyWith(
      products: replaceProductInList(state.products, updatedProduct),
      isLoading: false,
      isError: false,
      errorMessage: null,
    );
  }

  void deleteProduct(String productId) {
    state = state.copyWith(
      products: removeProductFromList(state.products, productId),
      isLoading: false,
      isError: false,
      errorMessage: null,
    );
  }

  Future<Product> getProductById(String productId) async {
    try {
      final cachedProduct = _cachedProductById(productId);
      if (cachedProduct != null) return cachedProduct;

      final response = await RestClientService.post('/product/$productId');
      final product = _parseProduct(response);
      if (product != null) {
        return product;
      }
      throw Exception('Product not found');
    } catch (e) {
      final message = DioErrorUtil.safeMessage(
        e,
        fallbackMessage: 'Product could not be loaded.',
      );
      state = state.copyWith(isError: true, errorMessage: message);
      throw Exception('Failed to get product: $message');
    }
  }

  Product? _cachedProductById(String productId) {
    return findProductById(state.products, productId);
  }

  Product? _parseProduct(dynamic response) {
    if (response is Product) return response;
    if (response is Map<String, dynamic>) {
      final product = response['product'] ?? response['data'] ?? response;
      if (product is Product) return product;
      if (product is Map<String, dynamic>) return Product.fromJson(product);
    }
    return null;
  }

  List<Product> _parseProducts(dynamic response) {
    if (response is List<Product>) return response;
    if (response is ProductList) return response.products ?? [];
    if (response is List) return Product.listFromJson(response);
    if (response is Map<String, dynamic>) {
      final products =
          response['products'] ?? response['data'] ?? response['items'];
      if (products is List<Product>) return products;
      if (products is List) return Product.listFromJson(products);
    }
    return const [];
  }
}
