import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_status_pill.dart';
import '../models/management_pack_contribution_bundle.dart';
import '../models/management_pack_contribution_source_group.dart';
import '../models/product_module_contribution_activation_summary.dart';

/// Header row for one module source group in the hook catalog.
class ProductManagementPackModuleHookGroupHeader extends StatelessWidget {
  const ProductManagementPackModuleHookGroupHeader({
    super.key,
    required this.group,
  });

  final ProductManagementPackContributionSourceGroup group;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent =
        group.isModuleActive ? Colors.teal.shade700 : colorScheme.outline;

    return LayoutBuilder(
      builder: (context, constraints) {
        final titleBlock = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              group.isModuleActive
                  ? Icons.extension_rounded
                  : Icons.extension_off_rounded,
              size: 19,
              color: accent,
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color:
                          group.isModuleActive
                              ? colorScheme.onSurface
                              : colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${group.reasonLabel} | ${group.mixLabel}',
                    maxLines: 2,
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
              label: group.statusLabel,
              color: accent,
              showDot: true,
              maxWidth: 104,
            ),
            AppStatusPill(
              label: group.activeCountLabel,
              color: accent,
              maxWidth: 112,
            ),
            AppStatusPill(
              label: group.contributionCountLabel,
              color: colorScheme.primary,
              maxWidth: 104,
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

@Preview(name: 'Management pack module hook group header')
Widget productManagementPackModuleHookGroupHeaderPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ProductManagementPackModuleHookGroupHeader(group: _previewGroup),
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
