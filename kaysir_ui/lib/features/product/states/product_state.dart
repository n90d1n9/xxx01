import '../models/product.dart';

const _unset = Object();

class ProductState {
  final List<Product>? products;
  final ProductCategory? category;
  final bool isEmpty;
  final bool isLoading;
  final bool isError;
  final String? errorMessage;

  ProductState({
    this.products,
    this.category,
    this.isEmpty = true,
    this.isLoading = false,
    this.isError = false,
    this.errorMessage,
  });

  factory ProductState.initial() => ProductState(isLoading: true);

  ProductState copyWith({
    List<Product>? products,
    ProductCategory? category,
    bool? isEmpty,
    bool? isLoading,
    bool? isError,
    Object? errorMessage = _unset,
  }) {
    final nextProducts = products ?? this.products;

    return ProductState(
      products: nextProducts,
      category: category ?? this.category,
      isEmpty: isEmpty ?? nextProducts == null || nextProducts.isEmpty,
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
      errorMessage:
          identical(errorMessage, _unset)
              ? this.errorMessage
              : errorMessage as String?,
    );
  }
}

class ProductCategory {
  final String? name;
  final String? description;

  ProductCategory({this.name, this.description});
}
