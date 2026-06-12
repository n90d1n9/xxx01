import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_status_pill.dart';
import '../models/management_pack_contribution_bundle.dart';
import '../models/management_pack_contribution_source_group.dart';
import '../models/management_pack_module_hook_catalog_summary.dart';
import '../models/product_module_contribution_activation_summary.dart';

/// Coverage summary strip for registered management-pack module hooks.
class ProductManagementPackModuleHookSummaryBar extends StatelessWidget {
  const ProductManagementPackModuleHookSummaryBar({
    super.key,
    required this.summary,
  });

  final ProductManagementPackModuleHookCatalogSummary summary;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent =
        summary.hasInactiveModules
            ? Colors.amber.shade800
            : Colors.teal.shade700;

    return LayoutBuilder(
      builder: (context, constraints) {
        final titleBlock = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.account_tree_rounded, size: 18, color: accent),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Module coverage',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    summary.statusLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
        final badges = Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            AppStatusPill(
              label: summary.moduleCoverageLabel,
              color: accent,
              maxWidth: 148,
            ),
            AppStatusPill(
              label: summary.hookCoverageLabel,
              color: colorScheme.primary,
              maxWidth: 136,
            ),
            if (summary.hasInactiveModules)
              AppStatusPill(
                label: summary.inactiveModuleCountLabel,
                color: Colors.amber.shade800,
                maxWidth: 144,
              ),
          ],
        );

        if (constraints.maxWidth < 720) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [titleBlock, const SizedBox(height: 10), badges],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: titleBlock),
            const SizedBox(width: 14),
            badges,
          ],
        );
      },
    );
  }
}

@Preview(name: 'Management pack module hook summary')
Widget productManagementPackModuleHookSummaryBarPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ProductManagementPackModuleHookSummaryBar(
          summary: ProductManagementPackModuleHookCatalogSummary(
            groups: [_previewGroup],
          ),
        ),
      ),
    ),
  );
}

final _previewGroup = ProductManagementPackContributionSourceGroup(
  id: 'core_catalog',
  title: 'Core Catalog',
  activationSummary: const ProductModuleContributionActivationSummary(
    id: 'core_catalog',
    title: 'Core Catalog',
    description: 'Catalog workflows and recommendations',
    isActive: true,
    reasonLabel: 'Core catalog capability matched',
    actionContributionCount: 1,
    setupReadinessContributionCount: 0,
    recommendationContributionCount: 1,
  ),
  contributions: [
    ProductManagementPackContributionSummary(
      id: 'catalog_review_actions',
      kind: ProductManagementPackContributionKind.workspaceAction,
      title: 'Catalog review actions',
      detailLabel: '3 actions across 1 group',
      statusLabel: 'Active',
      isActive: true,
      outputCount: 3,
      outputLabels: const ['Review products'],
      sourceId: 'core_catalog',
      sourceTitle: 'Core Catalog',
    ),
  ],
);
