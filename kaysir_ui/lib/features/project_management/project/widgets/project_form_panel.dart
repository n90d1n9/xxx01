import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_content_panel.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../models/project_form_focus.dart';
import '../models/project_form_draft.dart';
import '../models/project_portfolio_item.dart';
import '../services/project_form_validation_service.dart';
import 'project_form_action_bar.dart';
import 'project_form_domain_extensions_section.dart';
import 'project_form_draft_controller.dart';
import 'project_form_draft_fields_section.dart';
import 'project_form_draft_text_controllers.dart';
import 'project_form_readiness_pill.dart';
import 'project_form_support_panels.dart';
import 'project_form_validation_issue_list.dart';

/// Stateful project intake form that manages draft edits and submission.
class ProjectFormPanel extends StatefulWidget {
  const ProjectFormPanel({
    required this.initialDraft,
    required this.onSubmitted,
    this.submitLabel = 'Add Project',
    this.initialFocus = ProjectFormPanelFocus.none,
    this.focusedAttributeKey,
    this.validationService = const ProjectFormValidationService(),
    super.key,
  });

  final ProjectFormDraft initialDraft;
  final ValueChanged<ProjectFormDraft> onSubmitted;
  final String submitLabel;
  final ProjectFormPanelFocus initialFocus;
  final String? focusedAttributeKey;
  final ProjectFormValidationService validationService;

  @override
  State<ProjectFormPanel> createState() => _ProjectFormPanelState();
}

/// Maintains local controllers and focus behavior for the project form panel.
class _ProjectFormPanelState extends State<ProjectFormPanel> {
  late ProjectFormDraftController _draftController;
  late final ProjectFormDraftTextControllers _textControllers;
  final _domainExtensionsKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _draftController = ProjectFormDraftController(
      initialDraft: widget.initialDraft,
      validationService: widget.validationService,
    );
    _textControllers = ProjectFormDraftTextControllers.fromDraft(
      _draftController.draft,
    );
    _scheduleInitialFocus();
  }

  @override
  void dispose() {
    _textControllers.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ProjectFormPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    final didInitialDraftChange = oldWidget.initialDraft != widget.initialDraft;
    final didValidationServiceChange =
        oldWidget.validationService != widget.validationService;

    if (didInitialDraftChange || didValidationServiceChange) {
      setState(() {
        if (didValidationServiceChange) {
          _draftController.updateValidationService(widget.validationService);
        }
        if (didInitialDraftChange) {
          _draftController.replaceInitialDraft(widget.initialDraft);
          _textControllers.applyDraft(_draftController.draft);
        }
      });
    }

    if (didInitialDraftChange ||
        oldWidget.initialFocus != widget.initialFocus ||
        oldWidget.focusedAttributeKey != widget.focusedAttributeKey) {
      _scheduleInitialFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = _draftController.draft;
    final issues = _draftController.issues;
    final readinessIssues = _draftController.previewIssues();
    final colorScheme = Theme.of(context).colorScheme;
    final healthColor = draft.health.color(colorScheme);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppContentPanel(
          title: 'Project Intake Form',
          subtitle:
              'Reusable intake for construction, software, events, education, government, wedding, and operational projects.',
          leadingIcon: Icons.post_add_outlined,
          trailing: Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.end,
            children: [
              ProjectFormReadinessPill(issueCount: readinessIssues.length),
              AppStatusPill(
                label: draft.health.label,
                icon: draft.health.icon,
                color: healthColor,
                maxWidth: 130,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ProjectFormDraftFieldsSection(
                draft: draft,
                textControllers: _textControllers,
                onDraftChanged: _update,
              ),
              const SizedBox(height: 16),
              ProjectFormDomainExtensionsSection(
                key: _domainExtensionsKey,
                businessDomain: draft.businessDomain,
                attributes: draft.customAttributes,
                focusedAttributeKey: widget.focusedAttributeKey,
                onChanged:
                    (attributes) =>
                        _update(draft.copyWith(customAttributes: attributes)),
              ),
              if (issues.isNotEmpty) ...[
                const SizedBox(height: 16),
                ProjectFormValidationIssueList(issues: issues),
              ],
              const SizedBox(height: 18),
              ProjectFormActionBar(
                submitLabel: widget.submitLabel,
                onReset: _reset,
                onSubmit: _submit,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ProjectFormSupportPanels(draft: draft),
      ],
    );
  }

  void _update(ProjectFormDraft draft) {
    setState(() => _draftController.updateDraft(draft));
  }

  void _reset() {
    setState(() {
      _draftController.reset();
      _textControllers.applyDraft(_draftController.draft);
    });
  }

  void _submit() {
    late ProjectFormSubmitAttempt attempt;
    setState(() => attempt = _draftController.submit());
    if (!attempt.canSubmit) return;

    widget.onSubmitted(attempt.draft);
  }

  void _scheduleInitialFocus() {
    if (widget.initialFocus != ProjectFormPanelFocus.domainExtensions &&
        widget.focusedAttributeKey == null) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final context = _domainExtensionsKey.currentContext;
      if (context == null) return;

      Scrollable.ensureVisible(
        context,
        alignment: 0.08,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    });
  }
}
