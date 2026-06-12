import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/widgets/ui/app_action_button.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_filter_chip_group.dart';
import 'package:kaysir/widgets/ui/app_icon_badge.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../models/project_portfolio_item.dart';
import '../services/project_domain_gap_focus_service.dart';
import '../services/project_domain_extension_readiness_service.dart';
import '../services/project_portfolio_domain_readiness_service.dart';
import '../services/project_portfolio_view_service.dart';
import '../services/project_priority_service.dart';
import '../services/project_saved_view_service.dart';
import 'project_domain_readiness_compact_pill.dart';
import 'project_team_avatar_stack.dart';

class ProjectPortfolioSummaryGrid extends StatelessWidget {
  const ProjectPortfolioSummaryGrid({required this.projects, super.key});

  final List<ProjectPortfolioItem> projects;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final activeCount = projects.length;
    final atRiskCount =
        projects
            .where((project) => project.health == ProjectHealth.atRisk)
            .length;
    final blockedCount =
        projects
            .where((project) => project.health == ProjectHealth.blocked)
            .length;
    final attentionCount =
        projects.where((project) => projectNeedsAttention(project)).length;
    final domainReadiness = buildProjectPortfolioDomainReadiness(
      projects: projects,
    );
    final averageProgress =
        projects.isEmpty
            ? 0
            : projects.fold<double>(
                  0,
                  (sum, project) => sum + project.progress,
                ) /
                projects.length;

    return AppMetricGrid(
      minTileWidth: 180,
      metrics: [
        AppMetricGridItem(
          title: 'Active Projects',
          value: activeCount.toString(),
          icon: Icons.workspaces_outline,
          accentColor: colorScheme.primary,
        ),
        AppMetricGridItem(
          title: 'Average Progress',
          value: '${(averageProgress * 100).round()}%',
          icon: Icons.trending_up_rounded,
          accentColor: Colors.green.shade700,
        ),
        AppMetricGridItem(
          title: 'Needs Attention',
          value: attentionCount.toString(),
          icon: Icons.priority_high_rounded,
          accentColor:
              attentionCount == 0
                  ? Colors.green.shade700
                  : Colors.orange.shade700,
        ),
        AppMetricGridItem(
          title: 'Domain Context',
          value: '${domainReadiness.completionPercent}%',
          helper: domainReadiness.helperLabel,
          icon: Icons.extension_outlined,
          accentColor:
              domainReadiness.needsContextCount == 0
                  ? Colors.green.shade700
                  : Colors.orange.shade700,
        ),
        AppMetricGridItem(
          title: 'At Risk',
          value: atRiskCount.toString(),
          icon: Icons.warning_amber_rounded,
          accentColor: Colors.orange.shade700,
        ),
        AppMetricGridItem(
          title: 'Blocked',
          value: blockedCount.toString(),
          icon: Icons.block_outlined,
          accentColor: colorScheme.error,
        ),
      ],
    );
  }
}

class ProjectPortfolioList extends StatelessWidget {
  const ProjectPortfolioList({
    required this.projects,
    this.onProjectTap,
    this.onFocusGantt,
    super.key,
  });

  final List<ProjectPortfolioItem> projects;
  final ValueChanged<ProjectPortfolioItem>? onProjectTap;
  final ValueChanged<ProjectPortfolioItem>? onFocusGantt;

  @override
  Widget build(BuildContext context) {
    if (projects.isEmpty) {
      return const AppEmptyState(
        icon: Icons.search_off_outlined,
        title: 'No projects found',
        message: 'Try a different portfolio search or health filter.',
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 980 ? 2 : 1;
        final spacing = 12.0;
        final width =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final project in projects)
              SizedBox(
                width: width,
                child: ProjectPortfolioCard(
                  project,
                  onTap:
                      onProjectTap == null
                          ? null
                          : () => onProjectTap!(project),
                  onFocusGantt:
                      onFocusGantt == null
                          ? null
                          : () => onFocusGantt!(project),
                ),
              ),
          ],
        );
      },
    );
  }
}

class ProjectPortfolioSavedViewsBar extends StatelessWidget {
  const ProjectPortfolioSavedViewsBar({
    required this.projects,
    required this.value,
    required this.onChanged,
    this.today,
    super.key,
  });

  final List<ProjectPortfolioItem> projects;
  final ProjectPortfolioViewPreset value;
  final ValueChanged<ProjectPortfolioViewPreset> onChanged;
  final DateTime? today;

  @override
  Widget build(BuildContext context) {
    final counts = countProjectPortfolioViews(projects, today: today);

    return AppFilterChipGroup<ProjectPortfolioViewPreset>(
      value: value,
      options: [
        for (final preset in ProjectPortfolioViewPreset.values)
          AppFilterChipOption(
            value: preset,
            label: preset.label,
            icon: preset.icon,
            count: counts[preset] ?? 0,
          ),
      ],
      onChanged: onChanged,
    );
  }
}

class ProjectPortfolioActiveFiltersBar extends StatelessWidget {
  const ProjectPortfolioActiveFiltersBar({
    required this.query,
    required this.viewPreset,
    required this.healthFilter,
    required this.domainReadinessFilter,
    required this.domainGapFocus,
    required this.sortOption,
    required this.visibleCount,
    required this.totalCount,
    required this.onClear,
    super.key,
  });

  final String query;
  final ProjectPortfolioViewPreset viewPreset;
  final ProjectHealth? healthFilter;
  final ProjectDomainReadinessFilter domainReadinessFilter;
  final ProjectDomainGapFocus domainGapFocus;
  final ProjectPortfolioSortOption sortOption;
  final int visibleCount;
  final int totalCount;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final normalizedQuery = query.trim();
    final hasCustomView =
        normalizedQuery.isNotEmpty ||
        viewPreset != ProjectPortfolioViewPreset.all ||
        healthFilter != null ||
        domainReadinessFilter != ProjectDomainReadinessFilter.all ||
        domainGapFocus != ProjectDomainGapFocus.all ||
        sortOption != ProjectPortfolioSortOption.attention;

    if (!hasCustomView) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final healthColor = healthFilter?.color(colorScheme);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            'Active view',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w900,
            ),
          ),
          AppStatusPill(
            label: '$visibleCount of $totalCount projects',
            icon: Icons.view_list_outlined,
            color: colorScheme.primary,
            maxWidth: 180,
          ),
          if (normalizedQuery.isNotEmpty)
            AppStatusPill(
              label: '"$normalizedQuery"',
              icon: Icons.search,
              color: colorScheme.secondary,
              maxWidth: 220,
            ),
          if (viewPreset != ProjectPortfolioViewPreset.all)
            AppStatusPill(
              label: viewPreset.label,
              icon: viewPreset.icon,
              color: colorScheme.primary,
              maxWidth: 200,
            ),
          if (healthFilter != null)
            AppStatusPill(
              label: healthFilter!.label,
              icon: healthFilter!.icon,
              color: healthColor!,
              maxWidth: 160,
            ),
          if (domainReadinessFilter != ProjectDomainReadinessFilter.all)
            AppStatusPill(
              label: domainReadinessFilter.label,
              icon: Icons.extension_outlined,
              color: colorScheme.secondary,
              maxWidth: 190,
            ),
          if (domainGapFocus != ProjectDomainGapFocus.all)
            AppStatusPill(
              label: domainGapFocus.label,
              icon: domainGapFocus.icon,
              color: colorScheme.tertiary,
              maxWidth: 200,
            ),
          if (sortOption != ProjectPortfolioSortOption.attention)
            AppStatusPill(
              label: 'Sort: ${sortOption.label}',
              icon: sortOption.icon,
              color: colorScheme.primary,
              maxWidth: 210,
            ),
          AppActionButton(
            label: 'Clear View',
            icon: Icons.filter_alt_off_outlined,
            compact: true,
            variant: AppActionButtonVariant.secondary,
            onPressed: onClear,
          ),
        ],
      ),
    );
  }
}

class ProjectPortfolioCard extends StatelessWidget {
  const ProjectPortfolioCard(
    this.project, {
    this.onTap,
    this.onFocusGantt,
    super.key,
  });

  final ProjectPortfolioItem project;
  final VoidCallback? onTap;
  final VoidCallback? onFocusGantt;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final healthColor = project.health.color(colorScheme);
    final priority = projectPriorityFor(project);
    final priorityColor = priority.color(colorScheme);
    final domainReadiness = const ProjectDomainExtensionReadinessService()
        .build(
          businessDomain: project.businessDomain,
          attributes: project.customAttributes,
        );
    final dateFormat = DateFormat('MMM d');

    return Material(
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppIconBadge(
                    icon: Icons.folder_copy_outlined,
                    size: 42,
                    backgroundColor: colorScheme.primaryContainer,
                    foregroundColor: colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${project.client} - ${project.owner}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  AppStatusPill(
                    label: project.health.label,
                    icon: project.health.icon,
                    color: healthColor,
                    maxWidth: 120,
                  ),
                  if (onTap != null) ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  minHeight: 8,
                  value: project.progress.clamp(0, 1),
                  color: healthColor,
                  backgroundColor: healthColor.withValues(alpha: 0.14),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '${(project.progress * 100).round()}% complete',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${dateFormat.format(project.startDate)} - ${dateFormat.format(project.endDate)}',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  AppStatusPill(
                    label: project.businessDomain,
                    icon: Icons.domain_outlined,
                    color: colorScheme.secondary,
                    maxWidth: 220,
                  ),
                  ProjectDomainReadinessCompactPill(
                    summary: domainReadiness,
                    maxWidth: 190,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ProjectMilestoneStrip(milestones: project.milestones),
              if (project.team.isNotEmpty) ...[
                const SizedBox(height: 12),
                ProjectTeamAvatarSummary(members: project.team),
              ],
              const SizedBox(height: 12),
              AppInfoRow(
                title: '${project.openMilestoneCount} open milestones',
                subtitle:
                    '${project.durationDays} days - ${(project.budgetUsed * 100).round()}% budget used',
                icon: Icons.flag_outlined,
                iconStyle: AppInfoRowIconStyle.badge,
                contained: true,
                iconBackgroundColor: healthColor.withValues(alpha: 0.12),
                iconForegroundColor: healthColor,
                trailing: AppStatusPill(
                  label: priority.label,
                  icon: priority.icon,
                  color: priorityColor,
                  maxWidth: 112,
                ),
              ),
              if (onFocusGantt != null) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: AppActionButton(
                    label: 'Focus Gantt',
                    icon: Icons.timeline_outlined,
                    compact: true,
                    variant: AppActionButtonVariant.secondary,
                    onPressed: onFocusGantt!,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class ProjectMilestoneStrip extends StatelessWidget {
  const ProjectMilestoneStrip({required this.milestones, super.key});

  final List<ProjectMilestone> milestones;

  @override
  Widget build(BuildContext context) {
    if (milestones.isEmpty) {
      return const SizedBox.shrink();
    }

    final dateFormat = DateFormat('MMM d');

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final milestone in milestones.take(3))
          AppStatusPill(
            label: '${milestone.label} ${dateFormat.format(milestone.dueDate)}',
            icon:
                milestone.isComplete
                    ? Icons.check_rounded
                    : Icons.radio_button_unchecked_rounded,
            color:
                milestone.isComplete
                    ? Colors.green.shade700
                    : Theme.of(context).colorScheme.primary,
            maxWidth: 220,
          ),
      ],
    );
  }
}
