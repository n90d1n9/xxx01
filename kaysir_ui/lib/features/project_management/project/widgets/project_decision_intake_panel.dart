import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_select_field.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';
import 'package:kaysir/widgets/ui/app_surface.dart';

import '../data/project_portfolio_repository.dart';
import '../models/project_decision_record.dart';
import '../services/project_decision_intake_service.dart';
import '../services/project_decision_register_service.dart';
import '../services/project_decisions_workspace_service.dart';
import 'project_workflow_header.dart';
import 'project_workflow_issue_list.dart';
import 'project_workflow_submission_section.dart';
import 'project_workflow_text_field.dart';

/// Interactive decision intake flow with validation and local draft queue.
class ProjectDecisionIntakePanel extends StatefulWidget {
  const ProjectDecisionIntakePanel({
    required this.registerSummary,
    this.service = const ProjectDecisionIntakeService(),
    super.key,
  });

  final ProjectDecisionRegisterSummary registerSummary;
  final ProjectDecisionIntakeService service;

  @override
  State<ProjectDecisionIntakePanel> createState() =>
      _ProjectDecisionIntakePanelState();
}

/// Maintains local intake form controllers and demo draft queue state.
class _ProjectDecisionIntakePanelState
    extends State<ProjectDecisionIntakePanel> {
  late ProjectDecisionIntakeDraft _draft;
  late final TextEditingController _titleController;
  late final TextEditingController _detailController;
  late final TextEditingController _ownerController;
  late final TextEditingController _evidenceController;
  var _issues = const <ProjectDecisionIntakeIssue>[];
  var _submissions = const <ProjectDecisionIntakeSubmission>[];

  @override
  void initState() {
    super.initState();
    _draft = ProjectDecisionIntakeDraft.initial(widget.registerSummary);
    _titleController = TextEditingController(text: _draft.title);
    _detailController = TextEditingController(text: _draft.detail);
    _ownerController = TextEditingController(text: _draft.owner);
    _evidenceController = TextEditingController(text: _draft.evidenceLabel);
  }

  @override
  void didUpdateWidget(covariant ProjectDecisionIntakePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.registerSummary.project.id ==
        widget.registerSummary.project.id) {
      return;
    }

    _resetDraft(clearQueue: true);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _detailController.dispose();
    _ownerController.dispose();
    _evidenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final routeLabel = widget.service.routeLabelFor(_draft);
    final canSubmit = _issues.isEmpty;
    final routeColor =
        routeLabel == 'Sponsor route'
            ? colorScheme.error
            : routeLabel == 'Approval route'
            ? Colors.orange.shade700
            : colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProjectWorkflowHeader(
          title: 'Decision intake flow',
          subtitle:
              '${widget.registerSummary.project.name} - ${_submissions.length} queued drafts - $routeLabel',
          icon: Icons.post_add_outlined,
          color: routeColor,
          statusLabel: routeLabel,
          statusIcon: Icons.route_outlined,
        ),
        const SizedBox(height: 12),
        _DecisionIntakeFields(
          draft: _draft,
          titleController: _titleController,
          detailController: _detailController,
          ownerController: _ownerController,
          evidenceController: _evidenceController,
          onDraftChanged: _updateDraft,
        ),
        ProjectWorkflowIssueSection<ProjectDecisionIntakeIssue>(
          items: _issues,
          fieldFor: (issue) => issue.field,
          messageFor: (issue) => issue.message,
        ),
        const SizedBox(height: 12),
        _DecisionIntakePreview(
          draft: _draft,
          routeLabel: routeLabel,
          canSubmit: canSubmit,
        ),
        const SizedBox(height: 12),
        ProjectWorkflowSubmissionSection<ProjectDecisionIntakeSubmission>(
          submitLabel: 'Submit Draft',
          submitIcon: Icons.add_task_outlined,
          onReset: () => _resetDraft(clearQueue: false),
          onSubmit: _submitDraft,
          items: _submissions,
          emptyTitle: 'Draft queue empty',
          emptySubtitle: 'Submitted decision drafts will appear here.',
          titleFor: (submission) => submission.record.title,
          subtitleFor:
              (submission) =>
                  '${submission.routeLabel} - ${submission.record.status.label} - '
                  '${submission.record.ownerText} - ${submission.record.dueDateLabel}',
          iconFor: (submission) => submission.record.source.icon,
          colorFor:
              (context, submission) => submission.record.priority.color(
                Theme.of(context).colorScheme,
              ),
          statusColorFor:
              (context, submission) => submission.record.priority.color(
                Theme.of(context).colorScheme,
              ),
        ),
      ],
    );
  }

  void _updateDraft(ProjectDecisionIntakeDraft draft) {
    setState(() {
      _draft = draft;
      _issues = const [];
    });
  }

  void _submitDraft() {
    final issues = widget.service.validate(_draft);
    if (issues.isNotEmpty) {
      setState(() => _issues = issues);
      return;
    }

    final submission = widget.service.submit(
      register: widget.registerSummary,
      draft: _draft,
      queueIndex: _submissions.length + 1,
    );
    setState(() {
      _submissions = [submission, ..._submissions];
      _issues = const [];
      _draft = ProjectDecisionIntakeDraft.initial(
        widget.registerSummary,
      ).copyWith(
        source: _draft.source,
        priority: _draft.priority,
        status: _draft.status,
        dueOption: _draft.dueOption,
      );
      _syncControllers();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Decision draft queued: ${submission.record.title}'),
      ),
    );
  }

  void _resetDraft({required bool clearQueue}) {
    setState(() {
      _draft = ProjectDecisionIntakeDraft.initial(widget.registerSummary);
      _issues = const [];
      if (clearQueue) _submissions = const [];
      _syncControllers();
    });
  }

  void _syncControllers() {
    _titleController.text = _draft.title;
    _detailController.text = _draft.detail;
    _ownerController.text = _draft.owner;
    _evidenceController.text = _draft.evidenceLabel;
  }
}

/// Text and select fields that capture a decision intake draft.
class _DecisionIntakeFields extends StatelessWidget {
  const _DecisionIntakeFields({
    required this.draft,
    required this.titleController,
    required this.detailController,
    required this.ownerController,
    required this.evidenceController,
    required this.onDraftChanged,
  });

  final ProjectDecisionIntakeDraft draft;
  final TextEditingController titleController;
  final TextEditingController detailController;
  final TextEditingController ownerController;
  final TextEditingController evidenceController;
  final ValueChanged<ProjectDecisionIntakeDraft> onDraftChanged;

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProjectWorkflowTextField(
            fieldKey: const ValueKey('decision-intake-title'),
            controller: titleController,
            label: 'Decision title',
            icon: Icons.rule_folder_outlined,
            textInputAction: TextInputAction.next,
            onChanged: (value) => onDraftChanged(draft.copyWith(title: value)),
          ),
          const SizedBox(height: 12),
          ProjectWorkflowTextField(
            fieldKey: const ValueKey('decision-intake-detail'),
            controller: detailController,
            label: 'Decision context',
            icon: Icons.notes_outlined,
            minLines: 3,
            maxLines: 5,
            onChanged: (value) => onDraftChanged(draft.copyWith(detail: value)),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ProjectWorkflowTextField(
                fieldKey: const ValueKey('decision-intake-owner'),
                width: 260,
                controller: ownerController,
                label: 'Owner',
                icon: Icons.account_circle_outlined,
                textInputAction: TextInputAction.next,
                onChanged:
                    (value) => onDraftChanged(draft.copyWith(owner: value)),
              ),
              ProjectWorkflowTextField(
                fieldKey: const ValueKey('decision-intake-evidence'),
                width: 260,
                controller: evidenceController,
                label: 'Evidence',
                icon: Icons.fact_check_outlined,
                textInputAction: TextInputAction.done,
                onChanged:
                    (value) =>
                        onDraftChanged(draft.copyWith(evidenceLabel: value)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              AppSelectField<ProjectDecisionSource>(
                width: 220,
                label: 'Source',
                value: draft.source,
                icon: draft.source.icon,
                options: [
                  for (final source in ProjectDecisionSource.values)
                    AppSelectOption(value: source, label: source.label),
                ],
                onChanged:
                    (value) => onDraftChanged(draft.copyWith(source: value)),
              ),
              AppSelectField<ProjectDecisionStatus>(
                width: 220,
                label: 'Status',
                value: draft.status,
                icon: draft.status.icon,
                options: [
                  for (final status in ProjectDecisionStatus.values)
                    AppSelectOption(value: status, label: status.label),
                ],
                onChanged:
                    (value) => onDraftChanged(draft.copyWith(status: value)),
              ),
              AppSelectField<ProjectDecisionPriority>(
                width: 220,
                label: 'Priority',
                value: draft.priority,
                icon: draft.priority.icon,
                options: [
                  for (final priority in ProjectDecisionPriority.values)
                    AppSelectOption(value: priority, label: priority.label),
                ],
                onChanged:
                    (value) => onDraftChanged(draft.copyWith(priority: value)),
              ),
              AppSelectField<ProjectDecisionIntakeDueOption>(
                width: 220,
                label: 'Due',
                value: draft.dueOption,
                icon: draft.dueOption.icon,
                options: [
                  for (final option in ProjectDecisionIntakeDueOption.values)
                    AppSelectOption(value: option, label: option.label),
                ],
                onChanged:
                    (value) => onDraftChanged(draft.copyWith(dueOption: value)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Live preview card for the current decision intake draft.
class _DecisionIntakePreview extends StatelessWidget {
  const _DecisionIntakePreview({
    required this.draft,
    required this.routeLabel,
    required this.canSubmit,
  });

  final ProjectDecisionIntakeDraft draft;
  final String routeLabel;
  final bool canSubmit;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final priorityColor = draft.priority.color(colorScheme);

    return AppInfoRow(
      title:
          draft.title.trim().isEmpty ? 'Decision draft preview' : draft.title,
      subtitle:
          '${draft.status.label} - ${draft.priority.label} - '
          '${draft.dueOption.label} - Owner: ${draft.owner.trim().isEmpty ? 'Unassigned' : draft.owner} - $routeLabel',
      icon: canSubmit ? Icons.preview_outlined : Icons.edit_note_outlined,
      iconStyle: AppInfoRowIconStyle.badge,
      contained: true,
      iconBackgroundColor: priorityColor.withValues(alpha: 0.12),
      iconForegroundColor: priorityColor,
      titleMaxLines: 2,
      subtitleMaxLines: 3,
      trailing: AppStatusPill(
        label: draft.priority.label,
        icon: draft.priority.icon,
        color: priorityColor,
        maxWidth: 112,
      ),
    );
  }
}

@Preview(name: 'Project decision intake panel')
Widget projectDecisionIntakePanelPreview() {
  final workspace = buildProjectDecisionsWorkspaceSummary(
    project: demoProjectPortfolio.first,
    dependencyTasks: const [],
    today: DateTime(2026, 6, 11),
  );

  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ProjectDecisionIntakePanel(
          registerSummary: workspace.decisionRegisterSummary,
        ),
      ),
    ),
  );
}
