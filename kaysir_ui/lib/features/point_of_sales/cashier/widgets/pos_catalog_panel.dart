import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../product/models/product.dart';
import '../../../product/states/product_provider.dart';
import '../experiences/pos_catalog_behavior.dart';
import '../experiences/pos_experience_provider.dart';
import '../states/pos_catalog_filter_provider.dart';
import '../utils/pos_error_copy.dart';
import '../utils/pos_formatters.dart';
import 'category_filter.dart';
import 'pos_product_grid.dart';
import 'pos_touch_quick_button_panel.dart';
import 'pos_ui.dart';

class POSCatalogPanel extends ConsumerWidget {
  final bool dense;
  final ValueChanged<Product> onProductSelected;

  const POSCatalogPanel({
    super.key,
    this.dense = false,
    required this.onProductSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(posVisibleProductsProvider);
    final catalogSnapshotAsync = ref.watch(posCatalogSnapshotProvider);
    final catalogBehavior = ref.watch(posCatalogBehaviorProvider);
    final theme = Theme.of(context);

    return ColoredBox(
      color: theme.colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CatalogHeader(productsAsync: productsAsync, dense: dense),
          SizedBox(
            height: dense ? 44 : 52,
            child: CategoryFilter(
              onCategorySelected: (category) {
                final filter = ref.read(posCatalogFilterProvider);
                ref.read(posCatalogFilterProvider.notifier).state =
                    category == 'All'
                        ? filter.clearCategory()
                        : filter.copyWith(category: category);
              },
            ),
          ),
          catalogSnapshotAsync.maybeWhen(
            data:
                (snapshot) =>
                    snapshot.isFallback
                        ? _CatalogSourceNotice(snapshot: snapshot)
                        : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 160),
            child:
                productsAsync.isLoading
                    ? const LinearProgressIndicator(minHeight: 2)
                    : const SizedBox(height: 2),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, dense ? 8 : 12, 16, 0),
            child: POSTouchQuickButtonPanel(dense: dense),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, dense ? 8 : 16, 16, 16),
              child: productsAsync.when(
                data:
                    (products) => _buildProductGrid(products, catalogBehavior),
                loading: () => const Center(child: CircularProgressIndicator()),
                error:
                    (error, stackTrace) => _CatalogErrorState(
                      message: friendlyPOSErrorMessage(
                        error,
                        fallbackMessage:
                            'Products could not be loaded. Check the connection and retry.',
                      ),
                      onRetry: () {
                        ref.invalidate(posCatalogSnapshotProvider);
                        ref.invalidate(posCatalogProductsProvider);
                        ref.invalidate(posCatalogCategoriesProvider);
                        ref.invalidate(posVisibleProductsProvider);
                        ref.read(productsProvider.notifier).loadProducts();
                      },
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid(
    List<Product> products,
    POSCatalogBehavior catalogBehavior,
  ) {
    if (products.isEmpty) {
      return _CatalogEmptyState(message: catalogBehavior.emptyMessage);
    }

    return POSProductGrid(
      products: products,
      catalogBehavior: catalogBehavior,
      onProductSelected: onProductSelected,
      priceFormatter: formatPOSCurrency,
      dense: dense,
    );
  }
}

class _CatalogSourceNotice extends StatelessWidget {
  final POSCatalogSnapshot snapshot;

  const _CatalogSourceNotice({required this.snapshot});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
      child: POSSurface(
        color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.52),
        border: Border.all(
          color: theme.colorScheme.tertiary.withValues(alpha: 0.18),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 18,
              color: theme.colorScheme.onTertiaryContainer,
            ),
            const SizedBox(width: POSUiTokens.gap),
            Expanded(
              child: Text(
                snapshot.message ?? posLocalCatalogFallbackMessage,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onTertiaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            POSMetricPill(
              label: 'Local',
              backgroundColor: theme.colorScheme.surface,
              foregroundColor: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _CatalogHeader extends StatelessWidget {
  final AsyncValue<List<Product>> productsAsync;
  final bool dense;

  const _CatalogHeader({required this.productsAsync, required this.dense});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final count = productsAsync.maybeWhen(
      data: (products) => products.length,
      orElse: () => null,
    );

    return Container(
      padding: EdgeInsets.fromLTRB(16, dense ? 10 : 14, 16, dense ? 6 : 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          const POSIconBadge(icon: Icons.storefront_outlined),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Catalog',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (count != null)
            POSMetricPill(
              label: '$count items',
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              foregroundColor: theme.colorScheme.onSurfaceVariant,
            ),
        ],
      ),
    );
  }
}

class _CatalogEmptyState extends StatelessWidget {
  final String message;

  const _CatalogEmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return POSEmptyState(
      icon: Icons.search_off_outlined,
      title: message,
      message: 'Try another search or category.',
    );
  }
}

class _CatalogErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _CatalogErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return POSEmptyState(
      icon: Icons.inventory_2_outlined,
      title: 'Catalog unavailable',
      message: message,
      action: POSActionButton(
        icon: const Icon(Icons.refresh),
        label: 'Retry',
        onPressed: onRetry,
      ),
    );
  }
}
