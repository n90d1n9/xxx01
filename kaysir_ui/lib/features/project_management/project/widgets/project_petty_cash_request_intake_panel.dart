import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_select_field.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';
import 'package:kaysir/widgets/ui/app_surface.dart';

import '../data/project_portfolio_repository.dart';
import '../services/project_finance_workspace_service.dart';
import '../services/project_petty_cash_request_intake_service.dart';
import '../services/project_petty_cash_workspace_service.dart';
import 'project_workflow_header.dart';
import 'project_workflow_issue_list.dart';
import 'project_workflow_submission_section.dart';
import 'project_workflow_text_field.dart';

/// Interactive petty-cash request intake flow with validation and queueing.
class ProjectPettyCashRequestIntakePanel extends StatefulWidget {
  const ProjectPettyCashRequestIntakePanel({
    required this.summary,
    this.service = const ProjectPettyCashRequestIntakeService(),
    super.key,
  });

  final ProjectPettyCashWorkspaceSummary summary;
  final ProjectPettyCashRequestIntakeService service;

  @override
  State<ProjectPettyCashRequestIntakePanel> createState() =>
      _ProjectPettyCashRequestIntakePanelState();
}

/// Maintains local petty-cash request controllers and demo queue state.
class _ProjectPettyCashRequestIntakePanelState
    extends State<ProjectPettyCashRequestIntakePanel> {
  late ProjectPettyCashRequestDraft _draft;
  late final TextEditingController _titleController;
  late final TextEditingController _custodianController;
  late final TextEditingController _amountController;
  late final TextEditingController _evidenceController;
  var _issues = const <ProjectPettyCashRequestIssue>[];
  var _submissions = const <ProjectPettyCashRequestSubmission>[];

  @override
  void initState() {
    super.initState();
    _draft = widget.service.initialDraft(widget.summary);
    _titleController = TextEditingController(text: _draft.title);
    _custodianController = TextEditingController(text: _draft.custodian);
    _amountController = TextEditingController(text: _draft.amountText);
    _evidenceController = TextEditingController(text: _draft.evidenceNote);
  }

  @override
  void didUpdateWidget(covariant ProjectPettyCashRequestIntakePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.summary.projectId == widget.summary.projectId) return;

    _reset(clearQueue: true);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _custodianController.dispose();
    _amountController.dispose();
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
          title: 'Petty cash request flow',
          subtitle:
              '${widget.summary.projectName} - ${_submissions.length} queued requests - $routeLabel',
          icon: Icons.add_card_outlined,
          color: levelColor,
          statusLabel: routeLabel,
          statusIcon: Icons.route_outlined,
          statusMaxWidth: 142,
        ),
        const SizedBox(height: 12),
        _PettyCashRequestFields(
          draft: _draft,
          titleController: _titleController,
          custodianController: _custodianController,
          amountController: _amountController,
          evidenceController: _evidenceController,
          onDraftChanged: _updateDraft,
        ),
        ProjectWorkflowIssueSection<ProjectPettyCashRequestIssue>(
          items: _issues,
          fieldFor: (issue) => issue.field,
          messageFor: (issue) => issue.message,
        ),
        const SizedBox(height: 12),
        _PettyCashRequestPreview(
          summary: widget.summary,
          draft: _draft,
          routeLabel: routeLabel,
          service: widget.service,
        ),
        const SizedBox(height: 12),
        ProjectWorkflowSubmissionSection<ProjectPettyCashRequestSubmission>(
          submitLabel: 'Queue Request',
          submitIcon: Icons.payments_outlined,
          onReset: () => _reset(clearQueue: false),
          onSubmit: _queueRequest,
          items: _submissions,
          emptyTitle: 'Petty cash request queue empty',
          emptySubtitle: 'Queued float requests will appear here.',
          titleFor: (submission) => submission.entry.title,
          subtitleFor:
              (submission) =>
                  '${submission.amountLabel} - ${submission.purpose.label} - '
                  '${submission.routeLabel} - Custodian: ${submission.entry.custodian}',
          iconFor: (submission) => submission.purpose.icon,
          colorFor: (context, _) => Theme.of(context).colorScheme.primary,
        ),
      ],
    );
  }

  void _updateDraft(ProjectPettyCashRequestDraft draft) {
    setState(() {
      _draft = draft;
      _issues = const [];
    });
  }

  void _queueRequest() {
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
            purpose: _draft.purpose,
            dueOption: _draft.dueOption,
            custodian: _draft.custodian,
          );
      _syncControllers();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Petty cash request queued: ${submission.entry.title}'),
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
    _custodianController.text = _draft.custodian;
    _amountController.text = _draft.amountText;
    _evidenceController.text = _draft.evidenceNote;
  }
}

/// Text and select fields for one petty-cash request draft.
class _PettyCashRequestFields extends StatelessWidget {
  const _PettyCashRequestFields({
    required this.draft,
    required this.titleController,
    required this.custodianController,
    required this.amountController,
    required this.evidenceController,
    required this.onDraftChanged,
  });

  final ProjectPettyCashRequestDraft draft;
  final TextEditingController titleController;
  final TextEditingController custodianController;
  final TextEditingController amountController;
  final TextEditingController evidenceController;
  final ValueChanged<ProjectPettyCashRequestDraft> onDraftChanged;

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProjectWorkflowTextField(
            fieldKey: const ValueKey('petty-cash-request-title'),
            controller: titleController,
            label: 'Request title',
            icon: Icons.payments_outlined,
            textInputAction: TextInputAction.next,
            onChanged: (value) => onDraftChanged(draft.copyWith(title: value)),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ProjectWorkflowTextField(
                fieldKey: const ValueKey('petty-cash-request-custodian'),
                width: 280,
                controller: custodianController,
                label: 'Custodian',
                icon: Icons.account_circle_outlined,
                textInputAction: TextInputAction.next,
                onChanged:
                    (value) => onDraftChanged(draft.copyWith(custodian: value)),
              ),
              ProjectWorkflowTextField(
                fieldKey: const ValueKey('petty-cash-request-amount'),
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
              AppSelectField<ProjectPettyCashRequestPurpose>(
                width: 220,
                label: 'Purpose',
                value: draft.purpose,
                icon: draft.purpose.icon,
                options: [
                  for (final purpose in ProjectPettyCashRequestPurpose.values)
                    AppSelectOption(value: purpose, label: purpose.label),
                ],
                onChanged:
                    (value) => onDraftChanged(draft.copyWith(purpose: value)),
              ),
              AppSelectField<ProjectPettyCashRequestDueOption>(
                width: 200,
                label: 'Reconcile',
                value: draft.dueOption,
                icon: draft.dueOption.icon,
                options: [
                  for (final option in ProjectPettyCashRequestDueOption.values)
                    AppSelectOption(value: option, label: option.label),
                ],
                onChanged:
                    (value) => onDraftChanged(draft.copyWith(dueOption: value)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ProjectWorkflowTextField(
            fieldKey: const ValueKey('petty-cash-request-evidence'),
            controller: evidenceController,
            minLines: 3,
            maxLines: 5,
            label: 'Evidence note',
            icon: Icons.receipt_long_outlined,
            onChanged:
                (value) => onDraftChanged(draft.copyWith(evidenceNote: value)),
          ),
        ],
      ),
    );
  }
}

/// Live preview for the selected petty-cash request route.
class _PettyCashRequestPreview extends StatelessWidget {
  const _PettyCashRequestPreview({
    required this.summary,
    required this.draft,
    required this.routeLabel,
    required this.service,
  });

  final ProjectPettyCashWorkspaceSummary summary;
  final ProjectPettyCashRequestDraft draft;
  final String routeLabel;
  final ProjectPettyCashRequestIntakeService service;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final levelColor = summary.level.color(colorScheme);
    final amount = service.amountFor(draft);
    final amountLabel = amount == null ? 'Pending amount' : _money(amount);
    final dueDate = service.dueDateFor(
      summary: summary,
      option: draft.dueOption,
    );

    return AppInfoRow(
      title:
          draft.title.trim().isEmpty
              ? 'Petty cash request preview'
              : draft.title,
      subtitle:
          '$amountLabel - ${draft.purpose.label} - $routeLabel - '
          'Custodian: ${draft.custodian.trim().isEmpty ? 'Unassigned' : draft.custodian} - Reconcile ${_dateLabel(dueDate)}',
      icon: draft.purpose.icon,
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

@Preview(name: 'Project petty cash request intake panel')
Widget projectPettyCashRequestIntakePanelPreview() {
  final project =
      const ProjectPortfolioRepository().findById('retail-modernization')!;
  final workspace = buildProjectFinanceWorkspaceSummary(project);

  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ProjectPettyCashRequestIntakePanel(
          summary: buildProjectPettyCashWorkspaceSummary(workspace),
        ),
      ),
    ),
  );
}
