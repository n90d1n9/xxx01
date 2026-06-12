import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_status_pill.dart';
import '../../../widgets/ui/app_surface.dart';
import '../models/product_module_contribution_manifest.dart';
import '../models/product_module_contribution_registry_diagnostic_detail.dart';
import 'product_module_contribution_registry_diagnostic_detail_dialog.dart';

/// Row model rendered by a product module registry notice.
class ProductModuleContributionRegistryNoticeItem {
  const ProductModuleContributionRegistryNoticeItem({
    required this.title,
    required this.detail,
    this.icon = Icons.error_outline_rounded,
    this.severity = ProductModuleContributionDiagnosticSeverity.warning,
    this.resolutionGuidance = '',
    this.diagnosticDetail,
    this.statusLabel = '',
    this.statusColor,
    this.statusMaxWidth = 112,
  });

  final String title;
  final String detail;
  final IconData icon;
  final ProductModuleContributionDiagnosticSeverity severity;
  final String resolutionGuidance;
  final ProductModuleContributionRegistryDiagnosticDetail? diagnosticDetail;
  final String statusLabel;
  final Color? statusColor;
  final double statusMaxWidth;

  bool get hasStatus => statusLabel.trim().isNotEmpty;
  bool get hasResolutionGuidance => resolutionGuidance.trim().isNotEmpty;
  bool get hasDiagnosticDetail => diagnosticDetail != null;
  String get severityLabel => severity.label;
}

/// Reusable diagnostic surface for product module registry health issues.
class ProductModuleContributionRegistryNotice extends StatelessWidget {
  const ProductModuleContributionRegistryNotice({
    super.key,
    required this.title,
    required this.countLabel,
    required this.accentColor,
    required this.headerIcon,
    required this.countIcon,
    required this.items,
    this.countMaxWidth = 178,
  });

  final String title;
  final String countLabel;
  final Color accentColor;
  final IconData headerIcon;
  final IconData countIcon;
  final double countMaxWidth;
  final List<ProductModuleContributionRegistryNoticeItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final sortedItems = _sortedItems;

    return AppSurface(
      padding: const EdgeInsets.all(14),
      backgroundColor: Color.alphaBlend(
        accentColor.withValues(alpha: 0.08),
        colorScheme.surface,
      ),
      borderColor: accentColor.withValues(alpha: 0.38),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final titleRow = Row(
                children: [
                  Icon(headerIcon, color: accentColor, size: 21),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              );
              final status = AppStatusPill(
                label: countLabel,
                color: accentColor,
                icon: countIcon,
                maxWidth: countMaxWidth,
              );

              if (constraints.maxWidth < 560) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [titleRow, const SizedBox(height: 10), status],
                );
              }

              return Row(
                children: [
                  Expanded(child: titleRow),
                  const SizedBox(width: 12),
                  status,
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Column(
            children: [
              for (var index = 0; index < sortedItems.length; index += 1)
                _RegistryNoticeItemLine(
                  item: sortedItems[index],
                  accentColor: accentColor,
                  showDivider: index != sortedItems.length - 1,
                ),
            ],
          ),
        ],
      ),
    );
  }

  List<ProductModuleContributionRegistryNoticeItem> get _sortedItems {
    return List.unmodifiable(
      [...items]..sort((first, second) {
        final severityOrder = first.severity.sortRank.compareTo(
          second.severity.sortRank,
        );
        if (severityOrder != 0) return severityOrder;

        return first.title.compareTo(second.title);
      }),
    );
  }
}

@Preview(name: 'Product module registry notice')
Widget productModuleContributionRegistryNoticePreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ProductModuleContributionRegistryNotice(
          title: 'Module registry diagnostics',
          countLabel: '2 registry issues',
          accentColor: Colors.amber.shade800,
          headerIcon: Icons.warning_amber_rounded,
          countIcon: Icons.account_tree_rounded,
          items: [
            ProductModuleContributionRegistryNoticeItem(
              title: 'Duplicate module id / freshness_operations',
              detail:
                  'Duplicate freshness module was ignored because Freshness operations already registered "freshness_operations".',
              severity: ProductModuleContributionDiagnosticSeverity.error,
              resolutionGuidance:
                  'Rename Duplicate freshness module or merge it with Freshness operations.',
              diagnosticDetail: ProductModuleContributionRegistryDiagnosticDetail(
                title: 'Duplicate module id / freshness_operations',
                issueLabel: 'Ignored manifest',
                message:
                    'Duplicate freshness module was ignored because Freshness operations already registered "freshness_operations".',
                resolutionGuidance:
                    'Rename Duplicate freshness module or merge it with Freshness operations.',
                severity: ProductModuleContributionDiagnosticSeverity.error,
              ),
            ),
            ProductModuleContributionRegistryNoticeItem(
              title: 'Workspace action / freshness_queue',
              detail: 'Freshness A, Freshness B',
              icon: Icons.merge_type_rounded,
              resolutionGuidance:
                  'Give the duplicate workspace action a unique contribution id.',
              diagnosticDetail: ProductModuleContributionRegistryDiagnosticDetail(
                title: 'Workspace action / freshness_queue',
                issueLabel: 'Duplicate hook id',
                message:
                    'Workspace action "freshness_queue" is registered by Freshness A, Freshness B',
                resolutionGuidance:
                    'Give the duplicate workspace action a unique contribution id.',
                severity: ProductModuleContributionDiagnosticSeverity.warning,
              ),
              statusLabel: '2 sources',
            ),
          ],
        ),
      ),
    ),
  );
}

class _RegistryNoticeItemLine extends StatelessWidget {
  const _RegistryNoticeItemLine({
    required this.item,
    required this.accentColor,
    required this.showDivider,
  });

  final ProductModuleContributionRegistryNoticeItem item;
  final Color accentColor;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final severityColor = _severityColor(
      item.severity,
      accentColor,
      colorScheme,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(item.icon, size: 18, color: severityColor),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.detail,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (item.hasResolutionGuidance) ...[
                    const SizedBox(height: 7),
                    _RegistryNoticeResolutionLine(
                      guidance: item.resolutionGuidance,
                      color: severityColor,
                    ),
                  ],
                ],
              ),
            ),
            if (item.hasStatus) ...[
              const SizedBox(width: 10),
              AppStatusPill(
                label: item.statusLabel,
                color: item.statusColor ?? severityColor,
                maxWidth: item.statusMaxWidth,
              ),
            ],
            if (item.hasDiagnosticDetail) ...[
              const SizedBox(width: 6),
              IconButton(
                tooltip: 'Open diagnostic details',
                icon: const Icon(Icons.open_in_new_rounded),
                color: severityColor,
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder:
                        (context) =>
                            ProductModuleContributionRegistryDiagnosticDetailDialog(
                              detail: item.diagnosticDetail!,
                            ),
                  );
                },
              ),
            ],
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

class _RegistryNoticeResolutionLine extends StatelessWidget {
  const _RegistryNoticeResolutionLine({
    required this.guidance,
    required this.color,
  });

  final String guidance;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.tips_and_updates_rounded, size: 14, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            guidance,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
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
