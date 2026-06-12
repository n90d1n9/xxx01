import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_select_field.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';
import 'package:kaysir/widgets/ui/app_surface.dart';

import '../data/project_portfolio_repository.dart';
import '../models/project_decision_record.dart';
import '../services/project_decision_register_service.dart';
import '../services/project_decision_review_flow_service.dart';
import '../services/project_decisions_workspace_service.dart';
import 'project_workflow_header.dart';
import 'project_workflow_issue_list.dart';
import 'project_workflow_submission_section.dart';
import 'project_workflow_text_field.dart';

/// Interactive review flow for advancing existing decision records.
class ProjectDecisionReviewFlowPanel extends StatefulWidget {
  const ProjectDecisionReviewFlowPanel({
    required this.registerSummary,
    this.service = const ProjectDecisionReviewFlowService(),
    super.key,
  });

  final ProjectDecisionRegisterSummary registerSummary;
  final ProjectDecisionReviewFlowService service;

  @override
  State<ProjectDecisionReviewFlowPanel> createState() =>
      _ProjectDecisionReviewFlowPanelState();
}

/// Maintains local review draft controllers and demo outcome queue state.
class _ProjectDecisionReviewFlowPanelState
    extends State<ProjectDecisionReviewFlowPanel> {
  late ProjectDecisionReviewDraft _draft;
  late final TextEditingController _ownerController;
  late final TextEditingController _noteController;
  late final TextEditingController _evidenceController;
  var _issues = const <ProjectDecisionReviewIssue>[];
  var _submissions = const <ProjectDecisionReviewSubmission>[];

  @override
  void initState() {
    super.initState();
    _draft = widget.service.initialDraft(widget.registerSummary);
    _ownerController = TextEditingController(text: _draft.owner);
    _noteController = TextEditingController(text: _draft.note);
    _evidenceController = TextEditingController(text: _draft.evidenceLabel);
  }

  @override
  void didUpdateWidget(covariant ProjectDecisionReviewFlowPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.registerSummary.project.id ==
        widget.registerSummary.project.id) {
      return;
    }

    _reset(clearQueue: true);
  }

  @override
  void dispose() {
    _ownerController.dispose();
    _noteController.dispose();
    _evidenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final records = widget.service.reviewableRecords(widget.registerSummary);
    final selectedRecord =
        widget.service.recordFor(widget.registerSummary, _draft.recordId) ??
        records.first;
    final resultingStatus = widget.service.statusFor(_draft.outcome);
    final routeLabel = widget.service.routeLabelFor(_draft.outcome);
    final colorScheme = Theme.of(context).colorScheme;
    final outcomeColor = _draft.outcome.color(colorScheme);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProjectWorkflowHeader(
          title: 'Decision review flow',
          subtitle:
              '${selectedRecord.title} - ${_submissions.length} queued outcomes - $routeLabel',
          icon: Icons.rate_review_outlined,
          color: outcomeColor,
          statusLabel: _draft.outcome.label,
          statusIcon: _draft.outcome.icon,
          statusMaxWidth: 142,
        ),
        const SizedBox(height: 12),
        _DecisionReviewFields(
          draft: _draft,
          records: records,
          selectedRecord: selectedRecord,
          ownerController: _ownerController,
          noteController: _noteController,
          evidenceController: _evidenceController,
          onRecordChanged: _selectRecord,
          onDraftChanged: _updateDraft,
        ),
        ProjectWorkflowIssueSection<ProjectDecisionReviewIssue>(
          items: _issues,
          fieldFor: (issue) => issue.field,
          messageFor: (issue) => issue.message,
        ),
        const SizedBox(height: 12),
        _DecisionReviewPreview(
          record: selectedRecord,
          outcome: _draft.outcome,
          resultingStatus: resultingStatus,
          routeLabel: routeLabel,
        ),
        const SizedBox(height: 12),
        ProjectWorkflowSubmissionSection<ProjectDecisionReviewSubmission>(
          submitLabel: 'Queue Outcome',
          onReset: () => _reset(clearQueue: false),
          onSubmit: _queueOutcome,
          items: _submissions,
          emptyTitle: 'Review queue empty',
          emptySubtitle: 'Submitted review outcomes will appear here.',
          titleFor: (submission) => submission.originalRecord.title,
          subtitleFor:
              (submission) =>
                  '${submission.routeLabel} - ${submission.outcome.label} - '
                  '${submission.resultingStatus.label} - Owner: ${submission.owner}',
          iconFor: (submission) => submission.outcome.icon,
          colorFor:
              (context, submission) =>
                  submission.outcome.color(Theme.of(context).colorScheme),
          statusColorFor:
              (context, submission) =>
                  submission.outcome.color(Theme.of(context).colorScheme),
        ),
      ],
    );
  }

  void _selectRecord(String recordId) {
    final record = widget.service.recordFor(widget.registerSummary, recordId);
    if (record == null) return;

    setState(() {
      _draft = widget.service.draftForRecord(record);
      _issues = const [];
      _syncControllers();
    });
  }

  void _updateDraft(ProjectDecisionReviewDraft draft) {
    setState(() {
      _draft = draft;
      _issues = const [];
    });
  }

  void _queueOutcome() {
    final issues = widget.service.validate(
      register: widget.registerSummary,
      draft: _draft,
    );
    if (issues.isNotEmpty) {
      setState(() => _issues = issues);
      return;
    }

    final submission = widget.service.submit(
      register: widget.registerSummary,
      draft: _draft,
    );
    setState(() {
      _submissions = [submission, ..._submissions];
      _issues = const [];
      _draft = widget.service
          .draftForRecord(submission.originalRecord)
          .copyWith(
            outcome: _draft.outcome,
            owner: _draft.owner,
            evidenceLabel: _draft.evidenceLabel,
          );
      _syncControllers();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Review outcome queued: ${submission.outcome.label}'),
      ),
    );
  }

  void _reset({required bool clearQueue}) {
    setState(() {
      _draft = widget.service.initialDraft(widget.registerSummary);
      _issues = const [];
      if (clearQueue) _submissions = const [];
      _syncControllers();
    });
  }

  void _syncControllers() {
    _ownerController.text = _draft.owner;
    _noteController.text = _draft.note;
    _evidenceController.text = _draft.evidenceLabel;
  }
}

/// Select and text fields for one decision review draft.
class _DecisionReviewFields extends StatelessWidget {
  const _DecisionReviewFields({
    required this.draft,
    required this.records,
    required this.selectedRecord,
    required this.ownerController,
    required this.noteController,
    required this.evidenceController,
    required this.onRecordChanged,
    required this.onDraftChanged,
  });

  final ProjectDecisionReviewDraft draft;
  final List<ProjectDecisionRecord> records;
  final ProjectDecisionRecord selectedRecord;
  final TextEditingController ownerController;
  final TextEditingController noteController;
  final TextEditingController evidenceController;
  final ValueChanged<String> onRecordChanged;
  final ValueChanged<ProjectDecisionReviewDraft> onDraftChanged;

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              AppSelectField<String>(
                width: 420,
                label: 'Decision',
                value: selectedRecord.id,
                icon: selectedRecord.source.icon,
                options: [
                  for (final record in records)
                    AppSelectOption(value: record.id, label: record.title),
                ],
                onChanged: onRecordChanged,
              ),
              AppSelectField<ProjectDecisionReviewOutcome>(
                width: 240,
                label: 'Outcome',
                value: draft.outcome,
                icon: draft.outcome.icon,
                options: [
                  for (final outcome in ProjectDecisionReviewOutcome.values)
                    AppSelectOption(value: outcome, label: outcome.label),
                ],
                onChanged:
                    (value) => onDraftChanged(draft.copyWith(outcome: value)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ProjectWorkflowTextField(
                fieldKey: const ValueKey('decision-review-owner'),
                width: 280,
                controller: ownerController,
                label: 'Review owner',
                icon: Icons.account_circle_outlined,
                textInputAction: TextInputAction.next,
                onChanged:
                    (value) => onDraftChanged(draft.copyWith(owner: value)),
              ),
              ProjectWorkflowTextField(
                fieldKey: const ValueKey('decision-review-evidence'),
                width: 320,
                controller: evidenceController,
                label: 'Evidence',
                icon: Icons.fact_check_outlined,
                textInputAction: TextInputAction.next,
                onChanged:
                    (value) =>
                        onDraftChanged(draft.copyWith(evidenceLabel: value)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ProjectWorkflowTextField(
            fieldKey: const ValueKey('decision-review-note'),
            controller: noteController,
            label: 'Review note',
            icon: Icons.notes_outlined,
            minLines: 3,
            maxLines: 5,
            onChanged: (value) => onDraftChanged(draft.copyWith(note: value)),
          ),
        ],
      ),
    );
  }
}

/// Live preview for the selected review outcome.
class _DecisionReviewPreview extends StatelessWidget {
  const _DecisionReviewPreview({
    required this.record,
    required this.outcome,
    required this.resultingStatus,
    required this.routeLabel,
  });

  final ProjectDecisionRecord record;
  final ProjectDecisionReviewOutcome outcome;
  final ProjectDecisionStatus resultingStatus;
  final String routeLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final outcomeColor = outcome.color(colorScheme);

    return AppInfoRow(
      title: record.title,
      subtitle:
          '${record.status.label} -> ${resultingStatus.label} - '
          '${outcome.label} - $routeLabel',
      icon: outcome.icon,
      iconStyle: AppInfoRowIconStyle.badge,
      contained: true,
      iconBackgroundColor: outcomeColor.withValues(alpha: 0.12),
      iconForegroundColor: outcomeColor,
      titleMaxLines: 2,
      subtitleMaxLines: 3,
      trailing: AppStatusPill(
        label: resultingStatus.label,
        icon: resultingStatus.icon,
        color: resultingStatus.color(colorScheme),
        maxWidth: 118,
      ),
    );
  }
}

@Preview(name: 'Project decision review flow panel')
Widget projectDecisionReviewFlowPanelPreview() {
  final workspace = buildProjectDecisionsWorkspaceSummary(
    project: demoProjectPortfolio.first,
    dependencyTasks: const [],
    today: DateTime(2026, 6, 11),
  );

  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ProjectDecisionReviewFlowPanel(
          registerSummary: workspace.decisionRegisterSummary,
        ),
      ),
    ),
  );
}
