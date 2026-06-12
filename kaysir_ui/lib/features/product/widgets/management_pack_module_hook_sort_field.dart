import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/management_pack_module_hook_catalog_sort.dart';

/// Dropdown for ordering module hook catalog groups.
class ProductManagementPackModuleHookSortField extends StatelessWidget {
  const ProductManagementPackModuleHookSortField({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final ProductManagementPackModuleHookCatalogSort value;
  final ValueChanged<ProductManagementPackModuleHookCatalogSort> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<ProductManagementPackModuleHookCatalogSort>(
      key: ValueKey(value),
      initialValue: value,
      isExpanded: true,
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.sort_rounded),
        prefixIconConstraints: BoxConstraints(minWidth: 36, minHeight: 36),
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        isDense: true,
        border: OutlineInputBorder(),
      ),
      items: [
        for (final sort in ProductManagementPackModuleHookCatalogSort.values)
          DropdownMenuItem(
            value: sort,
            child: Text(
              sort.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
      onChanged: (sort) {
        if (sort == null) return;
        onChanged(sort);
      },
    );
  }
}

@Preview(name: 'Management pack module hook sort')
Widget productManagementPackModuleHookSortFieldPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ProductManagementPackModuleHookSortField(
          value: ProductManagementPackModuleHookCatalogSort.activeFirst,
          onChanged: (_) {},
        ),
      ),
    ),
  );
}
