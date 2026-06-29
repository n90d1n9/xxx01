import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_directory_roster_payroll_run_kickoff_models.dart';
import '../../models/employee_directory_roster_payroll_validation_models.dart';
import 'employee_directory_roster_payroll_run_kickoff_tiles.dart';

/// Launch gate for starting payroll processing from a validated import.
class EmployeeDirectoryRosterPayrollRunKickoffPanel extends StatefulWidget {
  final EmployeeDirectoryRosterPayrollRunKickoffReview review;
  final ValueChanged<String> onRunReferenceChanged;
  final ValueChanged<String> onRunOwnerChanged;
  final ValueChanged<String> onKickoffNoteChanged;
  final ValueChanged<bool> onFundingWindowChanged;
  final ValueChanged<bool> onPayslipHoldChanged;
  final ValueChanged<bool> onAuditArchiveChanged;
  final VoidCallback onSubmit;
  final VoidCallback onClear;

  const EmployeeDirectoryRosterPayrollRunKickoffPanel({
    super.key,
    required this.review,
    required this.onRunReferenceChanged,
    required this.onRunOwnerChanged,
    required this.onKickoffNoteChanged,
    required this.onFundingWindowChanged,
    required this.onPayslipHoldChanged,
    required this.onAuditArchiveChanged,
    required this.onSubmit,
    required this.onClear,
  });

  @override
  State<EmployeeDirectoryRosterPayrollRunKickoffPanel> createState() =>
      _EmployeeDirectoryRosterPayrollRunKickoffPanelState();
}

/// Keeps payroll run kickoff text fields aligned with provider state.
class _EmployeeDirectoryRosterPayrollRunKickoffPanelState
    extends State<EmployeeDirectoryRosterPayrollRunKickoffPanel> {
  late final TextEditingController _runReferenceController;
  late final TextEditingController _runOwnerController;
  late final TextEditingController _kickoffNoteController;

  @override
  void initState() {
    super.initState();
    _runReferenceController = TextEditingController(
      text: widget.review.draft.runReference,
    );
    _runOwnerController = TextEditingController(
      text: widget.review.draft.runOwner,
    );
    _kickoffNoteController = TextEditingController(
      text: widget.review.draft.kickoffNote,
    );
  }

  @override
  void didUpdateWidget(
    EmployeeDirectoryRosterPayrollRunKickoffPanel oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);
    _syncController(_runReferenceController, widget.review.draft.runReference);
    _syncController(_runOwnerController, widget.review.draft.runOwner);
    _syncController(_kickoffNoteController, widget.review.draft.kickoffNote);
  }

  @override
  void dispose() {
    _runReferenceController.dispose();
    _runOwnerController.dispose();
    _kickoffNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final review = widget.review;

    return HrisSectionPanel(
      key: const ValueKey(
        'employee-directory-roster-payroll-run-kickoff-panel',
      ),
      icon: Icons.play_circle_outline,
      title: 'Payroll run kickoff',
      subtitle:
          review.latestValidation == null
              ? 'Validate payroll import before launching payroll run'
              : 'Launch payroll run for ${review.latestValidation!.batchLabel}',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Batch',
              value: review.latestValidation?.batchLabel ?? 'None',
            ),
            HrisMetricStripItem(
              label: 'Profiles',
              value: '${review.latestValidation?.loadedProfileCount ?? 0}',
            ),
            HrisMetricStripItem(
              label: 'Items',
              value: '${review.latestValidation?.validationItemCount ?? 0}',
            ),
            HrisMetricStripItem(label: 'Kickoff', value: review.statusLabel),
          ],
        ),
        if (review.latestValidationRecord != null)
          EmployeeDirectoryRosterPayrollRunKickoffRecordTile(
            key: ValueKey(
              'employee-directory-roster-payroll-run-kickoff-${review.latestValidationRecord!.id}',
            ),
            record: review.latestValidationRecord!,
          ),
        _buildForm(context, review),
      ],
    );
  }

  Widget _buildForm(
    BuildContext context,
    EmployeeDirectoryRosterPayrollRunKickoffReview review,
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
                    _runReferenceField(),
                    const SizedBox(height: 12),
                    _runOwnerField(),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _runReferenceField()),
                  const SizedBox(width: 12),
                  Expanded(child: _runOwnerField()),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          _kickoffNoteField(),
          const SizedBox(height: 10),
          _toggleRow(
            key: const ValueKey(
              'employee-directory-roster-payroll-run-kickoff-funding-toggle',
            ),
            value: review.draft.confirmFundingWindow,
            label: 'Confirm payroll funding window',
            onChanged: widget.onFundingWindowChanged,
          ),
          const SizedBox(height: 8),
          _toggleRow(
            key: const ValueKey(
              'employee-directory-roster-payroll-run-kickoff-payslip-toggle',
            ),
            value: review.draft.confirmPayslipHold,
            label: 'Confirm payslip release hold remains active',
            onChanged: widget.onPayslipHoldChanged,
          ),
          const SizedBox(height: 8),
          _toggleRow(
            key: const ValueKey(
              'employee-directory-roster-payroll-run-kickoff-audit-toggle',
            ),
            value: review.draft.confirmAuditArchive,
            label: 'Confirm payroll audit trail archive',
            onChanged: widget.onAuditArchiveChanged,
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: review.completionRatio,
            color:
                review.canLaunch ? const Color(0xFF7C3AED) : HrisColors.primary,
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
                  'employee-directory-roster-payroll-run-kickoff-submit-button',
                ),
                onPressed: review.canLaunch ? widget.onSubmit : null,
                icon: const Icon(Icons.play_circle_outline),
                label: const Text('Launch run'),
              ),
              OutlinedButton.icon(
                key: const ValueKey(
                  'employee-directory-roster-payroll-run-kickoff-clear-button',
                ),
                onPressed: review.draft.hasInput ? widget.onClear : null,
                icon: const Icon(Icons.clear_all_outlined),
                label: const Text('Clear kickoff'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _runReferenceField() {
    return TextField(
      key: const ValueKey(
        'employee-directory-roster-payroll-run-kickoff-reference-field',
      ),
      controller: _runReferenceController,
      decoration: const InputDecoration(
        labelText: 'Run reference',
        prefixIcon: Icon(Icons.badge_outlined),
        border: OutlineInputBorder(),
      ),
      onChanged: widget.onRunReferenceChanged,
    );
  }

  Widget _runOwnerField() {
    return TextField(
      key: const ValueKey(
        'employee-directory-roster-payroll-run-kickoff-owner-field',
      ),
      controller: _runOwnerController,
      decoration: const InputDecoration(
        labelText: 'Run owner',
        prefixIcon: Icon(Icons.person_outline),
        border: OutlineInputBorder(),
      ),
      onChanged: widget.onRunOwnerChanged,
    );
  }

  Widget _kickoffNoteField() {
    return TextField(
      key: const ValueKey(
        'employee-directory-roster-payroll-run-kickoff-note-field',
      ),
      controller: _kickoffNoteController,
      minLines: 2,
      maxLines: 3,
      decoration: const InputDecoration(
        labelText: 'Kickoff note',
        prefixIcon: Icon(Icons.notes_outlined),
        border: OutlineInputBorder(),
      ),
      onChanged: widget.onKickoffNoteChanged,
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

@Preview(name: 'Employee payroll run kickoff')
Widget employeeDirectoryRosterPayrollRunKickoffPanelPreview() {
  final validation = EmployeeDirectoryRosterPayrollValidationRecord(
    id: 'payroll-validation-1',
    batchId: 'payroll-import-1',
    batchLabel: 'PAY-202605-001',
    releaseVersion: '2026.05.30-001',
    controlFileName: '2026-05-30-001-payroll-import.csv',
    validatedBy: 'Payroll Lead',
    validationNote: 'Import loaded and payroll run controls matched.',
    validatedAt: DateTime(2026, 5, 30),
    loadedProfileCount: 18,
    validationItemCount: 3,
    payrollImpactCount: 2,
  );
  final review = EmployeeDirectoryRosterPayrollRunKickoffReview(
    latestValidation: validation,
    draft: const EmployeeDirectoryRosterPayrollRunKickoffDraft(
      runReference: 'RUN-202605-001',
      runOwner: 'Payroll Lead',
      kickoffNote: 'Funding, payslip hold, and audit archive confirmed.',
      confirmFundingWindow: true,
      confirmPayslipHold: true,
      confirmAuditArchive: true,
    ),
    records: const [],
    errors: const [],
  );

  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: EmployeeDirectoryRosterPayrollRunKickoffPanel(
          review: review,
          onRunReferenceChanged: (_) {},
          onRunOwnerChanged: (_) {},
          onKickoffNoteChanged: (_) {},
          onFundingWindowChanged: (_) {},
          onPayslipHoldChanged: (_) {},
          onAuditArchiveChanged: (_) {},
          onSubmit: () {},
          onClear: () {},
        ),
      ),
    ),
  );
}

void _syncController(TextEditingController controller, String value) {
  if (controller.text == value) return;
  controller.text = value;
}
