import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../product_routes.dart';
import '../states/product_provider.dart';
import '../widgets/product_stock_count_board.dart';

class StockOpnameListScreen extends ConsumerWidget {
  const StockOpnameListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productState = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Opname'),
        actions: [
          IconButton(
            tooltip: 'Scan product',
            icon: const Icon(Icons.document_scanner),
            onPressed: () => context.go(ProductRoutes.scanProductUri()),
          ),
          IconButton(
            tooltip: 'Discrepancy report',
            icon: const Icon(Icons.assessment),
            onPressed: () => context.go(ProductRoutes.discrepancyReportUri()),
          ),
        ],
      ),
      body: ProductStockCountBoard(
        products: productState.products ?? const [],
        isLoading: productState.isLoading,
        errorMessage: productState.isError ? productState.errorMessage : null,
        onRefresh: () => ref.read(productsProvider.notifier).loadProducts(),
        onScan: () => context.go(ProductRoutes.scanProductUri()),
        onReport: () => context.go(ProductRoutes.discrepancyReportUri()),
        onOpenProduct:
            (product) => context.go(
              ProductRoutes.catalogUri(query: product.sku ?? product.name),
            ),
        onCaptureCount:
            (product) =>
                context.go(ProductRoutes.scanProductUri(query: product.id)),
      ),
    );
  }
}
