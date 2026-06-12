import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_status_pill.dart';
import '../models/management_pack_contribution_bundle.dart';
import '../models/management_pack_contribution_kind_section.dart';
import 'management_pack_contribution_visuals.dart';
import 'management_pack_extension_hook_list.dart';

/// Groups extension hooks by contribution kind for one module source.
class ProductManagementPackExtensionHookKindSectionList
    extends StatelessWidget {
  const ProductManagementPackExtensionHookKindSectionList({
    super.key,
    required this.sections,
    this.emptyLabel = 'No hook outputs registered for this module',
  });

  final List<ProductManagementPackContributionKindSection> sections;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    if (sections.isEmpty) {
      return Text(
        emptyLabel,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w700,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < sections.length; index += 1)
          _HookKindSection(
            section: sections[index],
            showDivider: index != sections.length - 1,
          ),
      ],
    );
  }
}

@Preview(name: 'Management pack extension hook sections')
Widget productManagementPackExtensionHookKindSectionListPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ProductManagementPackExtensionHookKindSectionList(
          sections: [_previewSection],
        ),
      ),
    ),
  );
}

/// Section for one contribution kind and its concrete hooks.
class _HookKindSection extends StatelessWidget {
  const _HookKindSection({required this.section, required this.showDivider});

  final ProductManagementPackContributionKindSection section;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent =
        section.hasActiveContributions
            ? productManagementPackContributionKindColor(section.kind)
            : colorScheme.outline;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final title = Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  productManagementPackContributionKindIcon(section.kind),
                  size: 17,
                  color: accent,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    section.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color:
                          section.hasActiveContributions
                              ? colorScheme.onSurface
                              : colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            );
            final badges = Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                AppStatusPill(
                  label: section.activeCountLabel,
                  color: accent,
                  maxWidth: 104,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                ),
                AppStatusPill(
                  label: section.outputCountLabel,
                  color: colorScheme.primary,
                  maxWidth: 94,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                ),
              ],
            );

            if (constraints.maxWidth < 620) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [title, const SizedBox(height: 8), badges],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: title),
                const SizedBox(width: 12),
                badges,
              ],
            );
          },
        ),
        const SizedBox(height: 10),
        ProductManagementPackExtensionHookList(
          contributions: section.contributions,
          showTitle: false,
        ),
        if (showDivider) ...[
          const SizedBox(height: 12),
          Divider(color: colorScheme.outlineVariant, height: 1),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

final _previewSection = ProductManagementPackContributionKindSection(
  kind: ProductManagementPackContributionKind.workspaceAction,
  contributions: [
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
    ProductManagementPackContributionSummary(
      id: 'freshness_queue',
      kind: ProductManagementPackContributionKind.workspaceAction,
      title: 'Freshness queue',
      detailLabel: 'Pack capability inactive',
      statusLabel: 'Inactive',
      isActive: false,
      outputCount: 0,
      outputLabels: const ['Freshness queue'],
      sourceId: 'fresh_goods',
      sourceTitle: 'Fresh Goods',
    ),
  ],
);
