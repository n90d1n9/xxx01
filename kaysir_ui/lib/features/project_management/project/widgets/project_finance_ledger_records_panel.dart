import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/widgets/ui/app_filter_chip_group.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../services/project_finance_ledger_records_service.dart';
import '../services/project_finance_ledger_summary_service.dart';

/// Filterable finance ledger record queue for project finance operations.
class ProjectFinanceLedgerRecordsPanel extends StatefulWidget {
  const ProjectFinanceLedgerRecordsPanel({
    required this.summary,
    this.maxRows = 8,
    super.key,
  });

  final ProjectFinanceLedgerSummary summary;
  final int maxRows;

  @override
  State<ProjectFinanceLedgerRecordsPanel> createState() =>
      _ProjectFinanceLedgerRecordsPanelState();
}

/// Stores the selected ledger lens independently from summary construction.
class _ProjectFinanceLedgerRecordsPanelState
    extends State<ProjectFinanceLedgerRecordsPanel> {
  var _lens = ProjectFinanceLedgerRecordLens.all;

  @override
  Widget build(BuildContext context) {
    final view = buildProjectFinanceLedgerRecordsView(widget.summary);
    final visibleRows = view.rowsFor(_lens).take(widget.maxRows).toList();
    final colorScheme = Theme.of(context).colorScheme;
    final priorityRow = view.priorityRow;
    final headerColor =
        view.blockedCount > 0
            ? colorScheme.error
            : view.openCount > 0
            ? Colors.orange.shade700
            : Colors.green.shade700;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppInfoRow(
          title:
              priorityRow == null
                  ? 'No finance records yet'
                  : '${view.rowCount} ledger records tracked',
          subtitle:
              priorityRow == null
                  ? 'Budget, expense, petty cash, approval, and evidence records will appear here.'
                  : '${view.openCount} open items - ${view.blockedCount} blocked - priority: ${priorityRow.title}.',
          icon:
              priorityRow == null
                  ? Icons.receipt_long_outlined
                  : priorityRow.kind.icon,
          iconStyle: AppInfoRowIconStyle.badge,
          contained: true,
          iconBackgroundColor: headerColor.withValues(alpha: 0.12),
          iconForegroundColor: headerColor,
          titleMaxLines: 2,
          subtitleMaxLines: 2,
          trailing: AppStatusPill(
            label: view.blockedCount > 0 ? 'Blocked' : 'Operational',
            icon:
                view.blockedCount > 0
                    ? Icons.block_outlined
                    : Icons.receipt_long_outlined,
            color: headerColor,
            maxWidth: 128,
          ),
        ),
        const SizedBox(height: 12),
        AppFilterChipGroup<ProjectFinanceLedgerRecordLens>(
          value: _lens,
          options: [
            for (final lens in ProjectFinanceLedgerRecordLens.values)
              AppFilterChipOption(
                value: lens,
                label: lens.label,
                icon: lens.icon,
                count: view.countFor(lens),
              ),
          ],
          onChanged: (value) => setState(() => _lens = value),
        ),
        const SizedBox(height: 12),
        if (visibleRows.isEmpty)
          AppInfoRow(
            title: 'No ${_lens.label.toLowerCase()} records',
            subtitle: 'Choose another ledger lens to inspect this project.',
            icon: _lens.icon,
            iconStyle: AppInfoRowIconStyle.badge,
            contained: true,
          )
        else
          for (var index = 0; index < visibleRows.length; index++) ...[
            _LedgerRecordTile(row: visibleRows[index]),
            if (index != visibleRows.length - 1) const SizedBox(height: 10),
          ],
        if (view.countFor(_lens) > widget.maxRows) ...[
          const SizedBox(height: 10),
          Text(
            'Showing ${widget.maxRows} of ${view.countFor(_lens)} ${_lens.label.toLowerCase()} records',
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

/// Ledger row tile with normalized amount, owner, due date, and status.
class _LedgerRecordTile extends StatelessWidget {
  const _LedgerRecordTile({required this.row});

  final ProjectFinanceLedgerRecordRow row;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = row.status.color(colorScheme);
    final iconColor = row.isBlocked ? colorScheme.error : colorScheme.primary;
    final dueDate = row.dueDateLabel;

    return AppInfoRow(
      title: row.title,
      subtitle: [
        row.kind.label,
        row.ownerText,
        if (dueDate.isNotEmpty) dueDate,
        row.detail,
      ].join(' - '),
      icon: row.category?.icon ?? row.kind.icon,
      iconStyle: AppInfoRowIconStyle.badge,
      contained: true,
      iconBackgroundColor: iconColor.withValues(alpha: 0.1),
      iconForegroundColor: iconColor,
      titleMaxLines: 2,
      subtitleMaxLines: 3,
      trailing: _LedgerRecordTrailing(row: row, statusColor: statusColor),
    );
  }
}

/// Fixed-width record trailing block that keeps rows from shifting laterally.
class _LedgerRecordTrailing extends StatelessWidget {
  const _LedgerRecordTrailing({required this.row, required this.statusColor});

  final ProjectFinanceLedgerRecordRow row;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 128,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            row.amountLabel,
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
              label: row.status.label,
              icon: row.status.icon,
              color: statusColor,
              maxWidth: 120,
            ),
          ),
        ],
      ),
    );
  }
}

@Preview(name: 'Project finance ledger records panel')
Widget projectFinanceLedgerRecordsPanelPreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ProjectFinanceLedgerRecordsPanel(
          summary: buildProjectFinanceLedgerSummary(
            projectId: 'retail-modernization',
          ),
        ),
      ),
    ),
  );
}
