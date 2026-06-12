import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/services/network/rest/rest_error_util.dart';

import '../../inventory/models/movement_type.dart';
import '../../inventory/models/stock_movement.dart';
import '../models/product.dart';
import '../states/product_provider.dart';
import '../states/stock_movement_provider.dart';
import '../utils/product_lookup.dart';
import '../utils/product_stock_movement_display.dart';
import '../widgets/add_movement_stock_dialog.dart';
import 'add_edit_product_screen.dart';

class ProductDetailScreen extends ConsumerWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productState = ref.watch(productsProvider);
    final localProduct = findProductById(productState.products, productId);
    final stockMovements =
        ref
            .watch(stockMovementsProvider)
            .where((movement) => movement.productId == productId)
            .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Product Details')),
      body:
          localProduct != null
              ? _ProductDetailContent(
                product: localProduct,
                stockMovements: stockMovements,
              )
              : _ProductDetailAsyncLookup(
                productId: productId,
                stockMovements: stockMovements,
              ),
    );
  }
}

class _ProductDetailAsyncLookup extends ConsumerWidget {
  const _ProductDetailAsyncLookup({
    required this.productId,
    required this.stockMovements,
  });

  final String productId;
  final List<StockMovement> stockMovements;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<Product>(
      future: ref.read(productsProvider.notifier).getProductById(productId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _ProductDetailMessage(
            icon: Icons.cloud_off_rounded,
            title: 'Product unavailable',
            message: DioErrorUtil.safeMessage(
              snapshot.error,
              fallbackMessage: 'Product could not be loaded.',
            ),
          );
        }

        final product = snapshot.data;
        if (product == null) {
          return const _ProductDetailMessage(
            icon: Icons.search_off_rounded,
            title: 'Product not found',
            message: 'This product may have been removed or archived.',
          );
        }

        return _ProductDetailContent(
          product: product,
          stockMovements: stockMovements,
        );
      },
    );
  }
}

class _ProductDetailContent extends StatelessWidget {
  const _ProductDetailContent({
    required this.product,
    required this.stockMovements,
  });

  final Product product;
  final List<StockMovement> stockMovements;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProductSummaryCard(product: product),
          const SizedBox(height: 24),
          _StockMovementHistoryCard(stockMovements: stockMovements),
          const SizedBox(height: 24),
          _StockActionBar(product: product),
        ],
      ),
    );
  }
}

class _ProductSummaryCard extends StatelessWidget {
  const _ProductSummaryCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final category = product.category?.trim();
    final sku = product.sku?.trim();
    final description = product.description?.trim();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final image = _ProductPlaceholderImage(size: 120);
            final details = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    IconButton.filledTonal(
                      tooltip: 'Edit product',
                      icon: const Icon(Icons.edit_rounded),
                      onPressed: () => _openEditProduct(context, product),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(
                      label: Text(
                        category == null || category.isEmpty
                            ? 'Uncategorized'
                            : category,
                      ),
                    ),
                    Chip(
                      label: Text(
                        sku == null || sku.isEmpty ? 'No SKU' : 'SKU: $sku',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  description == null || description.isEmpty
                      ? 'No product description yet.'
                      : description,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 32,
                  runSpacing: 12,
                  children: [
                    _ProductDetailMetric(
                      label: 'Price',
                      value: '\$${product.price.toStringAsFixed(2)}',
                      color: theme.colorScheme.primary,
                    ),
                    _ProductDetailMetric(
                      label: 'Current Stock',
                      value: product.currentStock.toString(),
                      color:
                          product.currentStock > 10
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                    ),
                  ],
                ),
              ],
            );

            if (constraints.maxWidth < 620) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [image, const SizedBox(height: 16), details],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                image,
                const SizedBox(width: 16),
                Expanded(child: details),
              ],
            );
          },
        ),
      ),
    );
  }

  void _openEditProduct(BuildContext context, Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditProductScreen(product: product),
      ),
    );
  }
}

class _ProductDetailMetric extends StatelessWidget {
  const _ProductDetailMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _StockMovementHistoryCard extends StatelessWidget {
  const _StockMovementHistoryCard({required this.stockMovements});

  final List<StockMovement> stockMovements;

  @override
  Widget build(BuildContext context) {
    final movements = [...stockMovements]
      ..sort((left, right) => right.date.compareTo(left.date));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Stock Movement History',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 16),
        Card(
          child:
              movements.isEmpty
                  ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: Text('No stock movements recorded')),
                  )
                  : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: movements.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      return _StockMovementTile(movement: movements[index]);
                    },
                  ),
        ),
      ],
    );
  }
}

class _StockMovementTile extends StatelessWidget {
  const _StockMovementTile({required this.movement});

  final StockMovement movement;

  @override
  Widget build(BuildContext context) {
    final display = ProductStockMovementDisplay.fromMovement(movement);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: display.color.withValues(alpha: 0.16),
        child: Icon(display.icon, color: display.color),
      ),
      title: Text(
        display.quantityLabel,
        style: TextStyle(fontWeight: FontWeight.bold, color: display.color),
      ),
      subtitle: Text(
        'Ref: ${movement.reference} | ${DateFormat('MMM dd, yyyy').format(movement.date)}',
      ),
      trailing: Chip(label: Text(display.typeLabel)),
    );
  }
}

class _StockActionBar extends StatelessWidget {
  const _StockActionBar({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final addStock = FilledButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('Add Stock'),
          onPressed:
              () => _showStockDialog(context, product, MovementType.inbound),
        );
        final removeStock = FilledButton.tonalIcon(
          icon: const Icon(Icons.remove),
          label: const Text('Remove Stock'),
          onPressed:
              () => _showStockDialog(context, product, MovementType.outbound),
        );

        if (constraints.maxWidth < 520) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [addStock, const SizedBox(height: 12), removeStock],
          );
        }

        return Row(
          children: [
            Expanded(child: addStock),
            const SizedBox(width: 16),
            Expanded(child: removeStock),
          ],
        );
      },
    );
  }

  void _showStockDialog(
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

class _ProductPlaceholderImage extends StatelessWidget {
  const _ProductPlaceholderImage({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Icon(Icons.inventory_2, size: 48, color: Colors.grey.shade500),
      ),
    );
  }
}

class _ProductDetailMessage extends StatelessWidget {
  const _ProductDetailMessage({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 42, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
