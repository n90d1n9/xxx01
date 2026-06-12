import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_directory_models.dart';
import '../../models/employee_directory_quality_gate_models.dart';
import '../../models/employee_directory_roster_diff_models.dart';
import '../../models/employee_directory_roster_handoff_models.dart';
import '../../models/employee_directory_roster_payroll_import_models.dart';
import '../../models/employee_directory_roster_payroll_sync_models.dart';
import '../../models/employee_directory_roster_publish_models.dart';
import 'employee_directory_roster_payroll_import_tiles.dart';

/// Stages a synced roster release as a payroll import packet.
class EmployeeDirectoryRosterPayrollImportPanel extends StatefulWidget {
  final EmployeeDirectoryRosterPayrollImportReview review;
  final ValueChanged<String> onBatchLabelChanged;
  final ValueChanged<String> onPreparedByChanged;
  final ValueChanged<String> onImportNoteChanged;
  final ValueChanged<bool> onColumnMappingChanged;
  final ValueChanged<bool> onAttentionProfilesChanged;
  final ValueChanged<bool> onPreviewControlsChanged;
  final VoidCallback onSubmit;
  final VoidCallback onClear;

  const EmployeeDirectoryRosterPayrollImportPanel({
    super.key,
    required this.review,
    required this.onBatchLabelChanged,
    required this.onPreparedByChanged,
    required this.onImportNoteChanged,
    required this.onColumnMappingChanged,
    required this.onAttentionProfilesChanged,
    required this.onPreviewControlsChanged,
    required this.onSubmit,
    required this.onClear,
  });

  @override
  State<EmployeeDirectoryRosterPayrollImportPanel> createState() =>
      _EmployeeDirectoryRosterPayrollImportPanelState();
}

/// Keeps payroll import text controllers aligned with provider-backed state.
class _EmployeeDirectoryRosterPayrollImportPanelState
    extends State<EmployeeDirectoryRosterPayrollImportPanel> {
  late final TextEditingController _batchLabelController;
  late final TextEditingController _preparedByController;
  late final TextEditingController _importNoteController;

  @override
  void initState() {
    super.initState();
    _batchLabelController = TextEditingController(
      text: widget.review.draft.batchLabel,
    );
    _preparedByController = TextEditingController(
      text: widget.review.draft.preparedBy,
    );
    _importNoteController = TextEditingController(
      text: widget.review.draft.importNote,
    );
  }

  @override
  void didUpdateWidget(EmployeeDirectoryRosterPayrollImportPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncController(_batchLabelController, widget.review.draft.batchLabel);
    _syncController(_preparedByController, widget.review.draft.preparedBy);
    _syncController(_importNoteController, widget.review.draft.importNote);
  }

  @override
  void dispose() {
    _batchLabelController.dispose();
    _preparedByController.dispose();
    _importNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final review = widget.review;

    return HrisSectionPanel(
      key: const ValueKey('employee-directory-roster-payroll-import-panel'),
      icon: Icons.upload_file_outlined,
      title: 'Payroll import packet',
      subtitle:
          review.latestRelease == null
              ? 'Sync a roster release before staging payroll import'
              : 'Stage ${review.latestRelease!.versionLabel} for payroll import',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Release',
              value: review.latestRelease?.versionLabel ?? 'None',
            ),
            HrisMetricStripItem(label: 'File', value: review.controlFileName),
            HrisMetricStripItem(
              label: 'Attention',
              value: '${review.attentionProfileCount}',
            ),
            HrisMetricStripItem(label: 'Import', value: review.statusLabel),
          ],
        ),
        if (review.latestReleaseBatch != null)
          EmployeeDirectoryRosterPayrollImportBatchTile(
            key: ValueKey(
              'employee-directory-roster-payroll-import-${review.latestReleaseBatch!.id}',
            ),
            batch: review.latestReleaseBatch!,
          ),
        _buildForm(context, review),
      ],
    );
  }

  Widget _buildForm(
    BuildContext context,
    EmployeeDirectoryRosterPayrollImportReview review,
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
                    _batchLabelField(),
                    const SizedBox(height: 12),
                    _preparedByField(),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _batchLabelField()),
                  const SizedBox(width: 12),
                  Expanded(child: _preparedByField()),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          _importNoteField(),
          const SizedBox(height: 10),
          _toggleRow(
            key: const ValueKey(
              'employee-directory-roster-payroll-import-mapping-toggle',
            ),
            value: review.draft.confirmColumnMapping,
            label: 'Confirm payroll import column mapping',
            onChanged: widget.onColumnMappingChanged,
          ),
          if (review.hasAttentionProfiles) ...[
            const SizedBox(height: 8),
            _toggleRow(
              key: const ValueKey(
                'employee-directory-roster-payroll-import-attention-toggle',
              ),
              value: review.draft.confirmAttentionProfiles,
              label:
                  'Review ${review.attentionProfileCount} payroll attention profile'
                  '${review.attentionProfileCount == 1 ? '' : 's'}',
              onChanged: widget.onAttentionProfilesChanged,
            ),
          ],
          const SizedBox(height: 8),
          _toggleRow(
            key: const ValueKey(
              'employee-directory-roster-payroll-import-preview-toggle',
            ),
            value: review.draft.confirmPreviewControls,
            label: 'Confirm payroll preview controls are ready',
            onChanged: widget.onPreviewControlsChanged,
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: review.completionRatio,
            color:
                review.canStage ? const Color(0xFF0F766E) : HrisColors.primary,
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
                  'employee-directory-roster-payroll-import-submit-button',
                ),
                onPressed: review.canStage ? widget.onSubmit : null,
                icon: const Icon(Icons.upload_file_outlined),
                label: const Text('Stage import'),
              ),
              OutlinedButton.icon(
                key: const ValueKey(
                  'employee-directory-roster-payroll-import-clear-button',
                ),
                onPressed: review.draft.hasInput ? widget.onClear : null,
                icon: const Icon(Icons.clear_all_outlined),
                label: const Text('Clear import'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _batchLabelField() {
    return TextField(
      key: const ValueKey(
        'employee-directory-roster-payroll-import-batch-field',
      ),
      controller: _batchLabelController,
      decoration: const InputDecoration(
        labelText: 'Import batch label',
        prefixIcon: Icon(Icons.badge_outlined),
        border: OutlineInputBorder(),
      ),
      onChanged: widget.onBatchLabelChanged,
    );
  }

  Widget _preparedByField() {
    return TextField(
      key: const ValueKey(
        'employee-directory-roster-payroll-import-preparer-field',
      ),
      controller: _preparedByController,
      decoration: const InputDecoration(
        labelText: 'Prepared by',
        prefixIcon: Icon(Icons.person_outline),
        border: OutlineInputBorder(),
      ),
      onChanged: widget.onPreparedByChanged,
    );
  }

  Widget _importNoteField() {
    return TextField(
      key: const ValueKey(
        'employee-directory-roster-payroll-import-note-field',
      ),
      controller: _importNoteController,
      minLines: 2,
      maxLines: 3,
      decoration: const InputDecoration(
        labelText: 'Import note',
        prefixIcon: Icon(Icons.notes_outlined),
        border: OutlineInputBorder(),
      ),
      onChanged: widget.onImportNoteChanged,
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

@Preview(name: 'Employee roster payroll import')
Widget employeeDirectoryRosterPayrollImportPanelPreview() {
  final release = _release();
  final syncReview = EmployeeDirectoryRosterPayrollSyncReview.fromState(
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
    draft: const EmployeeDirectoryRosterPayrollSyncDraft(),
    records: [
      EmployeeDirectoryRosterPayrollSyncRecord(
        id: 'payroll-sync-1',
        releaseId: release.id,
        releaseVersion: release.versionLabel,
        syncedBy: 'Payroll Lead',
        syncNote: 'Control totals matched payroll staging import.',
        syncedAt: DateTime(2026, 5, 30),
        profileCount: release.memberCount,
        payrollImpactCount: 0,
        acknowledgedHandoffCount: 3,
      ),
    ],
  );
  final review = EmployeeDirectoryRosterPayrollImportReview.fromState(
    syncReview: syncReview,
    draft: const EmployeeDirectoryRosterPayrollImportDraft(
      batchLabel: 'PAY-202605-001',
      preparedBy: 'Payroll Lead',
      importNote: 'Column mapping and payroll preview controls matched.',
      confirmColumnMapping: true,
      confirmAttentionProfiles: true,
      confirmPreviewControls: true,
    ),
    batches: const [],
  );

  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: EmployeeDirectoryRosterPayrollImportPanel(
          review: review,
          onBatchLabelChanged: (_) {},
          onPreparedByChanged: (_) {},
          onImportNoteChanged: (_) {},
          onColumnMappingChanged: (_) {},
          onAttentionProfilesChanged: (_) {},
          onPreviewControlsChanged: (_) {},
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
    memberCount: 2,
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
      EmployeeDirectoryRosterReleaseMemberSnapshot(
        employeeId: '2',
        name: 'Maya Santoso',
        position: 'Payroll Analyst',
        department: 'People Operations',
        manager: 'Emma Rodriguez',
        location: 'Jakarta',
        email: 'maya@example.com',
        phone: '+62 812 0000 0001',
        status: EmployeeDirectoryStatus.watchlist,
        joiningDate: DateTime(2024, 2, 1),
        performance: 4.3,
      ),
    ],
  );
}

void _syncController(TextEditingController controller, String value) {
  if (controller.text == value) return;
  controller.text = value;
}
