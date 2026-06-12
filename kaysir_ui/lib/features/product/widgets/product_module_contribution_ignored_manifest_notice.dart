import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/product_module_contribution_manifest.dart';
import '../models/product_module_contribution_registry_diagnostic_detail.dart';
import 'product_module_contribution_registry_notice.dart';

/// Warning notice for module manifests ignored by the contribution registry.
class ProductModuleContributionIgnoredManifestNotice extends StatelessWidget {
  const ProductModuleContributionIgnoredManifestNotice({
    super.key,
    required this.diagnostics,
  });

  final List<ProductModuleContributionIgnoredManifestDiagnostic> diagnostics;

  @override
  Widget build(BuildContext context) {
    if (diagnostics.isEmpty) return const SizedBox.shrink();

    final accent = Colors.deepOrange.shade700;

    return ProductModuleContributionRegistryNotice(
      key: const ValueKey('product-module-ignored-manifest-notice'),
      title: 'Ignored module manifests',
      countLabel: _countLabel(diagnostics.length, 'ignored manifest'),
      accentColor: accent,
      headerIcon: Icons.block_rounded,
      countIcon: Icons.rule_folder_rounded,
      countMaxWidth: 178,
      items: [
        for (final diagnostic in diagnostics)
          ProductModuleContributionRegistryNoticeItem(
            title: '${diagnostic.reasonLabel} / ${diagnostic.manifestLabel}',
            detail: diagnostic.message,
            severity: diagnostic.severity,
            resolutionGuidance: diagnostic.resolutionGuidance,
            diagnosticDetail:
                ProductModuleContributionRegistryDiagnosticDetail.fromIgnoredManifest(
                  diagnostic,
                ),
          ),
      ],
    );
  }
}

@Preview(name: 'Product module ignored manifest notice')
Widget productModuleContributionIgnoredManifestNoticePreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ProductModuleContributionIgnoredManifestNotice(
          diagnostics: const [
            ProductModuleContributionIgnoredManifestDiagnostic(
              reason: ProductModuleContributionIgnoredManifestReason.blankId,
              source: ProductModuleContributionSource(
                id: '',
                title: 'Blank module',
                description: 'Missing id.',
              ),
            ),
            ProductModuleContributionIgnoredManifestDiagnostic(
              reason:
                  ProductModuleContributionIgnoredManifestReason.duplicateId,
              source: ProductModuleContributionSource(
                id: 'freshness_operations',
                title: 'Duplicate freshness module',
                description: 'Duplicate id.',
              ),
              existingSource: ProductModuleContributionSource(
                id: 'freshness_operations',
                title: 'Freshness operations',
                description: 'Original module.',
              ),
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
