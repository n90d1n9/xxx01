import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../data/project_portfolio_repository.dart';
import '../services/project_approval_workspace_service.dart';
import '../services/project_finance_workspace_service.dart';

/// Reusable approval workspace panel for sign-offs and authority routing.
class ProjectApprovalWorkspacePanel extends StatelessWidget {
  const ProjectApprovalWorkspacePanel({
    required this.summary,
    this.maxItems = 8,
    super.key,
  });

  final ProjectApprovalWorkspaceSummary summary;
  final int maxItems;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final levelColor = summary.level.color(colorScheme);
    final visibleItems = summary.items.take(maxItems).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppInfoRow(
          title: summary.title,
          subtitle: summary.detail,
          icon: summary.level.icon,
          iconStyle: AppInfoRowIconStyle.badge,
          contained: true,
          iconBackgroundColor: levelColor.withValues(alpha: 0.12),
          iconForegroundColor: levelColor,
          titleMaxLines: 2,
          subtitleMaxLines: 3,
          trailing: AppStatusPill(
            label: summary.level.label,
            icon: summary.level.icon,
            color: levelColor,
            maxWidth: 128,
          ),
        ),
        const SizedBox(height: 12),
        _ApprovalReadinessStrip(summary: summary, color: levelColor),
        const SizedBox(height: 12),
        AppMetricGrid(
          minTileWidth: 128,
          maxColumns: 4,
          metrics: [
            AppMetricGridItem(
              title: 'Approvals',
              value: summary.itemCount.toString(),
              icon: Icons.verified_user_outlined,
              accentColor: colorScheme.primary,
              helper: 'Queue items',
            ),
            AppMetricGridItem(
              title: 'Amount',
              value: summary.totalAmountLabel,
              icon: Icons.account_balance_wallet_outlined,
              accentColor: levelColor,
              helper: 'Approval value',
            ),
            AppMetricGridItem(
              title: 'Review',
              value: summary.reviewCount.toString(),
              icon: Icons.rate_review_outlined,
              accentColor:
                  summary.reviewCount == 0
                      ? Colors.green.shade700
                      : Colors.orange.shade700,
              helper: 'Needs decision',
            ),
            AppMetricGridItem(
              title: 'Blocked',
              value: summary.blockedCount.toString(),
              icon: Icons.block_outlined,
              accentColor:
                  summary.blockedCount == 0
                      ? Colors.green.shade700
                      : colorScheme.error,
              helper: '${summary.approverCount} approvers',
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (var index = 0; index < visibleItems.length; index++) ...[
          _ApprovalWorkspaceItemTile(item: visibleItems[index]),
          if (index != visibleItems.length - 1) const SizedBox(height: 10),
        ],
        if (summary.itemCount > maxItems) ...[
          const SizedBox(height: 10),
          Text(
            'Showing $maxItems of ${summary.itemCount} approval items',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }
}

/// Compact approval readiness bar for fast blocked/review/ready scanning.
class _ApprovalReadinessStrip extends StatelessWidget {
  const _ApprovalReadinessStrip({required this.summary, required this.color});

  final ProjectApprovalWorkspaceSummary summary;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final readyPercent =
        summary.itemCount == 0 ? 0 : (summary.readyCount / summary.itemCount);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Approval readiness',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  AppStatusPill(
                    label: '${summary.readyCount} Ready',
                    icon: Icons.verified_outlined,
                    color: Colors.green.shade700,
                    maxWidth: 104,
                  ),
                  AppStatusPill(
                    label: '${summary.reviewCount} Review',
                    icon: Icons.rate_review_outlined,
                    color:
                        summary.reviewCount == 0
                            ? Colors.green.shade700
                            : Colors.orange.shade700,
                    maxWidth: 112,
                  ),
                  AppStatusPill(
                    label: '${summary.blockedCount} Blocked',
                    icon: Icons.block_outlined,
                    color:
                        summary.blockedCount == 0
                            ? Colors.green.shade700
                            : colorScheme.error,
                    maxWidth: 116,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: readyPercent.toDouble(),
              color: color,
              backgroundColor: color.withValues(alpha: 0.14),
            ),
          ),
        ],
      ),
    );
  }
}

/// Approval queue row with routing owner, evidence, action, and level context.
class _ApprovalWorkspaceItemTile extends StatelessWidget {
  const _ApprovalWorkspaceItemTile({required this.item});

  final ProjectApprovalWorkspaceItem item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final levelColor = item.level.color(colorScheme);

    return AppInfoRow(
      title: item.title,
      subtitle:
          '${item.detail} Approver: ${item.approverLabel}. Evidence: ${item.evidenceLabel}.',
      icon: item.icon,
      iconStyle: AppInfoRowIconStyle.badge,
      contained: true,
      iconBackgroundColor: levelColor.withValues(alpha: 0.12),
      iconForegroundColor: levelColor,
      titleMaxLines: 2,
      subtitleMaxLines: 4,
      trailing: _ApprovalWorkspaceItemTrailing(item: item),
    );
  }
}

/// Fixed-width approval row trailing content for stable queue alignment.
class _ApprovalWorkspaceItemTrailing extends StatelessWidget {
  const _ApprovalWorkspaceItemTrailing({required this.item});

  final ProjectApprovalWorkspaceItem item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final levelColor = item.level.color(colorScheme);

    return SizedBox(
      width: 152,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            item.amountLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: AppStatusPill(
              label: item.kind.label,
              icon: item.icon,
              color: colorScheme.primary,
              tooltip: item.sourceLabel,
              maxWidth: 144,
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: AppStatusPill(
              label: item.actionLabel,
              icon: item.level.icon,
              color: levelColor,
              tooltip: item.ownerLabel,
              maxWidth: 144,
            ),
          ),
        ],
      ),
    );
  }
}

@Preview(name: 'Project approval workspace panel')
Widget projectApprovalWorkspacePanelPreview() {
  final project =
      const ProjectPortfolioRepository().findById('warehouse-automation')!;
  final workspace = buildProjectFinanceWorkspaceSummary(project);

  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ProjectApprovalWorkspacePanel(
          summary: buildProjectApprovalWorkspaceSummary(workspace),
        ),
      ),
    ),
  );
}
