import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_select_field.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';
import 'package:kaysir/widgets/ui/app_surface.dart';

import '../data/project_portfolio_repository.dart';
import '../services/project_approval_action_flow_service.dart';
import '../services/project_approval_workspace_service.dart';
import '../services/project_finance_workspace_service.dart';
import 'project_workflow_header.dart';
import 'project_workflow_issue_list.dart';
import 'project_workflow_submission_section.dart';
import 'project_workflow_text_field.dart';

/// Interactive approval action flow with validation and local queueing.
class ProjectApprovalActionFlowPanel extends StatefulWidget {
  const ProjectApprovalActionFlowPanel({
    required this.summary,
    this.service = const ProjectApprovalActionFlowService(),
    super.key,
  });

  final ProjectApprovalWorkspaceSummary summary;
  final ProjectApprovalActionFlowService service;

  @override
  State<ProjectApprovalActionFlowPanel> createState() =>
      _ProjectApprovalActionFlowPanelState();
}

/// Maintains local approval action controllers and queued outcomes.
class _ProjectApprovalActionFlowPanelState
    extends State<ProjectApprovalActionFlowPanel> {
  late ProjectApprovalActionDraft _draft;
  late final TextEditingController _approverController;
  late final TextEditingController _evidenceController;
  late final TextEditingController _noteController;
  var _issues = const <ProjectApprovalActionIssue>[];
  var _submissions = const <ProjectApprovalActionSubmission>[];

  @override
  void initState() {
    super.initState();
    _draft = widget.service.initialDraft(widget.summary);
    _approverController = TextEditingController(text: _draft.approver);
    _evidenceController = TextEditingController(text: _draft.evidenceRef);
    _noteController = TextEditingController(text: _draft.note);
  }

  @override
  void didUpdateWidget(covariant ProjectApprovalActionFlowPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.summary.projectId == widget.summary.projectId) return;

    _reset(clearQueue: true);
  }

  @override
  void dispose() {
    _approverController.dispose();
    _evidenceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.service.actionableItems(widget.summary);
    if (items.isEmpty) {
      return const AppInfoRow(
        title: 'Approval action flow unavailable',
        subtitle: 'Create approval records before queueing approval actions.',
        icon: Icons.verified_user_outlined,
        iconStyle: AppInfoRowIconStyle.badge,
        contained: true,
      );
    }

    final selectedItem =
        widget.service.itemFor(widget.summary, _draft.itemId) ?? items.first;
    final colorScheme = Theme.of(context).colorScheme;
    final outcomeColor = _draft.outcome.color(colorScheme);
    final routeLabel = widget.service.routeLabelFor(_draft.outcome);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProjectWorkflowHeader(
          title: 'Approval action flow',
          subtitle:
              '${selectedItem.title} - ${_submissions.length} queued actions - $routeLabel',
          icon: Icons.verified_user_outlined,
          color: outcomeColor,
          statusLabel: _draft.outcome.label,
          statusIcon: _draft.outcome.icon,
          statusMaxWidth: 136,
        ),
        const SizedBox(height: 12),
        _ApprovalActionFields(
          draft: _draft,
          items: items,
          selectedItem: selectedItem,
          approverController: _approverController,
          evidenceController: _evidenceController,
          noteController: _noteController,
          onItemChanged: _selectItem,
          onDraftChanged: _updateDraft,
        ),
        ProjectWorkflowIssueSection<ProjectApprovalActionIssue>(
          items: _issues,
          fieldFor: (issue) => issue.field,
          messageFor: (issue) => issue.message,
        ),
        const SizedBox(height: 12),
        _ApprovalActionPreview(
          item: selectedItem,
          outcome: _draft.outcome,
          resultingLevel: widget.service.resultingLevelFor(_draft.outcome),
          routeLabel: routeLabel,
        ),
        const SizedBox(height: 12),
        ProjectWorkflowSubmissionSection<ProjectApprovalActionSubmission>(
          submitLabel: 'Queue Action',
          submitIcon: Icons.approval_outlined,
          onReset: () => _reset(clearQueue: false),
          onSubmit: _queueAction,
          items: _submissions,
          emptyTitle: 'Approval action queue empty',
          emptySubtitle: 'Queued approval actions will appear here.',
          titleFor: (submission) => submission.item.title,
          subtitleFor:
              (submission) =>
                  '${submission.routeLabel} - ${submission.outcome.label} - '
                  '${submission.resultingLevel.label} - Approver: ${submission.approver}',
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

  void _selectItem(String itemId) {
    final item = widget.service.itemFor(widget.summary, itemId);
    if (item == null) return;

    setState(() {
      _draft = widget.service.draftForItem(item);
      _issues = const [];
      _syncControllers();
    });
  }

  void _updateDraft(ProjectApprovalActionDraft draft) {
    setState(() {
      _draft = draft;
      _issues = const [];
    });
  }

  void _queueAction() {
    final issues = widget.service.validate(
      summary: widget.summary,
      draft: _draft,
    );
    if (issues.isNotEmpty) {
      setState(() => _issues = issues);
      return;
    }

    final submission = widget.service.submit(
      summary: widget.summary,
      draft: _draft,
    );
    setState(() {
      _submissions = [submission, ..._submissions];
      _issues = const [];
      _draft = widget.service
          .draftForItem(submission.item)
          .copyWith(outcome: _draft.outcome, approver: _draft.approver);
      _syncControllers();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Approval action queued: ${submission.item.title}'),
      ),
    );
  }

  void _reset({required bool clearQueue}) {
    setState(() {
      _draft = widget.service.initialDraft(widget.summary);
      _issues = const [];
      if (clearQueue) _submissions = const [];
      _syncControllers();
    });
  }

  void _syncControllers() {
    _approverController.text = _draft.approver;
    _evidenceController.text = _draft.evidenceRef;
    _noteController.text = _draft.note;
  }
}

/// Select and text fields for one approval action draft.
class _ApprovalActionFields extends StatelessWidget {
  const _ApprovalActionFields({
    required this.draft,
    required this.items,
    required this.selectedItem,
    required this.approverController,
    required this.evidenceController,
    required this.noteController,
    required this.onItemChanged,
    required this.onDraftChanged,
  });

  final ProjectApprovalActionDraft draft;
  final List<ProjectApprovalWorkspaceItem> items;
  final ProjectApprovalWorkspaceItem selectedItem;
  final TextEditingController approverController;
  final TextEditingController evidenceController;
  final TextEditingController noteController;
  final ValueChanged<String> onItemChanged;
  final ValueChanged<ProjectApprovalActionDraft> onDraftChanged;

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
                label: 'Approval item',
                value: selectedItem.id,
                icon: selectedItem.icon,
                menuMaxHeight: 320,
                options: [
                  for (final item in items)
                    AppSelectOption(value: item.id, label: item.title),
                ],
                onChanged: onItemChanged,
              ),
              AppSelectField<ProjectApprovalActionOutcome>(
                width: 230,
                label: 'Outcome',
                value: draft.outcome,
                icon: draft.outcome.icon,
                options: [
                  for (final outcome in ProjectApprovalActionOutcome.values)
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
                fieldKey: const ValueKey('approval-action-approver'),
                width: 280,
                controller: approverController,
                label: 'Approver',
                icon: Icons.account_circle_outlined,
                textInputAction: TextInputAction.next,
                onChanged:
                    (value) => onDraftChanged(draft.copyWith(approver: value)),
              ),
              ProjectWorkflowTextField(
                fieldKey: const ValueKey('approval-action-evidence'),
                width: 340,
                controller: evidenceController,
                label: 'Evidence',
                icon: Icons.fact_check_outlined,
                textInputAction: TextInputAction.next,
                onChanged:
                    (value) =>
                        onDraftChanged(draft.copyWith(evidenceRef: value)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ProjectWorkflowTextField(
            fieldKey: const ValueKey('approval-action-note'),
            controller: noteController,
            minLines: 3,
            maxLines: 5,
            label: 'Action note',
            icon: Icons.notes_outlined,
            onChanged: (value) => onDraftChanged(draft.copyWith(note: value)),
          ),
        ],
      ),
    );
  }
}

/// Live preview for the selected approval action outcome.
class _ApprovalActionPreview extends StatelessWidget {
  const _ApprovalActionPreview({
    required this.item,
    required this.outcome,
    required this.resultingLevel,
    required this.routeLabel,
  });

  final ProjectApprovalWorkspaceItem item;
  final ProjectApprovalActionOutcome outcome;
  final ProjectApprovalWorkspaceLevel resultingLevel;
  final String routeLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final outcomeColor = outcome.color(colorScheme);

    return AppInfoRow(
      title: item.title,
      subtitle:
          '${item.level.label} -> ${resultingLevel.label} - ${outcome.label} - $routeLabel',
      icon: outcome.icon,
      iconStyle: AppInfoRowIconStyle.badge,
      contained: true,
      iconBackgroundColor: outcomeColor.withValues(alpha: 0.12),
      iconForegroundColor: outcomeColor,
      titleMaxLines: 2,
      subtitleMaxLines: 3,
      trailing: AppStatusPill(
        label: resultingLevel.label,
        icon: resultingLevel.icon,
        color: resultingLevel.color(colorScheme),
        maxWidth: 116,
      ),
    );
  }
}

@Preview(name: 'Project approval action flow panel')
Widget projectApprovalActionFlowPanelPreview() {
  final project =
      const ProjectPortfolioRepository().findById('warehouse-automation')!;
  final workspace = buildProjectFinanceWorkspaceSummary(project);

  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ProjectApprovalActionFlowPanel(
          summary: buildProjectApprovalWorkspaceSummary(workspace),
        ),
      ),
    ),
  );
}
