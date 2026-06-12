import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/product_module_contribution_manifest.dart';
import '../models/product_module_contribution_registry_diagnostic_detail.dart';
import 'product_module_contribution_registry_notice.dart';

/// Warning notice for product modules that register duplicate hook IDs.
class ProductModuleContributionDuplicateHookNotice extends StatelessWidget {
  const ProductModuleContributionDuplicateHookNotice({
    super.key,
    required this.diagnostics,
  });

  final List<ProductModuleContributionDuplicateHookDiagnostic> diagnostics;

  @override
  Widget build(BuildContext context) {
    if (diagnostics.isEmpty) return const SizedBox.shrink();

    final accent = Colors.amber.shade800;

    return ProductModuleContributionRegistryNotice(
      key: const ValueKey('product-module-duplicate-hook-notice'),
      title: 'Duplicate hook diagnostics',
      countLabel: _countLabel(diagnostics.length, 'duplicate hook'),
      accentColor: accent,
      headerIcon: Icons.warning_amber_rounded,
      countIcon: Icons.account_tree_rounded,
      countMaxWidth: 168,
      items: [
        for (final diagnostic in diagnostics)
          ProductModuleContributionRegistryNoticeItem(
            title: '${diagnostic.kindLabel} / ${diagnostic.hookId}',
            detail: diagnostic.sourceLabel,
            icon: Icons.merge_type_rounded,
            severity: diagnostic.severity,
            resolutionGuidance: diagnostic.resolutionGuidance,
            diagnosticDetail:
                ProductModuleContributionRegistryDiagnosticDetail.fromDuplicateHook(
                  diagnostic,
                ),
            statusLabel: diagnostic.occurrenceCountLabel,
            statusColor: accent,
          ),
      ],
    );
  }
}

@Preview(name: 'Product module duplicate hook notice')
Widget productModuleContributionDuplicateHookNoticePreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ProductModuleContributionDuplicateHookNotice(
          diagnostics: [
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
            ProductModuleContributionDuplicateHookDiagnostic(
              kind: ProductModuleContributionHookKind.moduleBriefAction,
              hookId: 'shared_brief_action',
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

String _countLabel(int count, String singular, [String? plural]) {
  if (count == 1) return '1 $singular';

  return '$count ${plural ?? '${singular}s'}';
}
