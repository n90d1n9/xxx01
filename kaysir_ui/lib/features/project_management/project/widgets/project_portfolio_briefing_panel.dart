import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/widgets/ui/app_action_button.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../models/project_portfolio_item.dart';
import '../services/project_domain_extension_readiness_service.dart';
import '../services/project_portfolio_briefing_service.dart';

class ProjectPortfolioBriefingPanel extends StatelessWidget {
  const ProjectPortfolioBriefingPanel({
    required this.summary,
    this.onOpenProject,
    super.key,
  });

  final ProjectPortfolioBriefingSummary summary;
  final ValueChanged<String>? onOpenProject;

  @override
  Widget build(BuildContext context) {
    if (!summary.hasProjects) {
      return const AppEmptyState(
        icon: Icons.manage_search_outlined,
        title: 'No projects in this view',
        message: 'Adjust the board filters to surface portfolio signals.',
      );
    }

    final colorScheme = Theme.of(context).colorScheme;
    final signalColor = summary.signal.color(colorScheme);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppInfoRow(
          title: summary.actionTitle,
          subtitle: summary.actionDetail,
          icon: summary.signal.icon,
          iconStyle: AppInfoRowIconStyle.badge,
          contained: true,
          iconBackgroundColor: signalColor.withValues(alpha: 0.12),
          iconForegroundColor: signalColor,
          titleMaxLines: 2,
          subtitleMaxLines: 3,
          trailing: Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              AppStatusPill(
                label: summary.signal.label,
                icon: summary.signal.icon,
                color: signalColor,
                maxWidth: 120,
              ),
              if (onOpenProject != null && summary.recommendedProject != null)
                AppActionButton(
                  label: 'Open Project',
                  icon: Icons.open_in_new_rounded,
                  compact: true,
                  variant: AppActionButtonVariant.secondary,
                  onPressed:
                      () => onOpenProject!(summary.recommendedProject!.id),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AppMetricGrid(
          minTileWidth: 150,
          maxColumns: 5,
          metrics: [
            AppMetricGridItem(
              title: 'In View',
              value: '${summary.visibleCount}/${summary.totalCount}',
              icon: Icons.view_list_outlined,
              accentColor: colorScheme.primary,
            ),
            AppMetricGridItem(
              title: 'Needs Attention',
              value: summary.attentionCount.toString(),
              icon: Icons.priority_high_rounded,
              accentColor:
                  summary.attentionCount == 0
                      ? Colors.green.shade700
                      : Colors.orange.shade700,
            ),
            AppMetricGridItem(
              title: 'Blocked',
              value: summary.blockedCount.toString(),
              icon: Icons.block_outlined,
              accentColor:
                  summary.blockedCount == 0
                      ? Colors.green.shade700
                      : colorScheme.error,
            ),
            AppMetricGridItem(
              title: 'Budget Pressure',
              value: summary.budgetPressureCount.toString(),
              icon: Icons.account_balance_wallet_outlined,
              accentColor:
                  summary.budgetPressureCount == 0
                      ? colorScheme.primary
                      : Colors.orange.shade700,
            ),
            AppMetricGridItem(
              title: 'Domain Gaps',
              value: summary.domainContextGapCount.toString(),
              icon: Icons.extension_outlined,
              accentColor:
                  summary.domainContextGapCount == 0
                      ? Colors.green.shade700
                      : Colors.orange.shade700,
            ),
          ],
        ),
        const SizedBox(height: 12),
        _ProjectPortfolioBriefingSignals(
          summary: summary,
          onOpenProject: onOpenProject,
        ),
      ],
    );
  }
}

class _ProjectPortfolioBriefingSignals extends StatelessWidget {
  const _ProjectPortfolioBriefingSignals({
    required this.summary,
    required this.onOpenProject,
  });

  final ProjectPortfolioBriefingSummary summary;
  final ValueChanged<String>? onOpenProject;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columnCount =
            constraints.maxWidth >= 1040
                ? 3
                : constraints.maxWidth >= 760
                ? 2
                : 1;
        final spacing = 12.0;
        final width =
            columnCount == 1
                ? double.infinity
                : (constraints.maxWidth - spacing * (columnCount - 1)) /
                    columnCount;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            SizedBox(width: width, child: _RiskBrief(summary: summary)),
            SizedBox(
              width: width,
              child: _MilestoneBrief(
                summary: summary,
                onOpenProject: onOpenProject,
              ),
            ),
            SizedBox(
              width: width,
              child: _DomainContextBrief(
                summary: summary,
                onOpenProject: onOpenProject,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DomainContextBrief extends StatelessWidget {
  const _DomainContextBrief({
    required this.summary,
    required this.onOpenProject,
  });

  final ProjectPortfolioBriefingSummary summary;
  final ValueChanged<String>? onOpenProject;

  @override
  Widget build(BuildContext context) {
    final gap = summary.domainGap;
    final colorScheme = Theme.of(context).colorScheme;

    if (gap == null) {
      return AppInfoRow(
        title: 'Domain context ready',
        subtitle:
            'Required and recommended domain fields are complete in this view.',
        icon: Icons.extension_outlined,
        iconStyle: AppInfoRowIconStyle.badge,
        contained: true,
        iconBackgroundColor: Colors.green.shade700.withValues(alpha: 0.12),
        iconForegroundColor: Colors.green.shade700,
        subtitleMaxLines: 2,
      );
    }

    final color =
        gap.status == ProjectDomainExtensionReadinessStatus.needsContext
            ? Colors.orange.shade700
            : colorScheme.primary;

    return AppInfoRow(
      title: '${gap.projectName} domain context',
      subtitle:
          '${gap.businessDomain} - ${gap.completionLabel} fields complete - ${gap.missingFieldLabel}',
      icon: Icons.extension_outlined,
      iconStyle: AppInfoRowIconStyle.badge,
      contained: true,
      iconBackgroundColor: color.withValues(alpha: 0.12),
      iconForegroundColor: color,
      titleMaxLines: 1,
      subtitleMaxLines: 3,
      trailing: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          AppStatusPill(
            label: gap.statusLabel,
            icon:
                gap.status == ProjectDomainExtensionReadinessStatus.needsContext
                    ? Icons.edit_note_outlined
                    : Icons.pending_actions_outlined,
            color: color,
            maxWidth: 136,
          ),
          if (onOpenProject != null)
            AppActionButton(
              label: 'Project',
              icon: Icons.open_in_new_rounded,
              compact: true,
              variant: AppActionButtonVariant.secondary,
              onPressed: () => onOpenProject!(gap.projectId),
            ),
        ],
      ),
    );
  }
}

class _RiskBrief extends StatelessWidget {
  const _RiskBrief({required this.summary});

  final ProjectPortfolioBriefingSummary summary;

  @override
  Widget build(BuildContext context) {
    final risk = summary.strongestRisk;
    final colorScheme = Theme.of(context).colorScheme;

    if (risk == null) {
      return AppInfoRow(
        title: 'No active risk spike',
        subtitle: 'The current board view has no registered active risks.',
        icon: Icons.health_and_safety_outlined,
        iconStyle: AppInfoRowIconStyle.badge,
        contained: true,
        iconBackgroundColor: Colors.green.shade700.withValues(alpha: 0.12),
        iconForegroundColor: Colors.green.shade700,
        subtitleMaxLines: 2,
      );
    }

    final riskColor = risk.severity.color(colorScheme);

    return AppInfoRow(
      title: risk.title,
      subtitle: '${risk.projectName} - ${risk.detail}',
      icon: risk.severity.icon,
      iconStyle: AppInfoRowIconStyle.badge,
      contained: true,
      iconBackgroundColor: riskColor.withValues(alpha: 0.12),
      iconForegroundColor: riskColor,
      titleMaxLines: 1,
      subtitleMaxLines: 3,
      trailing: AppStatusPill(
        label: risk.severity.label,
        icon: risk.severity.icon,
        color: riskColor,
        maxWidth: 118,
      ),
    );
  }
}

class _MilestoneBrief extends StatelessWidget {
  const _MilestoneBrief({required this.summary, required this.onOpenProject});

  final ProjectPortfolioBriefingSummary summary;
  final ValueChanged<String>? onOpenProject;

  @override
  Widget build(BuildContext context) {
    final milestone = summary.nextMilestone;
    final colorScheme = Theme.of(context).colorScheme;

    if (milestone == null) {
      return AppInfoRow(
        title: 'No open milestones',
        subtitle: 'The current board view has no upcoming milestone work.',
        icon: Icons.flag_outlined,
        iconStyle: AppInfoRowIconStyle.badge,
        contained: true,
        iconBackgroundColor: Colors.green.shade700.withValues(alpha: 0.12),
        iconForegroundColor: Colors.green.shade700,
        subtitleMaxLines: 2,
      );
    }

    final milestoneColor =
        milestone.isOverdue ? colorScheme.error : colorScheme.primary;
    final dateFormat = DateFormat('MMM d');

    return AppInfoRow(
      title: milestone.label,
      subtitle:
          '${milestone.projectName} - ${milestone.dueLabel} (${dateFormat.format(milestone.dueDate)})',
      icon: Icons.flag_outlined,
      iconStyle: AppInfoRowIconStyle.badge,
      contained: true,
      iconBackgroundColor: milestoneColor.withValues(alpha: 0.12),
      iconForegroundColor: milestoneColor,
      titleMaxLines: 1,
      subtitleMaxLines: 2,
      trailing: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          AppStatusPill(
            label: milestone.dueLabel,
            icon:
                milestone.isOverdue
                    ? Icons.event_busy_outlined
                    : Icons.event_available_outlined,
            color: milestoneColor,
            maxWidth: 128,
          ),
          if (onOpenProject != null)
            AppActionButton(
              label: 'Project',
              icon: Icons.open_in_new_rounded,
              compact: true,
              variant: AppActionButtonVariant.secondary,
              onPressed: () => onOpenProject!(milestone.projectId),
            ),
        ],
      ),
    );
  }
}
