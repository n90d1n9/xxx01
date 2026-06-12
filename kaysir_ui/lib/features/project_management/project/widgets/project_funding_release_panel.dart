import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../data/project_portfolio_repository.dart';
import '../services/project_finance_workspace_service.dart';
import '../services/project_funding_release_service.dart';

/// Reusable funding release panel for budget gates and cash movement control.
class ProjectFundingReleasePanel extends StatelessWidget {
  const ProjectFundingReleasePanel({
    required this.summary,
    this.maxSteps = 6,
    super.key,
  });

  final ProjectFundingReleaseSummary summary;
  final int maxSteps;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final levelColor = summary.level.color(colorScheme);
    final visibleSteps = summary.steps.take(maxSteps).toList();

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
        _FundingReleaseReadinessStrip(summary: summary, color: levelColor),
        const SizedBox(height: 12),
        AppMetricGrid(
          minTileWidth: 128,
          maxColumns: 4,
          metrics: [
            AppMetricGridItem(
              title: 'Gates',
              value: summary.stepCount.toString(),
              icon: Icons.waterfall_chart_outlined,
              accentColor: colorScheme.primary,
              helper: 'Release gates',
            ),
            AppMetricGridItem(
              title: 'Release',
              value: summary.releaseAmountLabel,
              icon: Icons.account_balance_wallet_outlined,
              accentColor: levelColor,
              helper: 'Planned movement',
            ),
            AppMetricGridItem(
              title: 'Attention',
              value: summary.attentionAmountLabel,
              icon: Icons.priority_high_rounded,
              accentColor:
                  summary.attentionAmount <= 0
                      ? Colors.green.shade700
                      : levelColor,
              helper: 'Blocked/review value',
            ),
            AppMetricGridItem(
              title: 'Blocked',
              value: summary.blockedCount.toString(),
              icon: Icons.block_outlined,
              accentColor:
                  summary.blockedCount == 0
                      ? Colors.green.shade700
                      : colorScheme.error,
              helper: 'Held gates',
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (var index = 0; index < visibleSteps.length; index++) ...[
          _FundingReleaseStepTile(step: visibleSteps[index]),
          if (index != visibleSteps.length - 1) const SizedBox(height: 10),
        ],
        if (summary.stepCount > maxSteps) ...[
          const SizedBox(height: 10),
          Text(
            'Showing $maxSteps of ${summary.stepCount} funding release gates',
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

/// Compact readiness strip for release gates and held funding value.
class _FundingReleaseReadinessStrip extends StatelessWidget {
  const _FundingReleaseReadinessStrip({
    required this.summary,
    required this.color,
  });

  final ProjectFundingReleaseSummary summary;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final readyPercent =
        summary.stepCount == 0 ? 0 : summary.readyCount / summary.stepCount;

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
                'Release readiness',
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
                    icon: Icons.visibility_outlined,
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

/// Funding release row with amount, gate window, evidence, and action status.
class _FundingReleaseStepTile extends StatelessWidget {
  const _FundingReleaseStepTile({required this.step});

  final ProjectFundingReleaseStep step;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final levelColor = step.level.color(colorScheme);

    return AppInfoRow(
      title: step.title,
      subtitle:
          '${step.detail} Window: ${step.dateRangeLabel}. Gate: ${step.gateLabel}. Evidence: ${step.evidenceLabel}.',
      icon: step.icon,
      iconStyle: AppInfoRowIconStyle.badge,
      contained: true,
      iconBackgroundColor: levelColor.withValues(alpha: 0.12),
      iconForegroundColor: levelColor,
      titleMaxLines: 2,
      subtitleMaxLines: 4,
      trailing: _FundingReleaseStepTrailing(step: step),
    );
  }
}

/// Fixed-width funding release trailing content for consistent row alignment.
class _FundingReleaseStepTrailing extends StatelessWidget {
  const _FundingReleaseStepTrailing({required this.step});

  final ProjectFundingReleaseStep step;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final levelColor = step.level.color(colorScheme);

    return SizedBox(
      width: 154,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            step.amountLabel,
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
              label: step.kind.label,
              icon: step.icon,
              color: colorScheme.primary,
              tooltip: step.ownerLabel,
              maxWidth: 144,
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: AppStatusPill(
              label: step.actionLabel,
              icon: step.level.icon,
              color: levelColor,
              tooltip: step.releaseShareLabel,
              maxWidth: 144,
            ),
          ),
        ],
      ),
    );
  }
}

@Preview(name: 'Project funding release panel')
Widget projectFundingReleasePanelPreview() {
  final project =
      const ProjectPortfolioRepository().findById('warehouse-automation')!;
  final workspace = buildProjectFinanceWorkspaceSummary(project);

  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ProjectFundingReleasePanel(
          summary: buildProjectFundingReleaseSummary(workspace),
        ),
      ),
    ),
  );
}
