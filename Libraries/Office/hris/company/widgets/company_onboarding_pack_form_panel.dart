import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/company_onboarding_pack.dart';

class CompanyOnboardingPackFormPanel extends StatefulWidget {
  final CompanyOnboardingPackDraft draft;
  final List<String> entities;
  final List<String> jobProfileCodes;
  final List<String> contractTemplateNames;
  final ValueChanged<String> onPackNameChanged;
  final ValueChanged<String> onEntityChanged;
  final ValueChanged<CompanyOnboardingPackType> onTypeChanged;
  final ValueChanged<CompanyOnboardingPackStatus> onStatusChanged;
  final ValueChanged<String> onJobProfileChanged;
  final ValueChanged<String> onContractTemplateChanged;
  final ValueChanged<String> onOwnerChanged;
  final ValueChanged<String> onManagerHandoffChanged;
  final ValueChanged<String> onDocumentChecklistChanged;
  final ValueChanged<String> onAccessChecklistChanged;
  final ValueChanged<String> onEquipmentChecklistChanged;
  final ValueChanged<String> onRequiredTasksChanged;
  final ValueChanged<String> onAutomationChanged;
  final ValueChanged<String> onSlaChanged;
  final ValueChanged<String> onNextReviewChanged;
  final ValueChanged<String> onNotesChanged;
  final VoidCallback onSubmit;
  final VoidCallback onClear;

  const CompanyOnboardingPackFormPanel({
    super.key,
    required this.draft,
    required this.entities,
    required this.jobProfileCodes,
    required this.contractTemplateNames,
    required this.onPackNameChanged,
    required this.onEntityChanged,
    required this.onTypeChanged,
    required this.onStatusChanged,
    required this.onJobProfileChanged,
    required this.onContractTemplateChanged,
    required this.onOwnerChanged,
    required this.onManagerHandoffChanged,
    required this.onDocumentChecklistChanged,
    required this.onAccessChecklistChanged,
    required this.onEquipmentChecklistChanged,
    required this.onRequiredTasksChanged,
    required this.onAutomationChanged,
    required this.onSlaChanged,
    required this.onNextReviewChanged,
    required this.onNotesChanged,
    required this.onSubmit,
    required this.onClear,
  });

  @override
  State<CompanyOnboardingPackFormPanel> createState() =>
      _CompanyOnboardingPackFormPanelState();
}

class _CompanyOnboardingPackFormPanelState
    extends State<CompanyOnboardingPackFormPanel> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _ownerController;
  late final TextEditingController _managerController;
  late final TextEditingController _documentController;
  late final TextEditingController _accessController;
  late final TextEditingController _equipmentController;
  late final TextEditingController _tasksController;
  late final TextEditingController _automationController;
  late final TextEditingController _slaController;
  late final TextEditingController _reviewController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.draft.packName);
    _ownerController = TextEditingController(text: widget.draft.ownerName);
    _managerController = TextEditingController(
      text: widget.draft.managerHandoff,
    );
    _documentController = TextEditingController(
      text: widget.draft.documentChecklist,
    );
    _accessController = TextEditingController(
      text: widget.draft.accessChecklist,
    );
    _equipmentController = TextEditingController(
      text: widget.draft.equipmentChecklist,
    );
    _tasksController = TextEditingController(
      text: widget.draft.requiredTaskCountText,
    );
    _automationController = TextEditingController(
      text: widget.draft.automationCoverageText,
    );
    _slaController = TextEditingController(text: widget.draft.slaDaysText);
    _reviewController = TextEditingController(
      text: widget.draft.nextReviewDateText,
    );
    _notesController = TextEditingController(text: widget.draft.notes);
  }

  @override
  void didUpdateWidget(covariant CompanyOnboardingPackFormPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync(_nameController, widget.draft.packName);
    _sync(_ownerController, widget.draft.ownerName);
    _sync(_managerController, widget.draft.managerHandoff);
    _sync(_documentController, widget.draft.documentChecklist);
    _sync(_accessController, widget.draft.accessChecklist);
    _sync(_equipmentController, widget.draft.equipmentChecklist);
    _sync(_tasksController, widget.draft.requiredTaskCountText);
    _sync(_automationController, widget.draft.automationCoverageText);
    _sync(_slaController, widget.draft.slaDaysText);
    _sync(_reviewController, widget.draft.nextReviewDateText);
    _sync(_notesController, widget.draft.notes);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ownerController.dispose();
    _managerController.dispose();
    _documentController.dispose();
    _accessController.dispose();
    _equipmentController.dispose();
    _tasksController.dispose();
    _automationController.dispose();
    _slaController.dispose();
    _reviewController.dispose();
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
    final selectedContract =
        widget.contractTemplateNames.contains(widget.draft.contractTemplateName)
            ? widget.draft.contractTemplateName
            : widget.contractTemplateNames.firstOrNull;

    return HrisSectionPanel(
      icon: Icons.playlist_add_check_outlined,
      title: 'Onboarding Pack Form',
      subtitle: 'Create reusable preboarding, onboarding, and transfer packs',
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              _TextInput(
                key: const Key('company-onboarding-name-field'),
                controller: _nameController,
                label: 'Pack name',
                icon: Icons.playlist_add_check_outlined,
                onChanged: widget.onPackNameChanged,
                validator:
                    (value) => CompanyOnboardingPackDraft.validateRequired(
                      value,
                      'pack name',
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
                              CompanyOnboardingPackDraft.validateRequired(
                                value,
                                'legal entity',
                              ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<CompanyOnboardingPackType>(
                      isExpanded: true,
                      initialValue: widget.draft.type,
                      decoration: const InputDecoration(
                        labelText: 'Type',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.route_outlined),
                      ),
                      items:
                          CompanyOnboardingPackType.values
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
                    child: DropdownButtonFormField<CompanyOnboardingPackStatus>(
                      isExpanded: true,
                      initialValue: widget.draft.status,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.task_alt_outlined),
                      ),
                      items:
                          CompanyOnboardingPackStatus.values
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
                              CompanyOnboardingPackDraft.validateRequired(
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
                initialValue: selectedContract,
                decoration: const InputDecoration(
                  labelText: 'Contract template',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.article_outlined),
                ),
                items:
                    widget.contractTemplateNames
                        .map(
                          (template) => DropdownMenuItem(
                            value: template,
                            child: Text(
                              template,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                onChanged: (template) {
                  if (template != null) {
                    widget.onContractTemplateChanged(template);
                  }
                },
                validator:
                    (value) => CompanyOnboardingPackDraft.validateRequired(
                      value,
                      'contract template',
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-onboarding-owner-field'),
                      controller: _ownerController,
                      label: 'Owner',
                      icon: Icons.supervisor_account_outlined,
                      onChanged: widget.onOwnerChanged,
                      validator:
                          (value) =>
                              CompanyOnboardingPackDraft.validateRequired(
                                value,
                                'owner',
                              ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-onboarding-review-field'),
                      controller: _reviewController,
                      label: 'Next review (YYYY-MM-DD)',
                      icon: Icons.event_outlined,
                      onChanged: widget.onNextReviewChanged,
                      validator: CompanyOnboardingPackDraft.validateDate,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-onboarding-tasks-field'),
                      controller: _tasksController,
                      label: 'Required tasks',
                      icon: Icons.format_list_numbered_outlined,
                      keyboardType: TextInputType.number,
                      onChanged: widget.onRequiredTasksChanged,
                      validator:
                          (value) =>
                              CompanyOnboardingPackDraft.validatePositiveInt(
                                value,
                                'required tasks',
                              ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-onboarding-automation-field'),
                      controller: _automationController,
                      label: 'Automation %',
                      icon: Icons.auto_awesome_outlined,
                      keyboardType: TextInputType.number,
                      onChanged: widget.onAutomationChanged,
                      validator: CompanyOnboardingPackDraft.validatePercent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-onboarding-sla-field'),
                      controller: _slaController,
                      label: 'SLA days',
                      icon: Icons.timer_outlined,
                      keyboardType: TextInputType.number,
                      onChanged: widget.onSlaChanged,
                      validator:
                          (value) =>
                              CompanyOnboardingPackDraft.validatePositiveInt(
                                value,
                                'SLA days',
                              ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-onboarding-manager-field'),
                controller: _managerController,
                label: 'Manager handoff',
                icon: Icons.handshake_outlined,
                minLines: 2,
                maxLines: 3,
                onChanged: widget.onManagerHandoffChanged,
                validator:
                    (value) => CompanyOnboardingPackDraft.validateRequired(
                      value,
                      'manager handoff',
                    ),
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-onboarding-document-field'),
                controller: _documentController,
                label: 'Document checklist',
                icon: Icons.folder_copy_outlined,
                minLines: 2,
                maxLines: 3,
                onChanged: widget.onDocumentChecklistChanged,
                validator:
                    (value) => CompanyOnboardingPackDraft.validateRequired(
                      value,
                      'document checklist',
                    ),
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-onboarding-access-field'),
                controller: _accessController,
                label: 'Access checklist',
                icon: Icons.key_outlined,
                minLines: 2,
                maxLines: 3,
                onChanged: widget.onAccessChecklistChanged,
                validator:
                    (value) => CompanyOnboardingPackDraft.validateRequired(
                      value,
                      'access checklist',
                    ),
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-onboarding-equipment-field'),
                controller: _equipmentController,
                label: 'Equipment checklist',
                icon: Icons.devices_outlined,
                minLines: 2,
                maxLines: 3,
                onChanged: widget.onEquipmentChecklistChanged,
                validator:
                    (value) => CompanyOnboardingPackDraft.validateRequired(
                      value,
                      'equipment checklist',
                    ),
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-onboarding-notes-field'),
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
                    key: const Key('company-onboarding-save-button'),
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        widget.onSubmit();
                      }
                    },
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Save pack'),
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
