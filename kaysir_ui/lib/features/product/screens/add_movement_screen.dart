import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../inventory/models/movement_type.dart';
import '../models/product.dart';
import '../states/product_provider.dart';
import '../widgets/add_movement_stock_dialog.dart';
import '../widgets/product_stock_action_picker.dart';

class AddStockMovementScreen extends ConsumerWidget {
  const AddStockMovementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productState = ref.watch(productsProvider);
    final products = productState.products ?? const <Product>[];

    return Scaffold(
      appBar: AppBar(title: const Text('Add Stock Movement')),
      body: ProductStockActionPicker(
        products: products,
        isLoading: productState.isLoading,
        errorMessage: productState.isError ? productState.errorMessage : null,
        onRefresh: () => ref.read(productsProvider.notifier).loadProducts(),
        onAddStock:
            (product) => _showStockMovementDialog(
              context,
              product,
              MovementType.inbound,
            ),
        onRemoveStock:
            (product) => _showStockMovementDialog(
              context,
              product,
              MovementType.outbound,
            ),
      ),
    );
  }

  void _showStockMovementDialog(
    BuildContext context,
    Product product,
    MovementType type,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AddStockMovementDialog(product: product, type: type),
    );
  }
}
