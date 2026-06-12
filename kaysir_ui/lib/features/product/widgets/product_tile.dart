import 'package:flutter/material.dart';

import '../models/product.dart';

class ProductTile extends StatelessWidget {
  final Product item;

  const ProductTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => _buildProductDetailDialog(context),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: _ProductTileImage(image: item.image)),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),

                    Text(
                      '\$${item.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const Spacer(),
                    SizedBox(
                      height: 28,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: _buildStockIndicator()),
                          const SizedBox(width: 4),
                          IconButton(
                            icon: const Icon(Icons.add_shopping_cart, size: 18),
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                            constraints: const BoxConstraints.tightFor(
                              width: 28,
                              height: 28,
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Added ${item.name} to cart'),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockIndicator() {
    Color indicatorColor;
    String stockText;
    final stockQuantity = item.stockQuantity ?? item.currentStock;

    if (stockQuantity > 10) {
      indicatorColor = Colors.green;
      stockText = 'In Stock';
    } else if (stockQuantity > 0) {
      indicatorColor = Colors.orange;
      stockText = 'Low Stock';
    } else {
      indicatorColor = Colors.red;
      stockText = 'Out of Stock';
    }

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: indicatorColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            stockText,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildProductDetailDialog(BuildContext context) {
    final category = item.category?.trim();
    final description = item.description?.trim();
    final stockQuantity = item.stockQuantity ?? item.currentStock;

    return AlertDialog(
      title: Text(item.name),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: _ProductTileImage(image: item.image),
            ),
            const SizedBox(height: 16),
            Text(
              'Category: ${category == null || category.isEmpty ? 'Uncategorized' : category.toUpperCase()}',
            ),
            const SizedBox(height: 8),
            Text('Price: \$${item.price.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            Text('In Stock: $stockQuantity'),
            const SizedBox(height: 16),
            Text(
              description == null || description.isEmpty
                  ? 'No product description yet.'
                  : description,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Added ${item.name} to cart'),
                duration: const Duration(seconds: 1),
              ),
            );
            Navigator.of(context).pop();
          },
          child: const Text('Add to Cart'),
        ),
      ],
    );
  }
}

class _ProductTileImage extends StatelessWidget {
  const _ProductTileImage({required this.image});

  final String? image;

  @override
  Widget build(BuildContext context) {
    final imagePath = image?.trim();

    return Container(
      width: double.infinity,
      color: Colors.grey.shade200,
      child:
          imagePath == null || imagePath.isEmpty
              ? const Center(
                child: Icon(Icons.image_not_supported_outlined, size: 40),
              )
              : imagePath.startsWith('assets')
              ? Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const _MissingProductImage(),
              )
              : Image.network(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const _MissingProductImage(),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
              ),
    );
  }
}

class _MissingProductImage extends StatelessWidget {
  const _MissingProductImage();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(Icons.image_not_supported_outlined, size: 40),
    );
  }
}
