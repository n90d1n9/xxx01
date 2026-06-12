import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_payroll_run_console_audit_models.dart';
import '../../models/employee_payroll_run_console_command_models.dart';
import 'employee_payroll_run_console_audit_controls.dart';
import 'employee_payroll_run_console_audit_evidence_panel.dart';

/// Timeline surface for run-level payroll console command audit events.
class EmployeePayrollRunConsoleAuditTimelinePanel extends StatefulWidget {
  final List<EmployeePayrollRunConsoleAuditEvent> events;

  const EmployeePayrollRunConsoleAuditTimelinePanel({
    super.key,
    required this.events,
  });

  @override
  State<EmployeePayrollRunConsoleAuditTimelinePanel> createState() =>
      _EmployeePayrollRunConsoleAuditTimelinePanelState();
}

/// State holder for the active payroll console audit timeline filter.
class _EmployeePayrollRunConsoleAuditTimelinePanelState
    extends State<EmployeePayrollRunConsoleAuditTimelinePanel> {
  EmployeePayrollRunConsoleAuditFilter _selectedFilter =
      EmployeePayrollRunConsoleAuditFilter.all;

  @override
  Widget build(BuildContext context) {
    final summary = EmployeePayrollRunConsoleAuditSummary(
      events: widget.events,
    );
    final evidenceReport = EmployeePayrollRunConsoleAuditEvidenceReport(
      summary: summary,
    );
    final filteredEvents = summary.eventsFor(_selectedFilter);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Operation audit timeline',
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              HrisStatusPill(
                label: _timelineCountLabel(
                  visibleCount: filteredEvents.length,
                  totalCount: summary.eventCount,
                  filter: _selectedFilter,
                ),
                color:
                    summary.eventCount == 0
                        ? HrisColors.muted
                        : HrisColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (widget.events.isEmpty)
            const Text('No payroll console events yet.')
          else ...[
            EmployeePayrollRunConsoleAuditEvidencePanel(report: evidenceReport),
            const SizedBox(height: 12),
            EmployeePayrollRunConsoleAuditControls(
              summary: summary,
              selectedFilter: _selectedFilter,
              onFilterChanged: (filter) {
                setState(() => _selectedFilter = filter);
              },
            ),
            const SizedBox(height: 12),
            if (filteredEvents.isEmpty)
              const Text('No audit events match this filter.')
            else
              Column(
                children: [
                  for (
                    var index = 0;
                    index < filteredEvents.length;
                    index++
                  ) ...[
                    if (index > 0) const Divider(height: 18),
                    _PayrollRunConsoleAuditTile(event: filteredEvents[index]),
                  ],
                ],
              ),
          ],
        ],
      ),
    );
  }
}

/// Timeline tile for one payroll console command audit event.
class _PayrollRunConsoleAuditTile extends StatelessWidget {
  final EmployeePayrollRunConsoleAuditEvent event;

  const _PayrollRunConsoleAuditTile({required this.event});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(event.status);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(_iconFor(event.commandType), color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      event.message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  HrisStatusPill(label: event.status.label, color: color),
                ],
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _AuditMetaLabel(
                    icon: Icons.badge_outlined,
                    label: event.runReference,
                  ),
                  _AuditMetaLabel(
                    icon: Icons.group_outlined,
                    label: event.scopeLabel,
                  ),
                  _AuditMetaLabel(
                    icon: Icons.person_outline,
                    label: event.operatorName,
                  ),
                  _AuditMetaLabel(
                    icon: Icons.schedule_outlined,
                    label: _formatDate(event.occurredAt),
                  ),
                ],
              ),
              if (event.errors.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  event.errors.first,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFFB91C1C),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Compact metadata label used inside audit timeline tiles.
class _AuditMetaLabel extends StatelessWidget {
  final IconData icon;
  final String label;

  const _AuditMetaLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: HrisColors.muted),
        const SizedBox(width: 4),
        Text(
          label,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
        ),
      ],
    );
  }
}

@Preview(name: 'Employee payroll run console audit timeline')
Widget employeePayrollRunConsoleAuditTimelinePanelPreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: EmployeePayrollRunConsoleAuditTimelinePanel(
          events: [
            EmployeePayrollRunConsoleAuditEvent(
              id: 'payroll-console-audit-1',
              runReference: 'RUN-202605-001',
              commandType: EmployeePayrollRunConsoleCommandType.prepareExport,
              scopeLabel: '3 selected in run',
              operatorName: 'Payroll Lead',
              occurredAt: DateTime(2026, 5, 30, 9, 30),
              targetEmployeeCount: 3,
              completedCount: 2,
              skippedCount: 1,
              errors: const [],
              message: '2 employees prepared and exported, 1 skipped.',
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
        ),
      ),
    ),
  );
}

String _timelineCountLabel({
  required int visibleCount,
  required int totalCount,
  required EmployeePayrollRunConsoleAuditFilter filter,
}) {
  if (filter == EmployeePayrollRunConsoleAuditFilter.all) {
    return '$totalCount event${totalCount == 1 ? '' : 's'}';
  }
  return '$visibleCount of $totalCount';
}

IconData _iconFor(EmployeePayrollRunConsoleCommandType type) {
  return switch (type) {
    EmployeePayrollRunConsoleCommandType.prepareExport =>
      Icons.upload_file_outlined,
    EmployeePayrollRunConsoleCommandType.settlePayment =>
      Icons.payments_outlined,
    EmployeePayrollRunConsoleCommandType.publishPayslip =>
      Icons.receipt_long_outlined,
    EmployeePayrollRunConsoleCommandType.closePeriod =>
      Icons.lock_clock_outlined,
  };
}

Color _statusColor(EmployeePayrollRunConsoleAuditStatus status) {
  return switch (status) {
    EmployeePayrollRunConsoleAuditStatus.completed => const Color(0xFF15803D),
    EmployeePayrollRunConsoleAuditStatus.warning => const Color(0xFFB45309),
    EmployeePayrollRunConsoleAuditStatus.noChange => HrisColors.muted,
  };
}

String _formatDate(DateTime value) {
  return DateFormat('MMM d, HH:mm').format(value);
}
