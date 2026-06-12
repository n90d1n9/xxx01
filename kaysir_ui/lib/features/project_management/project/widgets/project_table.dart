import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';

import '../models/project_portfolio_item.dart';
import '../services/project_domain_extension_readiness_service.dart';
import '../services/project_priority_service.dart';
import '../services/project_table_custom_column_service.dart';
import '../services/project_table_view_service.dart';

typedef ProjectTableCustomAttributeEditCallback =
    void Function(
      ProjectPortfolioItem project,
      ProjectTableCustomColumn column,
    );

class ProjectPortfolioTable extends StatelessWidget {
  const ProjectPortfolioTable({
    required this.projects,
    this.onOpenProject,
    this.onEditProject,
    this.onEditProjectAttributes,
    this.onEditProjectCustomAttribute,
    this.onRemoveProject,
    this.removableProjectIds = const {},
    this.visibleColumns = projectOperationsTableColumns,
    this.customColumns = const [],
    super.key,
  });

  final List<ProjectPortfolioItem> projects;
  final ValueChanged<ProjectPortfolioItem>? onOpenProject;
  final ValueChanged<ProjectPortfolioItem>? onEditProject;
  final ValueChanged<ProjectPortfolioItem>? onEditProjectAttributes;
  final ProjectTableCustomAttributeEditCallback? onEditProjectCustomAttribute;
  final ValueChanged<ProjectPortfolioItem>? onRemoveProject;
  final Set<String> removableProjectIds;
  final Set<ProjectTableColumn> visibleColumns;
  final List<ProjectTableCustomColumn> customColumns;

  @override
  Widget build(BuildContext context) {
    if (projects.isEmpty) {
      return const AppEmptyState(
        icon: Icons.table_rows_outlined,
        title: 'No projects in this table',
        message: 'Adjust the search, health filter, or saved view.',
      );
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final columns =
        visibleColumns.isEmpty ? projectOperationsTableColumns : visibleColumns;
    final visibleCustomColumns =
        columns.contains(ProjectTableColumn.extensions)
            ? customColumns.take(3).toList(growable: false)
            : const <ProjectTableCustomColumn>[];

    return LayoutBuilder(
      builder: (context, constraints) {
        final minWidth =
            constraints.hasBoundedWidth ? constraints.maxWidth : 1280.0;

        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border.all(color: colorScheme.outlineVariant),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: minWidth),
                child: DataTable(
                  showCheckboxColumn: false,
                  horizontalMargin: 18,
                  columnSpacing: 24,
                  headingRowHeight: 48,
                  headingRowColor: WidgetStatePropertyAll(
                    colorScheme.surfaceContainerHighest,
                  ),
                  headingTextStyle: textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w900,
                  ),
                  dataTextStyle: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                  dataRowMinHeight: 66,
                  dataRowMaxHeight: 92,
                  dividerThickness: 0,
                  border: TableBorder(
                    horizontalInside: BorderSide(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.56),
                      width: 0.7,
                    ),
                  ),
                  columns: [
                    const DataColumn(label: Text('Project')),
                    if (columns.contains(ProjectTableColumn.owner))
                      const DataColumn(label: Text('Owner')),
                    if (columns.contains(ProjectTableColumn.health))
                      const DataColumn(label: Text('Health')),
                    if (columns.contains(ProjectTableColumn.progress))
                      const DataColumn(label: Text('Progress'), numeric: true),
                    if (columns.contains(ProjectTableColumn.budget))
                      const DataColumn(label: Text('Budget'), numeric: true),
                    if (columns.contains(ProjectTableColumn.openMilestones))
                      const DataColumn(
                        label: Text('Open Milestones'),
                        numeric: true,
                      ),
                    if (columns.contains(ProjectTableColumn.extensions))
                      const DataColumn(label: Text('Extensions')),
                    for (final column in visibleCustomColumns)
                      DataColumn(
                        label: Tooltip(
                          message: column.summaryLabel,
                          child: Text(column.label),
                        ),
                      ),
                    if (columns.contains(ProjectTableColumn.timeline))
                      const DataColumn(label: Text('Timeline')),
                    const DataColumn(label: Text('Action')),
                  ],
                  rows: [
                    for (var index = 0; index < projects.length; index++)
                      _ProjectTableRow(
                        project: projects[index],
                        rowIndex: index,
                        visibleColumns: columns,
                        customColumns: visibleCustomColumns,
                        canRemove: removableProjectIds.contains(
                          projects[index].id,
                        ),
                        onOpen:
                            onOpenProject == null
                                ? null
                                : () => onOpenProject!(projects[index]),
                        onEdit:
                            onEditProject == null
                                ? null
                                : () => onEditProject!(projects[index]),
                        onEditAttributes:
                            onEditProjectAttributes == null ||
                                    !removableProjectIds.contains(
                                      projects[index].id,
                                    )
                                ? null
                                : () =>
                                    onEditProjectAttributes!(projects[index]),
                        onEditAttribute:
                            onEditProjectCustomAttribute == null ||
                                    !removableProjectIds.contains(
                                      projects[index].id,
                                    )
                                ? null
                                : (column) => onEditProjectCustomAttribute!(
                                  projects[index],
                                  column,
                                ),
                        onRemove:
                            onRemoveProject == null
                                ? null
                                : () => onRemoveProject!(projects[index]),
                      ).build(context),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProjectTableRow {
  const _ProjectTableRow({
    required this.project,
    required this.rowIndex,
    required this.visibleColumns,
    required this.customColumns,
    required this.canRemove,
    required this.onOpen,
    required this.onEdit,
    required this.onEditAttributes,
    required this.onEditAttribute,
    required this.onRemove,
  });

  final ProjectPortfolioItem project;
  final int rowIndex;
  final Set<ProjectTableColumn> visibleColumns;
  final List<ProjectTableCustomColumn> customColumns;
  final bool canRemove;
  final VoidCallback? onOpen;
  final VoidCallback? onEdit;
  final VoidCallback? onEditAttributes;
  final ValueChanged<ProjectTableCustomColumn>? onEditAttribute;
  final VoidCallback? onRemove;

  DataRow build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dateFormat = DateFormat('MMM d');
    final healthColor = project.health.color(colorScheme);
    final priority = projectPriorityFor(project);

    return DataRow(
      color: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.hovered)) {
          return colorScheme.primary.withValues(alpha: 0.06);
        }
        if (rowIndex.isOdd) {
          return colorScheme.surfaceContainerLowest.withValues(alpha: 0.62);
        }
        return colorScheme.surface;
      }),
      onSelectChanged: onOpen == null ? null : (_) => onOpen!(),
      cells: [
        DataCell(
          SizedBox(
            width: 280,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                Text(
                  project.client,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (visibleColumns.contains(ProjectTableColumn.owner))
          DataCell(
            SizedBox(
              width: 150,
              child: Text(
                project.owner,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        if (visibleColumns.contains(ProjectTableColumn.health))
          DataCell(
            _ProjectTablePill(
              label: project.health.label,
              icon: project.health.icon,
              color: healthColor,
              maxWidth: 120,
            ),
          ),
        if (visibleColumns.contains(ProjectTableColumn.progress))
          DataCell(
            _ProjectMetricMeter(
              label: '${(project.progress * 100).round()}%',
              value: project.progress,
              color: healthColor,
              semanticLabel: 'Progress for ${project.name}',
            ),
          ),
        if (visibleColumns.contains(ProjectTableColumn.budget))
          DataCell(
            _ProjectMetricMeter(
              label: '${(project.budgetUsed * 100).round()}%',
              value: project.budgetUsed,
              color: _budgetColor(project.budgetUsed, colorScheme),
              semanticLabel: 'Budget used for ${project.name}',
            ),
          ),
        if (visibleColumns.contains(ProjectTableColumn.openMilestones))
          DataCell(Text(project.openMilestoneCount.toString())),
        if (visibleColumns.contains(ProjectTableColumn.extensions))
          DataCell(_ProjectAttributeSummary(project: project)),
        for (final column in customColumns)
          DataCell(
            _ProjectCustomAttributeCell(
              project: project,
              column: column,
              onFixGap:
                  onEditAttribute == null
                      ? onEditAttributes
                      : () => onEditAttribute!(column),
            ),
          ),
        if (visibleColumns.contains(ProjectTableColumn.timeline))
          DataCell(
            SizedBox(
              width: 142,
              child: Text(
                '${dateFormat.format(project.startDate)} - ${dateFormat.format(project.endDate)}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        DataCell(
          SizedBox(
            width: canRemove ? 152 : 96,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                IconButton(
                  tooltip: 'Open ${project.name} - ${priority.label}',
                  icon: Icon(priority.icon),
                  onPressed: onOpen,
                ),
                if (canRemove && onEdit != null)
                  IconButton(
                    tooltip: 'Edit ${project.name}',
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: onEdit,
                  ),
                if (canRemove && onRemove != null)
                  IconButton(
                    tooltip: 'Remove ${project.name}',
                    icon: const Icon(Icons.delete_outline_rounded),
                    onPressed: onRemove,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProjectCustomAttributeCell extends StatelessWidget {
  const _ProjectCustomAttributeCell({
    required this.project,
    required this.column,
    this.onFixGap,
  });

  final ProjectPortfolioItem project;
  final ProjectTableCustomColumn column;
  final VoidCallback? onFixGap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasValue = column.hasValueFor(project);
    final value = column.displayValueFor(project);
    final color = _attributeCellColor(column, project, colorScheme);
    final icon = _attributeCellIcon(column, project);
    final canFixGap = !hasValue && onFixGap != null;

    return SizedBox(
      width: canFixGap ? 176 : 148,
      child: Row(
        children: [
          Expanded(
            child: Tooltip(
              message: column.tooltipFor(project),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 14, color: color),
                    const SizedBox(width: 5),
                  ],
                  Flexible(
                    child: Text(
                      value,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: color,
                        fontWeight:
                            hasValue ? FontWeight.w800 : FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (canFixGap) ...[
            const SizedBox(width: 4),
            IconButton(
              key: ValueKey(
                'project-custom-attribute-fix-${project.id}-${column.key}',
              ),
              tooltip: 'Edit ${column.label} for ${project.name}',
              icon: const Icon(Icons.edit_note_outlined),
              iconSize: 16,
              constraints: const BoxConstraints.tightFor(width: 28, height: 28),
              padding: EdgeInsets.zero,
              onPressed: onFixGap,
            ),
          ],
        ],
      ),
    );
  }
}

Color _attributeCellColor(
  ProjectTableCustomColumn column,
  ProjectPortfolioItem project,
  ColorScheme colorScheme,
) {
  if (column.hasValueFor(project)) return colorScheme.onSurface;
  if (column.isRequiredFor(project)) return colorScheme.error;
  if (column.isRecommendedFor(project)) return colorScheme.primary;
  if (column.isRiskWatchedFor(project)) return colorScheme.tertiary;
  return colorScheme.onSurfaceVariant;
}

IconData? _attributeCellIcon(
  ProjectTableCustomColumn column,
  ProjectPortfolioItem project,
) {
  if (column.hasValueFor(project)) return null;
  if (column.isRequiredFor(project)) return Icons.priority_high_rounded;
  if (column.isRecommendedFor(project)) return Icons.fact_check_outlined;
  if (column.isRiskWatchedFor(project)) return Icons.sensors_outlined;
  return null;
}

class _ProjectMetricMeter extends StatelessWidget {
  const _ProjectMetricMeter({
    required this.label,
    required this.value,
    required this.color,
    required this.semanticLabel,
  });

  final String label;
  final double value;
  final Color color;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final normalizedValue = value.clamp(0, 1).toDouble();

    return SizedBox(
      width: 118,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 7),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: normalizedValue,
              minHeight: 6,
              semanticsLabel: semanticLabel,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectAttributeSummary extends StatelessWidget {
  const _ProjectAttributeSummary({required this.project});

  final ProjectPortfolioItem project;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final readiness = const ProjectDomainExtensionReadinessService().build(
      businessDomain: project.businessDomain,
      attributes: project.customAttributes,
    );
    final attributes = project.pinnedCustomAttributes
        .take(1)
        .toList(growable: false);

    return SizedBox(
      width: 250,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProjectReadinessPill(summary: readiness, maxWidth: 240),
          if (attributes.isNotEmpty) ...[
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final attribute in attributes)
                  _ProjectTablePill(
                    label: '${attribute.label}: ${attribute.displayValue}',
                    icon: Icons.extension_outlined,
                    color: colorScheme.primary,
                    maxWidth: 240,
                  ),
              ],
            ),
          ] else
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'No fields filled',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProjectReadinessPill extends StatelessWidget {
  const _ProjectReadinessPill({required this.summary, required this.maxWidth});

  final ProjectDomainExtensionReadinessSummary summary;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return _ProjectTablePill(
      label:
          '${summary.completedReadinessFieldCount}/${summary.readinessFieldCount} ${summary.statusLabel}',
      icon: _domainReadinessIcon(summary.status),
      color: _domainReadinessColor(summary.status, colorScheme),
      maxWidth: maxWidth,
      tooltip: '${summary.businessDomain}: ${summary.guidance}',
    );
  }
}

class _ProjectTablePill extends StatelessWidget {
  const _ProjectTablePill({
    required this.label,
    required this.icon,
    required this.color,
    required this.maxWidth,
    this.tooltip,
  });

  final String label;
  final IconData icon;
  final Color color;
  final double maxWidth;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final pill = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          border: Border.all(color: color.withValues(alpha: 0.35)),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (tooltip == null) return pill;
    return Tooltip(message: tooltip, child: pill);
  }
}

Color _domainReadinessColor(
  ProjectDomainExtensionReadinessStatus status,
  ColorScheme colorScheme,
) {
  return switch (status) {
    ProjectDomainExtensionReadinessStatus.needsContext =>
      Colors.orange.shade700,
    ProjectDomainExtensionReadinessStatus.inProgress => colorScheme.primary,
    ProjectDomainExtensionReadinessStatus.ready => Colors.green.shade700,
  };
}

IconData _domainReadinessIcon(ProjectDomainExtensionReadinessStatus status) {
  return switch (status) {
    ProjectDomainExtensionReadinessStatus.needsContext =>
      Icons.edit_note_outlined,
    ProjectDomainExtensionReadinessStatus.inProgress =>
      Icons.pending_actions_outlined,
    ProjectDomainExtensionReadinessStatus.ready => Icons.verified_outlined,
  };
}

Color _budgetColor(double budgetUsed, ColorScheme colorScheme) {
  if (budgetUsed >= 0.9) {
    return colorScheme.error;
  }
  if (budgetUsed >= 0.75) {
    return colorScheme.tertiary;
  }
  return colorScheme.primary;
}
