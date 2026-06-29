import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/company_document_requirement.dart';

class CompanyDocumentRequirementFormPanel extends StatefulWidget {
  final CompanyDocumentRequirementDraft draft;
  final List<String> entities;
  final List<String> jobProfileCodes;
  final List<String> contractTemplateNames;
  final List<String> onboardingPackNames;
  final List<String> probationPlanNames;
  final List<String> offboardingPackNames;
  final ValueChanged<String> onRequirementNameChanged;
  final ValueChanged<String> onEntityChanged;
  final ValueChanged<CompanyDocumentRequirementStage> onStageChanged;
  final ValueChanged<CompanyDocumentRequirementStatus> onStatusChanged;
  final ValueChanged<String> onJobProfileChanged;
  final ValueChanged<String> onContractTemplateChanged;
  final ValueChanged<String> onOnboardingPackChanged;
  final ValueChanged<String> onProbationPlanChanged;
  final ValueChanged<String> onOffboardingPackChanged;
  final ValueChanged<String> onOwnerChanged;
  final ValueChanged<String> onEvidenceOwnerChanged;
  final ValueChanged<String> onPolicyChanged;
  final ValueChanged<String> onCollectionChannelChanged;
  final ValueChanged<String> onStorageLocationChanged;
  final ValueChanged<String> onRetentionRuleChanged;
  final ValueChanged<String> onRequiredDocumentsChanged;
  final ValueChanged<String> onNextReviewChanged;
  final ValueChanged<String> onNotesChanged;
  final VoidCallback onSubmit;
  final VoidCallback onClear;

  const CompanyDocumentRequirementFormPanel({
    super.key,
    required this.draft,
    required this.entities,
    required this.jobProfileCodes,
    required this.contractTemplateNames,
    required this.onboardingPackNames,
    required this.probationPlanNames,
    required this.offboardingPackNames,
    required this.onRequirementNameChanged,
    required this.onEntityChanged,
    required this.onStageChanged,
    required this.onStatusChanged,
    required this.onJobProfileChanged,
    required this.onContractTemplateChanged,
    required this.onOnboardingPackChanged,
    required this.onProbationPlanChanged,
    required this.onOffboardingPackChanged,
    required this.onOwnerChanged,
    required this.onEvidenceOwnerChanged,
    required this.onPolicyChanged,
    required this.onCollectionChannelChanged,
    required this.onStorageLocationChanged,
    required this.onRetentionRuleChanged,
    required this.onRequiredDocumentsChanged,
    required this.onNextReviewChanged,
    required this.onNotesChanged,
    required this.onSubmit,
    required this.onClear,
  });

  @override
  State<CompanyDocumentRequirementFormPanel> createState() =>
      _CompanyDocumentRequirementFormPanelState();
}

class _CompanyDocumentRequirementFormPanelState
    extends State<CompanyDocumentRequirementFormPanel> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _ownerController;
  late final TextEditingController _evidenceOwnerController;
  late final TextEditingController _policyController;
  late final TextEditingController _channelController;
  late final TextEditingController _storageController;
  late final TextEditingController _retentionController;
  late final TextEditingController _countController;
  late final TextEditingController _reviewController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.draft.requirementName);
    _ownerController = TextEditingController(text: widget.draft.ownerName);
    _evidenceOwnerController = TextEditingController(
      text: widget.draft.evidenceOwnerName,
    );
    _policyController = TextEditingController(
      text: widget.draft.policyReference,
    );
    _channelController = TextEditingController(
      text: widget.draft.collectionChannel,
    );
    _storageController = TextEditingController(
      text: widget.draft.storageLocation,
    );
    _retentionController = TextEditingController(
      text: widget.draft.retentionRule,
    );
    _countController = TextEditingController(
      text: widget.draft.requiredDocumentCountText,
    );
    _reviewController = TextEditingController(
      text: widget.draft.nextReviewDateText,
    );
    _notesController = TextEditingController(text: widget.draft.notes);
  }

  @override
  void didUpdateWidget(
    covariant CompanyDocumentRequirementFormPanel oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);
    _sync(_nameController, widget.draft.requirementName);
    _sync(_ownerController, widget.draft.ownerName);
    _sync(_evidenceOwnerController, widget.draft.evidenceOwnerName);
    _sync(_policyController, widget.draft.policyReference);
    _sync(_channelController, widget.draft.collectionChannel);
    _sync(_storageController, widget.draft.storageLocation);
    _sync(_retentionController, widget.draft.retentionRule);
    _sync(_countController, widget.draft.requiredDocumentCountText);
    _sync(_reviewController, widget.draft.nextReviewDateText);
    _sync(_notesController, widget.draft.notes);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ownerController.dispose();
    _evidenceOwnerController.dispose();
    _policyController.dispose();
    _channelController.dispose();
    _storageController.dispose();
    _retentionController.dispose();
    _countController.dispose();
    _reviewController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectableEntities =
        widget.entities.where((entity) => entity != 'All').toList();
    final selectedEntity = _selectedString(
      selectableEntities,
      widget.draft.entityName,
    );
    final selectedJobProfile = _selectedString(
      widget.jobProfileCodes,
      widget.draft.jobProfileCode,
    );
    final selectedContract = _selectedString(
      widget.contractTemplateNames,
      widget.draft.contractTemplateName,
    );
    final selectedOnboarding = _selectedString(
      widget.onboardingPackNames,
      widget.draft.onboardingPackName,
    );
    final selectedProbation = _selectedString(
      widget.probationPlanNames,
      widget.draft.probationPlanName,
    );
    final selectedOffboarding = _selectedString(
      widget.offboardingPackNames,
      widget.draft.offboardingPackName,
    );

    return HrisSectionPanel(
      icon: Icons.folder_copy_outlined,
      title: 'Document Requirement Form',
      subtitle:
          'Define required employment evidence by stage, job, and lifecycle pack',
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              _TextInput(
                key: const Key('company-doc-requirement-name-field'),
                controller: _nameController,
                label: 'Requirement name',
                icon: Icons.folder_copy_outlined,
                onChanged: widget.onRequirementNameChanged,
                validator:
                    (value) => CompanyDocumentRequirementDraft.validateRequired(
                      value,
                      'requirement name',
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StringDropdown(
                      label: 'Legal entity',
                      icon: Icons.business_outlined,
                      value: selectedEntity,
                      options: selectableEntities,
                      onChanged: widget.onEntityChanged,
                      requiredLabel: 'legal entity',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<
                      CompanyDocumentRequirementStage
                    >(
                      isExpanded: true,
                      initialValue: widget.draft.stage,
                      decoration: const InputDecoration(
                        labelText: 'Stage',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.timeline_outlined),
                      ),
                      items:
                          CompanyDocumentRequirementStage.values
                              .map(
                                (stage) => DropdownMenuItem(
                                  value: stage,
                                  child: Text(
                                    stage.label,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (stage) {
                        if (stage != null) widget.onStageChanged(stage);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<
                      CompanyDocumentRequirementStatus
                    >(
                      isExpanded: true,
                      initialValue: widget.draft.status,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.task_alt_outlined),
                      ),
                      items:
                          CompanyDocumentRequirementStatus.values
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
                    child: _StringDropdown(
                      label: 'Job profile',
                      icon: Icons.badge_outlined,
                      value: selectedJobProfile,
                      options: widget.jobProfileCodes,
                      onChanged: widget.onJobProfileChanged,
                      requiredLabel: 'job profile',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StringDropdown(
                      label: 'Contract template',
                      icon: Icons.article_outlined,
                      value: selectedContract,
                      options: widget.contractTemplateNames,
                      onChanged: widget.onContractTemplateChanged,
                      requiredLabel:
                          widget.draft.requiresContractTemplate
                              ? 'contract template'
                              : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StringDropdown(
                      label: 'Onboarding pack',
                      icon: Icons.playlist_add_check_outlined,
                      value: selectedOnboarding,
                      options: widget.onboardingPackNames,
                      onChanged: widget.onOnboardingPackChanged,
                      requiredLabel:
                          widget.draft.requiresOnboardingPack
                              ? 'onboarding pack'
                              : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StringDropdown(
                      label: 'Probation plan',
                      icon: Icons.fact_check_outlined,
                      value: selectedProbation,
                      options: widget.probationPlanNames,
                      onChanged: widget.onProbationPlanChanged,
                      requiredLabel:
                          widget.draft.requiresProbationPlan
                              ? 'probation plan'
                              : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StringDropdown(
                      label: 'Offboarding pack',
                      icon: Icons.logout_outlined,
                      value: selectedOffboarding,
                      options: widget.offboardingPackNames,
                      onChanged: widget.onOffboardingPackChanged,
                      requiredLabel:
                          widget.draft.requiresOffboardingPack
                              ? 'offboarding pack'
                              : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-doc-requirement-owner-field'),
                      controller: _ownerController,
                      label: 'Owner',
                      icon: Icons.supervisor_account_outlined,
                      onChanged: widget.onOwnerChanged,
                      validator:
                          (value) =>
                              CompanyDocumentRequirementDraft.validateRequired(
                                value,
                                'owner',
                              ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TextInput(
                      key: const Key(
                        'company-doc-requirement-evidence-owner-field',
                      ),
                      controller: _evidenceOwnerController,
                      label: 'Evidence owner',
                      icon: Icons.assignment_ind_outlined,
                      onChanged: widget.onEvidenceOwnerChanged,
                      validator:
                          (value) =>
                              CompanyDocumentRequirementDraft.validateRequired(
                                value,
                                'evidence owner',
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
                      key: const Key('company-doc-requirement-count-field'),
                      controller: _countController,
                      label: 'Required documents',
                      icon: Icons.format_list_numbered_outlined,
                      keyboardType: TextInputType.number,
                      onChanged: widget.onRequiredDocumentsChanged,
                      validator:
                          (value) =>
                              CompanyDocumentRequirementDraft.validatePositiveInt(
                                value,
                                'required documents',
                              ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-doc-requirement-review-field'),
                      controller: _reviewController,
                      label: 'Next review',
                      icon: Icons.event_outlined,
                      onChanged: widget.onNextReviewChanged,
                      validator: CompanyDocumentRequirementDraft.validateDate,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-doc-requirement-policy-field'),
                controller: _policyController,
                label: 'Policy reference',
                icon: Icons.policy_outlined,
                onChanged: widget.onPolicyChanged,
                validator:
                    (value) => CompanyDocumentRequirementDraft.validateRequired(
                      value,
                      'policy reference',
                    ),
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-doc-requirement-channel-field'),
                controller: _channelController,
                label: 'Collection channel',
                icon: Icons.cloud_upload_outlined,
                minLines: 2,
                maxLines: 3,
                onChanged: widget.onCollectionChannelChanged,
                validator:
                    (value) => CompanyDocumentRequirementDraft.validateRequired(
                      value,
                      'collection channel',
                    ),
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-doc-requirement-storage-field'),
                controller: _storageController,
                label: 'Storage location',
                icon: Icons.inventory_2_outlined,
                onChanged: widget.onStorageLocationChanged,
                validator:
                    (value) => CompanyDocumentRequirementDraft.validateRequired(
                      value,
                      'storage location',
                    ),
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-doc-requirement-retention-field'),
                controller: _retentionController,
                label: 'Retention rule',
                icon: Icons.history_outlined,
                onChanged: widget.onRetentionRuleChanged,
                validator:
                    (value) => CompanyDocumentRequirementDraft.validateRequired(
                      value,
                      'retention rule',
                    ),
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-doc-requirement-notes-field'),
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
                    key: const Key('company-doc-requirement-save-button'),
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        widget.onSubmit();
                      }
                    },
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Save requirement'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String? _selectedString(List<String> options, String value) {
    return options.contains(value) ? value : null;
  }

  void _sync(TextEditingController controller, String value) {
    if (controller.text == value) return;
    controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }
}

class _StringDropdown extends StatelessWidget {
  final String label;
  final IconData icon;
  final String? value;
  final List<String> options;
  final ValueChanged<String> onChanged;
  final String? requiredLabel;

  const _StringDropdown({
    required this.label,
    required this.icon,
    required this.value,
    required this.options,
    required this.onChanged,
    this.requiredLabel,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
      items:
          options
              .map(
                (option) => DropdownMenuItem(
                  value: option,
                  child: Text(option, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
      onChanged: (option) {
        if (option != null) onChanged(option);
      },
      validator:
          requiredLabel == null
              ? null
              : (value) => CompanyDocumentRequirementDraft.validateRequired(
                value,
                requiredLabel!,
              ),
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
