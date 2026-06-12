import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_status_pill.dart';
import '../models/management_pack_contribution_bundle.dart';
import '../models/management_pack_contribution_kind_summary.dart';
import 'management_pack_contribution_visuals.dart';

/// Responsive breakdown of contribution output by hook kind.
class ProductManagementPackContributionBreakdown extends StatelessWidget {
  const ProductManagementPackContributionBreakdown({
    super.key,
    required this.summaries,
  });

  final List<ProductManagementPackContributionKindSummary> summaries;

  @override
  Widget build(BuildContext context) {
    if (summaries.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Hook coverage',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final columnCount =
                constraints.maxWidth >= 840
                    ? 3
                    : constraints.maxWidth >= 560
                    ? 2
                    : 1;
            const gap = 12.0;
            final itemWidth =
                (constraints.maxWidth - (gap * (columnCount - 1))) /
                columnCount;

            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (final summary in summaries)
                  SizedBox(
                    width: itemWidth,
                    child: _ContributionKindSummaryLine(summary: summary),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

@Preview(name: 'Management pack contribution breakdown')
Widget productManagementPackContributionBreakdownPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ProductManagementPackContributionBreakdown(
          summaries: _previewSummaries,
        ),
      ),
    ),
  );
}

/// Metric row for one contribution kind.
class _ContributionKindSummaryLine extends StatelessWidget {
  const _ContributionKindSummaryLine({required this.summary});

  final ProductManagementPackContributionKindSummary summary;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent =
        summary.hasActiveContributions
            ? productManagementPackContributionKindColor(summary.kind)
            : colorScheme.outline;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          productManagementPackContributionKindIcon(summary.kind),
          size: 19,
          color: accent,
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                summary.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color:
                      summary.hasActiveContributions
                          ? colorScheme.onSurface
                          : colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  AppStatusPill(
                    label: summary.activeCountLabel,
                    color: accent,
                    maxWidth: 104,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                  ),
                  AppStatusPill(
                    label: summary.outputCountLabel,
                    color: colorScheme.primary,
                    maxWidth: 94,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

const _previewSummaries = [
  ProductManagementPackContributionKindSummary(
    kind: ProductManagementPackContributionKind.workspaceAction,
    totalCount: 2,
    activeCount: 2,
    outputCount: 6,
  ),
  ProductManagementPackContributionKindSummary(
    kind: ProductManagementPackContributionKind.recommendation,
    totalCount: 3,
    activeCount: 1,
    outputCount: 2,
  ),
  ProductManagementPackContributionKindSummary(
    kind: ProductManagementPackContributionKind.moduleBriefAction,
    totalCount: 1,
    activeCount: 0,
    outputCount: 0,
  ),
];
