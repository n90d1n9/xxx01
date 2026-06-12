import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_select_field.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';
import 'package:kaysir/widgets/ui/app_surface.dart';

import '../data/project_portfolio_repository.dart';
import '../models/project_decision_record.dart';
import '../services/project_decision_evidence_intake_service.dart';
import '../services/project_decision_register_service.dart';
import '../services/project_decisions_workspace_service.dart';
import 'project_workflow_header.dart';
import 'project_workflow_issue_list.dart';
import 'project_workflow_submission_section.dart';
import 'project_workflow_text_field.dart';

/// Interactive intake flow for attaching proof to decision records.
class ProjectDecisionEvidenceIntakePanel extends StatefulWidget {
  const ProjectDecisionEvidenceIntakePanel({
    required this.registerSummary,
    this.service = const ProjectDecisionEvidenceIntakeService(),
    super.key,
  });

  final ProjectDecisionRegisterSummary registerSummary;
  final ProjectDecisionEvidenceIntakeService service;

  @override
  State<ProjectDecisionEvidenceIntakePanel> createState() =>
      _ProjectDecisionEvidenceIntakePanelState();
}

/// Maintains local evidence controllers and queued proof submissions.
class _ProjectDecisionEvidenceIntakePanelState
    extends State<ProjectDecisionEvidenceIntakePanel> {
  late ProjectDecisionEvidenceIntakeDraft _draft;
  late final TextEditingController _titleController;
  late final TextEditingController _referenceController;
  late final TextEditingController _noteController;
  var _issues = const <ProjectDecisionEvidenceIntakeIssue>[];
  var _submissions = const <ProjectDecisionEvidenceIntakeSubmission>[];

  @override
  void initState() {
    super.initState();
    _draft = widget.service.initialDraft(widget.registerSummary);
    _titleController = TextEditingController(text: _draft.title);
    _referenceController = TextEditingController(text: _draft.reference);
    _noteController = TextEditingController(text: _draft.note);
  }

  @override
  void didUpdateWidget(covariant ProjectDecisionEvidenceIntakePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.registerSummary.project.id ==
        widget.registerSummary.project.id) {
      return;
    }

    _reset(clearQueue: true);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _referenceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final records = widget.service.evidenceTargets(widget.registerSummary);
    if (records.isEmpty) {
      return const AppInfoRow(
        title: 'Decision evidence intake unavailable',
        subtitle: 'Create a decision before attaching proof and references.',
        icon: Icons.upload_file_outlined,
        iconStyle: AppInfoRowIconStyle.badge,
        contained: true,
      );
    }

    final selectedRecord =
        widget.service.recordFor(widget.registerSummary, _draft.recordId) ??
        records.first;
    final colorScheme = Theme.of(context).colorScheme;
    final confidenceColor = _draft.confidence.color(colorScheme);
    final evidenceLabel = widget.service.evidenceLabelFor(_draft);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProjectWorkflowHeader(
          title: 'Decision evidence intake',
          subtitle:
              '${selectedRecord.title} - ${_submissions.length} queued evidence items - $evidenceLabel',
          icon: Icons.upload_file_outlined,
          color: confidenceColor,
          statusLabel: _draft.confidence.label,
          statusIcon: _draft.confidence.icon,
          statusMaxWidth: 128,
        ),
        const SizedBox(height: 12),
        _DecisionEvidenceIntakeFields(
          draft: _draft,
          records: records,
          selectedRecord: selectedRecord,
          titleController: _titleController,
          referenceController: _referenceController,
          noteController: _noteController,
          onRecordChanged: _selectRecord,
          onDraftChanged: _updateDraft,
        ),
        ProjectWorkflowIssueSection<ProjectDecisionEvidenceIntakeIssue>(
          items: _issues,
          fieldFor: (issue) => issue.field,
          messageFor: (issue) => issue.message,
        ),
        const SizedBox(height: 12),
        _DecisionEvidenceIntakePreview(
          draft: _draft,
          record: selectedRecord,
          evidenceLabel: evidenceLabel,
        ),
        const SizedBox(height: 12),
        ProjectWorkflowSubmissionSection<
          ProjectDecisionEvidenceIntakeSubmission
        >(
          submitLabel: 'Queue Evidence',
          submitIcon: Icons.fact_check_outlined,
          onReset: () => _reset(clearQueue: false),
          onSubmit: _queueEvidence,
          items: _submissions,
          emptyTitle: 'Evidence queue empty',
          emptySubtitle: 'Queued evidence intake submissions will appear here.',
          titleFor: (submission) => submission.title,
          subtitleFor:
              (submission) =>
                  '${submission.record.title} - ${submission.evidenceLabel} - '
                  'Ref: ${submission.reference}',
          iconFor: (submission) => submission.kind.icon,
          colorFor:
              (context, submission) =>
                  submission.confidence.color(Theme.of(context).colorScheme),
          statusColorFor:
              (context, submission) =>
                  submission.confidence.color(Theme.of(context).colorScheme),
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

  void _updateDraft(ProjectDecisionEvidenceIntakeDraft draft) {
    setState(() {
      _draft = draft;
      _issues = const [];
    });
  }

  void _queueEvidence() {
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
          .draftForRecord(submission.record)
          .copyWith(kind: _draft.kind, confidence: _draft.confidence);
      _syncControllers();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Decision evidence queued: ${submission.title}')),
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
    _titleController.text = _draft.title;
    _referenceController.text = _draft.reference;
    _noteController.text = _draft.note;
  }
}

/// Select and text fields for one decision evidence intake draft.
class _DecisionEvidenceIntakeFields extends StatelessWidget {
  const _DecisionEvidenceIntakeFields({
    required this.draft,
    required this.records,
    required this.selectedRecord,
    required this.titleController,
    required this.referenceController,
    required this.noteController,
    required this.onRecordChanged,
    required this.onDraftChanged,
  });

  final ProjectDecisionEvidenceIntakeDraft draft;
  final List<ProjectDecisionRecord> records;
  final ProjectDecisionRecord selectedRecord;
  final TextEditingController titleController;
  final TextEditingController referenceController;
  final TextEditingController noteController;
  final ValueChanged<String> onRecordChanged;
  final ValueChanged<ProjectDecisionEvidenceIntakeDraft> onDraftChanged;

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
                menuMaxHeight: 320,
                options: [
                  for (final record in records)
                    AppSelectOption(value: record.id, label: record.title),
                ],
                onChanged: onRecordChanged,
              ),
              AppSelectField<ProjectDecisionEvidenceIntakeKind>(
                width: 230,
                label: 'Evidence type',
                value: draft.kind,
                icon: draft.kind.icon,
                options: [
                  for (final kind in ProjectDecisionEvidenceIntakeKind.values)
                    AppSelectOption(value: kind, label: kind.label),
                ],
                onChanged:
                    (value) => onDraftChanged(draft.copyWith(kind: value)),
              ),
              AppSelectField<ProjectDecisionEvidenceConfidence>(
                width: 220,
                label: 'Confidence',
                value: draft.confidence,
                icon: draft.confidence.icon,
                options: [
                  for (final confidence
                      in ProjectDecisionEvidenceConfidence.values)
                    AppSelectOption(value: confidence, label: confidence.label),
                ],
                onChanged:
                    (value) =>
                        onDraftChanged(draft.copyWith(confidence: value)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ProjectWorkflowTextField(
                fieldKey: const ValueKey('decision-evidence-title'),
                width: 360,
                controller: titleController,
                label: 'Evidence title',
                icon: Icons.rule_folder_outlined,
                textInputAction: TextInputAction.next,
                onChanged:
                    (value) => onDraftChanged(draft.copyWith(title: value)),
              ),
              ProjectWorkflowTextField(
                fieldKey: const ValueKey('decision-evidence-reference'),
                width: 300,
                controller: referenceController,
                label: 'Reference',
                icon: Icons.link_outlined,
                textInputAction: TextInputAction.next,
                onChanged:
                    (value) => onDraftChanged(draft.copyWith(reference: value)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ProjectWorkflowTextField(
            fieldKey: const ValueKey('decision-evidence-note'),
            controller: noteController,
            minLines: 3,
            maxLines: 5,
            label: 'Evidence note',
            icon: Icons.notes_outlined,
            onChanged: (value) => onDraftChanged(draft.copyWith(note: value)),
          ),
        ],
      ),
    );
  }
}

/// Live preview for the selected evidence intake draft.
class _DecisionEvidenceIntakePreview extends StatelessWidget {
  const _DecisionEvidenceIntakePreview({
    required this.draft,
    required this.record,
    required this.evidenceLabel,
  });

  final ProjectDecisionEvidenceIntakeDraft draft;
  final ProjectDecisionRecord record;
  final String evidenceLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final confidenceColor = draft.confidence.color(colorScheme);
    final reference =
        draft.reference.trim().isEmpty ? 'Pending reference' : draft.reference;

    return AppInfoRow(
      title:
          draft.title.trim().isEmpty ? 'Evidence intake preview' : draft.title,
      subtitle:
          '${record.title} - $evidenceLabel - Ref: $reference - '
          '${record.status.label} / ${record.source.label}',
      icon: draft.kind.icon,
      iconStyle: AppInfoRowIconStyle.badge,
      contained: true,
      iconBackgroundColor: confidenceColor.withValues(alpha: 0.12),
      iconForegroundColor: confidenceColor,
      titleMaxLines: 2,
      subtitleMaxLines: 3,
      trailing: AppStatusPill(
        label: record.status.label,
        icon: record.status.icon,
        color: record.status.color(colorScheme),
        maxWidth: 118,
      ),
    );
  }
}

@Preview(name: 'Project decision evidence intake panel')
Widget projectDecisionEvidenceIntakePanelPreview() {
  final workspace = buildProjectDecisionsWorkspaceSummary(
    project: demoProjectPortfolio.first,
    dependencyTasks: const [],
    today: DateTime(2026, 6, 11),
  );

  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ProjectDecisionEvidenceIntakePanel(
          registerSummary: workspace.decisionRegisterSummary,
        ),
      ),
    ),
  );
}
