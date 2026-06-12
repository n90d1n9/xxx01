import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_directory_models.dart';
import '../../models/employee_directory_quality_gate_models.dart';
import '../../models/employee_directory_roster_diff_models.dart';
import '../../models/employee_directory_roster_publish_models.dart';

/// Compact tile that explains one change between two roster releases.
class EmployeeDirectoryRosterDiffTile extends StatelessWidget {
  final EmployeeDirectoryRosterDiffItem item;

  const EmployeeDirectoryRosterDiffTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final color = _diffColor(item.type, item.payrollImpacting);

    return HrisListSurface(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_diffIcon(item.type), color: color),
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
                      item.employeeName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    HrisStatusPill(label: item.typeLabel, color: color),
                    if (item.payrollImpacting)
                      const HrisStatusPill(
                        label: 'Payroll impact',
                        color: Color(0xFFB91C1C),
                      ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  item.summaryLabel,
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

@Preview(name: 'Employee roster diff tile')
Widget employeeDirectoryRosterDiffTilePreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: EmployeeDirectoryRosterDiffTile(
          item: const EmployeeDirectoryRosterDiffItem(
            id: '1-department',
            type: EmployeeDirectoryRosterDiffType.departmentChanged,
            employeeId: '1',
            employeeName: 'Sarah Johnson',
            previousValue: 'Design',
            currentValue: 'People Operations',
            payrollImpacting: true,
          ),
        ),
      ),
    ),
  );
}

/// Small summary tile for the first release baseline state.
class EmployeeDirectoryRosterDiffBaselineTile extends StatelessWidget {
  final EmployeeDirectoryRosterRelease release;

  const EmployeeDirectoryRosterDiffBaselineTile({
    super.key,
    required this.release,
  });

  @override
  Widget build(BuildContext context) {
    return HrisListSurface(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: HrisColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.bookmark_added_outlined,
              color: HrisColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'First release baseline',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${release.versionLabel} captured '
                  '${release.memberSnapshots.length} roster snapshots.',
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

@Preview(name: 'Employee roster diff baseline')
Widget employeeDirectoryRosterDiffBaselineTilePreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: EmployeeDirectoryRosterDiffBaselineTile(
          release: EmployeeDirectoryRosterRelease(
            id: 'roster-release-1',
            versionLabel: '2026.05.30-001',
            preparedBy: 'Alya Rahman',
            releaseNote: 'Roster packet prepared for payroll cutoff handoff.',
            publishedAt: DateTime(2026, 5, 30),
            asOfDate: DateTime(2026, 5, 30),
            memberCount: 1,
            departmentCount: 1,
            gateStatus: EmployeeDirectoryQualityGateStatus.ready,
            readinessScore: 100,
            signoffId: 'quality-gate-1',
            signoffReviewer: 'Rafi Pratama',
            payrollNotified: true,
            memberSnapshots: [
              EmployeeDirectoryRosterReleaseMemberSnapshot(
                employeeId: '1',
                name: 'Sarah Johnson',
                position: 'HR Analyst',
                department: 'People Operations',
                manager: 'Emma Rodriguez',
                location: 'Jakarta',
                email: 'sarah@example.com',
                phone: '+62 812 0000 0000',
                status: EmployeeDirectoryStatus.active,
                joiningDate: DateTime(2024, 1, 1),
                performance: 4.5,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

IconData _diffIcon(EmployeeDirectoryRosterDiffType type) {
  return switch (type) {
    EmployeeDirectoryRosterDiffType.added => Icons.person_add_alt_1_outlined,
    EmployeeDirectoryRosterDiffType.removed => Icons.person_remove_outlined,
    EmployeeDirectoryRosterDiffType.departmentChanged =>
      Icons.apartment_outlined,
    EmployeeDirectoryRosterDiffType.managerChanged =>
      Icons.supervisor_account_outlined,
    EmployeeDirectoryRosterDiffType.statusChanged =>
      Icons.published_with_changes_outlined,
    EmployeeDirectoryRosterDiffType.roleChanged => Icons.work_outline,
    EmployeeDirectoryRosterDiffType.locationChanged =>
      Icons.location_on_outlined,
    EmployeeDirectoryRosterDiffType.contactChanged =>
      Icons.contact_mail_outlined,
  };
}

Color _diffColor(EmployeeDirectoryRosterDiffType type, bool payrollImpacting) {
  if (payrollImpacting) return const Color(0xFFB91C1C);
  return switch (type) {
    EmployeeDirectoryRosterDiffType.added => const Color(0xFF15803D),
    EmployeeDirectoryRosterDiffType.removed => const Color(0xFFD97706),
    EmployeeDirectoryRosterDiffType.departmentChanged => HrisColors.primary,
    EmployeeDirectoryRosterDiffType.managerChanged => HrisColors.primary,
    EmployeeDirectoryRosterDiffType.statusChanged => const Color(0xFF7C3AED),
    EmployeeDirectoryRosterDiffType.roleChanged => HrisColors.primary,
    EmployeeDirectoryRosterDiffType.locationChanged => const Color(0xFF0F766E),
    EmployeeDirectoryRosterDiffType.contactChanged => HrisColors.muted,
  };
}
