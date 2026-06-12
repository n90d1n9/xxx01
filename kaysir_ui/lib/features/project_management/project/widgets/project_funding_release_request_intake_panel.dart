import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_select_field.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';
import 'package:kaysir/widgets/ui/app_surface.dart';

import '../data/project_portfolio_repository.dart';
import '../services/project_finance_workspace_service.dart';
import '../services/project_funding_release_request_intake_service.dart';
import '../services/project_funding_release_service.dart';
import 'project_workflow_header.dart';
import 'project_workflow_issue_list.dart';
import 'project_workflow_submission_section.dart';
import 'project_workflow_text_field.dart';

/// Interactive intake flow for creating funding release requests.
class ProjectFundingReleaseRequestIntakePanel extends StatefulWidget {
  const ProjectFundingReleaseRequestIntakePanel({
    required this.summary,
    this.service = const ProjectFundingReleaseRequestIntakeService(),
    super.key,
  });

  final ProjectFundingReleaseSummary summary;
  final ProjectFundingReleaseRequestIntakeService service;

  @override
  State<ProjectFundingReleaseRequestIntakePanel> createState() =>
      _ProjectFundingReleaseRequestIntakePanelState();
}

/// Maintains local release request controllers and demo queue state.
class _ProjectFundingReleaseRequestIntakePanelState
    extends State<ProjectFundingReleaseRequestIntakePanel> {
  late ProjectFundingReleaseRequestDraft _draft;
  late final TextEditingController _titleController;
  late final TextEditingController _ownerController;
  late final TextEditingController _amountController;
  late final TextEditingController _gateController;
  late final TextEditingController _evidenceController;
  var _issues = const <ProjectFundingReleaseRequestIssue>[];
  var _submissions = const <ProjectFundingReleaseRequestSubmission>[];

  @override
  void initState() {
    super.initState();
    _draft = widget.service.initialDraft(widget.summary);
    _titleController = TextEditingController(text: _draft.title);
    _ownerController = TextEditingController(text: _draft.owner);
    _amountController = TextEditingController(text: _draft.amountText);
    _gateController = TextEditingController(text: _draft.gateNote);
    _evidenceController = TextEditingController(text: _draft.evidenceNote);
  }

  @override
  void didUpdateWidget(
    covariant ProjectFundingReleaseRequestIntakePanel oldWidget,
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
    _gateController.dispose();
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
          title: 'Funding release request flow',
          subtitle:
              '${widget.summary.projectName} - ${_submissions.length} queued releases - $routeLabel',
          icon: Icons.waterfall_chart_outlined,
          color: levelColor,
          statusLabel: routeLabel,
          statusIcon: Icons.route_outlined,
          statusMaxWidth: 142,
        ),
        const SizedBox(height: 12),
        _FundingReleaseRequestFields(
          draft: _draft,
          titleController: _titleController,
          ownerController: _ownerController,
          amountController: _amountController,
          gateController: _gateController,
          evidenceController: _evidenceController,
          onDraftChanged: _updateDraft,
        ),
        ProjectWorkflowIssueSection<ProjectFundingReleaseRequestIssue>(
          items: _issues,
          fieldFor: (issue) => issue.field,
          messageFor: (issue) => issue.message,
        ),
        const SizedBox(height: 12),
        _FundingReleaseRequestPreview(
          summary: widget.summary,
          draft: _draft,
          routeLabel: routeLabel,
          service: widget.service,
        ),
        const SizedBox(height: 12),
        ProjectWorkflowSubmissionSection<
          ProjectFundingReleaseRequestSubmission
        >(
          submitLabel: 'Queue Release',
          submitIcon: Icons.account_balance_wallet_outlined,
          onReset: () => _reset(clearQueue: false),
          onSubmit: _queueRelease,
          items: _submissions,
          emptyTitle: 'Funding release queue empty',
          emptySubtitle: 'Queued release requests will appear here.',
          titleFor: (submission) => submission.step.title,
          subtitleFor:
              (submission) =>
                  '${submission.step.amountLabel} - ${submission.step.kind.label} - '
                  '${submission.routeLabel} - Owner: ${submission.step.ownerLabel}',
          iconFor: (submission) => submission.step.kind.requestIcon,
          colorFor: (context, _) => Theme.of(context).colorScheme.primary,
        ),
      ],
    );
  }

  void _updateDraft(ProjectFundingReleaseRequestDraft draft) {
    setState(() {
      _draft = draft;
      _issues = const [];
    });
  }

  void _queueRelease() {
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
            dateOption: _draft.dateOption,
            owner: _draft.owner,
          );
      _syncControllers();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Funding release queued: ${submission.step.title}'),
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
    _gateController.text = _draft.gateNote;
    _evidenceController.text = _draft.evidenceNote;
  }
}

/// Text and select fields for one funding release request draft.
class _FundingReleaseRequestFields extends StatelessWidget {
  const _FundingReleaseRequestFields({
    required this.draft,
    required this.titleController,
    required this.ownerController,
    required this.amountController,
    required this.gateController,
    required this.evidenceController,
    required this.onDraftChanged,
  });

  final ProjectFundingReleaseRequestDraft draft;
  final TextEditingController titleController;
  final TextEditingController ownerController;
  final TextEditingController amountController;
  final TextEditingController gateController;
  final TextEditingController evidenceController;
  final ValueChanged<ProjectFundingReleaseRequestDraft> onDraftChanged;

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProjectWorkflowTextField(
            fieldKey: const ValueKey('funding-release-request-title'),
            controller: titleController,
            label: 'Release title',
            icon: Icons.waterfall_chart_outlined,
            textInputAction: TextInputAction.next,
            onChanged: (value) => onDraftChanged(draft.copyWith(title: value)),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              AppSelectField<ProjectFundingReleaseKind>(
                width: 240,
                label: 'Release type',
                value: draft.kind,
                icon: draft.kind.requestIcon,
                options: [
                  for (final kind in ProjectFundingReleaseKind.values)
                    AppSelectOption(value: kind, label: kind.label),
                ],
                onChanged:
                    (value) => onDraftChanged(draft.copyWith(kind: value)),
              ),
              ProjectWorkflowTextField(
                fieldKey: const ValueKey('funding-release-request-owner'),
                width: 260,
                controller: ownerController,
                label: 'Owner',
                icon: Icons.account_circle_outlined,
                textInputAction: TextInputAction.next,
                onChanged:
                    (value) => onDraftChanged(draft.copyWith(owner: value)),
              ),
              ProjectWorkflowTextField(
                fieldKey: const ValueKey('funding-release-request-amount'),
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
              AppSelectField<ProjectFundingReleaseRequestDateOption>(
                width: 210,
                label: 'Window',
                value: draft.dateOption,
                icon: draft.dateOption.icon,
                options: [
                  for (final option
                      in ProjectFundingReleaseRequestDateOption.values)
                    AppSelectOption(value: option, label: option.label),
                ],
                onChanged:
                    (value) =>
                        onDraftChanged(draft.copyWith(dateOption: value)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ProjectWorkflowTextField(
            fieldKey: const ValueKey('funding-release-request-gate'),
            controller: gateController,
            minLines: 3,
            maxLines: 5,
            label: 'Gate note',
            icon: Icons.account_tree_outlined,
            textInputAction: TextInputAction.next,
            onChanged:
                (value) => onDraftChanged(draft.copyWith(gateNote: value)),
          ),
          const SizedBox(height: 12),
          ProjectWorkflowTextField(
            fieldKey: const ValueKey('funding-release-request-evidence'),
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

/// Live preview for the selected funding release request route.
class _FundingReleaseRequestPreview extends StatelessWidget {
  const _FundingReleaseRequestPreview({
    required this.summary,
    required this.draft,
    required this.routeLabel,
    required this.service,
  });

  final ProjectFundingReleaseSummary summary;
  final ProjectFundingReleaseRequestDraft draft;
  final String routeLabel;
  final ProjectFundingReleaseRequestIntakeService service;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final levelColor = summary.level.color(colorScheme);
    final amount = service.amountFor(draft);
    final amountLabel = amount == null ? 'Pending amount' : _money(amount);
    final releaseDate = service.releaseDateFor(
      summary: summary,
      option: draft.dateOption,
    );

    return AppInfoRow(
      title:
          draft.title.trim().isEmpty
              ? 'Funding release request preview'
              : draft.title,
      subtitle:
          '$amountLabel - ${draft.kind.label} - $routeLabel - '
          'Owner: ${draft.owner.trim().isEmpty ? 'Unassigned' : draft.owner} - Release ${_dateLabel(releaseDate)}',
      icon: draft.kind.requestIcon,
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

@Preview(name: 'Project funding release request intake panel')
Widget projectFundingReleaseRequestIntakePanelPreview() {
  final project =
      const ProjectPortfolioRepository().findById('warehouse-automation')!;
  final workspace = buildProjectFinanceWorkspaceSummary(project);

  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ProjectFundingReleaseRequestIntakePanel(
          summary: buildProjectFundingReleaseSummary(workspace),
        ),
      ),
    ),
  );
}
