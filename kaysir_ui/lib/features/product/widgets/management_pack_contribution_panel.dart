import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_content_panel.dart';
import '../../../widgets/ui/app_status_pill.dart';
import '../models/management_pack.dart';
import '../models/management_pack_contribution_bundle.dart';
import '../models/management_pack_contribution_kind_summary.dart';
import '../models/management_pack_contribution_source_group.dart';
import '../models/product_module_contribution_manifest.dart';
import 'management_pack_contribution_breakdown.dart';
import 'management_pack_contract_summary.dart';
import 'management_pack_module_hook_catalog.dart';
import 'product_module_contribution_activation_strip.dart';
import 'product_module_contribution_registry_diagnostics_section.dart';

/// Dashboard panel for pack contracts and registered module contributions.
class ProductManagementPackContributionPanel extends StatelessWidget {
  const ProductManagementPackContributionPanel({
    super.key,
    required this.bundle,
  });

  final ProductManagementPackContributionBundle bundle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final kindSummaries = bundle.kindSummaries;
    final sourceGroups = bundle.moduleContributionSourceGroups;
    final hookColor =
        bundle.hasActiveModuleContributions
            ? Colors.teal.shade700
            : colorScheme.outline;
    final registryHealth = bundle.moduleRegistryHealthSummary;
    final registryDiagnosticColor = _registryHealthColor(
      registryHealth.highestSeverity,
      colorScheme,
    );

    return AppContentPanel(
      title: 'Pack contribution bundle',
      subtitle: bundle.subtitleLabel,
      leadingIcon: Icons.hub_rounded,
      trailing: Wrap(
        alignment: WrapAlignment.end,
        spacing: 8,
        runSpacing: 8,
        children: [
          AppStatusPill(
            label: bundle.moduleContributionStatusLabel,
            color: hookColor,
            icon: Icons.account_tree_rounded,
            maxWidth: 190,
          ),
          if (bundle.hasModuleRegistryDiagnostics)
            AppStatusPill(
              label: registryHealth.statusLabel,
              color: registryDiagnosticColor,
              icon: Icons.warning_amber_rounded,
              tooltip: registryHealth.tooltipLabel,
              maxWidth: 174,
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (registryHealth.hasIssues) ...[
            ProductModuleContributionRegistryDiagnosticsSection(
              healthSummary: registryHealth,
              ignoredManifestDiagnostics: bundle.ignoredManifestDiagnostics,
              duplicateHookDiagnostics: bundle.duplicateHookDiagnostics,
            ),
            const SizedBox(height: 18),
          ],
          ProductManagementPackContractSummary(bundle: bundle),
          const SizedBox(height: 18),
          if (bundle.moduleActivationSummaries.isNotEmpty) ...[
            ProductModuleContributionActivationStrip(
              summaries: bundle.moduleActivationSummaries,
            ),
            const SizedBox(height: 18),
          ],
          if (kindSummaries.isNotEmpty) ...[
            ProductManagementPackContributionBreakdown(
              summaries: kindSummaries,
            ),
            const SizedBox(height: 18),
          ],
          ProductManagementPackModuleHookCatalog(groups: sourceGroups),
        ],
      ),
    );
  }
}

@Preview(name: 'Management pack contribution panel')
Widget productManagementPackContributionPanelPreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ProductManagementPackContributionPanel(
          bundle: _previewContributionBundle,
        ),
      ),
    ),
  );
}

Color _registryHealthColor(
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

final _previewContributionBundle = ProductManagementPackContributionBundle(
  managementPack: coreProductManagementPack,
  workspaceActionGroups: const [],
  actionContributions: [
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
  recommendationContributions: [
    ProductManagementPackContributionSummary(
      id: 'quality_recommendations',
      kind: ProductManagementPackContributionKind.recommendation,
      title: 'Quality recommendations',
      detailLabel: '2 recommended steps',
      statusLabel: 'Active',
      isActive: true,
      outputCount: 2,
      outputLabels: const ['Fix missing SKUs', 'Review pricing'],
      sourceId: 'quality_engine',
      sourceTitle: 'Quality Engine',
    ),
  ],
  moduleBriefContributions: [
    ProductManagementPackContributionSummary(
      id: 'fresh_goods_brief',
      kind: ProductManagementPackContributionKind.moduleBriefAction,
      title: 'Fresh goods brief action',
      detailLabel: 'Pack inactive',
      statusLabel: 'Inactive',
      isActive: false,
      outputCount: 0,
      outputLabels: const ['Fresh Goods'],
      sourceId: 'fresh_goods',
      sourceTitle: 'Fresh Goods',
    ),
  ],
);
