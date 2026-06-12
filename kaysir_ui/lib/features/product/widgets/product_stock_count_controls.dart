import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_content_panel.dart';

import '../utils/product_stock_count_view.dart';
import 'product_stock_count_visuals.dart';

class ProductStockCountControls extends StatelessWidget {
  const ProductStockCountControls({
    super.key,
    required this.query,
    required this.filter,
    required this.controller,
    required this.visibleCount,
    required this.totalCount,
    required this.onQueryChanged,
    required this.onFilterChanged,
  });

  final String query;
  final ProductStockCountFilter filter;
  final TextEditingController controller;
  final int visibleCount;
  final int totalCount;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<ProductStockCountFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return AppContentPanel(
      title: 'Count queue',
      subtitle: 'Showing $visibleCount of $totalCount products',
      leadingIcon: Icons.tune_rounded,
      elevated: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: controller,
            onChanged: onQueryChanged,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search_rounded),
              hintText: 'Search products, SKU, category, or barcode',
              border: const OutlineInputBorder(),
              suffixIcon:
                  query.trim().isEmpty
                      ? null
                      : IconButton(
                        tooltip: 'Clear search',
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          controller.clear();
                          onQueryChanged('');
                        },
                      ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final option in ProductStockCountFilter.values)
                ChoiceChip(
                  label: Text(productStockCountFilterLabel(option)),
                  selected: filter == option,
                  onSelected: (_) => onFilterChanged(option),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
