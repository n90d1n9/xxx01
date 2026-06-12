import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/product_provider.dart';
import '../states/stock_movement_provider.dart';
import '../widgets/stock_movement_ledger.dart';
import 'add_movement_screen.dart';

class StockMovementsScreen extends ConsumerWidget {
  const StockMovementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stockMovements = ref.watch(stockMovementsProvider);
    final productState = ref.watch(productsProvider);
    final products = productState.products ?? const [];

    return Scaffold(
      appBar: AppBar(title: const Text('Stock Movements')),
      body: StockMovementLedger(movements: stockMovements, products: products),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddStockMovementScreen(),
            ),
          );
        },
        tooltip: 'Add Stock Movement',
        child: const Icon(Icons.add),
      ),
    );
  }
}
