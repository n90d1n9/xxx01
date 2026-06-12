import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_directory_roster_payroll_import_models.dart';

/// Compact audit tile for a staged roster payroll import packet.
class EmployeeDirectoryRosterPayrollImportBatchTile extends StatelessWidget {
  final EmployeeDirectoryRosterPayrollImportBatch batch;

  const EmployeeDirectoryRosterPayrollImportBatchTile({
    super.key,
    required this.batch,
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
              color: const Color(0xFF0F766E).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.upload_file_outlined,
              color: Color(0xFF0F766E),
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
                      'Payroll import staged',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    HrisStatusPill(
                      label: batch.releaseVersion,
                      color: const Color(0xFF0F766E),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  batch.summaryLabel,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _PayrollImportMetaChip(
                      icon: Icons.badge_outlined,
                      label: batch.batchLabel,
                    ),
                    _PayrollImportMetaChip(
                      icon: Icons.description_outlined,
                      label: batch.controlFileName,
                    ),
                    _PayrollImportMetaChip(
                      icon: Icons.person_outline,
                      label: batch.preparedBy,
                    ),
                    _PayrollImportMetaChip(
                      icon: Icons.event_available_outlined,
                      label: _formatDate(batch.stagedAt),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  batch.importNote,
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

/// Small metadata chip used by roster payroll import audit tiles.
class _PayrollImportMetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _PayrollImportMetaChip({required this.icon, required this.label});

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

@Preview(name: 'Employee roster payroll import batch')
Widget employeeDirectoryRosterPayrollImportBatchTilePreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: EmployeeDirectoryRosterPayrollImportBatchTile(
          batch: EmployeeDirectoryRosterPayrollImportBatch(
            id: 'payroll-import-1',
            releaseId: 'roster-release-1',
            releaseVersion: '2026.05.30-001',
            syncRecordId: 'payroll-sync-1',
            batchLabel: 'PAY-202605-001',
            preparedBy: 'Payroll Lead',
            importNote: 'Column mapping and payroll preview controls matched.',
            controlFileName: '2026-05-30-001-payroll-import.csv',
            stagedAt: DateTime(2026, 5, 30),
            totalProfileCount: 18,
            includedProfileCount: 18,
            attentionProfileCount: 2,
            departmentCount: 5,
            payrollImpactCount: 3,
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
