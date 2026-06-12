import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_status_pill.dart';
import '../models/product_module_contribution_manifest.dart';
import '../models/product_module_contribution_registry_diagnostic_detail.dart';
import '../models/product_module_contribution_registry_triage_plan.dart';

/// Grouped action list for registry triage plans.
class ProductModuleContributionRegistryTriageGroupList extends StatelessWidget {
  const ProductModuleContributionRegistryTriageGroupList({
    super.key,
    required this.groups,
    required this.accentColor,
    this.onInspectDiagnostic,
  });

  final List<ProductModuleContributionRegistryTriageGroup> groups;
  final Color accentColor;
  final ValueChanged<ProductModuleContributionRegistryDiagnosticDetail>?
  onInspectDiagnostic;

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        for (var index = 0; index < groups.length; index += 1)
          _TriageDiagnosticGroupTile(
            group: groups[index],
            accentColor: accentColor,
            showDivider: index != groups.length - 1,
            onInspectDiagnostic: onInspectDiagnostic,
          ),
      ],
    );
  }
}

@Preview(name: 'Product module registry triage group list')
Widget productModuleContributionRegistryTriageGroupListPreview() {
  final plan = ProductModuleContributionRegistryTriagePlan.fromDiagnostics([
    ProductModuleContributionRegistryDiagnosticDetail.fromIgnoredManifest(
      const ProductModuleContributionIgnoredManifestDiagnostic(
        reason: ProductModuleContributionIgnoredManifestReason.duplicateId,
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
  ]);

  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ProductModuleContributionRegistryTriageGroupList(
          groups: plan.previewGroups(),
          accentColor: Colors.deepOrange.shade700,
        ),
      ),
    ),
  );
}

/// One diagnostic group with its visible remediation actions.
class _TriageDiagnosticGroupTile extends StatelessWidget {
  const _TriageDiagnosticGroupTile({
    required this.group,
    required this.accentColor,
    required this.showDivider,
    this.onInspectDiagnostic,
  });

  final ProductModuleContributionRegistryTriageGroup group;
  final Color accentColor;
  final bool showDivider;
  final ValueChanged<ProductModuleContributionRegistryDiagnosticDetail>?
  onInspectDiagnostic;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final severityColor = _severityColor(
      group.severity,
      accentColor,
      colorScheme,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TriageGroupHeader(
          group: group,
          severityColor: severityColor,
          onInspectDiagnostic: onInspectDiagnostic,
        ),
        const SizedBox(height: 12),
        Column(
          children: [
            for (var index = 0; index < group.actions.length; index += 1)
              _TriageActionRow(
                action: group.actions[index],
                index: index,
                severityColor: severityColor,
                showDivider: index != group.actions.length - 1,
              ),
          ],
        ),
        if (showDivider) ...[
          const SizedBox(height: 14),
          Divider(color: colorScheme.outlineVariant, height: 1),
          const SizedBox(height: 14),
        ],
      ],
    );
  }
}

/// Header for one diagnostic group in the triage list.
class _TriageGroupHeader extends StatelessWidget {
  const _TriageGroupHeader({
    required this.group,
    required this.severityColor,
    this.onInspectDiagnostic,
  });

  final ProductModuleContributionRegistryTriageGroup group;
  final Color severityColor;
  final ValueChanged<ProductModuleContributionRegistryDiagnosticDetail>?
  onInspectDiagnostic;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.rule_folder_rounded, size: 18, color: severityColor),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                group.diagnosticTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 7),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  AppStatusPill(
                    label: group.severityLabel,
                    color: severityColor,
                    maxWidth: 112,
                  ),
                  AppStatusPill(
                    label: group.issueLabel,
                    color: colorScheme.primary,
                    maxWidth: 150,
                  ),
                  AppStatusPill(
                    label: group.actionCountLabel,
                    color: severityColor,
                    icon: Icons.checklist_rounded,
                    maxWidth: 112,
                  ),
                ],
              ),
            ],
          ),
        ),
        if (onInspectDiagnostic != null) ...[
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Inspect diagnostic',
            icon: const Icon(Icons.open_in_new_rounded),
            color: severityColor,
            onPressed: () => onInspectDiagnostic!(group.detail),
          ),
        ],
      ],
    );
  }
}

/// One remediation action inside a diagnostic group.
class _TriageActionRow extends StatelessWidget {
  const _TriageActionRow({
    required this.action,
    required this.index,
    required this.severityColor,
    required this.showDivider,
  });

  final ProductModuleContributionRegistryTriageAction action;
  final int index;
  final Color severityColor;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: severityColor.withValues(alpha: 0.12),
                border: Border.all(
                  color: severityColor.withValues(alpha: 0.42),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${index + 1}',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: severityColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    action.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    action.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      height: 1.28,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (showDivider) ...[
          const SizedBox(height: 10),
          Divider(color: colorScheme.outlineVariant, height: 1),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

Color _severityColor(
  ProductModuleContributionDiagnosticSeverity severity,
  Color accentColor,
  ColorScheme colorScheme,
) {
  return switch (severity) {
    ProductModuleContributionDiagnosticSeverity.error => colorScheme.error,
    ProductModuleContributionDiagnosticSeverity.warning => accentColor,
    ProductModuleContributionDiagnosticSeverity.info => colorScheme.primary,
  };
}
