import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_payroll_run_console_audit_handoff_models.dart';

/// Timeline tile for a payroll console audit package handoff record.
class EmployeePayrollRunConsoleAuditHandoffRecordTile extends StatelessWidget {
  final EmployeePayrollRunConsoleAuditHandoffRecord record;
  final VoidCallback? onApprove;
  final VoidCallback? onReturn;
  final bool showActions;

  const EmployeePayrollRunConsoleAuditHandoffRecordTile({
    super.key,
    required this.record,
    this.onApprove,
    this.onReturn,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(record.status);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: HrisColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: HrisColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_statusIcon(record.status), color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Payroll handoff submitted',
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: HrisColors.ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    HrisStatusPill(label: record.statusLabel, color: color),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  record.summaryLabel,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _MetaChip(
                      icon: Icons.inventory_2_outlined,
                      label: record.packageReference,
                    ),
                    _MetaChip(
                      icon: Icons.person_outline,
                      label: record.reviewer,
                    ),
                    _MetaChip(
                      icon: Icons.verified_user_outlined,
                      label: record.approver,
                    ),
                    _MetaChip(
                      icon: Icons.schedule_outlined,
                      label: 'Due ${_formatDate(record.dueDate)}',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  record.note,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.ink),
                ),
                if (showActions && record.canApprove) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton.icon(
                        key: ValueKey(
                          'employee-payroll-audit-handoff-approve-${record.id}',
                        ),
                        onPressed: onApprove,
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Approve'),
                      ),
                      OutlinedButton.icon(
                        key: ValueKey(
                          'employee-payroll-audit-handoff-return-${record.id}',
                        ),
                        onPressed: onReturn,
                        icon: const Icon(Icons.undo_outlined),
                        label: const Text('Return'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

@Preview(name: 'Employee payroll audit handoff record')
Widget employeePayrollRunConsoleAuditHandoffRecordTilePreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: EmployeePayrollRunConsoleAuditHandoffRecordTile(
          record: EmployeePayrollRunConsoleAuditHandoffRecord(
            id: 'PAH-1',
            packageReference: 'PKG-RUN-202605-001-04',
            reviewer: 'Alya Rahman',
            approver: 'Rafi Pratama',
            submittedAt: DateTime(2026, 6, 9, 10, 30),
            dueDate: DateTime(2026, 6, 10),
            note: 'Evidence package reviewed for payroll close handoff.',
            status: EmployeePayrollRunConsoleAuditHandoffStatus.submitted,
            readyItemCount: 5,
            totalItemCount: 5,
            evidencedCommandCount: 4,
            totalCommandCount: 4,
            reviewEventCount: 0,
          ),
        ),
      ),
    ),
  );
}

/// Compact metadata chip used inside payroll audit handoff tiles.
class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: HrisColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: HrisColors.muted),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: HrisColors.muted),
          ),
        ],
      ),
    );
  }
}

IconData _statusIcon(EmployeePayrollRunConsoleAuditHandoffStatus status) {
  return switch (status) {
    EmployeePayrollRunConsoleAuditHandoffStatus.approved =>
      Icons.verified_user_outlined,
    EmployeePayrollRunConsoleAuditHandoffStatus.returned =>
      Icons.assignment_return_outlined,
    EmployeePayrollRunConsoleAuditHandoffStatus.submitted =>
      Icons.outbox_outlined,
    EmployeePayrollRunConsoleAuditHandoffStatus.readyForReview =>
      Icons.fact_check_outlined,
    EmployeePayrollRunConsoleAuditHandoffStatus.draft =>
      Icons.edit_note_outlined,
  };
}

Color _statusColor(EmployeePayrollRunConsoleAuditHandoffStatus status) {
  return switch (status) {
    EmployeePayrollRunConsoleAuditHandoffStatus.approved => const Color(
      0xFF15803D,
    ),
    EmployeePayrollRunConsoleAuditHandoffStatus.returned => const Color(
      0xFFB91C1C,
    ),
    EmployeePayrollRunConsoleAuditHandoffStatus.submitted ||
    EmployeePayrollRunConsoleAuditHandoffStatus
        .readyForReview => HrisColors.primary,
    EmployeePayrollRunConsoleAuditHandoffStatus.draft => HrisColors.muted,
  };
}

String _formatDate(DateTime value) {
  return DateFormat('MMM d, yyyy').format(value);
}
