import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/services/network/rest/rest_error_util.dart';

import '../models/product.dart';
import '../models/management_pack.dart';
import '../states/product_provider.dart';
import 'add_edit_product_screen.dart';

class ProductEditorRouteScreen extends ConsumerWidget {
  const ProductEditorRouteScreen({
    super.key,
    this.productId,
    this.initialFocusFieldId,
  });

  final String? productId;
  final ProductManagementFieldId? initialFocusFieldId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final normalizedProductId = productId?.trim();
    if (normalizedProductId == null || normalizedProductId.isEmpty) {
      return AddEditProductScreen(initialFocusFieldId: initialFocusFieldId);
    }

    final localProduct = _localProduct(ref, normalizedProductId);
    if (localProduct != null) {
      return AddEditProductScreen(
        product: localProduct,
        initialFocusFieldId: initialFocusFieldId,
      );
    }

    return FutureBuilder<Product>(
      future: ref
          .read(productsProvider.notifier)
          .getProductById(normalizedProductId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            appBar: _ProductEditorRouteAppBar(title: 'Edit Product'),
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            appBar: const _ProductEditorRouteAppBar(title: 'Edit Product'),
            body: _ProductEditorRouteMessage(
              icon: Icons.cloud_off_rounded,
              title: 'Product unavailable',
              message: DioErrorUtil.safeMessage(
                snapshot.error,
                fallbackMessage: 'Product could not be loaded.',
              ),
            ),
          );
        }

        return AddEditProductScreen(
          product: snapshot.data,
          initialFocusFieldId: initialFocusFieldId,
        );
      },
    );
  }

  Product? _localProduct(WidgetRef ref, String productId) {
    final products = ref.watch(productsProvider).products ?? const <Product>[];

    for (final product in products) {
      if (product.id == productId) return product;
    }

    return null;
  }
}

class _ProductEditorRouteAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _ProductEditorRouteAppBar({required this.title});

  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(title: Text(title));
  }
}

class _ProductEditorRouteMessage extends StatelessWidget {
  const _ProductEditorRouteMessage({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
