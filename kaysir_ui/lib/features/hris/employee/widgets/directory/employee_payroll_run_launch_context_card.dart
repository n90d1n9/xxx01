import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_payroll_run_launch_context_models.dart';

/// Shows the directory payroll kickoff that feeds an employee payroll run.
class EmployeePayrollRunLaunchContextCard extends StatelessWidget {
  final EmployeePayrollRunLaunchContext context;

  const EmployeePayrollRunLaunchContextCard({super.key, required this.context});

  @override
  Widget build(BuildContext buildContext) {
    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.play_circle_outline,
                  color: Color(0xFF7C3AED),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Directory payroll kickoff',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        buildContext,
                      ).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      context.coverageLabel,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        buildContext,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(
                label: context.runReference,
                color: const Color(0xFF7C3AED),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _LaunchContextMetaChip(
                icon: Icons.badge_outlined,
                label: context.importBatchLabel,
              ),
              _LaunchContextMetaChip(
                icon: Icons.verified_outlined,
                label: context.releaseVersion,
              ),
              _LaunchContextMetaChip(
                icon: Icons.person_outline,
                label: context.runOwner,
              ),
              _LaunchContextMetaChip(
                icon: Icons.event_available_outlined,
                label: _formatDate(context.launchedAt),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Compact metadata chip for payroll run launch context cards.
class _LaunchContextMetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _LaunchContextMetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: HrisColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: HrisColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: HrisColors.muted),
          const SizedBox(width: 5),
          Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: HrisColors.muted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

@Preview(name: 'Employee payroll run launch context')
Widget employeePayrollRunLaunchContextCardPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: EmployeePayrollRunLaunchContextCard(
          context: EmployeePayrollRunLaunchContext(
            validationRecordId: 'payroll-validation-1',
            runReference: 'RUN-202605-001',
            importBatchLabel: 'PAY-202605-001',
            releaseVersion: '2026.05.30-001',
            runOwner: 'Payroll Lead',
            launchedAt: DateTime(2026, 5, 30),
            loadedProfileCount: 18,
            payrollImpactCount: 2,
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
