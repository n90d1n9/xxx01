import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/widgets/ui/app_filtered_empty_state.dart';

/// Empty state shown when module hook catalog filters hide all groups.
class ProductManagementPackModuleHookEmptyState extends StatelessWidget {
  const ProductManagementPackModuleHookEmptyState({
    super.key,
    required this.hasSearch,
    required this.onReset,
  });

  final bool hasSearch;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return AppFilteredEmptyState(
      icon: hasSearch ? Icons.search_off_rounded : Icons.filter_alt_off_rounded,
      title:
          hasSearch
              ? 'No modules match this search and filter'
              : 'No modules match this filter',
      actionLabel: 'Reset module filters',
      onAction: onReset,
    );
  }
}

@Preview(name: 'Management pack module hook empty state')
Widget productManagementPackModuleHookEmptyStatePreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ProductManagementPackModuleHookEmptyState(
          hasSearch: true,
          onReset: () {},
        ),
      ),
    ),
  );
}
