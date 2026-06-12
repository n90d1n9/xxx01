import 'package:flutter/material.dart';

import '../models/product.dart';
import '../screens/product_detail_screen.dart';
import 'stock_status_badge.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final ValueChanged<Product>? onSelected;
  final String Function(double amount)? priceFormatter;

  const ProductCard({
    super.key,
    required this.product,
    this.onSelected,
    this.priceFormatter,
  });

  @override
  Widget build(BuildContext context) {
    final stockStatus =
        product.currentStock > 20
            ? StockStatus.inStock
            : product.currentStock > 5
            ? StockStatus.limited
            : StockStatus.low;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          final handler = onSelected;
          if (handler != null) {
            handler(product);
            return;
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(productId: product.id),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.5,
              child: Container(
                color: Colors.grey[200],
                child: Center(
                  child: Icon(
                    Icons.inventory_2,
                    size: 48,
                    color: Colors.grey[500],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    product.category ?? 'Uncategorized',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          priceFormatter?.call(product.price) ??
                              '\$${product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (onSelected == null)
                        StockStatusBadge(status: stockStatus)
                      else
                        IconButton.filledTonal(
                          tooltip: 'Add to order',
                          icon: const Icon(Icons.add_shopping_cart),
                          onPressed: () => onSelected!(product),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
