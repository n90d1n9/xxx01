import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_status_pill.dart';
import '../../../widgets/ui/app_surface.dart';
import '../models/product_module_contribution_manifest.dart';
import '../models/product_module_contribution_registry_health_summary.dart';

/// Compact banner that highlights product module registry health and repairs.
class ProductModuleContributionRegistryHealthBanner extends StatelessWidget {
  const ProductModuleContributionRegistryHealthBanner({
    super.key,
    required this.summary,
  });

  final ProductModuleContributionRegistryHealthSummary summary;

  @override
  Widget build(BuildContext context) {
    if (!summary.hasIssues) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final healthColor = _healthColor(summary.highestSeverity, colorScheme);

    return AppSurface(
      padding: const EdgeInsets.all(14),
      backgroundColor: Color.alphaBlend(
        healthColor.withValues(alpha: 0.08),
        colorScheme.surface,
      ),
      borderColor: healthColor.withValues(alpha: 0.38),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final heading = Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    _healthIcon(summary.highestSeverity),
                    size: 20,
                    color: healthColor,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Module registry health',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(
                            context,
                          ).textTheme.titleSmall?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          summary.severityBreakdownLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
              final countPill = AppStatusPill(
                label: summary.countLabel,
                color: healthColor,
                icon: Icons.account_tree_rounded,
                maxWidth: 176,
              );

              if (constraints.maxWidth < 620) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [heading, const SizedBox(height: 10), countPill],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: heading),
                  const SizedBox(width: 12),
                  countPill,
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.tips_and_updates_rounded,
                size: 15,
                color: healthColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  summary.primaryNextActionLabel,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

@Preview(name: 'Product module registry health banner')
Widget productModuleContributionRegistryHealthBannerPreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ProductModuleContributionRegistryHealthBanner(
          summary: const ProductModuleContributionRegistryHealthSummary(
            errorCount: 1,
            warningCount: 2,
            primaryNextAction:
                'Rename Duplicate freshness module or merge it with Freshness operations.',
          ),
        ),
      ),
    ),
  );
}

Color _healthColor(
  ProductModuleContributionDiagnosticSeverity severity,
  ColorScheme colorScheme,
) {
  return switch (severity) {
    ProductModuleContributionDiagnosticSeverity.error => colorScheme.error,
    ProductModuleContributionDiagnosticSeverity.warning =>
      Colors.amber.shade800,
    ProductModuleContributionDiagnosticSeverity.info => colorScheme.primary,
  };
}

IconData _healthIcon(ProductModuleContributionDiagnosticSeverity severity) {
  return switch (severity) {
    ProductModuleContributionDiagnosticSeverity.error =>
      Icons.report_problem_rounded,
    ProductModuleContributionDiagnosticSeverity.warning =>
      Icons.manage_search_rounded,
    ProductModuleContributionDiagnosticSeverity.info =>
      Icons.info_outline_rounded,
  };
}
