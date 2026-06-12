import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_action_button.dart';
import '../../../widgets/ui/app_content_panel.dart';
import '../../../widgets/ui/app_status_pill.dart';
import '../models/product_workspace_action_group.dart';
import '../models/product_workspace_overview.dart';
import '../models/sales_channel_profile_readiness.dart';
import 'workspace_preview_fixtures.dart';

/// Operational health panel for catalog setup, channel readiness, and stock attention.
class ProductWorkspacePulsePanel extends StatelessWidget {
  const ProductWorkspacePulsePanel({
    super.key,
    required this.overview,
    required this.onReviewLaunchQueue,
    required this.onReviewAttention,
  });

  final ProductWorkspaceOverview overview;
  final VoidCallback onReviewLaunchQueue;
  final VoidCallback onReviewAttention;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = _profileStatusColor(
      colorScheme,
      overview.profileReadinessSummary.level,
    );

    return AppContentPanel(
      title: 'Workspace pulse',
      subtitle: overview.pulseSubtitle,
      leadingIcon: Icons.monitor_heart_rounded,
      trailing: Wrap(
        alignment: WrapAlignment.end,
        spacing: 8,
        runSpacing: 8,
        children: [
          AppStatusPill(
            label: overview.profileReadinessSummary.statusLabel,
            color: statusColor,
            icon: _profileStatusIcon(overview.profileReadinessSummary.level),
            maxWidth: 124,
          ),
          AppStatusPill(
            label: overview.channelProfile.title,
            color: colorScheme.primary,
            icon: Icons.account_tree_rounded,
            maxWidth: 156,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final columns =
                  constraints.maxWidth >= 1040
                      ? 4
                      : constraints.maxWidth >= 680
                      ? 2
                      : 1;
              const gap = 10.0;
              final tileWidth =
                  (constraints.maxWidth - gap * (columns - 1)) / columns;

              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  SizedBox(
                    width: tileWidth,
                    child: _WorkspacePulseTile(
                      icon: Icons.inventory_2_rounded,
                      title: 'Catalog setup',
                      value: overview.qualitySummary.completeCountLabel,
                      detail:
                          overview.hasCatalogQualityIssues
                              ? '${overview.qualitySummary.totalIssueCount} setup gaps'
                              : 'No setup gaps',
                      accent:
                          overview.hasCatalogQualityIssues
                              ? colorScheme.tertiary
                              : colorScheme.secondary,
                    ),
                  ),
                  SizedBox(
                    width: tileWidth,
                    child: _WorkspacePulseTile(
                      icon: Icons.low_priority_rounded,
                      title: 'Launch queue',
                      value: overview.launchQueueLabel,
                      detail: overview.strategyBrief.nextActionLabel,
                      accent: statusColor,
                    ),
                  ),
                  SizedBox(
                    width: tileWidth,
                    child: _WorkspacePulseTile(
                      icon: Icons.route_rounded,
                      title: 'Workflow readiness',
                      value: overview.workflowReadinessLabel,
                      detail: overview.actionSummary.readinessTooltip,
                      accent: _actionStatusColor(
                        colorScheme,
                        overview.actionSummary.availability,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: tileWidth,
                    child: _WorkspacePulseTile(
                      icon: Icons.warning_amber_rounded,
                      title: 'Attention',
                      value: overview.attentionLabel,
                      detail:
                          '${overview.summary.trackedProductCount} tracked products',
                      accent:
                          overview.hasAttention
                              ? colorScheme.error
                              : colorScheme.secondary,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            runSpacing: 8,
            children: [
              AppActionButton(
                label: 'Review queue',
                icon: Icons.arrow_forward_rounded,
                variant: AppActionButtonVariant.secondary,
                onPressed: onReviewLaunchQueue,
              ),
              AppActionButton(
                label: 'Review attention',
                icon: Icons.manage_search_rounded,
                onPressed: onReviewAttention,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

@Preview(name: 'Product workspace pulse')
Widget workspacePulsePanelPreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ProductWorkspacePulsePanel(
          overview: previewProductWorkspaceOverview,
          onReviewLaunchQueue: () {},
          onReviewAttention: () {},
        ),
      ),
    ),
  );
}

/// Compact metric tile used inside the workspace pulse panel.
class _WorkspacePulseTile extends StatelessWidget {
  const _WorkspacePulseTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.detail,
    required this.accent,
  });

  final IconData icon;
  final String title;
  final String value;
  final String detail;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.06),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(icon, color: accent, size: 18),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    detail,
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
          ],
        ),
      ),
    );
  }
}

Color _profileStatusColor(
  ColorScheme colorScheme,
  ProductSalesChannelProfileReadinessLevel level,
) {
  return switch (level) {
    ProductSalesChannelProfileReadinessLevel.blocked => colorScheme.error,
    ProductSalesChannelProfileReadinessLevel.improving => colorScheme.tertiary,
    ProductSalesChannelProfileReadinessLevel.ready => colorScheme.secondary,
  };
}

IconData _profileStatusIcon(ProductSalesChannelProfileReadinessLevel level) {
  return switch (level) {
    ProductSalesChannelProfileReadinessLevel.blocked =>
      Icons.report_problem_rounded,
    ProductSalesChannelProfileReadinessLevel.improving =>
      Icons.trending_up_rounded,
    ProductSalesChannelProfileReadinessLevel.ready => Icons.task_alt_rounded,
  };
}

Color _actionStatusColor(
  ColorScheme colorScheme,
  ProductWorkspaceActionGroupAvailability availability,
) {
  return switch (availability) {
    ProductWorkspaceActionGroupAvailability.ready => colorScheme.secondary,
    ProductWorkspaceActionGroupAvailability.partial => colorScheme.tertiary,
    ProductWorkspaceActionGroupAvailability.gated => colorScheme.error,
  };
}
