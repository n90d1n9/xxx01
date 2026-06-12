import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../data/project_portfolio_repository.dart';
import '../services/project_budget_change_workspace_service.dart';
import '../services/project_finance_workspace_service.dart';

/// Reusable budget-change workspace panel for variation request review.
class ProjectBudgetChangeWorkspacePanel extends StatelessWidget {
  const ProjectBudgetChangeWorkspacePanel({
    required this.summary,
    this.maxRequests = 6,
    super.key,
  });

  final ProjectBudgetChangeWorkspaceSummary summary;
  final int maxRequests;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final levelColor = summary.level.color(colorScheme);
    final visibleRequests = summary.requests.take(maxRequests).toList();

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
        AppMetricGrid(
          minTileWidth: 128,
          maxColumns: 4,
          metrics: [
            AppMetricGridItem(
              title: 'Requests',
              value: summary.requestCount.toString(),
              icon: Icons.rule_folder_outlined,
              accentColor: colorScheme.primary,
              helper: 'Change candidates',
            ),
            AppMetricGridItem(
              title: 'Amount',
              value: summary.requestedAmountTotalLabel,
              icon: Icons.account_balance_wallet_outlined,
              accentColor: levelColor,
              helper: 'Requested impact',
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
              helper: 'Cannot approve',
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (var index = 0; index < visibleRequests.length; index++) ...[
          _BudgetChangeRequestTile(request: visibleRequests[index]),
          if (index != visibleRequests.length - 1) const SizedBox(height: 10),
        ],
        if (summary.requestCount > maxRequests) ...[
          const SizedBox(height: 10),
          Text(
            'Showing $maxRequests of ${summary.requestCount} budget change requests',
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

/// Budget change request row with approval, evidence, and impact context.
class _BudgetChangeRequestTile extends StatelessWidget {
  const _BudgetChangeRequestTile({required this.request});

  final ProjectBudgetChangeRequest request;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final requestColor = request.level.color(colorScheme);

    return AppInfoRow(
      title: request.title,
      subtitle:
          '${request.detail} Owner: ${request.ownerLabel}. Approval: ${request.approvalLabel}. Evidence: ${request.evidenceLabel}.',
      icon: request.icon,
      iconStyle: AppInfoRowIconStyle.badge,
      contained: true,
      iconBackgroundColor: requestColor.withValues(alpha: 0.12),
      iconForegroundColor: requestColor,
      titleMaxLines: 2,
      subtitleMaxLines: 4,
      trailing: _BudgetChangeRequestTrailing(request: request),
    );
  }
}

/// Fixed-width budget change trailing content for stable row alignment.
class _BudgetChangeRequestTrailing extends StatelessWidget {
  const _BudgetChangeRequestTrailing({required this.request});

  final ProjectBudgetChangeRequest request;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final requestColor = request.level.color(colorScheme);

    return SizedBox(
      width: 142,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            request.requestedAmountLabel,
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
              label: request.level.label,
              icon: request.level.icon,
              color: requestColor,
              tooltip: request.impactLabel,
              maxWidth: 128,
            ),
          ),
        ],
      ),
    );
  }
}

@Preview(name: 'Project budget change workspace panel')
Widget projectBudgetChangeWorkspacePanelPreview() {
  final project =
      const ProjectPortfolioRepository().findById('warehouse-automation')!;
  final workspace = buildProjectFinanceWorkspaceSummary(project);

  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ProjectBudgetChangeWorkspacePanel(
          summary: buildProjectBudgetChangeWorkspaceSummary(workspace),
        ),
      ),
    ),
  );
}
