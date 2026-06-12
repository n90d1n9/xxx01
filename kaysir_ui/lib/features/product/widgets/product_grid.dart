import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/services/network/rest/rest_error_util.dart';

import '../models/product.dart';
import '../states/product_provider.dart';
import 'product_card.dart';

class ProductGrid extends ConsumerWidget {
  final List<Product>? products;
  final ValueChanged<Product>? onProductSelected;
  final int? crossAxisCount;
  final double childAspectRatio;
  final EdgeInsetsGeometry padding;
  final String emptyMessage;
  final String Function(double amount)? priceFormatter;

  const ProductGrid({
    super.key,
    this.products,
    this.onProductSelected,
    this.crossAxisCount,
    this.childAspectRatio = 0.86,
    this.padding = EdgeInsets.zero,
    this.emptyMessage = 'No products found',
    this.priceFormatter,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsState = products == null ? ref.watch(productsProvider) : null;
    final visibleProducts = products ?? productsState?.products ?? [];

    if (productsState?.isLoading == true && visibleProducts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    } else if (productsState?.isError == true && visibleProducts.isEmpty) {
      final message = DioErrorUtil.safeMessage(
        productsState?.errorMessage,
        fallbackMessage: 'Products could not be loaded.',
      );
      return Center(child: Text('Products unavailable. $message'));
    } else if (visibleProducts.isEmpty) {
      return Center(child: Text(emptyMessage));
    } else {
      return LayoutBuilder(
        builder: (context, constraints) {
          final resolvedColumns =
              crossAxisCount ??
              (constraints.maxWidth >= 1100
                  ? 4
                  : constraints.maxWidth >= 720
                  ? 3
                  : constraints.maxWidth >= 420
                  ? 2
                  : 1);

          return GridView.builder(
            padding: padding,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: resolvedColumns,
              childAspectRatio: childAspectRatio,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: visibleProducts.length,
            itemBuilder: (context, index) {
              final product = visibleProducts[index];
              return ProductCard(
                product: product,
                onSelected: onProductSelected,
                priceFormatter: priceFormatter,
              );
            },
          );
        },
      );
    }
  }
}
