import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/company_probation_plan.dart';

class CompanyProbationPlanFormPanel extends StatefulWidget {
  final CompanyProbationPlanDraft draft;
  final List<String> entities;
  final List<String> jobProfileCodes;
  final List<String> onboardingPackNames;
  final ValueChanged<String> onPlanNameChanged;
  final ValueChanged<String> onEntityChanged;
  final ValueChanged<CompanyProbationPlanType> onTypeChanged;
  final ValueChanged<CompanyProbationPlanStatus> onStatusChanged;
  final ValueChanged<String> onJobProfileChanged;
  final ValueChanged<String> onOnboardingPackChanged;
  final ValueChanged<String> onOwnerChanged;
  final ValueChanged<String> onManagerRoleChanged;
  final ValueChanged<String> onCadenceChanged;
  final ValueChanged<String> onCheckpointCountChanged;
  final ValueChanged<String> onFirstReviewChanged;
  final ValueChanged<String> onFinalDecisionChanged;
  final ValueChanged<String> onNextReviewChanged;
  final ValueChanged<String> onSuccessCriteriaChanged;
  final ValueChanged<String> onFeedbackTemplateChanged;
  final ValueChanged<String> onNotesChanged;
  final VoidCallback onSubmit;
  final VoidCallback onClear;

  const CompanyProbationPlanFormPanel({
    super.key,
    required this.draft,
    required this.entities,
    required this.jobProfileCodes,
    required this.onboardingPackNames,
    required this.onPlanNameChanged,
    required this.onEntityChanged,
    required this.onTypeChanged,
    required this.onStatusChanged,
    required this.onJobProfileChanged,
    required this.onOnboardingPackChanged,
    required this.onOwnerChanged,
    required this.onManagerRoleChanged,
    required this.onCadenceChanged,
    required this.onCheckpointCountChanged,
    required this.onFirstReviewChanged,
    required this.onFinalDecisionChanged,
    required this.onNextReviewChanged,
    required this.onSuccessCriteriaChanged,
    required this.onFeedbackTemplateChanged,
    required this.onNotesChanged,
    required this.onSubmit,
    required this.onClear,
  });

  @override
  State<CompanyProbationPlanFormPanel> createState() =>
      _CompanyProbationPlanFormPanelState();
}

class _CompanyProbationPlanFormPanelState
    extends State<CompanyProbationPlanFormPanel> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _ownerController;
  late final TextEditingController _managerController;
  late final TextEditingController _cadenceController;
  late final TextEditingController _checkpointController;
  late final TextEditingController _firstReviewController;
  late final TextEditingController _finalDecisionController;
  late final TextEditingController _reviewController;
  late final TextEditingController _criteriaController;
  late final TextEditingController _feedbackController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.draft.planName);
    _ownerController = TextEditingController(text: widget.draft.ownerName);
    _managerController = TextEditingController(text: widget.draft.managerRole);
    _cadenceController = TextEditingController(
      text: widget.draft.reviewCadenceDaysText,
    );
    _checkpointController = TextEditingController(
      text: widget.draft.checkpointCountText,
    );
    _firstReviewController = TextEditingController(
      text: widget.draft.firstReviewDueDaysText,
    );
    _finalDecisionController = TextEditingController(
      text: widget.draft.finalDecisionDueDaysText,
    );
    _reviewController = TextEditingController(
      text: widget.draft.nextReviewDateText,
    );
    _criteriaController = TextEditingController(
      text: widget.draft.successCriteria,
    );
    _feedbackController = TextEditingController(
      text: widget.draft.feedbackTemplate,
    );
    _notesController = TextEditingController(text: widget.draft.notes);
  }

  @override
  void didUpdateWidget(covariant CompanyProbationPlanFormPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync(_nameController, widget.draft.planName);
    _sync(_ownerController, widget.draft.ownerName);
    _sync(_managerController, widget.draft.managerRole);
    _sync(_cadenceController, widget.draft.reviewCadenceDaysText);
    _sync(_checkpointController, widget.draft.checkpointCountText);
    _sync(_firstReviewController, widget.draft.firstReviewDueDaysText);
    _sync(_finalDecisionController, widget.draft.finalDecisionDueDaysText);
    _sync(_reviewController, widget.draft.nextReviewDateText);
    _sync(_criteriaController, widget.draft.successCriteria);
    _sync(_feedbackController, widget.draft.feedbackTemplate);
    _sync(_notesController, widget.draft.notes);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ownerController.dispose();
    _managerController.dispose();
    _cadenceController.dispose();
    _checkpointController.dispose();
    _firstReviewController.dispose();
    _finalDecisionController.dispose();
    _reviewController.dispose();
    _criteriaController.dispose();
    _feedbackController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectableEntities =
        widget.entities.where((entity) => entity != 'All').toList();
    final selectedEntity =
        selectableEntities.contains(widget.draft.entityName)
            ? widget.draft.entityName
            : selectableEntities.firstOrNull;
    final selectedJobProfile =
        widget.jobProfileCodes.contains(widget.draft.jobProfileCode)
            ? widget.draft.jobProfileCode
            : widget.jobProfileCodes.firstOrNull;
    final selectedOnboardingPack =
        widget.onboardingPackNames.contains(widget.draft.onboardingPackName)
            ? widget.draft.onboardingPackName
            : widget.onboardingPackNames.firstOrNull;

    return HrisSectionPanel(
      icon: Icons.fact_check_outlined,
      title: 'Probation Plan Form',
      subtitle: 'Create milestone templates for new hire review decisions',
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              _TextInput(
                key: const Key('company-probation-name-field'),
                controller: _nameController,
                label: 'Plan name',
                icon: Icons.fact_check_outlined,
                onChanged: widget.onPlanNameChanged,
                validator:
                    (value) => CompanyProbationPlanDraft.validateRequired(
                      value,
                      'plan name',
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: selectedEntity,
                      decoration: const InputDecoration(
                        labelText: 'Legal entity',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.business_outlined),
                      ),
                      items:
                          selectableEntities
                              .map(
                                (entity) => DropdownMenuItem(
                                  value: entity,
                                  child: Text(
                                    entity,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (entity) {
                        if (entity != null) widget.onEntityChanged(entity);
                      },
                      validator:
                          (value) => CompanyProbationPlanDraft.validateRequired(
                            value,
                            'legal entity',
                          ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<CompanyProbationPlanType>(
                      isExpanded: true,
                      initialValue: widget.draft.type,
                      decoration: const InputDecoration(
                        labelText: 'Type',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.route_outlined),
                      ),
                      items:
                          CompanyProbationPlanType.values
                              .map(
                                (type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(
                                    type.label,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (type) {
                        if (type != null) widget.onTypeChanged(type);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<CompanyProbationPlanStatus>(
                      isExpanded: true,
                      initialValue: widget.draft.status,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.task_alt_outlined),
                      ),
                      items:
                          CompanyProbationPlanStatus.values
                              .map(
                                (status) => DropdownMenuItem(
                                  value: status,
                                  child: Text(
                                    status.label,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (status) {
                        if (status != null) widget.onStatusChanged(status);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: selectedJobProfile,
                      decoration: const InputDecoration(
                        labelText: 'Job profile',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                      items:
                          widget.jobProfileCodes
                              .map(
                                (code) => DropdownMenuItem(
                                  value: code,
                                  child: Text(
                                    code,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (code) {
                        if (code != null) widget.onJobProfileChanged(code);
                      },
                      validator:
                          (value) => CompanyProbationPlanDraft.validateRequired(
                            value,
                            'job profile',
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: selectedOnboardingPack,
                decoration: const InputDecoration(
                  labelText: 'Onboarding pack',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.playlist_add_check_outlined),
                ),
                items:
                    widget.onboardingPackNames
                        .map(
                          (pack) => DropdownMenuItem(
                            value: pack,
                            child: Text(pack, overflow: TextOverflow.ellipsis),
                          ),
                        )
                        .toList(),
                onChanged: (pack) {
                  if (pack != null) widget.onOnboardingPackChanged(pack);
                },
                validator:
                    (value) => CompanyProbationPlanDraft.validateRequired(
                      value,
                      'onboarding pack',
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-probation-owner-field'),
                      controller: _ownerController,
                      label: 'Owner',
                      icon: Icons.supervisor_account_outlined,
                      onChanged: widget.onOwnerChanged,
                      validator:
                          (value) => CompanyProbationPlanDraft.validateRequired(
                            value,
                            'owner',
                          ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-probation-manager-field'),
                      controller: _managerController,
                      label: 'Manager role',
                      icon: Icons.manage_accounts_outlined,
                      onChanged: widget.onManagerRoleChanged,
                      validator:
                          (value) => CompanyProbationPlanDraft.validateRequired(
                            value,
                            'manager role',
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-probation-cadence-field'),
                      controller: _cadenceController,
                      label: 'Cadence days',
                      icon: Icons.repeat_outlined,
                      keyboardType: TextInputType.number,
                      onChanged: widget.onCadenceChanged,
                      validator:
                          (value) =>
                              CompanyProbationPlanDraft.validatePositiveInt(
                                value,
                                'cadence days',
                              ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-probation-checkpoints-field'),
                      controller: _checkpointController,
                      label: 'Checkpoints',
                      icon: Icons.format_list_numbered_outlined,
                      keyboardType: TextInputType.number,
                      onChanged: widget.onCheckpointCountChanged,
                      validator:
                          (value) =>
                              CompanyProbationPlanDraft.validatePositiveInt(
                                value,
                                'checkpoints',
                              ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-probation-review-field'),
                      controller: _reviewController,
                      label: 'Next review',
                      icon: Icons.event_outlined,
                      onChanged: widget.onNextReviewChanged,
                      validator: CompanyProbationPlanDraft.validateDate,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-probation-first-due-field'),
                      controller: _firstReviewController,
                      label: 'First review due',
                      icon: Icons.schedule_outlined,
                      keyboardType: TextInputType.number,
                      onChanged: widget.onFirstReviewChanged,
                      validator:
                          (value) =>
                              CompanyProbationPlanDraft.validatePositiveInt(
                                value,
                                'first review days',
                              ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-probation-final-due-field'),
                      controller: _finalDecisionController,
                      label: 'Final decision due',
                      icon: Icons.gavel_outlined,
                      keyboardType: TextInputType.number,
                      onChanged: widget.onFinalDecisionChanged,
                      validator:
                          (value) =>
                              CompanyProbationPlanDraft.validatePositiveInt(
                                value,
                                'final decision days',
                              ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-probation-criteria-field'),
                controller: _criteriaController,
                label: 'Success criteria',
                icon: Icons.rule_outlined,
                minLines: 2,
                maxLines: 3,
                onChanged: widget.onSuccessCriteriaChanged,
                validator:
                    (value) => CompanyProbationPlanDraft.validateRequired(
                      value,
                      'success criteria',
                    ),
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-probation-feedback-field'),
                controller: _feedbackController,
                label: 'Feedback template',
                icon: Icons.rate_review_outlined,
                minLines: 2,
                maxLines: 3,
                onChanged: widget.onFeedbackTemplateChanged,
                validator:
                    (value) => CompanyProbationPlanDraft.validateRequired(
                      value,
                      'feedback template',
                    ),
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-probation-notes-field'),
                controller: _notesController,
                label: 'Notes',
                icon: Icons.notes_outlined,
                minLines: 2,
                maxLines: 3,
                onChanged: widget.onNotesChanged,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: widget.onClear,
                    child: const Text('Clear'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    key: const Key('company-probation-save-button'),
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        widget.onSubmit();
                      }
                    },
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Save plan'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _sync(TextEditingController controller, String value) {
    if (controller.text == value) return;
    controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }
}

class _TextInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int minLines;
  final int maxLines;

  const _TextInput({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.onChanged,
    this.validator,
    this.keyboardType,
    this.minLines = 1,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      minLines: minLines,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
      validator: validator,
      onChanged: onChanged,
    );
  }
}
