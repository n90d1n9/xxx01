import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_action_button.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../models/project_portfolio_item.dart';
import '../services/project_risk_exposure_service.dart';

class ProjectRiskExposurePanel extends StatelessWidget {
  const ProjectRiskExposurePanel({
    required this.summary,
    this.maxItems = 5,
    this.onOpenProject,
    super.key,
  });

  final ProjectRiskExposureSummary summary;
  final int maxItems;
  final ValueChanged<String>? onOpenProject;

  @override
  Widget build(BuildContext context) {
    if (summary.totalCount == 0) {
      return const AppEmptyState(
        icon: Icons.health_and_safety_outlined,
        title: 'No portfolio risks',
        message: 'Project risks will appear here when teams register them.',
      );
    }

    final colorScheme = Theme.of(context).colorScheme;
    final signalColor = summary.signal.color(colorScheme);
    final visibleItems = summary.prioritizedItems.take(maxItems).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppInfoRow(
          title: 'Risk Exposure ${summary.signal.riskLabel}',
          subtitle:
              '${summary.activeCount} active risks across ${summary.projectCount} projects',
          icon: summary.signal.riskIcon,
          iconStyle: AppInfoRowIconStyle.badge,
          contained: true,
          iconBackgroundColor: signalColor.withValues(alpha: 0.12),
          iconForegroundColor: signalColor,
          titleMaxLines: 1,
          subtitleMaxLines: 2,
          trailing: AppStatusPill(
            label: summary.signal.riskLabel,
            icon: summary.signal.riskIcon,
            color: signalColor,
            maxWidth: 120,
          ),
        ),
        const SizedBox(height: 12),
        AppMetricGrid(
          minTileWidth: 150,
          maxColumns: 4,
          metrics: [
            AppMetricGridItem(
              title: 'Active Risks',
              value: summary.activeCount.toString(),
              icon: Icons.health_and_safety_outlined,
              accentColor:
                  summary.activeCount == 0
                      ? Colors.green.shade700
                      : Colors.orange.shade700,
            ),
            AppMetricGridItem(
              title: 'Critical',
              value: summary.criticalCount.toString(),
              icon: ProjectHealth.blocked.riskIcon,
              accentColor:
                  summary.criticalCount == 0
                      ? Colors.green.shade700
                      : colorScheme.error,
            ),
            AppMetricGridItem(
              title: 'Warnings',
              value: summary.warningCount.toString(),
              icon: ProjectHealth.atRisk.riskIcon,
              accentColor:
                  summary.warningCount == 0
                      ? colorScheme.primary
                      : Colors.orange.shade700,
            ),
            AppMetricGridItem(
              title: 'Exposure',
              value: summary.exposureScore.toString(),
              icon: Icons.radar_outlined,
              accentColor: signalColor,
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (var index = 0; index < visibleItems.length; index++) ...[
          _ProjectRiskExposureTile(
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
}

class _ProjectRiskExposureTile extends StatelessWidget {
  const _ProjectRiskExposureTile({
    required this.item,
    required this.onOpenProject,
  });

  final ProjectRiskExposureItem item;
  final VoidCallback? onOpenProject;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final severityColor = item.severity.color(colorScheme);

    return AppInfoRow(
      title: item.title,
      subtitle: projectRiskExposureDetail(item),
      icon: item.severity.riskIcon,
      iconStyle: AppInfoRowIconStyle.badge,
      contained: true,
      iconBackgroundColor: severityColor.withValues(alpha: 0.12),
      iconForegroundColor: severityColor,
      titleMaxLines: 1,
      subtitleMaxLines: 2,
      trailing: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          AppStatusPill(
            label: item.severity.riskLabel,
            icon: item.severity.riskIcon,
            color: severityColor,
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
