import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/management_pack_module_hook_catalog_filter.dart';
import '../models/management_pack_module_hook_catalog_result_summary.dart';
import '../models/management_pack_module_hook_catalog_sort.dart';

/// Divider with copy describing the currently visible hook catalog results.
class ProductManagementPackModuleHookResultSummaryDivider
    extends StatelessWidget {
  const ProductManagementPackModuleHookResultSummaryDivider({
    super.key,
    required this.summary,
  });

  final ProductManagementPackModuleHookCatalogResultSummary summary;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w800,
    );

    return Row(
      children: [
        Flexible(
          child: Text(
            '${summary.resultLabel} | ${summary.contextLabel}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textStyle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Divider(color: colorScheme.outlineVariant, height: 1)),
      ],
    );
  }
}

@Preview(name: 'Management pack module hook result summary')
Widget productManagementPackModuleHookResultSummaryDividerPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ProductManagementPackModuleHookResultSummaryDivider(
          summary: const ProductManagementPackModuleHookCatalogResultSummary(
            totalCount: 8,
            visibleCount: 3,
            filter: ProductManagementPackModuleHookCatalogFilter.active,
            kindFilter:
                ProductManagementPackModuleHookKindFilter.recommendation,
            query: 'launch',
            sort: ProductManagementPackModuleHookCatalogSort.activeFirst,
          ),
        ),
      ),
    ),
  );
}
