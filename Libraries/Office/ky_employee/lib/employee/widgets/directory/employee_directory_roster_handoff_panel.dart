import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_directory_quality_gate_models.dart';
import '../../models/employee_directory_roster_handoff_models.dart';
import '../../models/employee_directory_roster_publish_models.dart';
import 'employee_directory_roster_handoff_tiles.dart';

/// Tracks stakeholder acknowledgement after a roster release packet is published.
class EmployeeDirectoryRosterHandoffPanel extends StatelessWidget {
  final EmployeeDirectoryRosterHandoffReview review;
  final ValueChanged<EmployeeDirectoryRosterHandoffRecipient> onAcknowledge;
  final ValueChanged<EmployeeDirectoryRosterHandoffRecipient> onResend;
  final ValueChanged<EmployeeDirectoryRosterHandoffRecipient> onEscalate;

  const EmployeeDirectoryRosterHandoffPanel({
    super.key,
    required this.review,
    required this.onAcknowledge,
    required this.onResend,
    required this.onEscalate,
  });

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      key: const ValueKey('employee-directory-roster-handoff-panel'),
      icon: Icons.handshake_outlined,
      title: 'Roster handoff tracker',
      subtitle: review.summaryLabel,
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Release',
              value: review.latestRelease?.versionLabel ?? 'None',
            ),
            HrisMetricStripItem(label: 'Pending', value: '${review.openCount}'),
            HrisMetricStripItem(
              label: 'Ack',
              value: '${review.acknowledgedCount}',
            ),
            HrisMetricStripItem(label: 'Status', value: review.statusLabel),
          ],
        ),
        HrisListSurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                review.summaryLabel,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: HrisColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              HrisProgressBar(
                value: review.completionRatio,
                color:
                    review.openCount == 0 && review.hasRelease
                        ? const Color(0xFF15803D)
                        : HrisColors.primary,
                label:
                    '${(review.completionRatio * 100).round()}% acknowledged',
              ),
            ],
          ),
        ),
        ...review.recipients.map(
          (recipient) => EmployeeDirectoryRosterHandoffRecipientTile(
            key: ValueKey('employee-directory-roster-handoff-${recipient.id}'),
            recipient: recipient,
            onAcknowledge: onAcknowledge,
            onResend: onResend,
            onEscalate: onEscalate,
          ),
        ),
      ],
    );
  }
}

@Preview(name: 'Employee roster handoff tracker')
Widget employeeDirectoryRosterHandoffPanelPreview() {
  final release = EmployeeDirectoryRosterRelease(
    id: 'roster-release-1',
    versionLabel: '2026.05.30-001',
    preparedBy: 'Alya Rahman',
    releaseNote: 'Roster packet prepared for payroll cutoff.',
    publishedAt: DateTime(2026, 5, 30),
    asOfDate: DateTime(2026, 5, 30),
    memberCount: 18,
    departmentCount: 4,
    gateStatus: EmployeeDirectoryQualityGateStatus.ready,
    readinessScore: 100,
    signoffId: 'quality-gate-1',
    signoffReviewer: 'Rafi Pratama',
    payrollNotified: true,
  );

  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: EmployeeDirectoryRosterHandoffPanel(
          review: EmployeeDirectoryRosterHandoffReview.fromState(
            latestRelease: release,
            recipientsByRelease: const {},
          ),
          onAcknowledge: (_) {},
          onResend: (_) {},
          onEscalate: (_) {},
        ),
      ),
    ),
  );
}
