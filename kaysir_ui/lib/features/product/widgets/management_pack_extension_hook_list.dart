import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_status_pill.dart';
import '../models/management_pack_contribution_bundle.dart';
import 'management_pack_contribution_visuals.dart';

/// List of extension hook contributions registered by a management pack module.
class ProductManagementPackExtensionHookList extends StatelessWidget {
  const ProductManagementPackExtensionHookList({
    super.key,
    required this.contributions,
    this.title = 'Extension hook catalog',
    this.emptyLabel = 'No extension hooks registered for this pack',
    this.showTitle = true,
  });

  final List<ProductManagementPackContributionSummary> contributions;
  final String title;
  final String emptyLabel;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showTitle) ...[
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
        ],
        if (contributions.isEmpty)
          Text(
            emptyLabel,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          )
        else
          Column(
            children: [
              for (var index = 0; index < contributions.length; index += 1)
                _ContributionLine(
                  contribution: contributions[index],
                  showDivider: index != contributions.length - 1,
                ),
            ],
          ),
      ],
    );
  }
}

@Preview(name: 'Management pack extension hooks')
Widget productManagementPackExtensionHookListPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ProductManagementPackExtensionHookList(
          contributions: _previewContributions,
        ),
      ),
    ),
  );
}

/// Single extension hook row with output and activation status.
class _ContributionLine extends StatelessWidget {
  const _ContributionLine({
    required this.contribution,
    required this.showDivider,
  });

  final ProductManagementPackContributionSummary contribution;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color =
        contribution.isActive
            ? productManagementPackContributionKindColor(contribution.kind)
            : colorScheme.outline;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final titleBlock = Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  productManagementPackContributionKindIcon(contribution.kind),
                  size: 19,
                  color: color,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contribution.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color:
                              contribution.isActive
                                  ? colorScheme.onSurface
                                  : colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${contribution.provenanceLabel} | '
                        '${contribution.outputPreviewLabel}',
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
            final status = AppStatusPill(
              label: contribution.statusLabel,
              color: color,
              showDot: true,
              maxWidth: 112,
            );

            if (constraints.maxWidth < 620) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [titleBlock, const SizedBox(height: 10), status],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: titleBlock),
                const SizedBox(width: 14),
                status,
              ],
            );
          },
        ),
        if (showDivider) ...[
          const SizedBox(height: 12),
          Divider(color: colorScheme.outlineVariant, height: 1),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

final _previewContributions = [
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
  ProductManagementPackContributionSummary(
    id: 'freshness_queue',
    kind: ProductManagementPackContributionKind.workspaceAction,
    title: 'Freshness queue',
    detailLabel: 'Pack capability inactive',
    statusLabel: 'Inactive',
    isActive: false,
    outputCount: 0,
    outputLabels: const ['Freshness queue'],
    sourceId: 'fresh_goods',
    sourceTitle: 'Fresh Goods',
  ),
];
