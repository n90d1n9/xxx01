import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_payroll_run_console_audit_decision_models.dart';
import '../../models/employee_payroll_run_console_audit_decision_receipt_models.dart';
import '../../models/employee_payroll_run_console_audit_handoff_models.dart';

/// Decision receipt shown after a payroll audit handoff is approved or returned.
class EmployeePayrollRunConsoleAuditDecisionReceiptCard
    extends StatelessWidget {
  final EmployeePayrollRunConsoleAuditDecisionReceipt receipt;

  const EmployeePayrollRunConsoleAuditDecisionReceiptCard({
    super.key,
    required this.receipt,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        receipt.isApproval ? const Color(0xFF15803D) : const Color(0xFFB91C1C);
    final icon =
        receipt.isApproval
            ? Icons.verified_user_outlined
            : Icons.assignment_return_outlined;
    final decidedAt = receipt.record.decidedAt;

    return Container(
      key: const ValueKey('employee-payroll-audit-decision-receipt'),
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: HrisColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: HrisColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  receipt.title,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              HrisStatusPill(label: receipt.outcomeLabel, color: color),
            ],
          ),
          const SizedBox(height: 10),
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(
                label: 'Controls',
                value: receipt.controlsLabel,
              ),
              HrisMetricStripItem(
                label: 'Evidence',
                value: receipt.evidenceLabel,
              ),
              HrisMetricStripItem(
                label: 'Review',
                value: '${receipt.record.reviewEventCount} events',
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ReceiptMetaChip(
                icon: Icons.people_outline,
                label: receipt.reviewerApproverLabel,
              ),
              if (decidedAt != null)
                _ReceiptMetaChip(
                  icon: Icons.event_available_outlined,
                  label: _formatDateTime(decidedAt),
                ),
              _ReceiptMetaChip(
                icon: Icons.inventory_2_outlined,
                label: receipt.record.packageReference,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            receipt.decisionNoteLabel,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.ink),
          ),
          if (receipt.attestations.isNotEmpty) ...[
            const SizedBox(height: 10),
            for (final attestation in receipt.attestations)
              _ReceiptAttestationRow(attestation: attestation),
          ],
        ],
      ),
    );
  }
}

@Preview(name: 'Employee payroll audit decision receipt')
Widget employeePayrollRunConsoleAuditDecisionReceiptCardPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: EmployeePayrollRunConsoleAuditDecisionReceiptCard(
          receipt: EmployeePayrollRunConsoleAuditDecisionReceipt(
            record: EmployeePayrollRunConsoleAuditHandoffRecord(
              id: 'PAH-1',
              packageReference: 'PKG-RUN-202605-001-04',
              reviewer: 'Alya Rahman',
              approver: 'Rafi Pratama',
              submittedAt: DateTime(2026, 6, 9, 10, 30),
              dueDate: DateTime(2026, 6, 10),
              note: 'Evidence package reviewed for payroll close handoff.',
              status: EmployeePayrollRunConsoleAuditHandoffStatus.approved,
              readyItemCount: 5,
              totalItemCount: 5,
              evidencedCommandCount: 4,
              totalCommandCount: 4,
              reviewEventCount: 0,
              decidedAt: DateTime(2026, 6, 9, 11, 15),
              decisionNote: 'Approved after validating close evidence.',
              decisionAttestations:
                  EmployeePayrollRunConsoleAuditDecisionAttestation.values
                      .toSet(),
            ),
          ),
        ),
      ),
    ),
  );
}

/// Compact metadata chip used by payroll audit decision receipts.
class _ReceiptMetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ReceiptMetaChip({required this.icon, required this.label});

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
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: HrisColors.muted),
          ),
        ],
      ),
    );
  }
}

/// Read-only row for one approval control captured in the receipt.
class _ReceiptAttestationRow extends StatelessWidget {
  final EmployeePayrollRunConsoleAuditDecisionAttestation attestation;

  const _ReceiptAttestationRow({required this.attestation});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 16,
            color: Color(0xFF15803D),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              attestation.label,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: HrisColors.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDateTime(DateTime value) {
  return DateFormat('MMM d, yyyy HH:mm').format(value);
}
