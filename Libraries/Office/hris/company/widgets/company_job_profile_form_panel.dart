import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/company_job_profile.dart';

class CompanyJobProfileFormPanel extends StatefulWidget {
  final CompanyJobProfileDraft draft;
  final List<String> entities;
  final List<String> orgUnits;
  final List<String> compensationBands;
  final ValueChanged<String> onJobCodeChanged;
  final ValueChanged<String> onJobTitleChanged;
  final ValueChanged<String> onEntityChanged;
  final ValueChanged<String> onOrgUnitChanged;
  final ValueChanged<CompanyJobFamily> onFamilyChanged;
  final ValueChanged<String> onLevelChanged;
  final ValueChanged<CompanyJobProfileStatus> onStatusChanged;
  final ValueChanged<String> onCompensationBandChanged;
  final ValueChanged<String> onOwnerChanged;
  final ValueChanged<String> onNextReviewChanged;
  final ValueChanged<String> onDescriptionChanged;
  final ValueChanged<String> onSkillsChanged;
  final ValueChanged<String> onLinkedPolicyChanged;
  final VoidCallback onSubmit;
  final VoidCallback onClear;

  const CompanyJobProfileFormPanel({
    super.key,
    required this.draft,
    required this.entities,
    required this.orgUnits,
    required this.compensationBands,
    required this.onJobCodeChanged,
    required this.onJobTitleChanged,
    required this.onEntityChanged,
    required this.onOrgUnitChanged,
    required this.onFamilyChanged,
    required this.onLevelChanged,
    required this.onStatusChanged,
    required this.onCompensationBandChanged,
    required this.onOwnerChanged,
    required this.onNextReviewChanged,
    required this.onDescriptionChanged,
    required this.onSkillsChanged,
    required this.onLinkedPolicyChanged,
    required this.onSubmit,
    required this.onClear,
  });

  @override
  State<CompanyJobProfileFormPanel> createState() =>
      _CompanyJobProfileFormPanelState();
}

class _CompanyJobProfileFormPanelState
    extends State<CompanyJobProfileFormPanel> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codeController;
  late final TextEditingController _titleController;
  late final TextEditingController _levelController;
  late final TextEditingController _ownerController;
  late final TextEditingController _reviewController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _skillsController;
  late final TextEditingController _policyController;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.draft.jobCode);
    _titleController = TextEditingController(text: widget.draft.jobTitle);
    _levelController = TextEditingController(text: widget.draft.levelName);
    _ownerController = TextEditingController(text: widget.draft.ownerName);
    _reviewController = TextEditingController(
      text: widget.draft.nextReviewDateText,
    );
    _descriptionController = TextEditingController(
      text: widget.draft.jobDescription,
    );
    _skillsController = TextEditingController(text: widget.draft.skillsSummary);
    _policyController = TextEditingController(text: widget.draft.linkedPolicy);
  }

  @override
  void didUpdateWidget(covariant CompanyJobProfileFormPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync(_codeController, widget.draft.jobCode);
    _sync(_titleController, widget.draft.jobTitle);
    _sync(_levelController, widget.draft.levelName);
    _sync(_ownerController, widget.draft.ownerName);
    _sync(_reviewController, widget.draft.nextReviewDateText);
    _sync(_descriptionController, widget.draft.jobDescription);
    _sync(_skillsController, widget.draft.skillsSummary);
    _sync(_policyController, widget.draft.linkedPolicy);
  }

  @override
  void dispose() {
    _codeController.dispose();
    _titleController.dispose();
    _levelController.dispose();
    _ownerController.dispose();
    _reviewController.dispose();
    _descriptionController.dispose();
    _skillsController.dispose();
    _policyController.dispose();
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
    final selectedOrgUnit =
        widget.orgUnits.contains(widget.draft.orgUnitName)
            ? widget.draft.orgUnitName
            : widget.orgUnits.firstOrNull;
    final selectedBand =
        widget.compensationBands.contains(widget.draft.compensationBand)
            ? widget.draft.compensationBand
            : widget.compensationBands.firstOrNull;

    return HrisSectionPanel(
      icon: Icons.badge_outlined,
      title: 'Job Profile Form',
      subtitle: 'Define job codes, families, levels, skills, and linked bands',
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-job-code-field'),
                      controller: _codeController,
                      label: 'Job code',
                      icon: Icons.tag_outlined,
                      onChanged: widget.onJobCodeChanged,
                      validator:
                          (value) => CompanyJobProfileDraft.validateRequired(
                            value,
                            'job code',
                          ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-job-title-field'),
                      controller: _titleController,
                      label: 'Job title',
                      icon: Icons.badge_outlined,
                      onChanged: widget.onJobTitleChanged,
                      validator:
                          (value) => CompanyJobProfileDraft.validateRequired(
                            value,
                            'job title',
                          ),
                    ),
                  ),
                ],
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
                          (value) => CompanyJobProfileDraft.validateRequired(
                            value,
                            'legal entity',
                          ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: selectedOrgUnit,
                      decoration: const InputDecoration(
                        labelText: 'Org unit',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.account_tree_outlined),
                      ),
                      items:
                          widget.orgUnits
                              .map(
                                (unit) => DropdownMenuItem(
                                  value: unit,
                                  child: Text(
                                    unit,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (unit) {
                        if (unit != null) widget.onOrgUnitChanged(unit);
                      },
                      validator:
                          (value) => CompanyJobProfileDraft.validateRequired(
                            value,
                            'org unit',
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<CompanyJobFamily>(
                      isExpanded: true,
                      initialValue: widget.draft.family,
                      decoration: const InputDecoration(
                        labelText: 'Family',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items:
                          CompanyJobFamily.values
                              .map(
                                (family) => DropdownMenuItem(
                                  value: family,
                                  child: Text(
                                    family.label,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (family) {
                        if (family != null) widget.onFamilyChanged(family);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<CompanyJobProfileStatus>(
                      isExpanded: true,
                      initialValue: widget.draft.status,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.task_alt_outlined),
                      ),
                      items:
                          CompanyJobProfileStatus.values
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
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-job-level-field'),
                      controller: _levelController,
                      label: 'Level name',
                      icon: Icons.stacked_bar_chart_outlined,
                      onChanged: widget.onLevelChanged,
                      validator:
                          (value) => CompanyJobProfileDraft.validateRequired(
                            value,
                            'level name',
                          ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: selectedBand,
                      decoration: const InputDecoration(
                        labelText: 'Compensation band',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.price_change_outlined),
                      ),
                      items:
                          widget.compensationBands
                              .map(
                                (band) => DropdownMenuItem(
                                  value: band,
                                  child: Text(
                                    band,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (band) {
                        if (band != null) {
                          widget.onCompensationBandChanged(band);
                        }
                      },
                      validator:
                          (value) => CompanyJobProfileDraft.validateRequired(
                            value,
                            'compensation band',
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
                      key: const Key('company-job-owner-field'),
                      controller: _ownerController,
                      label: 'Owner',
                      icon: Icons.supervisor_account_outlined,
                      onChanged: widget.onOwnerChanged,
                      validator:
                          (value) => CompanyJobProfileDraft.validateRequired(
                            value,
                            'owner',
                          ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-job-review-field'),
                      controller: _reviewController,
                      label: 'Next review (YYYY-MM-DD)',
                      icon: Icons.event_outlined,
                      onChanged: widget.onNextReviewChanged,
                      validator: CompanyJobProfileDraft.validateDate,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-job-description-field'),
                controller: _descriptionController,
                label: 'Job description',
                icon: Icons.description_outlined,
                minLines: 2,
                maxLines: 3,
                onChanged: widget.onDescriptionChanged,
                validator:
                    (value) => CompanyJobProfileDraft.validateRequired(
                      value,
                      'job description',
                    ),
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-job-skills-field'),
                controller: _skillsController,
                label: 'Skills summary',
                icon: Icons.psychology_outlined,
                minLines: 2,
                maxLines: 3,
                onChanged: widget.onSkillsChanged,
                validator:
                    (value) => CompanyJobProfileDraft.validateRequired(
                      value,
                      'skills summary',
                    ),
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-job-policy-field'),
                controller: _policyController,
                label: 'Linked policy',
                icon: Icons.policy_outlined,
                onChanged: widget.onLinkedPolicyChanged,
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
                    key: const Key('company-job-save-button'),
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        widget.onSubmit();
                      }
                    },
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Save job'),
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
  final int minLines;
  final int maxLines;

  const _TextInput({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.onChanged,
    this.validator,
    this.minLines = 1,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
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
