import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_status_pill.dart';
import '../../../widgets/ui/app_surface.dart';
import '../models/product_module_contribution_manifest.dart';
import '../models/product_module_contribution_registry_diagnostic_detail.dart';
import '../models/product_module_contribution_registry_triage_plan.dart';
import 'product_module_contribution_registry_diagnostic_detail_dialog.dart';
import 'product_module_contribution_registry_triage_group_list.dart';
import 'product_module_contribution_registry_triage_plan_dialog.dart';

/// Compact action plan for the registry diagnostics currently in view.
class ProductModuleContributionRegistryTriagePanel extends StatelessWidget {
  const ProductModuleContributionRegistryTriagePanel({
    super.key,
    required this.plan,
    required this.accentColor,
    this.visibleActionLimit = 3,
  });

  final ProductModuleContributionRegistryTriagePlan plan;
  final Color accentColor;
  final int visibleActionLimit;

  @override
  Widget build(BuildContext context) {
    if (!plan.hasActions) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final groups = plan.previewGroups(actionLimit: visibleActionLimit);
    final hiddenCount = plan.hiddenActionCount(
      visibleLimit: visibleActionLimit,
    );

    return AppSurface(
      padding: const EdgeInsets.all(14),
      backgroundColor: Color.alphaBlend(
        accentColor.withValues(alpha: 0.07),
        colorScheme.surface,
      ),
      borderColor: accentColor.withValues(alpha: 0.25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TriagePanelHeader(
            plan: plan,
            accentColor: accentColor,
            onCopyPlan: () => _copyPlan(context),
          ),
          const SizedBox(height: 12),
          ProductModuleContributionRegistryTriageGroupList(
            groups: groups,
            accentColor: accentColor,
            onInspectDiagnostic:
                (detail) => _showDiagnosticDetail(context, detail),
          ),
          if (hiddenCount > 0) ...[
            const SizedBox(height: 12),
            _TriageOverflowLabel(
              label:
                  '${plan.hiddenActionCountLabel(visibleLimit: visibleActionLimit)} '
                  'across visible diagnostics',
              accentColor: accentColor,
              onViewFullPlan: () => _showFullPlan(context),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _copyPlan(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: plan.reportText));
    if (!context.mounted) return;

    ScaffoldMessenger.maybeOf(
      context,
    )?.showSnackBar(const SnackBar(content: Text('Action plan copied')));
  }

  void _showFullPlan(BuildContext context) {
    showDialog<void>(
      context: context,
      builder:
          (context) => ProductModuleContributionRegistryTriagePlanDialog(
            plan: plan,
            accentColor: accentColor,
          ),
    );
  }

  void _showDiagnosticDetail(
    BuildContext context,
    ProductModuleContributionRegistryDiagnosticDetail detail,
  ) {
    showDialog<void>(
      context: context,
      builder:
          (context) => ProductModuleContributionRegistryDiagnosticDetailDialog(
            detail: detail,
          ),
    );
  }
}

@Preview(name: 'Product module registry triage panel')
Widget productModuleContributionRegistryTriagePanelPreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ProductModuleContributionRegistryTriagePanel(
          accentColor: Colors.deepOrange.shade700,
          plan: ProductModuleContributionRegistryTriagePlan.fromDiagnostics([
            ProductModuleContributionRegistryDiagnosticDetail.fromIgnoredManifest(
              const ProductModuleContributionIgnoredManifestDiagnostic(
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
            ),
            ProductModuleContributionRegistryDiagnosticDetail.fromDuplicateHook(
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
            ),
          ]),
        ),
      ),
    ),
  );
}

/// Header row for the visible registry triage plan.
class _TriagePanelHeader extends StatelessWidget {
  const _TriagePanelHeader({
    required this.plan,
    required this.accentColor,
    required this.onCopyPlan,
  });

  final ProductModuleContributionRegistryTriagePlan plan;
  final Color accentColor;
  final VoidCallback onCopyPlan;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final title = Row(
          children: [
            Icon(Icons.fact_check_rounded, color: accentColor, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    plan.primaryActionLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
        final actions = Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.end,
          children: [
            AppStatusPill(
              label: plan.summaryLabel,
              color: accentColor,
              icon: Icons.checklist_rounded,
              maxWidth: 210,
            ),
            TextButton.icon(
              icon: const Icon(Icons.copy_rounded, size: 18),
              label: const Text('Copy action plan'),
              onPressed: onCopyPlan,
            ),
          ],
        );

        if (constraints.maxWidth < 620) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [title, const SizedBox(height: 10), actions],
          );
        }

        return Row(
          children: [
            Expanded(child: title),
            const SizedBox(width: 12),
            actions,
          ],
        );
      },
    );
  }
}

/// Compact footer for actions hidden from the triage preview.
class _TriageOverflowLabel extends StatelessWidget {
  const _TriageOverflowLabel({
    required this.label,
    required this.accentColor,
    required this.onViewFullPlan,
  });

  final String label;
  final Color accentColor;
  final VoidCallback onViewFullPlan;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final colorScheme = Theme.of(context).colorScheme;
        final summary = Row(
          children: [
            Icon(Icons.more_horiz_rounded, color: accentColor, size: 18),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        );
        final action = TextButton.icon(
          icon: const Icon(Icons.open_in_full_rounded, size: 18),
          label: const Text('View full plan'),
          onPressed: onViewFullPlan,
        );

        if (constraints.maxWidth < 540) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [summary, const SizedBox(height: 8), action],
          );
        }

        return Row(
          children: [
            Expanded(child: summary),
            const SizedBox(width: 12),
            action,
          ],
        );
      },
    );
  }
}
