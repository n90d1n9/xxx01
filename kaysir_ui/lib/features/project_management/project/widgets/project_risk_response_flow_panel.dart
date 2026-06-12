import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_select_field.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';
import 'package:kaysir/widgets/ui/app_surface.dart';

import '../data/project_portfolio_repository.dart';
import '../services/project_finance_workspace_service.dart';
import '../services/project_risk_issue_workspace_service.dart';
import '../services/project_risk_response_flow_service.dart';
import 'project_workflow_header.dart';
import 'project_workflow_issue_list.dart';
import 'project_workflow_submission_section.dart';
import 'project_workflow_text_field.dart';

/// Interactive flow for queueing mitigation, recovery, and escalation work.
class ProjectRiskResponseFlowPanel extends StatefulWidget {
  const ProjectRiskResponseFlowPanel({
    required this.summary,
    this.service = const ProjectRiskResponseFlowService(),
    super.key,
  });

  final ProjectRiskIssueWorkspaceSummary summary;
  final ProjectRiskResponseFlowService service;

  @override
  State<ProjectRiskResponseFlowPanel> createState() =>
      _ProjectRiskResponseFlowPanelState();
}

/// Maintains local risk response controllers and queued response state.
class _ProjectRiskResponseFlowPanelState
    extends State<ProjectRiskResponseFlowPanel> {
  late ProjectRiskResponseDraft _draft;
  late final TextEditingController _titleController;
  late final TextEditingController _ownerController;
  late final TextEditingController _responseController;
  late final TextEditingController _evidenceController;
  var _issues = const <ProjectRiskResponseIssue>[];
  var _submissions = const <ProjectRiskResponseSubmission>[];

  @override
  void initState() {
    super.initState();
    _draft = widget.service.initialDraft(widget.summary);
    _titleController = TextEditingController(text: _draft.title);
    _ownerController = TextEditingController(text: _draft.owner);
    _responseController = TextEditingController(text: _draft.responseNote);
    _evidenceController = TextEditingController(text: _draft.evidenceNote);
  }

  @override
  void didUpdateWidget(covariant ProjectRiskResponseFlowPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.summary.projectId == widget.summary.projectId) return;

    _reset(clearQueue: true);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _ownerController.dispose();
    _responseController.dispose();
    _evidenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.service.actionableItems(widget.summary);
    if (items.isEmpty) {
      return const AppInfoRow(
        title: 'Risk response flow unavailable',
        subtitle: 'Create risk or issue records before queueing responses.',
        icon: Icons.health_and_safety_outlined,
        iconStyle: AppInfoRowIconStyle.badge,
        contained: true,
      );
    }

    final selectedItem =
        widget.service.itemFor(widget.summary, _draft.itemId) ?? items.first;
    final colorScheme = Theme.of(context).colorScheme;
    final modeColor = _draft.mode.color(colorScheme);
    final routeLabel = widget.service.routeLabelFor(
      item: selectedItem,
      mode: _draft.mode,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProjectWorkflowHeader(
          title: 'Risk response flow',
          subtitle:
              '${selectedItem.title} - ${_submissions.length} queued responses - $routeLabel',
          icon: Icons.health_and_safety_outlined,
          color: modeColor,
          statusLabel: _draft.mode.label,
          statusIcon: _draft.mode.icon,
          statusMaxWidth: 126,
        ),
        const SizedBox(height: 12),
        _RiskResponseFields(
          draft: _draft,
          items: items,
          selectedItem: selectedItem,
          titleController: _titleController,
          ownerController: _ownerController,
          responseController: _responseController,
          evidenceController: _evidenceController,
          onItemChanged: _selectItem,
          onDraftChanged: _updateDraft,
        ),
        ProjectWorkflowIssueSection<ProjectRiskResponseIssue>(
          items: _issues,
          fieldFor: (issue) => issue.field,
          messageFor: (issue) => issue.message,
        ),
        const SizedBox(height: 12),
        _RiskResponsePreview(
          item: selectedItem,
          draft: _draft,
          routeLabel: routeLabel,
          service: widget.service,
        ),
        const SizedBox(height: 12),
        ProjectWorkflowSubmissionSection<ProjectRiskResponseSubmission>(
          submitLabel: 'Queue Response',
          submitIcon: Icons.health_and_safety_outlined,
          onReset: () => _reset(clearQueue: false),
          onSubmit: _queueResponse,
          items: _submissions,
          emptyTitle: 'Risk response queue empty',
          emptySubtitle:
              'Queued mitigation and escalation responses will appear here.',
          titleFor: (submission) => submission.responseItem.title,
          subtitleFor:
              (submission) =>
                  '${submission.sourceItem.title} - ${submission.routeLabel} - '
                  'Owner: ${submission.responseItem.ownerLabel}',
          iconFor: (submission) => submission.mode.icon,
          colorFor:
              (context, submission) =>
                  submission.mode.color(Theme.of(context).colorScheme),
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

  void _updateDraft(ProjectRiskResponseDraft draft) {
    setState(() {
      _draft = draft;
      _issues = const [];
    });
  }

  void _queueResponse() {
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
      queueIndex: _submissions.length + 1,
    );
    setState(() {
      _submissions = [submission, ..._submissions];
      _issues = const [];
      _draft = widget.service
          .draftForItem(submission.sourceItem)
          .copyWith(mode: _draft.mode, owner: _draft.owner);
      _syncControllers();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Risk response queued: ${submission.responseItem.title}'),
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
    _titleController.text = _draft.title;
    _ownerController.text = _draft.owner;
    _responseController.text = _draft.responseNote;
    _evidenceController.text = _draft.evidenceNote;
  }
}

/// Select and text fields for one risk response draft.
class _RiskResponseFields extends StatelessWidget {
  const _RiskResponseFields({
    required this.draft,
    required this.items,
    required this.selectedItem,
    required this.titleController,
    required this.ownerController,
    required this.responseController,
    required this.evidenceController,
    required this.onItemChanged,
    required this.onDraftChanged,
  });

  final ProjectRiskResponseDraft draft;
  final List<ProjectRiskIssueItem> items;
  final ProjectRiskIssueItem selectedItem;
  final TextEditingController titleController;
  final TextEditingController ownerController;
  final TextEditingController responseController;
  final TextEditingController evidenceController;
  final ValueChanged<String> onItemChanged;
  final ValueChanged<ProjectRiskResponseDraft> onDraftChanged;

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
                label: 'Risk or issue',
                value: selectedItem.id,
                icon: selectedItem.icon,
                menuMaxHeight: 320,
                options: [
                  for (final item in items)
                    AppSelectOption(value: item.id, label: item.title),
                ],
                onChanged: onItemChanged,
              ),
              AppSelectField<ProjectRiskResponseMode>(
                width: 220,
                label: 'Response',
                value: draft.mode,
                icon: draft.mode.icon,
                options: [
                  for (final mode in ProjectRiskResponseMode.values)
                    AppSelectOption(value: mode, label: mode.label),
                ],
                onChanged:
                    (value) => onDraftChanged(draft.copyWith(mode: value)),
              ),
              AppSelectField<ProjectRiskResponseDueOption>(
                width: 220,
                label: 'Due',
                value: draft.dueOption,
                icon: draft.dueOption.icon,
                options: [
                  for (final option in ProjectRiskResponseDueOption.values)
                    AppSelectOption(value: option, label: option.label),
                ],
                onChanged:
                    (value) => onDraftChanged(draft.copyWith(dueOption: value)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ProjectWorkflowTextField(
            fieldKey: const ValueKey('risk-response-title'),
            controller: titleController,
            label: 'Response title',
            icon: Icons.health_and_safety_outlined,
            textInputAction: TextInputAction.next,
            onChanged: (value) => onDraftChanged(draft.copyWith(title: value)),
          ),
          const SizedBox(height: 12),
          ProjectWorkflowTextField(
            fieldKey: const ValueKey('risk-response-owner'),
            width: 320,
            controller: ownerController,
            label: 'Owner',
            icon: Icons.account_circle_outlined,
            textInputAction: TextInputAction.next,
            onChanged: (value) => onDraftChanged(draft.copyWith(owner: value)),
          ),
          const SizedBox(height: 12),
          ProjectWorkflowTextField(
            fieldKey: const ValueKey('risk-response-note'),
            controller: responseController,
            minLines: 3,
            maxLines: 5,
            label: 'Response note',
            icon: Icons.description_outlined,
            textInputAction: TextInputAction.next,
            onChanged:
                (value) => onDraftChanged(draft.copyWith(responseNote: value)),
          ),
          const SizedBox(height: 12),
          ProjectWorkflowTextField(
            fieldKey: const ValueKey('risk-response-evidence'),
            controller: evidenceController,
            minLines: 3,
            maxLines: 5,
            label: 'Evidence note',
            icon: Icons.fact_check_outlined,
            onChanged:
                (value) => onDraftChanged(draft.copyWith(evidenceNote: value)),
          ),
        ],
      ),
    );
  }
}

/// Live preview for the selected risk response route.
class _RiskResponsePreview extends StatelessWidget {
  const _RiskResponsePreview({
    required this.item,
    required this.draft,
    required this.routeLabel,
    required this.service,
  });

  final ProjectRiskIssueItem item;
  final ProjectRiskResponseDraft draft;
  final String routeLabel;
  final ProjectRiskResponseFlowService service;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final modeColor = draft.mode.color(colorScheme);
    final resultingLevel = service.resultingLevelFor(draft.mode);
    final dueDate = service.dueDateFor(draft.dueOption);
    final owner =
        draft.owner.trim().isEmpty ? 'Unassigned' : draft.owner.trim();

    return AppInfoRow(
      title:
          draft.title.trim().isEmpty
              ? 'Risk response preview'
              : draft.title.trim(),
      subtitle:
          '${item.title} - ${draft.mode.label} - $routeLabel - '
          'Owner: $owner - Due ${_dateLabel(dueDate)}',
      icon: draft.mode.icon,
      iconStyle: AppInfoRowIconStyle.badge,
      contained: true,
      iconBackgroundColor: modeColor.withValues(alpha: 0.12),
      iconForegroundColor: modeColor,
      titleMaxLines: 2,
      subtitleMaxLines: 3,
      trailing: AppStatusPill(
        label: resultingLevel.label,
        icon: resultingLevel.icon,
        color: resultingLevel.color(colorScheme),
        maxWidth: 112,
      ),
    );
  }
}

String _dateLabel(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

@Preview(name: 'Project risk response flow panel')
Widget projectRiskResponseFlowPanelPreview() {
  final project =
      const ProjectPortfolioRepository().findById('warehouse-automation')!;
  final workspace = buildProjectFinanceWorkspaceSummary(project);

  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ProjectRiskResponseFlowPanel(
          summary: buildProjectRiskIssueWorkspaceSummary(workspace),
        ),
      ),
    ),
  );
}
