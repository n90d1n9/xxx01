import 'package:flutter/material.dart';

import '../utils/product_filtering.dart';

class CategoryDropdown extends StatelessWidget {
  final Map<String, dynamic>? filters;
  final List<String> categories;
  final String value;
  final ValueChanged<String?>? onChanged;

  const CategoryDropdown({
    super.key,
    this.filters,
    this.categories = const [allProductCategoryFilter],
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final options = _options();
    final selectedCategory = _selectedCategory(options);

    return DropdownButtonFormField<String>(
      initialValue: selectedCategory,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Category',
        prefixIcon: Icon(Icons.category_rounded),
        border: OutlineInputBorder(),
      ),
      onChanged: onChanged,
      items:
          options.map((category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Text(productCategoryFilterLabel(category)),
            );
          }).toList(),
    );
  }

  List<String> _options() {
    final selected = normalizeProductCategoryFilter(_filterCategory() ?? value);
    final options = productCategoryFilterOptions(categories);
    if (options.contains(selected)) return options;
    return [...options, selected];
  }

  String _selectedCategory(List<String> options) {
    final selected = normalizeProductCategoryFilter(_filterCategory() ?? value);
    return options.contains(selected) ? selected : allProductCategoryFilter;
  }

  String? _filterCategory() {
    final category = filters?['category'];
    return category is String ? category : null;
  }
}
