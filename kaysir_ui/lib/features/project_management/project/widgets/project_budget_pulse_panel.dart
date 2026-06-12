import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_action_button.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../services/project_budget_pulse_service.dart';

class ProjectBudgetPulsePanel extends StatelessWidget {
  const ProjectBudgetPulsePanel({
    required this.summary,
    this.maxItems = 5,
    this.onOpenProject,
    super.key,
  });

  final ProjectBudgetPulseSummary summary;
  final int maxItems;
  final ValueChanged<String>? onOpenProject;

  @override
  Widget build(BuildContext context) {
    if (summary.projectCount == 0) {
      return const AppEmptyState(
        icon: Icons.account_balance_wallet_outlined,
        title: 'No budget pulse',
        message: 'Project budget and progress signals will appear here.',
      );
    }

    final colorScheme = Theme.of(context).colorScheme;
    final signalColor = summary.signal.color(colorScheme);
    final visibleItems = summary.prioritizedItems.take(maxItems).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppInfoRow(
          title: 'Budget Pulse ${summary.signal.label}',
          subtitle:
              '${summary.pressureCount} projects under pressure - ${_signedPoints(summary.averageVariancePoints)} avg gap',
          icon: summary.signal.icon,
          iconStyle: AppInfoRowIconStyle.badge,
          contained: true,
          iconBackgroundColor: signalColor.withValues(alpha: 0.12),
          iconForegroundColor: signalColor,
          titleMaxLines: 1,
          subtitleMaxLines: 2,
          trailing: AppStatusPill(
            label: summary.signal.label,
            icon: summary.signal.icon,
            color: signalColor,
            maxWidth: 118,
          ),
        ),
        const SizedBox(height: 12),
        AppMetricGrid(
          minTileWidth: 150,
          maxColumns: 4,
          metrics: [
            AppMetricGridItem(
              title: 'Projects',
              value: summary.projectCount.toString(),
              icon: Icons.workspaces_outline,
              accentColor: colorScheme.primary,
            ),
            AppMetricGridItem(
              title: 'Pressure',
              value: summary.pressureCount.toString(),
              icon: ProjectBudgetPulseState.pressure.icon,
              accentColor:
                  summary.pressureCount == 0
                      ? Colors.green.shade700
                      : Colors.orange.shade700,
            ),
            AppMetricGridItem(
              title: 'Critical',
              value: summary.criticalCount.toString(),
              icon: ProjectBudgetPulseState.critical.icon,
              accentColor:
                  summary.criticalCount == 0
                      ? Colors.green.shade700
                      : colorScheme.error,
            ),
            AppMetricGridItem(
              title: 'Avg Gap',
              value: _signedPoints(summary.averageVariancePoints),
              icon: Icons.speed_outlined,
              accentColor:
                  summary.averageVariancePoints >= 15
                      ? Colors.orange.shade700
                      : colorScheme.primary,
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (var index = 0; index < visibleItems.length; index++) ...[
          _ProjectBudgetPulseTile(
            item: visibleItems[index],
            onOpenProject:
                onOpenProject == null
                    ? null
                    : () => onOpenProject!(visibleItems[index].projectId),
          ),
          if (index != visibleItems.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }

  String _signedPoints(int points) {
    if (points == 0) return '0 pts';
    return '${points > 0 ? '+' : ''}$points pts';
  }
}

class _ProjectBudgetPulseTile extends StatelessWidget {
  const _ProjectBudgetPulseTile({
    required this.item,
    required this.onOpenProject,
  });

  final ProjectBudgetPulseItem item;
  final VoidCallback? onOpenProject;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final stateColor = item.state.color(colorScheme);

    return AppInfoRow(
      title: item.projectName,
      subtitle: projectBudgetPulseDetail(item),
      icon: item.state.icon,
      iconStyle: AppInfoRowIconStyle.badge,
      contained: true,
      iconBackgroundColor: stateColor.withValues(alpha: 0.12),
      iconForegroundColor: stateColor,
      titleMaxLines: 1,
      subtitleMaxLines: 2,
      trailing: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          AppStatusPill(
            label: item.state.label,
            icon: item.state.icon,
            color: stateColor,
            maxWidth: 118,
          ),
          if (onOpenProject != null)
            AppActionButton(
              label: 'Project',
              icon: Icons.open_in_new_rounded,
              compact: true,
              variant: AppActionButtonVariant.secondary,
              onPressed: onOpenProject,
            ),
        ],
      ),
    );
  }
}
