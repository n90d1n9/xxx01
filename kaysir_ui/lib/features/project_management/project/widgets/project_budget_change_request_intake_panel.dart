import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_select_field.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';
import 'package:kaysir/widgets/ui/app_surface.dart';

import '../data/project_portfolio_repository.dart';
import '../services/project_budget_change_request_intake_service.dart';
import '../services/project_budget_change_workspace_service.dart';
import '../services/project_finance_workspace_service.dart';
import 'project_workflow_header.dart';
import 'project_workflow_issue_list.dart';
import 'project_workflow_submission_section.dart';
import 'project_workflow_text_field.dart';

/// Interactive intake flow for creating project budget change requests.
class ProjectBudgetChangeRequestIntakePanel extends StatefulWidget {
  const ProjectBudgetChangeRequestIntakePanel({
    required this.summary,
    this.service = const ProjectBudgetChangeRequestIntakeService(),
    super.key,
  });

  final ProjectBudgetChangeWorkspaceSummary summary;
  final ProjectBudgetChangeRequestIntakeService service;

  @override
  State<ProjectBudgetChangeRequestIntakePanel> createState() =>
      _ProjectBudgetChangeRequestIntakePanelState();
}

/// Maintains local budget change request controllers and queue state.
class _ProjectBudgetChangeRequestIntakePanelState
    extends State<ProjectBudgetChangeRequestIntakePanel> {
  late ProjectBudgetChangeRequestDraft _draft;
  late final TextEditingController _titleController;
  late final TextEditingController _ownerController;
  late final TextEditingController _amountController;
  late final TextEditingController _impactController;
  late final TextEditingController _evidenceController;
  var _issues = const <ProjectBudgetChangeRequestIssue>[];
  var _submissions = const <ProjectBudgetChangeRequestSubmission>[];

  @override
  void initState() {
    super.initState();
    _draft = widget.service.initialDraft(widget.summary);
    _titleController = TextEditingController(text: _draft.title);
    _ownerController = TextEditingController(text: _draft.owner);
    _amountController = TextEditingController(text: _draft.amountText);
    _impactController = TextEditingController(text: _draft.impactNote);
    _evidenceController = TextEditingController(text: _draft.evidenceNote);
  }

  @override
  void didUpdateWidget(
    covariant ProjectBudgetChangeRequestIntakePanel oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.summary.projectId == widget.summary.projectId) return;

    _reset(clearQueue: true);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _ownerController.dispose();
    _amountController.dispose();
    _impactController.dispose();
    _evidenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final routeLabel = widget.service.routeLabelFor(
      summary: widget.summary,
      draft: _draft,
    );
    final levelColor = widget.summary.level.color(colorScheme);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProjectWorkflowHeader(
          title: 'Budget change request flow',
          subtitle:
              '${widget.summary.projectName} - ${_submissions.length} queued changes - $routeLabel',
          icon: Icons.rule_folder_outlined,
          color: levelColor,
          statusLabel: routeLabel,
          statusIcon: Icons.route_outlined,
          statusMaxWidth: 142,
        ),
        const SizedBox(height: 12),
        _BudgetChangeRequestFields(
          draft: _draft,
          titleController: _titleController,
          ownerController: _ownerController,
          amountController: _amountController,
          impactController: _impactController,
          evidenceController: _evidenceController,
          onDraftChanged: _updateDraft,
        ),
        ProjectWorkflowIssueSection<ProjectBudgetChangeRequestIssue>(
          items: _issues,
          fieldFor: (issue) => issue.field,
          messageFor: (issue) => issue.message,
        ),
        const SizedBox(height: 12),
        _BudgetChangeRequestPreview(
          summary: widget.summary,
          draft: _draft,
          routeLabel: routeLabel,
          service: widget.service,
        ),
        const SizedBox(height: 12),
        ProjectWorkflowSubmissionSection<ProjectBudgetChangeRequestSubmission>(
          submitLabel: 'Queue Change',
          submitIcon: Icons.request_quote_outlined,
          onReset: () => _reset(clearQueue: false),
          onSubmit: _queueChange,
          items: _submissions,
          emptyTitle: 'Budget change queue empty',
          emptySubtitle: 'Queued variation requests will appear here.',
          titleFor: (submission) => submission.request.title,
          subtitleFor:
              (submission) =>
                  '${submission.request.requestedAmountLabel} - '
                  '${submission.request.kind.label} - ${submission.routeLabel} - '
                  'Owner: ${submission.request.ownerLabel}',
          iconFor: (submission) => submission.request.kind.icon,
          colorFor: (context, _) => Theme.of(context).colorScheme.primary,
        ),
      ],
    );
  }

  void _updateDraft(ProjectBudgetChangeRequestDraft draft) {
    setState(() {
      _draft = draft;
      _issues = const [];
    });
  }

  void _queueChange() {
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
          .initialDraft(widget.summary)
          .copyWith(
            kind: _draft.kind,
            reviewOption: _draft.reviewOption,
            owner: _draft.owner,
          );
      _syncControllers();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Budget change queued: ${submission.request.title}'),
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
    _amountController.text = _draft.amountText;
    _impactController.text = _draft.impactNote;
    _evidenceController.text = _draft.evidenceNote;
  }
}

/// Form fields for one budget change request draft.
class _BudgetChangeRequestFields extends StatelessWidget {
  const _BudgetChangeRequestFields({
    required this.draft,
    required this.titleController,
    required this.ownerController,
    required this.amountController,
    required this.impactController,
    required this.evidenceController,
    required this.onDraftChanged,
  });

  final ProjectBudgetChangeRequestDraft draft;
  final TextEditingController titleController;
  final TextEditingController ownerController;
  final TextEditingController amountController;
  final TextEditingController impactController;
  final TextEditingController evidenceController;
  final ValueChanged<ProjectBudgetChangeRequestDraft> onDraftChanged;

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProjectWorkflowTextField(
            fieldKey: const ValueKey('budget-change-request-title'),
            controller: titleController,
            label: 'Change title',
            icon: Icons.rule_folder_outlined,
            textInputAction: TextInputAction.next,
            onChanged: (value) => onDraftChanged(draft.copyWith(title: value)),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              AppSelectField<ProjectBudgetChangeKind>(
                width: 240,
                label: 'Type',
                value: draft.kind,
                icon: draft.kind.icon,
                options: [
                  for (final kind in ProjectBudgetChangeKind.values)
                    AppSelectOption(value: kind, label: kind.label),
                ],
                onChanged:
                    (value) => onDraftChanged(draft.copyWith(kind: value)),
              ),
              ProjectWorkflowTextField(
                fieldKey: const ValueKey('budget-change-request-owner'),
                width: 260,
                controller: ownerController,
                label: 'Owner',
                icon: Icons.account_circle_outlined,
                textInputAction: TextInputAction.next,
                onChanged:
                    (value) => onDraftChanged(draft.copyWith(owner: value)),
              ),
              ProjectWorkflowTextField(
                fieldKey: const ValueKey('budget-change-request-amount'),
                width: 220,
                controller: amountController,
                keyboardType: TextInputType.number,
                label: 'Amount',
                icon: Icons.account_balance_wallet_outlined,
                textInputAction: TextInputAction.next,
                onChanged:
                    (value) =>
                        onDraftChanged(draft.copyWith(amountText: value)),
              ),
              AppSelectField<ProjectBudgetChangeReviewOption>(
                width: 210,
                label: 'Review',
                value: draft.reviewOption,
                icon: draft.reviewOption.icon,
                options: [
                  for (final option in ProjectBudgetChangeReviewOption.values)
                    AppSelectOption(value: option, label: option.label),
                ],
                onChanged:
                    (value) =>
                        onDraftChanged(draft.copyWith(reviewOption: value)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ProjectWorkflowTextField(
            fieldKey: const ValueKey('budget-change-request-impact'),
            controller: impactController,
            minLines: 3,
            maxLines: 5,
            label: 'Impact note',
            icon: Icons.insights_outlined,
            textInputAction: TextInputAction.next,
            onChanged:
                (value) => onDraftChanged(draft.copyWith(impactNote: value)),
          ),
          const SizedBox(height: 12),
          ProjectWorkflowTextField(
            fieldKey: const ValueKey('budget-change-request-evidence'),
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

/// Live preview for the selected budget change request route.
class _BudgetChangeRequestPreview extends StatelessWidget {
  const _BudgetChangeRequestPreview({
    required this.summary,
    required this.draft,
    required this.routeLabel,
    required this.service,
  });

  final ProjectBudgetChangeWorkspaceSummary summary;
  final ProjectBudgetChangeRequestDraft draft;
  final String routeLabel;
  final ProjectBudgetChangeRequestIntakeService service;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final levelColor = summary.level.color(colorScheme);
    final amount = service.amountFor(draft);
    final amountLabel = amount == null ? 'Pending amount' : _money(amount);
    final reviewDate = service.reviewDateFor(
      summary: summary,
      option: draft.reviewOption,
    );

    return AppInfoRow(
      title:
          draft.title.trim().isEmpty
              ? 'Budget change request preview'
              : draft.title,
      subtitle:
          '$amountLabel - ${draft.kind.label} - $routeLabel - '
          'Owner: ${draft.owner.trim().isEmpty ? 'Unassigned' : draft.owner} - Review ${_dateLabel(reviewDate)}',
      icon: draft.kind.icon,
      iconStyle: AppInfoRowIconStyle.badge,
      contained: true,
      iconBackgroundColor: levelColor.withValues(alpha: 0.12),
      iconForegroundColor: levelColor,
      titleMaxLines: 2,
      subtitleMaxLines: 3,
      trailing: AppStatusPill(
        label: summary.level.label,
        icon: summary.level.icon,
        color: levelColor,
        maxWidth: 112,
      ),
    );
  }
}

String _money(double value) {
  if (value <= 0) return '-';
  if (value >= 1000000000) {
    return '${(value / 1000000000).toStringAsFixed(1)}B';
  }
  if (value >= 1000000) {
    return '${(value / 1000000).toStringAsFixed(1)}M';
  }
  if (value >= 1000) {
    return '${(value / 1000).toStringAsFixed(0)}K';
  }
  return value.toStringAsFixed(0);
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

@Preview(name: 'Project budget change request intake panel')
Widget projectBudgetChangeRequestIntakePanelPreview() {
  final project =
      const ProjectPortfolioRepository().findById('warehouse-automation')!;
  final workspace = buildProjectFinanceWorkspaceSummary(project);

  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ProjectBudgetChangeRequestIntakePanel(
          summary: buildProjectBudgetChangeWorkspaceSummary(workspace),
        ),
      ),
    ),
  );
}
