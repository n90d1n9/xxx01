import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../product_routes.dart';
import '../states/product_provider.dart';
import '../widgets/product_stock_review_board.dart';

class DiscrepancyReportScreen extends ConsumerWidget {
  const DiscrepancyReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productState = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discrepancy Report'),
        actions: [
          IconButton(
            tooltip: 'Open count queue',
            icon: const Icon(Icons.fact_check_rounded),
            onPressed: () => context.go(ProductRoutes.stockOpnameUri()),
          ),
        ],
      ),
      body: ProductStockReviewBoard(
        products: productState.products ?? const [],
        isLoading: productState.isLoading,
        errorMessage: productState.isError ? productState.errorMessage : null,
        onRefresh: () => ref.read(productsProvider.notifier).loadProducts(),
        onOpenCountQueue: () => context.go(ProductRoutes.stockOpnameUri()),
        onOpenProduct:
            (product) => context.go(
              ProductRoutes.catalogUri(query: product.sku ?? product.name),
            ),
        onCaptureCount:
            (product) => context.go(
              ProductRoutes.scanProductUri(
                query: product.id,
                returnTarget: ProductScanReturnTarget.discrepancyReport,
              ),
            ),
      ),
    );
  }
}
