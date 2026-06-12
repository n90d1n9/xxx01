import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_action_button.dart';
import '../../../widgets/ui/app_content_panel.dart';
import '../../../widgets/ui/app_status_pill.dart';
import '../models/management_pack.dart';
import '../models/management_pack_readiness.dart';
import '../models/management_pack_contribution_bundle.dart';

/// Readiness dashboard for the selected product management pack.
class ProductManagementPackReadinessPanel extends StatelessWidget {
  const ProductManagementPackReadinessPanel({
    super.key,
    required this.readiness,
    required this.onPrimaryAction,
  });

  final ProductManagementPackReadiness readiness;
  final VoidCallback onPrimaryAction;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = _levelColor(colorScheme, readiness.level);

    return AppContentPanel(
      title: 'Pack readiness',
      subtitle: readiness.subtitleLabel,
      leadingIcon: Icons.fact_check_rounded,
      trailing: Wrap(
        alignment: WrapAlignment.end,
        spacing: 8,
        runSpacing: 8,
        children: [
          AppStatusPill(
            label: readiness.statusLabel,
            color: accent,
            icon: _levelIcon(readiness.level),
            maxWidth: 118,
          ),
          AppStatusPill(
            label: readiness.scoreLabel,
            color: colorScheme.primary,
            icon: Icons.speed_rounded,
            maxWidth: 124,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ReadinessScoreBar(readiness: readiness, accent: accent),
          const SizedBox(height: 16),
          _ReadinessSectionGrid(sections: readiness.sections),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: AppActionButton(
              label: readiness.primaryActionLabel,
              icon: Icons.arrow_forward_rounded,
              variant: AppActionButtonVariant.secondary,
              onPressed: onPrimaryAction,
            ),
          ),
        ],
      ),
    );
  }
}

@Preview(name: 'Product management pack readiness')
Widget productManagementPackReadinessPanelPreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ProductManagementPackReadinessPanel(
          readiness: _previewReadiness,
          onPrimaryAction: () {},
        ),
      ),
    ),
  );
}

/// Progress summary for overall pack readiness.
class _ReadinessScoreBar extends StatelessWidget {
  const _ReadinessScoreBar({required this.readiness, required this.accent});

  final ProductManagementPackReadiness readiness;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                readiness.titleLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              readiness.scoreLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: accent,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: readiness.scorePercent / 100,
            minHeight: 8,
            backgroundColor: colorScheme.surfaceContainerHighest,
            color: accent,
          ),
        ),
      ],
    );
  }
}

/// Responsive grid of pack readiness sections.
class _ReadinessSectionGrid extends StatelessWidget {
  const _ReadinessSectionGrid({required this.sections});

  final List<ProductManagementPackReadinessSection> sections;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columnCount =
            constraints.maxWidth >= 900
                ? 4
                : constraints.maxWidth >= 620
                ? 2
                : 1;
        const gap = 10.0;
        final itemWidth =
            (constraints.maxWidth - (gap * (columnCount - 1))) / columnCount;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final section in sections)
              SizedBox(
                width: itemWidth,
                child: _ReadinessSectionTile(section: section),
              ),
          ],
        );
      },
    );
  }
}

/// Single scored readiness section card.
class _ReadinessSectionTile extends StatelessWidget {
  const _ReadinessSectionTile({required this.section});

  final ProductManagementPackReadinessSection section;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = _levelColor(colorScheme, section.level);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.06),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_sectionIcon(section.id), size: 18, color: accent),
                const Spacer(),
                AppStatusPill(
                  label: '${section.scorePercent}%',
                  color: accent,
                  maxWidth: 64,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              section.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 5),
            Text(
              section.detailLabel,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

IconData _sectionIcon(String sectionId) {
  switch (sectionId) {
    case productManagementPackReadinessDataSectionId:
      return Icons.dataset_rounded;
    case productManagementPackReadinessChannelSectionId:
      return Icons.route_rounded;
    case productManagementPackReadinessWorkflowSectionId:
      return Icons.bolt_rounded;
    case productManagementPackReadinessExtensionSectionId:
      return Icons.account_tree_rounded;
  }

  return Icons.checklist_rounded;
}

IconData _levelIcon(ProductManagementPackReadinessLevel level) {
  switch (level) {
    case ProductManagementPackReadinessLevel.blocked:
      return Icons.report_problem_rounded;
    case ProductManagementPackReadinessLevel.improving:
      return Icons.trending_up_rounded;
    case ProductManagementPackReadinessLevel.ready:
      return Icons.task_alt_rounded;
  }
}

Color _levelColor(
  ColorScheme colorScheme,
  ProductManagementPackReadinessLevel level,
) {
  switch (level) {
    case ProductManagementPackReadinessLevel.blocked:
      return colorScheme.error;
    case ProductManagementPackReadinessLevel.improving:
      return Colors.orange.shade700;
    case ProductManagementPackReadinessLevel.ready:
      return Colors.green.shade700;
  }
}

final _previewReadiness = ProductManagementPackReadiness(
  bundle: ProductManagementPackContributionBundle(
    managementPack: coreProductManagementPack,
    workspaceActionGroups: const [],
    actionContributions: const [],
    recommendationContributions: const [],
  ),
  sections: const [
    ProductManagementPackReadinessSection(
      id: productManagementPackReadinessDataSectionId,
      title: 'Data contract',
      detailLabel: '2/4 ready, 2 gaps',
      scorePercent: 50,
      level: ProductManagementPackReadinessLevel.improving,
    ),
    ProductManagementPackReadinessSection(
      id: productManagementPackReadinessChannelSectionId,
      title: 'Channel coverage',
      detailLabel: '2/3 channels ready, 2 product-channel gaps',
      scorePercent: 70,
      level: ProductManagementPackReadinessLevel.improving,
    ),
    ProductManagementPackReadinessSection(
      id: productManagementPackReadinessWorkflowSectionId,
      title: 'Workflow availability',
      detailLabel: '4 ready, 1 waiting for setup.',
      scorePercent: 80,
      level: ProductManagementPackReadinessLevel.improving,
    ),
    ProductManagementPackReadinessSection(
      id: productManagementPackReadinessExtensionSectionId,
      title: 'Extension hooks',
      detailLabel: 'No active extension hooks required',
      scorePercent: 100,
      level: ProductManagementPackReadinessLevel.ready,
    ),
  ],
);
