import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_list_surface.dart';

import '../models/product.dart';
import '../utils/product_stock_count_view.dart';
import 'product_stock_count_controls.dart';
import 'product_stock_count_state_widgets.dart';
import 'product_stock_count_summary_panel.dart';
import 'product_stock_count_tile.dart';

class ProductStockCountBoard extends StatefulWidget {
  const ProductStockCountBoard({
    super.key,
    required this.products,
    required this.onScan,
    required this.onReport,
    required this.onOpenProduct,
    required this.onCaptureCount,
    this.isLoading = false,
    this.errorMessage,
    this.onRefresh,
  });

  final List<Product> products;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRefresh;
  final VoidCallback onScan;
  final VoidCallback onReport;
  final ValueChanged<Product> onOpenProduct;
  final ValueChanged<Product> onCaptureCount;

  @override
  State<ProductStockCountBoard> createState() => _ProductStockCountBoardState();
}

class _ProductStockCountBoardState extends State<ProductStockCountBoard> {
  final _searchController = TextEditingController();
  var _query = '';
  var _filter = ProductStockCountFilter.all;

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
        icon: Icons.fact_check_outlined,
        title: 'Loading count queue',
        message: 'Preparing products for stock opname.',
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
        title: 'No products ready to count',
        message: 'Add products before starting stock opname.',
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
      header: ProductStockCountSummaryPanel(
        summary: view.summary,
        isLoading: widget.isLoading,
        onScan: widget.onScan,
        onReport: widget.onReport,
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
          const ProductStockCountState(
            icon: Icons.manage_search_rounded,
            title: 'No products match this view',
            message: 'Try another search term or count status filter.',
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
}
