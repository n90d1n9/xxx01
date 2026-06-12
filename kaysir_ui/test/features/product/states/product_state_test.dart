import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/features/product/states/product_state.dart';

void main() {
  test('copyWith can clear an existing error message', () {
    final state = ProductState(
      products: const [],
      isError: true,
      errorMessage: 'Backend unavailable',
    );

    final nextState = state.copyWith(isError: false, errorMessage: null);

    expect(nextState.isError, isFalse);
    expect(nextState.errorMessage, isNull);
  });

  test('copyWith recomputes empty state when products change', () {
    final state = ProductState.initial();

    final nextState = state.copyWith(
      products: [Product(id: 'coffee', name: 'Coffee', price: 25000)],
      isLoading: false,
    );

    expect(nextState.isEmpty, isFalse);
    expect(nextState.products, hasLength(1));
  });
}
