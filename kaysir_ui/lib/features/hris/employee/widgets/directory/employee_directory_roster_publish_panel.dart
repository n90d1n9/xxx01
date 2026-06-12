import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_directory_models.dart';
import '../../models/employee_directory_quality_gate_models.dart';
import '../../models/employee_directory_quality_signoff_models.dart';
import '../../models/employee_directory_roster_publish_models.dart';
import 'employee_directory_roster_publish_tiles.dart';

/// Publish workspace for preparing a governed roster release packet.
class EmployeeDirectoryRosterPublishPanel extends StatefulWidget {
  final EmployeeDirectoryRosterPublishReview review;
  final ValueChanged<String> onPreparedByChanged;
  final ValueChanged<String> onReleaseNoteChanged;
  final ValueChanged<bool> onConfirmPayrollHandoffChanged;
  final VoidCallback onSubmit;
  final VoidCallback onClear;

  const EmployeeDirectoryRosterPublishPanel({
    super.key,
    required this.review,
    required this.onPreparedByChanged,
    required this.onReleaseNoteChanged,
    required this.onConfirmPayrollHandoffChanged,
    required this.onSubmit,
    required this.onClear,
  });

  @override
  State<EmployeeDirectoryRosterPublishPanel> createState() =>
      _EmployeeDirectoryRosterPublishPanelState();
}

/// Keeps roster publish text fields aligned with provider-backed draft state.
class _EmployeeDirectoryRosterPublishPanelState
    extends State<EmployeeDirectoryRosterPublishPanel> {
  late final TextEditingController _preparedByController;
  late final TextEditingController _releaseNoteController;

  @override
  void initState() {
    super.initState();
    _preparedByController = TextEditingController(
      text: widget.review.draft.preparedBy,
    );
    _releaseNoteController = TextEditingController(
      text: widget.review.draft.releaseNote,
    );
  }

  @override
  void didUpdateWidget(EmployeeDirectoryRosterPublishPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncController(_preparedByController, widget.review.draft.preparedBy);
    _syncController(_releaseNoteController, widget.review.draft.releaseNote);
  }

  @override
  void dispose() {
    _preparedByController.dispose();
    _releaseNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final review = widget.review;

    return HrisSectionPanel(
      key: const ValueKey('employee-directory-roster-publish-panel'),
      icon: Icons.publish_outlined,
      title: 'Roster release packet',
      subtitle:
          review.latestRelease == null
              ? 'Prepare a governed roster snapshot for payroll handoff'
              : 'Latest packet ${review.latestRelease!.versionLabel}',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Version',
              value: review.nextVersionLabel,
            ),
            HrisMetricStripItem(
              label: 'Profiles',
              value: '${review.members.length}',
            ),
            HrisMetricStripItem(label: 'Gate', value: review.gate.status.label),
            HrisMetricStripItem(label: 'Publish', value: review.statusLabel),
          ],
        ),
        if (review.latestRelease != null)
          EmployeeDirectoryRosterReleaseTile(
            key: ValueKey(
              'employee-directory-roster-release-${review.latestRelease!.id}',
            ),
            release: review.latestRelease!,
          ),
        _buildForm(context, review),
      ],
    );
  }

  Widget _buildForm(
    BuildContext context,
    EmployeeDirectoryRosterPublishReview review,
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
                    _preparedByField(),
                    const SizedBox(height: 12),
                    _releaseNoteField(),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _preparedByField()),
                  const SizedBox(width: 12),
                  Expanded(child: _releaseNoteField()),
                ],
              );
            },
          ),
          const SizedBox(height: 10),
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap:
                () => widget.onConfirmPayrollHandoffChanged(
                  !review.draft.confirmPayrollHandoff,
                ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Checkbox(
                    key: const ValueKey(
                      'employee-directory-roster-publish-payroll-toggle',
                    ),
                    value: review.draft.confirmPayrollHandoff,
                    onChanged:
                        (value) => widget.onConfirmPayrollHandoffChanged(
                          value ?? false,
                        ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Confirm payroll and operations handoff for '
                      '${review.members.length} profile'
                      '${review.members.length == 1 ? '' : 's'}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: review.completionRatio,
            color:
                review.canPublish
                    ? const Color(0xFF15803D)
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
                  'employee-directory-roster-publish-submit-button',
                ),
                onPressed: review.canPublish ? widget.onSubmit : null,
                icon: const Icon(Icons.outbox_outlined),
                label: const Text('Publish packet'),
              ),
              OutlinedButton.icon(
                key: const ValueKey(
                  'employee-directory-roster-publish-clear-button',
                ),
                onPressed: review.draft.hasInput ? widget.onClear : null,
                icon: const Icon(Icons.clear_all_outlined),
                label: const Text('Clear packet'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _preparedByField() {
    return TextField(
      key: const ValueKey('employee-directory-roster-publish-preparer-field'),
      controller: _preparedByController,
      decoration: const InputDecoration(
        labelText: 'Prepared by',
        prefixIcon: Icon(Icons.person_outline),
        border: OutlineInputBorder(),
      ),
      onChanged: widget.onPreparedByChanged,
    );
  }

  Widget _releaseNoteField() {
    return TextField(
      key: const ValueKey('employee-directory-roster-publish-note-field'),
      controller: _releaseNoteController,
      minLines: 2,
      maxLines: 3,
      decoration: const InputDecoration(
        labelText: 'Release note',
        prefixIcon: Icon(Icons.notes_outlined),
        border: OutlineInputBorder(),
      ),
      onChanged: widget.onReleaseNoteChanged,
    );
  }
}

@Preview(name: 'Employee roster publish panel')
Widget employeeDirectoryRosterPublishPanelPreview() {
  const gate = EmployeeDirectoryQualityGate(
    status: EmployeeDirectoryQualityGateStatus.ready,
    memberCount: 2,
    readinessScore: 100,
    blockerCount: 0,
    reviewCount: 0,
    advisoryCount: 0,
    nextIssue: null,
    checks: [],
  );
  final signoff = EmployeeDirectoryQualityGateSignoff(
    id: 'quality-gate-1',
    reviewer: 'Rafi Pratama',
    note: 'Roster gate reviewed and ready.',
    signedAt: DateTime(2026, 5, 30),
    gateStatus: EmployeeDirectoryQualityGateStatus.ready,
    readinessScore: 100,
    memberCount: 2,
    acceptedReviewCount: 0,
  );
  final review = EmployeeDirectoryRosterPublishReview.fromState(
    gate: gate,
    latestSignoff: signoff,
    draft: const EmployeeDirectoryRosterPublishDraft(
      preparedBy: 'Alya Rahman',
      releaseNote: 'Roster packet prepared for payroll cutoff.',
      confirmPayrollHandoff: true,
    ),
    releases: const [],
    members: [
      EmployeeDirectoryMember(
        id: '1',
        name: 'Sarah Johnson',
        position: 'HR Analyst',
        department: 'People Operations',
        avatarUrl: 'https://example.com/avatar.png',
        email: 'sarah@example.com',
        phone: '+62 812 0000 0000',
        joiningDate: DateTime(2024, 1, 1),
        performance: 4.5,
        location: 'Jakarta',
        manager: 'Emma Rodriguez',
        status: EmployeeDirectoryStatus.active,
      ),
      EmployeeDirectoryMember(
        id: '2',
        name: 'Maya Santoso',
        position: 'Payroll Specialist',
        department: 'Finance',
        avatarUrl: 'https://example.com/avatar.png',
        email: 'maya@example.com',
        phone: '+62 812 1111 1111',
        joiningDate: DateTime(2024, 2, 1),
        performance: 4.6,
        location: 'Jakarta',
        manager: 'Emma Rodriguez',
        status: EmployeeDirectoryStatus.active,
      ),
    ],
    asOfDate: DateTime(2026, 5, 30),
  );

  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: EmployeeDirectoryRosterPublishPanel(
          review: review,
          onPreparedByChanged: (_) {},
          onReleaseNoteChanged: (_) {},
          onConfirmPayrollHandoffChanged: (_) {},
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
