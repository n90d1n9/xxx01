import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/management_pack_contribution_source_group.dart';
import '../models/management_pack_module_hook_catalog_filter.dart';

/// Dropdown for filtering module hooks by contribution kind.
class ProductManagementPackModuleHookKindFilterField extends StatelessWidget {
  const ProductManagementPackModuleHookKindFilterField({
    super.key,
    required this.groups,
    required this.value,
    required this.statusFilter,
    required this.query,
    required this.onChanged,
  });

  final List<ProductManagementPackContributionSourceGroup> groups;
  final ProductManagementPackModuleHookKindFilter value;
  final ProductManagementPackModuleHookCatalogFilter statusFilter;
  final String query;
  final ValueChanged<ProductManagementPackModuleHookKindFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<ProductManagementPackModuleHookKindFilter>(
      key: ValueKey(value),
      initialValue: value,
      isExpanded: true,
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.category_rounded),
        prefixIconConstraints: BoxConstraints(minWidth: 36, minHeight: 36),
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        isDense: true,
        border: OutlineInputBorder(),
      ),
      items: [
        for (final filter in ProductManagementPackModuleHookKindFilter.values)
          DropdownMenuItem(
            value: filter,
            child: Text(
              '${filter.label} (${_countFor(filter)})',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
      onChanged: (filter) {
        if (filter == null) return;
        onChanged(filter);
      },
    );
  }

  int _countFor(ProductManagementPackModuleHookKindFilter filter) {
    return countProductManagementPackModuleHookKindFilterMatches(
      groups: groups,
      kindFilter: filter,
      filter: statusFilter,
      query: query,
    );
  }
}

@Preview(name: 'Management pack module hook kind field')
Widget productManagementPackModuleHookKindFilterFieldPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ProductManagementPackModuleHookKindFilterField(
          groups: const [],
          value: ProductManagementPackModuleHookKindFilter.all,
          statusFilter: ProductManagementPackModuleHookCatalogFilter.all,
          query: '',
          onChanged: (_) {},
        ),
      ),
    ),
  );
}
