import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_status_pill.dart';
import '../models/product_module_contribution_manifest.dart';
import '../models/product_module_contribution_registry_diagnostic_detail.dart';
import 'product_module_contribution_registry_next_action_list.dart';

/// Dialog that presents the full context for one module registry diagnostic.
class ProductModuleContributionRegistryDiagnosticDetailDialog
    extends StatelessWidget {
  const ProductModuleContributionRegistryDiagnosticDetailDialog({
    super.key,
    required this.detail,
  });

  final ProductModuleContributionRegistryDiagnosticDetail detail;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final severityColor = _severityColor(detail.severity, colorScheme);

    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 18),
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_severityIcon(detail.severity), color: severityColor, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              detail.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  AppStatusPill(
                    label: detail.severityLabel,
                    color: severityColor,
                    icon: _severityIcon(detail.severity),
                    maxWidth: 128,
                  ),
                  AppStatusPill(
                    label: detail.issueLabel,
                    color: colorScheme.primary,
                    icon: Icons.rule_folder_rounded,
                    maxWidth: 170,
                  ),
                  if (detail.hasSources)
                    AppStatusPill(
                      label: detail.sourceCountLabel,
                      color: colorScheme.secondary,
                      icon: Icons.account_tree_rounded,
                      maxWidth: 128,
                    ),
                  if (detail.hasNextActions)
                    AppStatusPill(
                      label: detail.nextActionCountLabel,
                      color: severityColor,
                      icon: Icons.checklist_rounded,
                      maxWidth: 128,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              _DetailSection(
                title: 'What happened',
                child: Text(
                  detail.message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (detail.hasResolutionGuidance) ...[
                const SizedBox(height: 14),
                _DetailSection(
                  title: 'Recommended fix',
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.tips_and_updates_rounded,
                        color: severityColor,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          detail.resolutionGuidance,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (detail.hasNextActions) ...[
                const SizedBox(height: 14),
                _DetailSection(
                  title: 'Next actions',
                  child: ProductModuleContributionRegistryNextActionList(
                    actions: detail.nextActions,
                    accentColor: severityColor,
                  ),
                ),
              ],
              if (detail.hasMetadata) ...[
                const SizedBox(height: 14),
                _DetailSection(
                  title: 'Diagnostic metadata',
                  child: Column(
                    children: [
                      for (final row in detail.metadata)
                        _DetailMetadataRow(row: row),
                    ],
                  ),
                ),
              ],
              if (detail.hasSources) ...[
                const SizedBox(height: 14),
                _DetailSection(
                  title: 'Affected sources',
                  child: Column(
                    children: [
                      for (
                        var index = 0;
                        index < detail.sources.length;
                        index += 1
                      )
                        _DetailSourceTile(
                          source: detail.sources[index],
                          showDivider: index != detail.sources.length - 1,
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton.icon(
          icon: const Icon(Icons.copy_rounded, size: 18),
          label: const Text('Copy report'),
          onPressed: () => _copyReport(context),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Future<void> _copyReport(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: detail.reportText));
    if (!context.mounted) return;

    ScaffoldMessenger.maybeOf(
      context,
    )?.showSnackBar(const SnackBar(content: Text('Diagnostic report copied')));
  }
}

@Preview(name: 'Product module registry diagnostic detail dialog')
Widget productModuleContributionRegistryDiagnosticDetailDialogPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: ProductModuleContributionRegistryDiagnosticDetailDialog(
          detail:
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
        ),
      ),
    ),
  );
}

/// Labelled section inside a registry diagnostic detail dialog.
class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

/// Key-value line shown in registry diagnostic metadata.
class _DetailMetadataRow extends StatelessWidget {
  const _DetailMetadataRow({required this.row});

  final ProductModuleContributionRegistryDiagnosticDetailRow row;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 128,
            child: Text(
              row.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              row.value,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

/// Source tile shown inside a registry diagnostic detail dialog.
class _DetailSourceTile extends StatelessWidget {
  const _DetailSourceTile({required this.source, required this.showDivider});

  final ProductModuleContributionRegistryDiagnosticSourceDetail source;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.extension_rounded, size: 18, color: colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    source.roleLabel,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    source.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    source.id,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (source.description.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      source.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
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
  ColorScheme colorScheme,
) {
  return switch (severity) {
    ProductModuleContributionDiagnosticSeverity.error => colorScheme.error,
    ProductModuleContributionDiagnosticSeverity.warning =>
      Colors.amber.shade800,
    ProductModuleContributionDiagnosticSeverity.info => colorScheme.primary,
  };
}

IconData _severityIcon(ProductModuleContributionDiagnosticSeverity severity) {
  return switch (severity) {
    ProductModuleContributionDiagnosticSeverity.error =>
      Icons.report_problem_rounded,
    ProductModuleContributionDiagnosticSeverity.warning =>
      Icons.warning_amber_rounded,
    ProductModuleContributionDiagnosticSeverity.info =>
      Icons.info_outline_rounded,
  };
}
