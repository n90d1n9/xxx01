import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_directory_models.dart';
import '../../models/employee_directory_quality_gate_models.dart';
import '../../models/employee_directory_roster_diff_models.dart';
import '../../models/employee_directory_roster_publish_models.dart';
import 'employee_directory_roster_diff_tiles.dart';

/// Reviews changes between the newest roster release and its previous packet.
class EmployeeDirectoryRosterDiffPanel extends StatelessWidget {
  final EmployeeDirectoryRosterDiffReview review;

  const EmployeeDirectoryRosterDiffPanel({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      key: const ValueKey('employee-directory-roster-diff-panel'),
      icon: Icons.compare_arrows_outlined,
      title: 'Roster release diff',
      subtitle: review.summaryLabel,
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(label: 'Added', value: '${review.addedCount}'),
            HrisMetricStripItem(
              label: 'Removed',
              value: '${review.removedCount}',
            ),
            HrisMetricStripItem(
              label: 'Changed',
              value: '${review.changedCount}',
            ),
            HrisMetricStripItem(
              label: 'Payroll',
              value: '${review.payrollImpactCount}',
            ),
          ],
        ),
        if (!review.hasRelease)
          const HrisListSurface(
            child: Text('Publish a roster packet to start diff review.'),
          )
        else if (!review.hasBaseline && review.latestRelease != null)
          EmployeeDirectoryRosterDiffBaselineTile(
            release: review.latestRelease!,
          )
        else if (review.items.isEmpty)
          const HrisListSurface(
            child: Text(
              'No roster changes detected since the previous packet.',
            ),
          )
        else
          ...review.items
              .take(6)
              .map(
                (item) => EmployeeDirectoryRosterDiffTile(
                  key: ValueKey('employee-directory-roster-diff-${item.id}'),
                  item: item,
                ),
              ),
      ],
    );
  }
}

@Preview(name: 'Employee roster release diff')
Widget employeeDirectoryRosterDiffPanelPreview() {
  final previous = _release(
    id: 'roster-release-1',
    versionLabel: '2026.05.30-001',
    department: 'Design',
    status: EmployeeDirectoryStatus.active,
  );
  final latest = _release(
    id: 'roster-release-2',
    versionLabel: '2026.05.30-002',
    department: 'People Operations',
    status: EmployeeDirectoryStatus.watchlist,
  );

  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: EmployeeDirectoryRosterDiffPanel(
          review: EmployeeDirectoryRosterDiffReview.fromReleases([
            latest,
            previous,
          ]),
        ),
      ),
    ),
  );
}

EmployeeDirectoryRosterRelease _release({
  required String id,
  required String versionLabel,
  required String department,
  required EmployeeDirectoryStatus status,
}) {
  return EmployeeDirectoryRosterRelease(
    id: id,
    versionLabel: versionLabel,
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
        department: department,
        manager: 'Emma Rodriguez',
        location: 'Jakarta',
        email: 'sarah@example.com',
        phone: '+62 812 0000 0000',
        status: status,
        joiningDate: DateTime(2024, 1, 1),
        performance: 4.5,
      ),
    ],
  );
}
