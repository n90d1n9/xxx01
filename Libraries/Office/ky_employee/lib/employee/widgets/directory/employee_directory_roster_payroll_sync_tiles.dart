import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_directory_roster_payroll_sync_models.dart';

/// Compact audit tile for a roster release synced into payroll.
class EmployeeDirectoryRosterPayrollSyncRecordTile extends StatelessWidget {
  final EmployeeDirectoryRosterPayrollSyncRecord record;

  const EmployeeDirectoryRosterPayrollSyncRecordTile({
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
              color: const Color(0xFF15803D).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.sync_outlined,
              color: Color(0xFF15803D),
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
                      'Payroll synced',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    HrisStatusPill(
                      label: record.releaseVersion,
                      color: const Color(0xFF15803D),
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
                    _PayrollSyncMetaChip(
                      icon: Icons.person_outline,
                      label: record.syncedBy,
                    ),
                    _PayrollSyncMetaChip(
                      icon: Icons.groups_2_outlined,
                      label: '${record.acknowledgedHandoffCount} handoffs',
                    ),
                    _PayrollSyncMetaChip(
                      icon: Icons.event_available_outlined,
                      label: _formatDate(record.syncedAt),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  record.syncNote,
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

/// Small metadata chip used by roster payroll sync audit tiles.
class _PayrollSyncMetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _PayrollSyncMetaChip({required this.icon, required this.label});

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

@Preview(name: 'Employee roster payroll sync record')
Widget employeeDirectoryRosterPayrollSyncRecordTilePreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: EmployeeDirectoryRosterPayrollSyncRecordTile(
          record: EmployeeDirectoryRosterPayrollSyncRecord(
            id: 'payroll-sync-1',
            releaseId: 'roster-release-1',
            releaseVersion: '2026.05.30-001',
            syncedBy: 'Payroll Lead',
            syncNote: 'Control totals matched payroll staging import.',
            syncedAt: DateTime(2026, 5, 30),
            profileCount: 18,
            payrollImpactCount: 3,
            acknowledgedHandoffCount: 3,
          ),
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
