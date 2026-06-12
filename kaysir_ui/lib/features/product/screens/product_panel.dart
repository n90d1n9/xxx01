import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_browser_controls.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_browser_filter_host.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_segmented_filter_bar.dart';
import 'package:kaysir/services/network/rest/rest_error_util.dart';

import '../models/product.dart';
import '../states/inventory_provider.dart';
import '../utils/product_filtering.dart';
import '../utils/management_browser_state.dart';
import '../widgets/product_tile.dart';

class ProductPanel extends ConsumerStatefulWidget {
  const ProductPanel({super.key});

  @override
  ConsumerState<ProductPanel> createState() => _ProductPanelState();
}

class _ProductPanelState extends ConsumerState<ProductPanel> {
  @override
  Widget build(BuildContext context) {
    final inventory = ref.watch(inventoryProvider);

    return POSBrowserFilterHost<String>(
      initialFilter: allProductCategoryFilter,
      builder: (context, browserController, browserActions) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: inventory.when(
                data: (items) {
                  final browserState = ProductManagementBrowserState.resolve(
                    products: items,
                    category: browserController.filter,
                    query: browserController.query,
                  );

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ProductPanelControls(
                        browserState: browserState,
                        searchController: browserController.searchController,
                        onSearchChanged: browserActions.setQuery,
                        onClearSearch: browserActions.clearSearch,
                        onCategorySelected:
                            (category) => browserActions.setFilter(
                              normalizeProductCategoryFilter(category),
                            ),
                      ),
                      Expanded(
                        child: _ProductPanelGrid(
                          items: browserState.entries,
                          hasActiveFilters:
                              browserState.hasQuery ||
                              browserState.category != allProductCategoryFilter,
                          onResetFilters: browserActions.reset,
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error:
                    (error, stack) => _ProductPanelMessage(
                      icon: Icons.cloud_off_rounded,
                      title: 'Products unavailable',
                      message: DioErrorUtil.safeMessage(
                        error,
                        fallbackMessage: 'Products could not be loaded.',
                      ),
                    ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ProductPanelControls extends StatelessWidget {
  const _ProductPanelControls({
    required this.browserState,
    required this.searchController,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onCategorySelected,
  });

  final ProductManagementBrowserState browserState;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final ValueChanged<String> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: POSBrowserControls<String>(
        filterScrollKey: const ValueKey('product-panel-category-filter-scroll'),
        selectedFilter: browserState.category,
        filterOptions: POSSegmentedFilterOption.fromValues(
          browserState.categories,
          labelBuilder: productCategoryFilterLabel,
          countBuilder: browserState.countFor,
          iconBuilder: _productCategoryFilterIcon,
        ),
        onFilterSelected: onCategorySelected,
        searchController: searchController,
        searchHintText: 'Search products, SKU, barcode, or category',
        onSearchChanged: onSearchChanged,
        searchSummary:
            browserState.shouldShowSearchSummary
                ? POSBrowserSearchSummary.fromFilterSearchState(
                  state: browserState.searchState,
                  clearActionKey: const ValueKey(
                    'product-panel-clear-search-action',
                  ),
                  recoveryActionKey: const ValueKey(
                    'product-panel-show-search-matches-action',
                  ),
                  onClear: onClearSearch,
                  onRecoverFilter: onCategorySelected,
                )
                : null,
      ),
    );
  }
}

IconData _productCategoryFilterIcon(String category) {
  return category == allProductCategoryFilter
      ? Icons.inventory_2_outlined
      : Icons.category_outlined;
}

class _ProductPanelGrid extends StatelessWidget {
  const _ProductPanelGrid({
    required this.items,
    required this.hasActiveFilters,
    required this.onResetFilters,
  });

  final List<Product> items;
  final bool hasActiveFilters;
  final VoidCallback onResetFilters;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return _ProductPanelMessage(
        icon: Icons.search_off_rounded,
        title: 'No products found',
        message: 'Try another search term or category.',
        action:
            hasActiveFilters
                ? TextButton.icon(
                  onPressed: onResetFilters,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Reset filters'),
                )
                : null,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = _gridColumnCount(constraints.maxWidth);

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            childAspectRatio: columns == 1 ? 1.25 : 0.86,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return ProductTile(item: items[index]);
          },
        );
      },
    );
  }

  int _gridColumnCount(double width) {
    if (width >= 1200) return 5;
    if (width >= 900) return 4;
    if (width >= 640) return 3;
    if (width >= 380) return 2;
    return 1;
  }
}

class _ProductPanelMessage extends StatelessWidget {
  const _ProductPanelMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
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
            if (action != null) ...[const SizedBox(height: 12), action!],
          ],
        ),
      ),
    );
  }
}
