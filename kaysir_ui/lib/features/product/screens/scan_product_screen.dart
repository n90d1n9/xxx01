import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../product_routes.dart';
import '../states/product_provider.dart';
import '../widgets/product_count_capture_form.dart';

class ScanProductScreen extends ConsumerWidget {
  const ScanProductScreen({
    super.key,
    this.initialQuery = '',
    this.returnTarget = ProductScanReturnTarget.stockOpname,
  });

  final String initialQuery;
  final ProductScanReturnTarget returnTarget;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productState = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Scan Product')),
      body: ProductCountCaptureForm(
        products: productState.products ?? const [],
        initialQuery: initialQuery,
        isLoading: productState.isLoading,
        errorMessage: productState.isError ? productState.errorMessage : null,
        onRefresh: () => ref.read(productsProvider.notifier).loadProducts(),
        onSave: (product, actualStock, notes) {
          ref
              .read(productsProvider.notifier)
              .updateProductStock(product.id, actualStock, notes);
          context.go(ProductRoutes.scanReturnUri(returnTarget));
        },
      ),
    );
  }
}
