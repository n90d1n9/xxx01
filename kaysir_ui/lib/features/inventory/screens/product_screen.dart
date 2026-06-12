import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/inventory_product_catalog_operation.dart';
import '../widgets/inventory_navigation_drawer.dart';
import '../widgets/inventory_navigation_scaffold.dart';
import '../widgets/inventory_product_catalog_workspace.dart';

class ProductPage extends ConsumerStatefulWidget {
  const ProductPage({super.key});

  @override
  ConsumerState<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends ConsumerState<ProductPage> {
  @override
  Widget build(BuildContext context) {
    return InventoryNavigationScaffold(
      currentDestination: InventoryNavigationDestination.products,
      appBar: AppBar(title: const Text('Products')),
      body: InventoryProductCatalogWorkspace(
        eyebrow: 'Inventory Catalog',
        onOperationCompleted: _showOperationResult,
      ),
    );
  }

  void _showOperationResult(InventoryProductCatalogOperationResult result) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(result.message),
          action:
              result.canUndo
                  ? SnackBarAction(
                    label: result.undoLabel,
                    onPressed: result.undo!,
                  )
                  : null,
          duration: const Duration(milliseconds: 1600),
        ),
      );
  }
}
