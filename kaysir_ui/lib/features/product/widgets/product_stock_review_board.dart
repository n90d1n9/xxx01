import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_list_surface.dart';

import '../models/product.dart';
import '../utils/product_stock_count_view.dart';
import 'product_stock_count_controls.dart';
import 'product_stock_count_state_widgets.dart';
import 'product_stock_count_tile.dart';
import 'product_stock_review_summary_panel.dart';

class ProductStockReviewBoard extends StatefulWidget {
  const ProductStockReviewBoard({
    super.key,
    required this.products,
    required this.onOpenProduct,
    required this.onCaptureCount,
    required this.onOpenCountQueue,
    this.isLoading = false,
    this.errorMessage,
    this.onRefresh,
  });

  final List<Product> products;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRefresh;
  final ValueChanged<Product> onOpenProduct;
  final ValueChanged<Product> onCaptureCount;
  final VoidCallback onOpenCountQueue;

  @override
  State<ProductStockReviewBoard> createState() =>
      _ProductStockReviewBoardState();
}

class _ProductStockReviewBoardState extends State<ProductStockReviewBoard> {
  final _searchController = TextEditingController();
  var _query = '';
  var _filter = ProductStockCountFilter.needsReview;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasProducts = widget.products.isNotEmpty;
    final errorMessage = widget.errorMessage?.trim();

    if (widget.isLoading && !hasProducts) {
      return ProductStockCountState(
        icon: Icons.rule_rounded,
        title: 'Loading variance review',
        message: 'Preparing count exceptions for review.',
        showProgress: true,
        onRefresh: widget.onRefresh,
      );
    }

    if (!hasProducts && errorMessage != null && errorMessage.isNotEmpty) {
      return ProductStockCountState(
        icon: Icons.cloud_off_rounded,
        title: 'Products unavailable',
        message: errorMessage,
        onRefresh: widget.onRefresh,
      );
    }

    if (!hasProducts) {
      return ProductStockCountState(
        icon: Icons.inventory_2_outlined,
        title: 'No products to review',
        message: 'Add products and run stock opname before reviewing variance.',
        onRefresh: widget.onRefresh,
      );
    }

    final view = buildProductStockCountView(
      products: widget.products,
      query: _query,
      filter: _filter,
    );

    return AppListSurface(
      padding: const EdgeInsets.all(16),
      sectionSpacing: 16,
      itemSpacing: 12,
      header: ProductStockReviewSummaryPanel(
        summary: view.summary,
        isLoading: widget.isLoading,
        onOpenCountQueue: widget.onOpenCountQueue,
        onRefresh: widget.onRefresh,
      ),
      filters: ProductStockCountControls(
        query: _query,
        filter: _filter,
        controller: _searchController,
        visibleCount: view.visibleSummary.totalProducts,
        totalCount: view.summary.totalProducts,
        onQueryChanged: (query) => setState(() => _query = query),
        onFilterChanged: (filter) => setState(() => _filter = filter),
      ),
      children: [
        if (errorMessage != null && errorMessage.isNotEmpty)
          ProductStockCountNotice(
            message: errorMessage,
            onRefresh: widget.onRefresh,
          ),
        if (view.entries.isEmpty)
          ProductStockCountState(
            icon: Icons.verified_outlined,
            title: _emptyTitle,
            message: _emptyMessage,
            compact: true,
          )
        else
          for (final entry in view.entries)
            ProductStockCountTile(
              entry: entry,
              onOpenProduct: widget.onOpenProduct,
              onCaptureCount: widget.onCaptureCount,
            ),
      ],
    );
  }

  String get _emptyTitle {
    if (_query.trim().isNotEmpty) return 'No matching review items';
    if (_filter == ProductStockCountFilter.needsReview) {
      return 'No count exceptions';
    }
    return 'No products match this filter';
  }

  String get _emptyMessage {
    if (_query.trim().isNotEmpty) {
      return 'Try another product name, SKU, category, or barcode.';
    }
    if (_filter == ProductStockCountFilter.needsReview) {
      return 'Pending counts and stock variances will appear here.';
    }
    return 'Choose another review status to keep auditing stock counts.';
  }
}
