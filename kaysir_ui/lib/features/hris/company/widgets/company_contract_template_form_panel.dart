import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/company_contract_template.dart';

class CompanyContractTemplateFormPanel extends StatefulWidget {
  final CompanyContractTemplateDraft draft;
  final List<String> entities;
  final List<String> jobProfileCodes;
  final List<String> compensationBands;
  final ValueChanged<String> onTemplateNameChanged;
  final ValueChanged<String> onEntityChanged;
  final ValueChanged<CompanyContractTemplateType> onTypeChanged;
  final ValueChanged<CompanyContractTemplateStatus> onStatusChanged;
  final ValueChanged<String> onJobProfileChanged;
  final ValueChanged<String> onCompensationBandChanged;
  final ValueChanged<String> onOwnerChanged;
  final ValueChanged<String> onLegalReviewerChanged;
  final ValueChanged<String> onSignatoryChanged;
  final ValueChanged<String> onLanguageChanged;
  final ValueChanged<String> onVersionChanged;
  final ValueChanged<String> onNextReviewChanged;
  final ValueChanged<String> onClauseChanged;
  final ValueChanged<String> onOnboardingChanged;
  final VoidCallback onSubmit;
  final VoidCallback onClear;

  const CompanyContractTemplateFormPanel({
    super.key,
    required this.draft,
    required this.entities,
    required this.jobProfileCodes,
    required this.compensationBands,
    required this.onTemplateNameChanged,
    required this.onEntityChanged,
    required this.onTypeChanged,
    required this.onStatusChanged,
    required this.onJobProfileChanged,
    required this.onCompensationBandChanged,
    required this.onOwnerChanged,
    required this.onLegalReviewerChanged,
    required this.onSignatoryChanged,
    required this.onLanguageChanged,
    required this.onVersionChanged,
    required this.onNextReviewChanged,
    required this.onClauseChanged,
    required this.onOnboardingChanged,
    required this.onSubmit,
    required this.onClear,
  });

  @override
  State<CompanyContractTemplateFormPanel> createState() =>
      _CompanyContractTemplateFormPanelState();
}

class _CompanyContractTemplateFormPanelState
    extends State<CompanyContractTemplateFormPanel> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _ownerController;
  late final TextEditingController _reviewerController;
  late final TextEditingController _signatoryController;
  late final TextEditingController _languageController;
  late final TextEditingController _versionController;
  late final TextEditingController _reviewController;
  late final TextEditingController _clauseController;
  late final TextEditingController _onboardingController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.draft.templateName);
    _ownerController = TextEditingController(text: widget.draft.ownerName);
    _reviewerController = TextEditingController(
      text: widget.draft.legalReviewerName,
    );
    _signatoryController = TextEditingController(
      text: widget.draft.signatoryRole,
    );
    _languageController = TextEditingController(text: widget.draft.language);
    _versionController = TextEditingController(text: widget.draft.versionLabel);
    _reviewController = TextEditingController(
      text: widget.draft.nextReviewDateText,
    );
    _clauseController = TextEditingController(text: widget.draft.clauseSummary);
    _onboardingController = TextEditingController(
      text: widget.draft.onboardingChecklist,
    );
  }

  @override
  void didUpdateWidget(covariant CompanyContractTemplateFormPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync(_nameController, widget.draft.templateName);
    _sync(_ownerController, widget.draft.ownerName);
    _sync(_reviewerController, widget.draft.legalReviewerName);
    _sync(_signatoryController, widget.draft.signatoryRole);
    _sync(_languageController, widget.draft.language);
    _sync(_versionController, widget.draft.versionLabel);
    _sync(_reviewController, widget.draft.nextReviewDateText);
    _sync(_clauseController, widget.draft.clauseSummary);
    _sync(_onboardingController, widget.draft.onboardingChecklist);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ownerController.dispose();
    _reviewerController.dispose();
    _signatoryController.dispose();
    _languageController.dispose();
    _versionController.dispose();
    _reviewController.dispose();
    _clauseController.dispose();
    _onboardingController.dispose();
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
    final selectedBand =
        widget.compensationBands.contains(widget.draft.compensationBand)
            ? widget.draft.compensationBand
            : widget.compensationBands.firstOrNull;

    return HrisSectionPanel(
      icon: Icons.article_outlined,
      title: 'Contract Template Form',
      subtitle: 'Manage offer, employment, contractor, and addendum templates',
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              _TextInput(
                key: const Key('company-contract-name-field'),
                controller: _nameController,
                label: 'Template name',
                icon: Icons.article_outlined,
                onChanged: widget.onTemplateNameChanged,
                validator:
                    (value) => CompanyContractTemplateDraft.validateRequired(
                      value,
                      'template name',
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
                          (value) =>
                              CompanyContractTemplateDraft.validateRequired(
                                value,
                                'legal entity',
                              ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<CompanyContractTemplateType>(
                      isExpanded: true,
                      initialValue: widget.draft.type,
                      decoration: const InputDecoration(
                        labelText: 'Type',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description_outlined),
                      ),
                      items:
                          CompanyContractTemplateType.values
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
                    child:
                        DropdownButtonFormField<CompanyContractTemplateStatus>(
                          isExpanded: true,
                          initialValue: widget.draft.status,
                          decoration: const InputDecoration(
                            labelText: 'Status',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.task_alt_outlined),
                          ),
                          items:
                              CompanyContractTemplateStatus.values
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
                          (value) =>
                              CompanyContractTemplateDraft.validateRequired(
                                value,
                                'job profile',
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
                          (value) =>
                              CompanyContractTemplateDraft.validateRequired(
                                value,
                                'compensation band',
                              ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-contract-version-field'),
                      controller: _versionController,
                      label: 'Version',
                      icon: Icons.commit_outlined,
                      onChanged: widget.onVersionChanged,
                      validator:
                          (value) =>
                              CompanyContractTemplateDraft.validateRequired(
                                value,
                                'version',
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
                      key: const Key('company-contract-owner-field'),
                      controller: _ownerController,
                      label: 'Owner',
                      icon: Icons.supervisor_account_outlined,
                      onChanged: widget.onOwnerChanged,
                      validator:
                          (value) =>
                              CompanyContractTemplateDraft.validateRequired(
                                value,
                                'owner',
                              ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-contract-reviewer-field'),
                      controller: _reviewerController,
                      label: 'Legal reviewer',
                      icon: Icons.gavel_outlined,
                      onChanged: widget.onLegalReviewerChanged,
                      validator:
                          (value) =>
                              CompanyContractTemplateDraft.validateRequired(
                                value,
                                'legal reviewer',
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
                      key: const Key('company-contract-signatory-field'),
                      controller: _signatoryController,
                      label: 'Signatory role',
                      icon: Icons.assignment_ind_outlined,
                      onChanged: widget.onSignatoryChanged,
                      validator:
                          (value) =>
                              CompanyContractTemplateDraft.validateRequired(
                                value,
                                'signatory role',
                              ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-contract-language-field'),
                      controller: _languageController,
                      label: 'Language',
                      icon: Icons.translate_outlined,
                      onChanged: widget.onLanguageChanged,
                      validator:
                          (value) =>
                              CompanyContractTemplateDraft.validateRequired(
                                value,
                                'language',
                              ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-contract-review-field'),
                controller: _reviewController,
                label: 'Next review (YYYY-MM-DD)',
                icon: Icons.event_outlined,
                onChanged: widget.onNextReviewChanged,
                validator: CompanyContractTemplateDraft.validateDate,
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-contract-clause-field'),
                controller: _clauseController,
                label: 'Clause summary',
                icon: Icons.fact_check_outlined,
                minLines: 2,
                maxLines: 3,
                onChanged: widget.onClauseChanged,
                validator:
                    (value) => CompanyContractTemplateDraft.validateRequired(
                      value,
                      'clause summary',
                    ),
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-contract-onboarding-field'),
                controller: _onboardingController,
                label: 'Onboarding checklist',
                icon: Icons.playlist_add_check_outlined,
                minLines: 2,
                maxLines: 3,
                onChanged: widget.onOnboardingChanged,
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
                    key: const Key('company-contract-save-button'),
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        widget.onSubmit();
                      }
                    },
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Save template'),
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
