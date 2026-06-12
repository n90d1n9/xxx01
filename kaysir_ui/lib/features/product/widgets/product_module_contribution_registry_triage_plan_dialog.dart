import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_status_pill.dart';
import '../models/product_module_contribution_manifest.dart';
import '../models/product_module_contribution_registry_diagnostic_detail.dart';
import '../models/product_module_contribution_registry_triage_plan.dart';
import 'product_module_contribution_registry_diagnostic_detail_dialog.dart';
import 'product_module_contribution_registry_triage_group_list.dart';

/// Dialog that shows every action in a registry triage plan.
class ProductModuleContributionRegistryTriagePlanDialog
    extends StatelessWidget {
  const ProductModuleContributionRegistryTriagePlanDialog({
    super.key,
    required this.plan,
    required this.accentColor,
  });

  final ProductModuleContributionRegistryTriagePlan plan;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 18),
      title: Row(
        children: [
          Icon(Icons.fact_check_rounded, color: accentColor, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Full action plan',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640, maxHeight: 560),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  AppStatusPill(
                    label: plan.title,
                    color: accentColor,
                    icon: Icons.rule_folder_rounded,
                    maxWidth: 230,
                  ),
                  AppStatusPill(
                    label: plan.summaryLabel,
                    color: colorScheme.primary,
                    icon: Icons.checklist_rounded,
                    maxWidth: 210,
                  ),
                  AppStatusPill(
                    label: plan.highestSeverityLabel,
                    color: accentColor,
                    icon: Icons.priority_high_rounded,
                    maxWidth: 120,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ProductModuleContributionRegistryTriageGroupList(
                groups: plan.groups,
                accentColor: accentColor,
                onInspectDiagnostic:
                    (detail) => _showDiagnosticDetail(context, detail),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton.icon(
          icon: const Icon(Icons.copy_rounded, size: 18),
          label: const Text('Copy action plan'),
          onPressed: () => _copyPlan(context),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Future<void> _copyPlan(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: plan.reportText));
    if (!context.mounted) return;

    ScaffoldMessenger.maybeOf(
      context,
    )?.showSnackBar(const SnackBar(content: Text('Action plan copied')));
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

@Preview(name: 'Product module registry triage plan dialog')
Widget productModuleContributionRegistryTriagePlanDialogPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: ProductModuleContributionRegistryTriagePlanDialog(
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
