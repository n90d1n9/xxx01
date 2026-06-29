import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_directory_quality_gate_models.dart';
import '../../models/employee_directory_roster_publish_models.dart';

/// Compact audit tile for a published roster release packet.
class EmployeeDirectoryRosterReleaseTile extends StatelessWidget {
  final EmployeeDirectoryRosterRelease release;

  const EmployeeDirectoryRosterReleaseTile({super.key, required this.release});

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
              Icons.outbox_outlined,
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
                      'Roster published',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    HrisStatusPill(
                      label: release.versionLabel,
                      color: HrisColors.primary,
                    ),
                    HrisStatusPill(
                      label: release.handoffLabel,
                      color:
                          release.payrollNotified
                              ? const Color(0xFF15803D)
                              : const Color(0xFFD97706),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  release.summaryLabel,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _RosterReleaseMetaChip(
                      icon: Icons.person_outline,
                      label: release.preparedBy,
                    ),
                    _RosterReleaseMetaChip(
                      icon: Icons.verified_user_outlined,
                      label: release.signoffReviewer,
                    ),
                    _RosterReleaseMetaChip(
                      icon: Icons.event_available_outlined,
                      label: _formatDate(release.publishedAt),
                    ),
                    _RosterReleaseMetaChip(
                      icon: Icons.fact_check_outlined,
                      label: release.statusLabel,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  release.releaseNote,
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

/// Small metadata chip used by roster release audit tiles.
class _RosterReleaseMetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _RosterReleaseMetaChip({required this.icon, required this.label});

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

@Preview(name: 'Employee roster release tile')
Widget employeeDirectoryRosterReleaseTilePreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: EmployeeDirectoryRosterReleaseTile(
          release: EmployeeDirectoryRosterRelease(
            id: 'roster-release-1',
            versionLabel: '2026.05.30-001',
            preparedBy: 'Alya Rahman',
            releaseNote: 'Roster packet prepared for payroll cutoff handoff.',
            publishedAt: DateTime(2026, 5, 30),
            asOfDate: DateTime(2026, 5, 30),
            memberCount: 18,
            departmentCount: 4,
            gateStatus: EmployeeDirectoryQualityGateStatus.ready,
            readinessScore: 100,
            signoffId: 'quality-gate-1',
            signoffReviewer: 'Rafi Pratama',
            payrollNotified: true,
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
