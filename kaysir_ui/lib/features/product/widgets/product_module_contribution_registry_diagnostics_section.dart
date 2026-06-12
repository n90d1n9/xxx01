import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_filtered_empty_state.dart';
import '../../../widgets/ui/app_status_pill.dart';
import '../models/product_module_contribution_manifest.dart';
import '../models/product_module_contribution_registry_diagnostics_view.dart';
import '../models/product_module_contribution_registry_health_summary.dart';
import 'product_module_contribution_duplicate_hook_notice.dart';
import 'product_module_contribution_ignored_manifest_notice.dart';
import 'product_module_contribution_registry_health_banner.dart';
import 'product_module_contribution_registry_triage_panel.dart';

/// Registry diagnostics block with severity filtering and repair guidance.
class ProductModuleContributionRegistryDiagnosticsSection
    extends StatefulWidget {
  const ProductModuleContributionRegistryDiagnosticsSection({
    super.key,
    required this.healthSummary,
    required this.ignoredManifestDiagnostics,
    required this.duplicateHookDiagnostics,
  });

  final ProductModuleContributionRegistryHealthSummary healthSummary;
  final List<ProductModuleContributionIgnoredManifestDiagnostic>
  ignoredManifestDiagnostics;
  final List<ProductModuleContributionDuplicateHookDiagnostic>
  duplicateHookDiagnostics;

  @override
  State<ProductModuleContributionRegistryDiagnosticsSection> createState() =>
      _ProductModuleContributionRegistryDiagnosticsSectionState();
}

/// State that tracks the selected registry diagnostics severity filter.
class _ProductModuleContributionRegistryDiagnosticsSectionState
    extends State<ProductModuleContributionRegistryDiagnosticsSection> {
  ProductModuleContributionRegistryDiagnosticFilter _filter =
      ProductModuleContributionRegistryDiagnosticFilter.all;

  @override
  Widget build(BuildContext context) {
    if (!widget.healthSummary.hasIssues) return const SizedBox.shrink();

    final diagnosticsView = ProductModuleContributionRegistryDiagnosticsView(
      filter: _filter,
      healthSummary: widget.healthSummary,
      ignoredManifestDiagnostics: widget.ignoredManifestDiagnostics,
      duplicateHookDiagnostics: widget.duplicateHookDiagnostics,
    );
    final triagePlan = diagnosticsView.visibleTriagePlan;
    final triageAccentColor = _triageSeverityColor(
      triagePlan.highestSeverity,
      Theme.of(context).colorScheme,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProductModuleContributionRegistryHealthBanner(
          summary: widget.healthSummary,
        ),
        const SizedBox(height: 12),
        _RegistryDiagnosticFilterBar(
          selectedFilter: _filter,
          summary: widget.healthSummary,
          onChanged: (filter) => setState(() => _filter = filter),
        ),
        const SizedBox(height: 12),
        if (diagnosticsView.hasVisibleDiagnostics) ...[
          _RegistryDiagnosticFilterSummary(
            view: diagnosticsView,
            onCopyReport: () => _copyVisibleReport(context, diagnosticsView),
          ),
          const SizedBox(height: 12),
          if (triagePlan.hasActions) ...[
            ProductModuleContributionRegistryTriagePanel(
              plan: triagePlan,
              accentColor: triageAccentColor,
              visibleActionLimit: 2,
            ),
            const SizedBox(height: 12),
          ],
        ] else
          _RegistryDiagnosticFilterEmptyState(
            filter: _filter,
            onReset:
                () => setState(() {
                  _filter =
                      ProductModuleContributionRegistryDiagnosticFilter.all;
                }),
          ),
        if (diagnosticsView.hasVisibleIgnoredManifestDiagnostics) ...[
          ProductModuleContributionIgnoredManifestNotice(
            diagnostics: diagnosticsView.visibleIgnoredManifestDiagnostics,
          ),
          if (diagnosticsView.shouldSeparateVisibleNotices)
            const SizedBox(height: 18),
        ],
        if (diagnosticsView.hasVisibleDuplicateHookDiagnostics)
          ProductModuleContributionDuplicateHookNotice(
            diagnostics: diagnosticsView.visibleDuplicateHookDiagnostics,
          ),
      ],
    );
  }

  Future<void> _copyVisibleReport(
    BuildContext context,
    ProductModuleContributionRegistryDiagnosticsView view,
  ) async {
    await Clipboard.setData(ClipboardData(text: view.visibleReportText));
    if (!context.mounted) return;

    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      const SnackBar(content: Text('Visible diagnostics report copied')),
    );
  }
}

@Preview(name: 'Product module registry diagnostics section')
Widget productModuleContributionRegistryDiagnosticsSectionPreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ProductModuleContributionRegistryDiagnosticsSection(
          healthSummary:
              ProductModuleContributionRegistryHealthSummary.fromDiagnostics(
                ignoredManifestDiagnostics: const [
                  ProductModuleContributionIgnoredManifestDiagnostic(
                    reason:
                        ProductModuleContributionIgnoredManifestReason
                            .duplicateId,
                    source: ProductModuleContributionSource(
                      id: 'freshness_operations',
                      title: 'Duplicate freshness module',
                      description: 'Duplicate module id.',
                    ),
                    existingSource: ProductModuleContributionSource(
                      id: 'freshness_operations',
                      title: 'Freshness operations',
                      description: 'Original module.',
                    ),
                  ),
                ],
                duplicateHookDiagnostics: [
                  ProductModuleContributionDuplicateHookDiagnostic(
                    kind: ProductModuleContributionHookKind.action,
                    hookId: 'freshness_queue',
                    sources: const [
                      ProductModuleContributionSource(
                        id: 'freshness_a',
                        title: 'Freshness A',
                        description: 'First freshness module.',
                      ),
                      ProductModuleContributionSource(
                        id: 'freshness_b',
                        title: 'Freshness B',
                        description: 'Second freshness module.',
                      ),
                    ],
                  ),
                ],
              ),
          ignoredManifestDiagnostics: const [
            ProductModuleContributionIgnoredManifestDiagnostic(
              reason:
                  ProductModuleContributionIgnoredManifestReason.duplicateId,
              source: ProductModuleContributionSource(
                id: 'freshness_operations',
                title: 'Duplicate freshness module',
                description: 'Duplicate module id.',
              ),
              existingSource: ProductModuleContributionSource(
                id: 'freshness_operations',
                title: 'Freshness operations',
                description: 'Original module.',
              ),
            ),
          ],
          duplicateHookDiagnostics: [
            ProductModuleContributionDuplicateHookDiagnostic(
              kind: ProductModuleContributionHookKind.action,
              hookId: 'freshness_queue',
              sources: const [
                ProductModuleContributionSource(
                  id: 'freshness_a',
                  title: 'Freshness A',
                  description: 'First freshness module.',
                ),
                ProductModuleContributionSource(
                  id: 'freshness_b',
                  title: 'Freshness B',
                  description: 'Second freshness module.',
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

/// Compact summary for the diagnostics currently visible under the filter.
class _RegistryDiagnosticFilterSummary extends StatelessWidget {
  const _RegistryDiagnosticFilterSummary({
    required this.view,
    required this.onCopyReport,
  });

  final ProductModuleContributionRegistryDiagnosticsView view;
  final VoidCallback onCopyReport;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final summary = Row(
          children: [
            Icon(
              Icons.visibility_rounded,
              size: 18,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                view.visibleSummaryLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        );
        final count = AppStatusPill(
          label: view.visibleDiagnosticCountLabel,
          color: colorScheme.primary,
          icon: Icons.filter_list_rounded,
          maxWidth: 150,
        );
        final actions = Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            count,
            TextButton.icon(
              icon: const Icon(Icons.copy_rounded, size: 18),
              label: const Text('Copy visible report'),
              onPressed: onCopyReport,
            ),
          ],
        );

        if (constraints.maxWidth < 680) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [summary, const SizedBox(height: 8), actions],
          );
        }

        return Row(
          children: [
            Expanded(child: summary),
            const SizedBox(width: 12),
            actions,
          ],
        );
      },
    );
  }
}

/// Control that switches registry diagnostics between severity buckets.
class _RegistryDiagnosticFilterBar extends StatelessWidget {
  const _RegistryDiagnosticFilterBar({
    required this.selectedFilter,
    required this.summary,
    required this.onChanged,
  });

  final ProductModuleContributionRegistryDiagnosticFilter selectedFilter;
  final ProductModuleContributionRegistryHealthSummary summary;
  final ValueChanged<ProductModuleContributionRegistryDiagnosticFilter>
  onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SegmentedButton<ProductModuleContributionRegistryDiagnosticFilter>(
        showSelectedIcon: false,
        segments: [
          for (final filter
              in ProductModuleContributionRegistryDiagnosticFilter.values)
            ButtonSegment(
              value: filter,
              icon: Icon(_filterIcon(filter)),
              label: Text(filter.labelFor(summary)),
            ),
        ],
        selected: {selectedFilter},
        onSelectionChanged: (selection) {
          if (selection.isEmpty) return;
          onChanged(selection.first);
        },
      ),
    );
  }
}

/// Empty state shown when the selected diagnostics filter has no matches.
class _RegistryDiagnosticFilterEmptyState extends StatelessWidget {
  const _RegistryDiagnosticFilterEmptyState({
    required this.filter,
    required this.onReset,
  });

  final ProductModuleContributionRegistryDiagnosticFilter filter;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return AppFilteredEmptyState(
      icon: _filterIcon(filter),
      title: filter.emptyTitle,
      actionLabel: 'Show all diagnostics',
      onAction: onReset,
    );
  }
}

IconData _filterIcon(ProductModuleContributionRegistryDiagnosticFilter filter) {
  return switch (filter) {
    ProductModuleContributionRegistryDiagnosticFilter.all =>
      Icons.account_tree_rounded,
    ProductModuleContributionRegistryDiagnosticFilter.errors =>
      Icons.report_problem_rounded,
    ProductModuleContributionRegistryDiagnosticFilter.warnings =>
      Icons.manage_search_rounded,
  };
}

Color _triageSeverityColor(
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
