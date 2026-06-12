import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_directory_models.dart';
import '../../models/employee_directory_quality_gate_models.dart';
import '../../models/employee_directory_roster_payroll_import_models.dart';
import '../../models/employee_directory_roster_payroll_sync_models.dart';
import '../../models/employee_directory_roster_payroll_validation_models.dart';
import '../../models/employee_directory_roster_publish_models.dart';
import 'employee_directory_roster_payroll_validation_tiles.dart';

/// Approves a staged payroll import packet after load and control validation.
class EmployeeDirectoryRosterPayrollValidationPanel extends StatefulWidget {
  final EmployeeDirectoryRosterPayrollValidationReview review;
  final ValueChanged<String> onValidatedByChanged;
  final ValueChanged<String> onValidationNoteChanged;
  final ValueChanged<bool> onFileLoadedChanged;
  final ValueChanged<bool> onValidationItemsChanged;
  final ValueChanged<bool> onPayrollRunControlsChanged;
  final VoidCallback onSubmit;
  final VoidCallback onClear;

  const EmployeeDirectoryRosterPayrollValidationPanel({
    super.key,
    required this.review,
    required this.onValidatedByChanged,
    required this.onValidationNoteChanged,
    required this.onFileLoadedChanged,
    required this.onValidationItemsChanged,
    required this.onPayrollRunControlsChanged,
    required this.onSubmit,
    required this.onClear,
  });

  @override
  State<EmployeeDirectoryRosterPayrollValidationPanel> createState() =>
      _EmployeeDirectoryRosterPayrollValidationPanelState();
}

/// Keeps payroll validation text controllers aligned with provider state.
class _EmployeeDirectoryRosterPayrollValidationPanelState
    extends State<EmployeeDirectoryRosterPayrollValidationPanel> {
  late final TextEditingController _validatedByController;
  late final TextEditingController _validationNoteController;

  @override
  void initState() {
    super.initState();
    _validatedByController = TextEditingController(
      text: widget.review.draft.validatedBy,
    );
    _validationNoteController = TextEditingController(
      text: widget.review.draft.validationNote,
    );
  }

  @override
  void didUpdateWidget(
    EmployeeDirectoryRosterPayrollValidationPanel oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);
    _syncController(_validatedByController, widget.review.draft.validatedBy);
    _syncController(
      _validationNoteController,
      widget.review.draft.validationNote,
    );
  }

  @override
  void dispose() {
    _validatedByController.dispose();
    _validationNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final review = widget.review;

    return HrisSectionPanel(
      key: const ValueKey('employee-directory-roster-payroll-validation-panel'),
      icon: Icons.verified_outlined,
      title: 'Payroll import validation',
      subtitle:
          review.latestBatch == null
              ? 'Stage payroll import before validation'
              : 'Validate ${review.latestBatch!.batchLabel} before payroll run',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Batch',
              value: review.latestBatch?.batchLabel ?? 'None',
            ),
            HrisMetricStripItem(
              label: 'Loaded',
              value: '${review.latestBatch?.includedProfileCount ?? 0}',
            ),
            HrisMetricStripItem(
              label: 'Items',
              value: '${review.validationItemCount}',
            ),
            HrisMetricStripItem(label: 'Validation', value: review.statusLabel),
          ],
        ),
        if (review.latestBatchRecord != null)
          EmployeeDirectoryRosterPayrollValidationRecordTile(
            key: ValueKey(
              'employee-directory-roster-payroll-validation-${review.latestBatchRecord!.id}',
            ),
            record: review.latestBatchRecord!,
          ),
        ...review.items.map(
          (item) => EmployeeDirectoryRosterPayrollValidationItemTile(
            key: ValueKey(
              'employee-directory-roster-payroll-validation-item-${item.id}',
            ),
            item: item,
          ),
        ),
        _buildForm(context, review),
      ],
    );
  }

  Widget _buildForm(
    BuildContext context,
    EmployeeDirectoryRosterPayrollValidationReview review,
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
                    _validatedByField(),
                    const SizedBox(height: 12),
                    _validationNoteField(),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _validatedByField()),
                  const SizedBox(width: 12),
                  Expanded(child: _validationNoteField()),
                ],
              );
            },
          ),
          const SizedBox(height: 10),
          _toggleRow(
            key: const ValueKey(
              'employee-directory-roster-payroll-validation-file-toggle',
            ),
            value: review.draft.confirmFileLoaded,
            label: 'Confirm payroll import file loaded successfully',
            onChanged: widget.onFileLoadedChanged,
          ),
          if (review.hasValidationItems) ...[
            const SizedBox(height: 8),
            _toggleRow(
              key: const ValueKey(
                'employee-directory-roster-payroll-validation-items-toggle',
              ),
              value: review.draft.confirmValidationItems,
              label:
                  'Review ${review.validationItemCount} payroll import validation item'
                  '${review.validationItemCount == 1 ? '' : 's'}',
              onChanged: widget.onValidationItemsChanged,
            ),
          ],
          const SizedBox(height: 8),
          _toggleRow(
            key: const ValueKey(
              'employee-directory-roster-payroll-validation-controls-toggle',
            ),
            value: review.draft.confirmPayrollRunControls,
            label: 'Confirm payroll run controls are ready',
            onChanged: widget.onPayrollRunControlsChanged,
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: review.completionRatio,
            color:
                review.canValidate
                    ? const Color(0xFF2563EB)
                    : HrisColors.primary,
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
                  'employee-directory-roster-payroll-validation-submit-button',
                ),
                onPressed: review.canValidate ? widget.onSubmit : null,
                icon: const Icon(Icons.verified_outlined),
                label: const Text('Approve validation'),
              ),
              OutlinedButton.icon(
                key: const ValueKey(
                  'employee-directory-roster-payroll-validation-clear-button',
                ),
                onPressed: review.draft.hasInput ? widget.onClear : null,
                icon: const Icon(Icons.clear_all_outlined),
                label: const Text('Clear validation'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _validatedByField() {
    return TextField(
      key: const ValueKey(
        'employee-directory-roster-payroll-validation-owner-field',
      ),
      controller: _validatedByController,
      decoration: const InputDecoration(
        labelText: 'Validation owner',
        prefixIcon: Icon(Icons.person_outline),
        border: OutlineInputBorder(),
      ),
      onChanged: widget.onValidatedByChanged,
    );
  }

  Widget _validationNoteField() {
    return TextField(
      key: const ValueKey(
        'employee-directory-roster-payroll-validation-note-field',
      ),
      controller: _validationNoteController,
      minLines: 2,
      maxLines: 3,
      decoration: const InputDecoration(
        labelText: 'Validation note',
        prefixIcon: Icon(Icons.notes_outlined),
        border: OutlineInputBorder(),
      ),
      onChanged: widget.onValidationNoteChanged,
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

@Preview(name: 'Employee payroll import validation')
Widget employeeDirectoryRosterPayrollValidationPanelPreview() {
  final release = _release();
  final batch = EmployeeDirectoryRosterPayrollImportBatch(
    id: 'payroll-import-1',
    releaseId: release.id,
    releaseVersion: release.versionLabel,
    syncRecordId: 'payroll-sync-1',
    batchLabel: 'PAY-202605-001',
    preparedBy: 'Payroll Lead',
    importNote: 'Column mapping and payroll preview controls matched.',
    controlFileName: '2026-05-30-001-payroll-import.csv',
    stagedAt: DateTime(2026, 5, 30),
    totalProfileCount: 2,
    includedProfileCount: 2,
    attentionProfileCount: 1,
    departmentCount: 1,
    payrollImpactCount: 3,
  );
  final importReview = EmployeeDirectoryRosterPayrollImportReview(
    latestRelease: release,
    latestSyncRecord: EmployeeDirectoryRosterPayrollSyncRecord(
      id: 'payroll-sync-1',
      releaseId: release.id,
      releaseVersion: release.versionLabel,
      syncedBy: 'Payroll Lead',
      syncNote: 'Control totals matched payroll staging import.',
      syncedAt: DateTime(2026, 5, 30),
      profileCount: release.memberCount,
      payrollImpactCount: 3,
      acknowledgedHandoffCount: 3,
    ),
    draft: const EmployeeDirectoryRosterPayrollImportDraft(),
    batches: [batch],
    errors: const [],
  );
  final review = EmployeeDirectoryRosterPayrollValidationReview.fromState(
    importReview: importReview,
    draft: const EmployeeDirectoryRosterPayrollValidationDraft(
      validatedBy: 'Payroll Lead',
      validationNote: 'Import loaded and payroll run controls matched.',
      confirmFileLoaded: true,
      confirmValidationItems: true,
      confirmPayrollRunControls: true,
    ),
    records: const [],
  );

  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: EmployeeDirectoryRosterPayrollValidationPanel(
          review: review,
          onValidatedByChanged: (_) {},
          onValidationNoteChanged: (_) {},
          onFileLoadedChanged: (_) {},
          onValidationItemsChanged: (_) {},
          onPayrollRunControlsChanged: (_) {},
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
