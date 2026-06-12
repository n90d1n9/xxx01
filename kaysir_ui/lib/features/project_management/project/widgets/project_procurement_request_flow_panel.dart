import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_select_field.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';
import 'package:kaysir/widgets/ui/app_surface.dart';

import '../data/project_portfolio_repository.dart';
import '../services/project_finance_workspace_service.dart';
import '../services/project_procurement_commitment_service.dart';
import '../services/project_procurement_request_flow_service.dart';
import 'project_workflow_header.dart';
import 'project_workflow_issue_list.dart';
import 'project_workflow_submission_section.dart';
import 'project_workflow_text_field.dart';

/// Interactive request flow for procurement packages, vendors, and proof.
class ProjectProcurementRequestFlowPanel extends StatefulWidget {
  const ProjectProcurementRequestFlowPanel({
    required this.summary,
    this.service = const ProjectProcurementRequestFlowService(),
    super.key,
  });

  final ProjectProcurementCommitmentSummary summary;
  final ProjectProcurementRequestFlowService service;

  @override
  State<ProjectProcurementRequestFlowPanel> createState() =>
      _ProjectProcurementRequestFlowPanelState();
}

/// Maintains local procurement request controllers and demo queue state.
class _ProjectProcurementRequestFlowPanelState
    extends State<ProjectProcurementRequestFlowPanel> {
  late ProjectProcurementRequestDraft _draft;
  late final TextEditingController _titleController;
  late final TextEditingController _vendorController;
  late final TextEditingController _ownerController;
  late final TextEditingController _amountController;
  late final TextEditingController _scopeController;
  late final TextEditingController _evidenceController;
  var _issues = const <ProjectProcurementRequestIssue>[];
  var _submissions = const <ProjectProcurementRequestSubmission>[];

  @override
  void initState() {
    super.initState();
    _draft = widget.service.initialDraft(widget.summary);
    _titleController = TextEditingController(text: _draft.title);
    _vendorController = TextEditingController(text: _draft.vendor);
    _ownerController = TextEditingController(text: _draft.owner);
    _amountController = TextEditingController(text: _draft.amountText);
    _scopeController = TextEditingController(text: _draft.scopeNote);
    _evidenceController = TextEditingController(text: _draft.evidenceNote);
  }

  @override
  void didUpdateWidget(covariant ProjectProcurementRequestFlowPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.summary.projectId == widget.summary.projectId) return;

    _reset(clearQueue: true);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _vendorController.dispose();
    _ownerController.dispose();
    _amountController.dispose();
    _scopeController.dispose();
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
          title: 'Procurement request flow',
          subtitle:
              '${widget.summary.projectName} - ${_submissions.length} queued requests - $routeLabel',
          icon: Icons.inventory_2_outlined,
          color: levelColor,
          statusLabel: routeLabel,
          statusIcon: Icons.route_outlined,
          statusMaxWidth: 160,
        ),
        const SizedBox(height: 12),
        _ProcurementRequestFields(
          draft: _draft,
          titleController: _titleController,
          vendorController: _vendorController,
          ownerController: _ownerController,
          amountController: _amountController,
          scopeController: _scopeController,
          evidenceController: _evidenceController,
          onDraftChanged: _updateDraft,
        ),
        ProjectWorkflowIssueSection<ProjectProcurementRequestIssue>(
          items: _issues,
          fieldFor: (issue) => issue.field,
          messageFor: (issue) => issue.message,
        ),
        const SizedBox(height: 12),
        _ProcurementRequestPreview(
          summary: widget.summary,
          draft: _draft,
          routeLabel: routeLabel,
          service: widget.service,
        ),
        const SizedBox(height: 12),
        ProjectWorkflowSubmissionSection<ProjectProcurementRequestSubmission>(
          submitLabel: 'Queue Request',
          submitIcon: Icons.shopping_cart_outlined,
          onReset: () => _reset(clearQueue: false),
          onSubmit: _queueRequest,
          items: _submissions,
          emptyTitle: 'Procurement request queue empty',
          emptySubtitle: 'Queued procurement requests will appear here.',
          titleFor: (submission) => submission.item.title,
          subtitleFor:
              (submission) =>
                  '${submission.item.amountLabel} - ${submission.item.kind.label} - '
                  '${submission.routeLabel} - ${submission.item.sourceLabel} - '
                  'Owner: ${submission.item.ownerLabel}',
          iconFor: (submission) => submission.item.kind.requestIcon,
          colorFor: (context, _) => Theme.of(context).colorScheme.primary,
        ),
      ],
    );
  }

  void _updateDraft(ProjectProcurementRequestDraft draft) {
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
            kind: _draft.kind,
            owner: _draft.owner,
            vendor: _draft.vendor,
            windowOption: _draft.windowOption,
          );
      _syncControllers();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Procurement request queued: ${submission.item.title}'),
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
    _vendorController.text = _draft.vendor;
    _ownerController.text = _draft.owner;
    _amountController.text = _draft.amountText;
    _scopeController.text = _draft.scopeNote;
    _evidenceController.text = _draft.evidenceNote;
  }
}

/// Form fields for one procurement request draft.
class _ProcurementRequestFields extends StatelessWidget {
  const _ProcurementRequestFields({
    required this.draft,
    required this.titleController,
    required this.vendorController,
    required this.ownerController,
    required this.amountController,
    required this.scopeController,
    required this.evidenceController,
    required this.onDraftChanged,
  });

  final ProjectProcurementRequestDraft draft;
  final TextEditingController titleController;
  final TextEditingController vendorController;
  final TextEditingController ownerController;
  final TextEditingController amountController;
  final TextEditingController scopeController;
  final TextEditingController evidenceController;
  final ValueChanged<ProjectProcurementRequestDraft> onDraftChanged;

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProjectWorkflowTextField(
            fieldKey: const ValueKey('procurement-request-title'),
            controller: titleController,
            label: 'Request title',
            icon: Icons.inventory_2_outlined,
            textInputAction: TextInputAction.next,
            onChanged: (value) => onDraftChanged(draft.copyWith(title: value)),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              AppSelectField<ProjectProcurementCommitmentKind>(
                width: 250,
                label: 'Request type',
                value: draft.kind,
                icon: draft.kind.requestIcon,
                options: [
                  for (final kind in ProjectProcurementCommitmentKind.values)
                    AppSelectOption(value: kind, label: kind.label),
                ],
                onChanged:
                    (value) => onDraftChanged(draft.copyWith(kind: value)),
              ),
              ProjectWorkflowTextField(
                fieldKey: const ValueKey('procurement-request-vendor'),
                width: 260,
                controller: vendorController,
                label: 'Vendor / supplier',
                icon: Icons.storefront_outlined,
                textInputAction: TextInputAction.next,
                onChanged:
                    (value) => onDraftChanged(draft.copyWith(vendor: value)),
              ),
              ProjectWorkflowTextField(
                fieldKey: const ValueKey('procurement-request-owner'),
                width: 240,
                controller: ownerController,
                label: 'Owner',
                icon: Icons.account_circle_outlined,
                textInputAction: TextInputAction.next,
                onChanged:
                    (value) => onDraftChanged(draft.copyWith(owner: value)),
              ),
              ProjectWorkflowTextField(
                fieldKey: const ValueKey('procurement-request-amount'),
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
              AppSelectField<ProjectProcurementRequestWindowOption>(
                width: 220,
                label: 'Target',
                value: draft.windowOption,
                icon: draft.windowOption.icon,
                options: [
                  for (final option
                      in ProjectProcurementRequestWindowOption.values)
                    AppSelectOption(value: option, label: option.label),
                ],
                onChanged:
                    (value) =>
                        onDraftChanged(draft.copyWith(windowOption: value)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ProjectWorkflowTextField(
            fieldKey: const ValueKey('procurement-request-scope'),
            controller: scopeController,
            minLines: 3,
            maxLines: 5,
            label: 'Scope note',
            icon: Icons.description_outlined,
            textInputAction: TextInputAction.next,
            onChanged:
                (value) => onDraftChanged(draft.copyWith(scopeNote: value)),
          ),
          const SizedBox(height: 12),
          ProjectWorkflowTextField(
            fieldKey: const ValueKey('procurement-request-evidence'),
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

/// Live preview for the selected procurement request route.
class _ProcurementRequestPreview extends StatelessWidget {
  const _ProcurementRequestPreview({
    required this.summary,
    required this.draft,
    required this.routeLabel,
    required this.service,
  });

  final ProjectProcurementCommitmentSummary summary;
  final ProjectProcurementRequestDraft draft;
  final String routeLabel;
  final ProjectProcurementRequestFlowService service;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final levelColor = summary.level.color(colorScheme);
    final amount = service.amountFor(draft);
    final amountLabel = amount == null ? 'Pending amount' : _money(amount);
    final targetDate = service.targetDateFor(
      summary: summary,
      option: draft.windowOption,
    );
    final vendor =
        draft.vendor.trim().isEmpty ? 'Vendor pending' : draft.vendor.trim();
    final owner =
        draft.owner.trim().isEmpty ? 'Unassigned' : draft.owner.trim();

    return AppInfoRow(
      title:
          draft.title.trim().isEmpty
              ? 'Procurement request preview'
              : draft.title.trim(),
      subtitle:
          '$amountLabel - ${draft.kind.label} - $routeLabel - '
          '$vendor - Owner: $owner - Target ${_dateLabel(targetDate)}',
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

@Preview(name: 'Project procurement request flow panel')
Widget projectProcurementRequestFlowPanelPreview() {
  final project =
      const ProjectPortfolioRepository().findById('warehouse-automation')!;
  final workspace = buildProjectFinanceWorkspaceSummary(project);

  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ProjectProcurementRequestFlowPanel(
          summary: buildProjectProcurementCommitmentSummary(workspace),
        ),
      ),
    ),
  );
}
