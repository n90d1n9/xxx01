import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_filter_chip_group.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../services/project_readiness_score_service.dart';

enum ProjectReadinessFactorFilter { all, critical, warning, positive }

extension ProjectReadinessFactorFilterPresentation
    on ProjectReadinessFactorFilter {
  String get label {
    switch (this) {
      case ProjectReadinessFactorFilter.all:
        return 'All';
      case ProjectReadinessFactorFilter.critical:
        return ProjectReadinessFactorLevel.critical.label;
      case ProjectReadinessFactorFilter.warning:
        return ProjectReadinessFactorLevel.warning.label;
      case ProjectReadinessFactorFilter.positive:
        return ProjectReadinessFactorLevel.positive.label;
    }
  }

  IconData get icon {
    switch (this) {
      case ProjectReadinessFactorFilter.all:
        return Icons.filter_list_rounded;
      case ProjectReadinessFactorFilter.critical:
        return ProjectReadinessFactorLevel.critical.icon;
      case ProjectReadinessFactorFilter.warning:
        return ProjectReadinessFactorLevel.warning.icon;
      case ProjectReadinessFactorFilter.positive:
        return ProjectReadinessFactorLevel.positive.icon;
    }
  }

  bool matches(ProjectReadinessFactor factor) {
    switch (this) {
      case ProjectReadinessFactorFilter.all:
        return true;
      case ProjectReadinessFactorFilter.critical:
        return factor.level == ProjectReadinessFactorLevel.critical;
      case ProjectReadinessFactorFilter.warning:
        return factor.level == ProjectReadinessFactorLevel.warning;
      case ProjectReadinessFactorFilter.positive:
        return factor.level == ProjectReadinessFactorLevel.positive;
    }
  }
}

class ProjectReadinessScorePanel extends StatefulWidget {
  const ProjectReadinessScorePanel({
    required this.summary,
    this.maxFactors = 5,
    super.key,
  });

  final ProjectReadinessScoreSummary summary;
  final int maxFactors;

  @override
  State<ProjectReadinessScorePanel> createState() =>
      _ProjectReadinessScorePanelState();
}

class _ProjectReadinessScorePanelState
    extends State<ProjectReadinessScorePanel> {
  var _filter = ProjectReadinessFactorFilter.all;

  @override
  Widget build(BuildContext context) {
    final summary = widget.summary;
    final colorScheme = Theme.of(context).colorScheme;
    final levelColor = summary.level.color(colorScheme);
    final visibleFactors =
        summary.factors.where(_filter.matches).take(widget.maxFactors).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppInfoRow(
          title: 'Readiness ${summary.level.label}',
          subtitle:
              '${summary.score}/100 confidence score for ${summary.project.name}',
          icon: summary.level.icon,
          iconStyle: AppInfoRowIconStyle.badge,
          contained: true,
          iconBackgroundColor: levelColor.withValues(alpha: 0.12),
          iconForegroundColor: levelColor,
          titleMaxLines: 1,
          subtitleMaxLines: 2,
          trailing: AppStatusPill(
            label: summary.level.label,
            icon: summary.level.icon,
            color: levelColor,
            maxWidth: 130,
          ),
        ),
        const SizedBox(height: 12),
        AppMetricGrid(
          minTileWidth: 130,
          maxColumns: 4,
          metrics: [
            AppMetricGridItem(
              title: 'Score',
              value: '${summary.score}',
              icon: Icons.speed_outlined,
              accentColor: levelColor,
              helper: 'out of 100',
            ),
            AppMetricGridItem(
              title: 'Critical',
              value: summary.criticalCount.toString(),
              icon: ProjectReadinessFactorLevel.critical.icon,
              accentColor:
                  summary.criticalCount == 0
                      ? Colors.green.shade700
                      : colorScheme.error,
            ),
            AppMetricGridItem(
              title: 'Watch',
              value: summary.warningCount.toString(),
              icon: ProjectReadinessFactorLevel.warning.icon,
              accentColor:
                  summary.warningCount == 0
                      ? colorScheme.primary
                      : Colors.orange.shade700,
            ),
            AppMetricGridItem(
              title: 'Stable',
              value: summary.positiveCount.toString(),
              icon: ProjectReadinessFactorLevel.positive.icon,
              accentColor: Colors.green.shade700,
            ),
          ],
        ),
        if (summary.factors.isNotEmpty) ...[
          const SizedBox(height: 12),
          AppFilterChipGroup<ProjectReadinessFactorFilter>(
            value: _filter,
            options: [
              AppFilterChipOption(
                value: ProjectReadinessFactorFilter.all,
                label: ProjectReadinessFactorFilter.all.label,
                icon: ProjectReadinessFactorFilter.all.icon,
                count: summary.factors.length,
              ),
              AppFilterChipOption(
                value: ProjectReadinessFactorFilter.critical,
                label: ProjectReadinessFactorFilter.critical.label,
                icon: ProjectReadinessFactorFilter.critical.icon,
                count: summary.criticalCount,
              ),
              AppFilterChipOption(
                value: ProjectReadinessFactorFilter.warning,
                label: ProjectReadinessFactorFilter.warning.label,
                icon: ProjectReadinessFactorFilter.warning.icon,
                count: summary.warningCount,
              ),
              AppFilterChipOption(
                value: ProjectReadinessFactorFilter.positive,
                label: ProjectReadinessFactorFilter.positive.label,
                icon: ProjectReadinessFactorFilter.positive.icon,
                count: summary.positiveCount,
              ),
            ],
            onChanged: (value) => setState(() => _filter = value),
          ),
          const SizedBox(height: 12),
          if (visibleFactors.isEmpty)
            AppEmptyState(
              icon: _filter.icon,
              title: 'No ${_filter.label.toLowerCase()} factors',
              message: 'Readiness signals for this level will appear here.',
            )
          else
            for (var index = 0; index < visibleFactors.length; index++) ...[
              _ProjectReadinessFactorTile(factor: visibleFactors[index]),
              if (index != visibleFactors.length - 1)
                const SizedBox(height: 10),
            ],
          if (_filter == ProjectReadinessFactorFilter.all &&
              summary.factors.length > widget.maxFactors) ...[
            const SizedBox(height: 10),
            Text(
              'Showing ${widget.maxFactors} of ${summary.factors.length} readiness factors',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ],
      ],
    );
  }
}

class _ProjectReadinessFactorTile extends StatelessWidget {
  const _ProjectReadinessFactorTile({required this.factor});

  final ProjectReadinessFactor factor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final factorColor = factor.level.color(colorScheme);

    return AppInfoRow(
      title: factor.title,
      subtitle: factor.detail,
      icon: factor.icon,
      iconStyle: AppInfoRowIconStyle.badge,
      contained: true,
      iconBackgroundColor: factorColor.withValues(alpha: 0.12),
      iconForegroundColor: factorColor,
      titleMaxLines: 1,
      subtitleMaxLines: 2,
      trailing: AppStatusPill(
        label: factor.level.label,
        icon: factor.level.icon,
        color: factorColor,
        maxWidth: 110,
      ),
    );
  }
}

extension _ProjectReadinessFactorIcon on ProjectReadinessFactorLevel {
  IconData get icon {
    switch (this) {
      case ProjectReadinessFactorLevel.critical:
        return Icons.priority_high_rounded;
      case ProjectReadinessFactorLevel.warning:
        return Icons.warning_amber_rounded;
      case ProjectReadinessFactorLevel.positive:
        return Icons.check_circle_outline;
    }
  }
}
