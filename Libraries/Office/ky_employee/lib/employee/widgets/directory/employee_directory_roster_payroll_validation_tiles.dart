import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_directory_roster_payroll_validation_models.dart';

/// Compact audit tile for an approved payroll import validation.
class EmployeeDirectoryRosterPayrollValidationRecordTile
    extends StatelessWidget {
  final EmployeeDirectoryRosterPayrollValidationRecord record;

  const EmployeeDirectoryRosterPayrollValidationRecordTile({
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
              color: const Color(0xFF2563EB).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.verified_outlined,
              color: Color(0xFF2563EB),
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
                      'Payroll import validated',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    HrisStatusPill(
                      label: record.batchLabel,
                      color: const Color(0xFF2563EB),
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
                    _PayrollValidationMetaChip(
                      icon: Icons.description_outlined,
                      label: record.controlFileName,
                    ),
                    _PayrollValidationMetaChip(
                      icon: Icons.person_outline,
                      label: record.validatedBy,
                    ),
                    _PayrollValidationMetaChip(
                      icon: Icons.event_available_outlined,
                      label: _formatDate(record.validatedAt),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  record.validationNote,
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

/// Review item tile for import validation attention and pay-impact controls.
class EmployeeDirectoryRosterPayrollValidationItemTile extends StatelessWidget {
  final EmployeeDirectoryRosterPayrollValidationItem item;

  const EmployeeDirectoryRosterPayrollValidationItemTile({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return HrisListSurface(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.fact_check_outlined,
              color: Color(0xFFB45309),
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
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
                      item.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    HrisStatusPill(
                      label: item.typeLabel,
                      color: const Color(0xFFF59E0B),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  item.detail,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Small metadata chip used by payroll validation audit tiles.
class _PayrollValidationMetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _PayrollValidationMetaChip({required this.icon, required this.label});

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

@Preview(name: 'Employee payroll validation record')
Widget employeeDirectoryRosterPayrollValidationRecordTilePreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: EmployeeDirectoryRosterPayrollValidationRecordTile(
          record: EmployeeDirectoryRosterPayrollValidationRecord(
            id: 'payroll-validation-1',
            batchId: 'payroll-import-1',
            batchLabel: 'PAY-202605-001',
            releaseVersion: '2026.05.30-001',
            controlFileName: '2026-05-30-001-payroll-import.csv',
            validatedBy: 'Payroll Lead',
            validationNote: 'Import loaded and payroll run controls matched.',
            validatedAt: DateTime(2026, 5, 30),
            loadedProfileCount: 18,
            validationItemCount: 4,
            payrollImpactCount: 3,
          ),
        ),
      ),
    ),
  );
}

@Preview(name: 'Employee payroll validation item')
Widget employeeDirectoryRosterPayrollValidationItemTilePreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: EmployeeDirectoryRosterPayrollValidationItemTile(
          item: const EmployeeDirectoryRosterPayrollValidationItem(
            id: 'payroll-impact',
            type:
                EmployeeDirectoryRosterPayrollValidationItemType.payrollImpact,
            title: 'Confirm payroll-impacting roster changes',
            detail: '3 payroll-impacting changes included in the staged file.',
            count: 3,
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
