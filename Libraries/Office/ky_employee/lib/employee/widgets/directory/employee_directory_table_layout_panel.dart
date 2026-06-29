import 'package:flutter/material.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_directory_table_layout_models.dart';

class EmployeeDirectoryTableLayoutPanel extends StatelessWidget {
  final EmployeeDirectoryTableLayout layout;
  final ValueChanged<EmployeeDirectoryTableColumn> onColumnToggled;
  final ValueChanged<EmployeeDirectoryTableDensity> onDensityChanged;
  final VoidCallback onReset;

  const EmployeeDirectoryTableLayoutPanel({
    super.key,
    required this.layout,
    required this.onColumnToggled,
    required this.onDensityChanged,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      key: const ValueKey('employee-directory-table-layout-panel'),
      icon: Icons.view_column_outlined,
      title: 'Table layout',
      subtitle:
          '${layout.visibleColumnCount} visible columns, ${layout.density.label.toLowerCase()} rows',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Visible',
              value: '${layout.visibleColumnCount}',
            ),
            HrisMetricStripItem(
              label: 'Hidden',
              value: '${layout.hiddenColumnCount}',
            ),
            HrisMetricStripItem(label: 'Density', value: layout.density.label),
            const HrisMetricStripItem(label: 'Pinned', value: '2'),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: SegmentedButton<EmployeeDirectoryTableDensity>(
                key: const ValueKey('employee-directory-table-density-control'),
                segments:
                    EmployeeDirectoryTableDensity.values
                        .map(
                          (density) => ButtonSegment(
                            value: density,
                            icon: Icon(_densityIcon(density)),
                            label: Text(density.label),
                          ),
                        )
                        .toList(),
                selected: {layout.density},
                onSelectionChanged: (values) => onDensityChanged(values.single),
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              key: const ValueKey('employee-directory-table-layout-reset'),
              onPressed: onReset,
              icon: const Icon(Icons.restart_alt_outlined),
              label: const Text('Reset'),
            ),
          ],
        ),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children:
              EmployeeDirectoryTableColumn.values.map((column) {
                return _TableColumnToggle(
                  column: column,
                  selected: layout.isVisible(column),
                  onChanged: (_) => onColumnToggled(column),
                );
              }).toList(),
        ),
      ],
    );
  }
}

class _TableColumnToggle extends StatelessWidget {
  final EmployeeDirectoryTableColumn column;
  final bool selected;
  final ValueChanged<bool?> onChanged;

  const _TableColumnToggle({
    required this.column,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final color = column.isPinned ? HrisColors.muted : HrisColors.primary;

    return SizedBox(
      width: 180,
      child: HrisListSurface(
        child: Row(
          children: [
            Checkbox(
              key: ValueKey(
                'employee-directory-table-layout-column-${column.name}-checkbox',
              ),
              value: selected,
              onChanged: column.isPinned ? null : onChanged,
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: 6),
            Icon(_columnIcon(column), color: color, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                column.label,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: column.isPinned ? HrisColors.muted : HrisColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

IconData _densityIcon(EmployeeDirectoryTableDensity density) {
  switch (density) {
    case EmployeeDirectoryTableDensity.comfortable:
      return Icons.view_agenda_outlined;
    case EmployeeDirectoryTableDensity.compact:
      return Icons.density_small_outlined;
  }
}

IconData _columnIcon(EmployeeDirectoryTableColumn column) {
  switch (column) {
    case EmployeeDirectoryTableColumn.employee:
      return Icons.badge_outlined;
    case EmployeeDirectoryTableColumn.department:
      return Icons.account_tree_outlined;
    case EmployeeDirectoryTableColumn.role:
      return Icons.work_outline;
    case EmployeeDirectoryTableColumn.manager:
      return Icons.supervisor_account_outlined;
    case EmployeeDirectoryTableColumn.status:
      return Icons.verified_user_outlined;
    case EmployeeDirectoryTableColumn.rating:
      return Icons.trending_up_outlined;
    case EmployeeDirectoryTableColumn.tenure:
      return Icons.timelapse_outlined;
    case EmployeeDirectoryTableColumn.joinDate:
      return Icons.event_outlined;
    case EmployeeDirectoryTableColumn.contact:
      return Icons.contact_mail_outlined;
    case EmployeeDirectoryTableColumn.actions:
      return Icons.more_horiz_outlined;
  }
}
