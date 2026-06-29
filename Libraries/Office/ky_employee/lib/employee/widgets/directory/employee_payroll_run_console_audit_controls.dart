import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_payroll_run_console_audit_models.dart';
import '../../models/employee_payroll_run_console_command_models.dart';

/// Summary and filter controls for payroll console audit event triage.
class EmployeePayrollRunConsoleAuditControls extends StatelessWidget {
  final EmployeePayrollRunConsoleAuditSummary summary;
  final EmployeePayrollRunConsoleAuditFilter selectedFilter;
  final ValueChanged<EmployeePayrollRunConsoleAuditFilter> onFilterChanged;

  const EmployeePayrollRunConsoleAuditControls({
    super.key,
    required this.summary,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Events',
              value: '${summary.eventCount}',
            ),
            HrisMetricStripItem(
              label: 'Completed',
              value: '${summary.completedCount}',
            ),
            HrisMetricStripItem(
              label: 'Review',
              value: '${summary.attentionCount}',
            ),
            HrisMetricStripItem(
              label: 'No change',
              value: '${summary.noChangeCount}',
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final filter in EmployeePayrollRunConsoleAuditFilter.values)
              _PayrollRunConsoleAuditFilterChip(
                filter: filter,
                count: summary.countFor(filter),
                selected: selectedFilter == filter,
                onSelected: onFilterChanged,
              ),
          ],
        ),
      ],
    );
  }
}

/// Selectable chip used to switch payroll console audit event filters.
class _PayrollRunConsoleAuditFilterChip extends StatelessWidget {
  final EmployeePayrollRunConsoleAuditFilter filter;
  final int count;
  final bool selected;
  final ValueChanged<EmployeePayrollRunConsoleAuditFilter> onSelected;

  const _PayrollRunConsoleAuditFilterChip({
    required this.filter,
    required this.count,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final color = _filterColor(filter);

    return ChoiceChip(
      avatar: Icon(_filterIcon(filter), size: 16, color: color),
      label: Text('${filter.label} ($count)'),
      selected: selected,
      onSelected: (_) => onSelected(filter),
      selectedColor: color.withValues(alpha: 0.14),
      backgroundColor: HrisColors.surface,
      side: BorderSide(
        color: selected ? color.withValues(alpha: 0.5) : HrisColors.border,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: selected ? color : HrisColors.muted,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

@Preview(name: 'Employee payroll run console audit controls')
Widget employeePayrollRunConsoleAuditControlsPreview() {
  final summary = EmployeePayrollRunConsoleAuditSummary(
    events: [
      EmployeePayrollRunConsoleAuditEvent(
        id: 'payroll-console-audit-1',
        runReference: 'RUN-202605-001',
        commandType: EmployeePayrollRunConsoleCommandType.prepareExport,
        scopeLabel: 'All 5 run employees',
        operatorName: 'Payroll Lead',
        occurredAt: DateTime(2026, 5, 30, 9, 30),
        targetEmployeeCount: 5,
        completedCount: 3,
        skippedCount: 2,
        errors: const [],
        message: '3 employees prepared and exported, 2 skipped.',
      ),
      EmployeePayrollRunConsoleAuditEvent(
        id: 'payroll-console-audit-2',
        runReference: 'RUN-202605-001',
        commandType: EmployeePayrollRunConsoleCommandType.settlePayment,
        scopeLabel: 'All 5 run employees',
        operatorName: 'Payroll Lead',
        occurredAt: DateTime(2026, 5, 30, 10, 15),
        targetEmployeeCount: 5,
        completedCount: 0,
        skippedCount: 5,
        errors: const ['Maya Santoso: Verify bank account first.'],
        message: 'Settle pay could not update employees.',
      ),
    ],
  );

  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: EmployeePayrollRunConsoleAuditControls(
          summary: summary,
          selectedFilter: EmployeePayrollRunConsoleAuditFilter.attention,
          onFilterChanged: (_) {},
        ),
      ),
    ),
  );
}

IconData _filterIcon(EmployeePayrollRunConsoleAuditFilter filter) {
  return switch (filter) {
    EmployeePayrollRunConsoleAuditFilter.all => Icons.manage_history_outlined,
    EmployeePayrollRunConsoleAuditFilter.completed =>
      Icons.check_circle_outline,
    EmployeePayrollRunConsoleAuditFilter.attention =>
      Icons.warning_amber_outlined,
    EmployeePayrollRunConsoleAuditFilter.noChange => Icons.remove_done_outlined,
  };
}

Color _filterColor(EmployeePayrollRunConsoleAuditFilter filter) {
  return switch (filter) {
    EmployeePayrollRunConsoleAuditFilter.all => HrisColors.primary,
    EmployeePayrollRunConsoleAuditFilter.completed => const Color(0xFF15803D),
    EmployeePayrollRunConsoleAuditFilter.attention => const Color(0xFFB45309),
    EmployeePayrollRunConsoleAuditFilter.noChange => HrisColors.muted,
  };
}
