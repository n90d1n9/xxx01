import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_directory_roster_payroll_run_kickoff_models.dart';

/// Compact audit tile for a launched roster payroll run.
class EmployeeDirectoryRosterPayrollRunKickoffRecordTile
    extends StatelessWidget {
  final EmployeeDirectoryRosterPayrollRunKickoffRecord record;

  const EmployeeDirectoryRosterPayrollRunKickoffRecordTile({
    super.key,
    required this.record,
  });

  @override
  Widget build(BuildContext context) {
    return HrisListSurface(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.play_circle_outline,
              color: Color(0xFF7C3AED),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Payroll run launched',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    HrisStatusPill(
                      label: record.runReference,
                      color: const Color(0xFF7C3AED),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  record.summaryLabel,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _PayrollRunKickoffMetaChip(
                      icon: Icons.badge_outlined,
                      label: record.batchLabel,
                    ),
                    _PayrollRunKickoffMetaChip(
                      icon: Icons.person_outline,
                      label: record.runOwner,
                    ),
                    _PayrollRunKickoffMetaChip(
                      icon: Icons.event_available_outlined,
                      label: _formatDate(record.launchedAt),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  record.kickoffNote,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Small metadata chip used by payroll run kickoff audit tiles.
class _PayrollRunKickoffMetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _PayrollRunKickoffMetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: HrisColors.surface,
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
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: HrisColors.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

@Preview(name: 'Employee payroll run kickoff record')
Widget employeeDirectoryRosterPayrollRunKickoffRecordTilePreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: EmployeeDirectoryRosterPayrollRunKickoffRecordTile(
          record: EmployeeDirectoryRosterPayrollRunKickoffRecord(
            id: 'payroll-run-kickoff-1',
            validationRecordId: 'payroll-validation-1',
            batchLabel: 'PAY-202605-001',
            releaseVersion: '2026.05.30-001',
            runReference: 'RUN-202605-001',
            runOwner: 'Payroll Lead',
            kickoffNote: 'Funding, payslip hold, and audit archive confirmed.',
            launchedAt: DateTime(2026, 5, 30),
            loadedProfileCount: 18,
            validationItemCount: 3,
            payrollImpactCount: 2,
          ),
        ),
      ),
    ),
  );
}

@Preview(name: 'Employee payroll run kickoff metadata chip')
Widget employeeDirectoryRosterPayrollRunKickoffMetaChipPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _PayrollRunKickoffMetaChip(
          icon: Icons.event_available_outlined,
          label: '30/05/2026',
        ),
      ),
    ),
  );
}

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}
