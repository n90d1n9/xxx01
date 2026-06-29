import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_directory_models.dart';
import '../../models/employee_directory_quality_gate_models.dart';
import '../../models/employee_directory_roster_diff_models.dart';
import '../../models/employee_directory_roster_handoff_models.dart';
import '../../models/employee_directory_roster_payroll_sync_models.dart';
import '../../models/employee_directory_roster_publish_models.dart';
import 'employee_directory_roster_payroll_sync_tiles.dart';

/// Reconciles a published roster release before syncing it into payroll.
class EmployeeDirectoryRosterPayrollSyncPanel extends StatefulWidget {
  final EmployeeDirectoryRosterPayrollSyncReview review;
  final ValueChanged<String> onSyncedByChanged;
  final ValueChanged<String> onSyncNoteChanged;
  final ValueChanged<bool> onPayrollImpactReviewChanged;
  final ValueChanged<bool> onControlTotalsChanged;
  final VoidCallback onSubmit;
  final VoidCallback onClear;

  const EmployeeDirectoryRosterPayrollSyncPanel({
    super.key,
    required this.review,
    required this.onSyncedByChanged,
    required this.onSyncNoteChanged,
    required this.onPayrollImpactReviewChanged,
    required this.onControlTotalsChanged,
    required this.onSubmit,
    required this.onClear,
  });

  @override
  State<EmployeeDirectoryRosterPayrollSyncPanel> createState() =>
      _EmployeeDirectoryRosterPayrollSyncPanelState();
}

/// Keeps payroll sync text fields aligned with provider-backed draft state.
class _EmployeeDirectoryRosterPayrollSyncPanelState
    extends State<EmployeeDirectoryRosterPayrollSyncPanel> {
  late final TextEditingController _syncedByController;
  late final TextEditingController _syncNoteController;

  @override
  void initState() {
    super.initState();
    _syncedByController = TextEditingController(
      text: widget.review.draft.syncedBy,
    );
    _syncNoteController = TextEditingController(
      text: widget.review.draft.syncNote,
    );
  }

  @override
  void didUpdateWidget(EmployeeDirectoryRosterPayrollSyncPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncController(_syncedByController, widget.review.draft.syncedBy);
    _syncController(_syncNoteController, widget.review.draft.syncNote);
  }

  @override
  void dispose() {
    _syncedByController.dispose();
    _syncNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final review = widget.review;

    return HrisSectionPanel(
      key: const ValueKey('employee-directory-roster-payroll-sync-panel'),
      icon: Icons.sync_alt_outlined,
      title: 'Payroll sync reconciliation',
      subtitle:
          review.latestRelease == null
              ? 'Publish a roster packet before payroll sync'
              : 'Reconcile ${review.latestRelease!.versionLabel} before payroll import',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Release',
              value: review.latestRelease?.versionLabel ?? 'None',
            ),
            HrisMetricStripItem(
              label: 'Impact',
              value: '${review.payrollImpactCount}',
            ),
            HrisMetricStripItem(
              label: 'Handoff',
              value: '${review.handoffReview.acknowledgedCount}',
            ),
            HrisMetricStripItem(label: 'Sync', value: review.statusLabel),
          ],
        ),
        if (review.latestReleaseRecord != null)
          EmployeeDirectoryRosterPayrollSyncRecordTile(
            key: ValueKey(
              'employee-directory-roster-payroll-sync-${review.latestReleaseRecord!.id}',
            ),
            record: review.latestReleaseRecord!,
          ),
        _buildForm(context, review),
      ],
    );
  }

  Widget _buildForm(
    BuildContext context,
    EmployeeDirectoryRosterPayrollSyncReview review,
  ) {
    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 720) {
                return Column(
                  children: [
                    _syncedByField(),
                    const SizedBox(height: 12),
                    _syncNoteField(),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _syncedByField()),
                  const SizedBox(width: 12),
                  Expanded(child: _syncNoteField()),
                ],
              );
            },
          ),
          if (review.hasPayrollImpact) ...[
            const SizedBox(height: 10),
            _toggleRow(
              key: const ValueKey(
                'employee-directory-roster-payroll-sync-impact-toggle',
              ),
              value: review.draft.confirmPayrollImpactReview,
              label:
                  'Confirm ${review.payrollImpactCount} payroll-impacting change'
                  '${review.payrollImpactCount == 1 ? '' : 's'} reviewed',
              onChanged: widget.onPayrollImpactReviewChanged,
            ),
          ],
          const SizedBox(height: 10),
          _toggleRow(
            key: const ValueKey(
              'employee-directory-roster-payroll-sync-totals-toggle',
            ),
            value: review.draft.confirmControlTotals,
            label: 'Confirm payroll control totals match roster release',
            onChanged: widget.onControlTotalsChanged,
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: review.completionRatio,
            color:
                review.canSync ? const Color(0xFF15803D) : HrisColors.primary,
            label: '${(review.completionRatio * 100).round()}% ready',
          ),
          if (review.errors.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review.errors.first,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFFB91C1C),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                key: const ValueKey(
                  'employee-directory-roster-payroll-sync-submit-button',
                ),
                onPressed: review.canSync ? widget.onSubmit : null,
                icon: const Icon(Icons.sync_outlined),
                label: const Text('Sync payroll'),
              ),
              OutlinedButton.icon(
                key: const ValueKey(
                  'employee-directory-roster-payroll-sync-clear-button',
                ),
                onPressed: review.draft.hasInput ? widget.onClear : null,
                icon: const Icon(Icons.clear_all_outlined),
                label: const Text('Clear sync'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _syncedByField() {
    return TextField(
      key: const ValueKey(
        'employee-directory-roster-payroll-sync-operator-field',
      ),
      controller: _syncedByController,
      decoration: const InputDecoration(
        labelText: 'Payroll operator',
        prefixIcon: Icon(Icons.person_outline),
        border: OutlineInputBorder(),
      ),
      onChanged: widget.onSyncedByChanged,
    );
  }

  Widget _syncNoteField() {
    return TextField(
      key: const ValueKey('employee-directory-roster-payroll-sync-note-field'),
      controller: _syncNoteController,
      minLines: 2,
      maxLines: 3,
      decoration: const InputDecoration(
        labelText: 'Sync note',
        prefixIcon: Icon(Icons.notes_outlined),
        border: OutlineInputBorder(),
      ),
      onChanged: widget.onSyncNoteChanged,
    );
  }

  Widget _toggleRow({
    required Key key,
    required bool value,
    required String label,
    required ValueChanged<bool> onChanged,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Checkbox(
              key: key,
              value: value,
              onChanged: (next) => onChanged(next ?? false),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: HrisColors.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

@Preview(name: 'Employee roster payroll sync')
Widget employeeDirectoryRosterPayrollSyncPanelPreview() {
  final release = _release();
  final review = EmployeeDirectoryRosterPayrollSyncReview.fromState(
    diffReview: EmployeeDirectoryRosterDiffReview.fromReleases([release]),
    handoffReview: EmployeeDirectoryRosterHandoffReview(
      latestRelease: release,
      recipients:
          defaultRosterHandoffRecipients(release).map((recipient) {
            return recipient.copyWith(
              status: EmployeeDirectoryRosterHandoffStatus.acknowledged,
              lastActionAt: DateTime(2026, 5, 30),
            );
          }).toList(),
    ),
    draft: const EmployeeDirectoryRosterPayrollSyncDraft(
      syncedBy: 'Payroll Lead',
      syncNote: 'Control totals matched payroll staging import.',
      confirmControlTotals: true,
    ),
    records: const [],
  );

  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: EmployeeDirectoryRosterPayrollSyncPanel(
          review: review,
          onSyncedByChanged: (_) {},
          onSyncNoteChanged: (_) {},
          onPayrollImpactReviewChanged: (_) {},
          onControlTotalsChanged: (_) {},
          onSubmit: () {},
          onClear: () {},
        ),
      ),
    ),
  );
}

EmployeeDirectoryRosterRelease _release() {
  return EmployeeDirectoryRosterRelease(
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
  );
}

void _syncController(TextEditingController controller, String value) {
  if (controller.text == value) return;
  controller.text = value;
}
