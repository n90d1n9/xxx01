import 'package:flutter/material.dart';

import '../../../product/models/product.dart';
import '../experiences/pos_catalog_behavior.dart';
import 'pos_product_card.dart';

class POSProductGrid extends StatelessWidget {
  final List<Product> products;
  final POSCatalogBehavior catalogBehavior;
  final ValueChanged<Product> onProductSelected;
  final String Function(double amount) priceFormatter;
  final bool dense;

  const POSProductGrid({
    super.key,
    required this.products,
    required this.catalogBehavior,
    required this.onProductSelected,
    required this.priceFormatter,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = _resolveColumns(constraints.maxWidth);

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            childAspectRatio: dense ? 0.96 : 0.86,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            return POSProductCard(
              product: products[index],
              catalogBehavior: catalogBehavior,
              onSelected: onProductSelected,
              priceFormatter: priceFormatter,
              dense: dense,
            );
          },
        );
      },
    );
  }

  int _resolveColumns(double width) {
    if (width >= 1220) return 5;
    if (width >= 940) return 4;
    if (width >= 640) return 3;
    if (width >= 380) return 2;
    return 1;
  }
}
