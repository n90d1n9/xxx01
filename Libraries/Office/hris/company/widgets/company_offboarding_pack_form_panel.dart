import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/company_offboarding_pack.dart';

class CompanyOffboardingPackFormPanel extends StatefulWidget {
  final CompanyOffboardingPackDraft draft;
  final List<String> entities;
  final List<String> jobProfileCodes;
  final ValueChanged<String> onPackNameChanged;
  final ValueChanged<String> onEntityChanged;
  final ValueChanged<CompanyOffboardingPackType> onTypeChanged;
  final ValueChanged<CompanyOffboardingPackStatus> onStatusChanged;
  final ValueChanged<String> onJobProfileChanged;
  final ValueChanged<String> onOwnerChanged;
  final ValueChanged<String> onManagerRoleChanged;
  final ValueChanged<String> onKnowledgeTransferChanged;
  final ValueChanged<String> onAssetReturnChanged;
  final ValueChanged<String> onAccessRevocationChanged;
  final ValueChanged<String> onFinalPayrollChanged;
  final ValueChanged<String> onDocumentChecklistChanged;
  final ValueChanged<String> onExitInterviewChanged;
  final ValueChanged<String> onRequiredTasksChanged;
  final ValueChanged<String> onSlaChanged;
  final ValueChanged<String> onNextReviewChanged;
  final ValueChanged<String> onNotesChanged;
  final VoidCallback onSubmit;
  final VoidCallback onClear;

  const CompanyOffboardingPackFormPanel({
    super.key,
    required this.draft,
    required this.entities,
    required this.jobProfileCodes,
    required this.onPackNameChanged,
    required this.onEntityChanged,
    required this.onTypeChanged,
    required this.onStatusChanged,
    required this.onJobProfileChanged,
    required this.onOwnerChanged,
    required this.onManagerRoleChanged,
    required this.onKnowledgeTransferChanged,
    required this.onAssetReturnChanged,
    required this.onAccessRevocationChanged,
    required this.onFinalPayrollChanged,
    required this.onDocumentChecklistChanged,
    required this.onExitInterviewChanged,
    required this.onRequiredTasksChanged,
    required this.onSlaChanged,
    required this.onNextReviewChanged,
    required this.onNotesChanged,
    required this.onSubmit,
    required this.onClear,
  });

  @override
  State<CompanyOffboardingPackFormPanel> createState() =>
      _CompanyOffboardingPackFormPanelState();
}

class _CompanyOffboardingPackFormPanelState
    extends State<CompanyOffboardingPackFormPanel> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _ownerController;
  late final TextEditingController _managerController;
  late final TextEditingController _knowledgeController;
  late final TextEditingController _assetController;
  late final TextEditingController _accessController;
  late final TextEditingController _payrollController;
  late final TextEditingController _documentController;
  late final TextEditingController _interviewController;
  late final TextEditingController _tasksController;
  late final TextEditingController _slaController;
  late final TextEditingController _reviewController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.draft.packName);
    _ownerController = TextEditingController(text: widget.draft.ownerName);
    _managerController = TextEditingController(text: widget.draft.managerRole);
    _knowledgeController = TextEditingController(
      text: widget.draft.knowledgeTransferPlan,
    );
    _assetController = TextEditingController(
      text: widget.draft.assetReturnChecklist,
    );
    _accessController = TextEditingController(
      text: widget.draft.accessRevocationChecklist,
    );
    _payrollController = TextEditingController(
      text: widget.draft.finalPayrollChecklist,
    );
    _documentController = TextEditingController(
      text: widget.draft.documentChecklist,
    );
    _interviewController = TextEditingController(
      text: widget.draft.exitInterviewTemplate,
    );
    _tasksController = TextEditingController(
      text: widget.draft.requiredTaskCountText,
    );
    _slaController = TextEditingController(text: widget.draft.slaDaysText);
    _reviewController = TextEditingController(
      text: widget.draft.nextReviewDateText,
    );
    _notesController = TextEditingController(text: widget.draft.notes);
  }

  @override
  void didUpdateWidget(covariant CompanyOffboardingPackFormPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync(_nameController, widget.draft.packName);
    _sync(_ownerController, widget.draft.ownerName);
    _sync(_managerController, widget.draft.managerRole);
    _sync(_knowledgeController, widget.draft.knowledgeTransferPlan);
    _sync(_assetController, widget.draft.assetReturnChecklist);
    _sync(_accessController, widget.draft.accessRevocationChecklist);
    _sync(_payrollController, widget.draft.finalPayrollChecklist);
    _sync(_documentController, widget.draft.documentChecklist);
    _sync(_interviewController, widget.draft.exitInterviewTemplate);
    _sync(_tasksController, widget.draft.requiredTaskCountText);
    _sync(_slaController, widget.draft.slaDaysText);
    _sync(_reviewController, widget.draft.nextReviewDateText);
    _sync(_notesController, widget.draft.notes);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ownerController.dispose();
    _managerController.dispose();
    _knowledgeController.dispose();
    _assetController.dispose();
    _accessController.dispose();
    _payrollController.dispose();
    _documentController.dispose();
    _interviewController.dispose();
    _tasksController.dispose();
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

    return HrisSectionPanel(
      icon: Icons.logout_outlined,
      title: 'Offboarding Pack Form',
      subtitle:
          'Create reusable exit workflows for access, payroll, and handover',
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              _TextInput(
                key: const Key('company-offboarding-name-field'),
                controller: _nameController,
                label: 'Pack name',
                icon: Icons.logout_outlined,
                onChanged: widget.onPackNameChanged,
                validator:
                    (value) => CompanyOffboardingPackDraft.validateRequired(
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
                              CompanyOffboardingPackDraft.validateRequired(
                                value,
                                'legal entity',
                              ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<CompanyOffboardingPackType>(
                      isExpanded: true,
                      initialValue: widget.draft.type,
                      decoration: const InputDecoration(
                        labelText: 'Type',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.route_outlined),
                      ),
                      items:
                          CompanyOffboardingPackType.values
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
                        DropdownButtonFormField<CompanyOffboardingPackStatus>(
                          isExpanded: true,
                          initialValue: widget.draft.status,
                          decoration: const InputDecoration(
                            labelText: 'Status',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.task_alt_outlined),
                          ),
                          items:
                              CompanyOffboardingPackStatus.values
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
                              CompanyOffboardingPackDraft.validateRequired(
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
                    child: _TextInput(
                      key: const Key('company-offboarding-owner-field'),
                      controller: _ownerController,
                      label: 'Owner',
                      icon: Icons.supervisor_account_outlined,
                      onChanged: widget.onOwnerChanged,
                      validator:
                          (value) =>
                              CompanyOffboardingPackDraft.validateRequired(
                                value,
                                'owner',
                              ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-offboarding-manager-field'),
                      controller: _managerController,
                      label: 'Manager role',
                      icon: Icons.manage_accounts_outlined,
                      onChanged: widget.onManagerRoleChanged,
                      validator:
                          (value) =>
                              CompanyOffboardingPackDraft.validateRequired(
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
                      key: const Key('company-offboarding-tasks-field'),
                      controller: _tasksController,
                      label: 'Required tasks',
                      icon: Icons.format_list_numbered_outlined,
                      keyboardType: TextInputType.number,
                      onChanged: widget.onRequiredTasksChanged,
                      validator:
                          (value) =>
                              CompanyOffboardingPackDraft.validatePositiveInt(
                                value,
                                'required tasks',
                              ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-offboarding-sla-field'),
                      controller: _slaController,
                      label: 'SLA days',
                      icon: Icons.timer_outlined,
                      keyboardType: TextInputType.number,
                      onChanged: widget.onSlaChanged,
                      validator:
                          (value) =>
                              CompanyOffboardingPackDraft.validatePositiveInt(
                                value,
                                'SLA days',
                              ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-offboarding-review-field'),
                      controller: _reviewController,
                      label: 'Next review',
                      icon: Icons.event_outlined,
                      onChanged: widget.onNextReviewChanged,
                      validator: CompanyOffboardingPackDraft.validateDate,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-offboarding-knowledge-field'),
                controller: _knowledgeController,
                label: 'Knowledge transfer plan',
                icon: Icons.transfer_within_a_station_outlined,
                minLines: 2,
                maxLines: 3,
                onChanged: widget.onKnowledgeTransferChanged,
                validator:
                    (value) => CompanyOffboardingPackDraft.validateRequired(
                      value,
                      'knowledge transfer',
                    ),
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-offboarding-asset-field'),
                controller: _assetController,
                label: 'Asset return checklist',
                icon: Icons.inventory_2_outlined,
                minLines: 2,
                maxLines: 3,
                onChanged: widget.onAssetReturnChanged,
                validator:
                    (value) => CompanyOffboardingPackDraft.validateRequired(
                      value,
                      'asset return',
                    ),
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-offboarding-access-field'),
                controller: _accessController,
                label: 'Access revocation checklist',
                icon: Icons.no_accounts_outlined,
                minLines: 2,
                maxLines: 3,
                onChanged: widget.onAccessRevocationChanged,
                validator:
                    (value) => CompanyOffboardingPackDraft.validateRequired(
                      value,
                      'access revocation',
                    ),
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-offboarding-payroll-field'),
                controller: _payrollController,
                label: 'Final payroll checklist',
                icon: Icons.payments_outlined,
                minLines: 2,
                maxLines: 3,
                onChanged: widget.onFinalPayrollChanged,
                validator:
                    (value) => CompanyOffboardingPackDraft.validateRequired(
                      value,
                      'final payroll',
                    ),
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-offboarding-document-field'),
                controller: _documentController,
                label: 'Document checklist',
                icon: Icons.folder_copy_outlined,
                minLines: 2,
                maxLines: 3,
                onChanged: widget.onDocumentChecklistChanged,
                validator:
                    (value) => CompanyOffboardingPackDraft.validateRequired(
                      value,
                      'document checklist',
                    ),
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-offboarding-interview-field'),
                controller: _interviewController,
                label: 'Exit interview template',
                icon: Icons.rate_review_outlined,
                minLines: 2,
                maxLines: 3,
                onChanged: widget.onExitInterviewChanged,
                validator:
                    (value) => CompanyOffboardingPackDraft.validateRequired(
                      value,
                      'exit interview',
                    ),
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-offboarding-notes-field'),
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
                    key: const Key('company-offboarding-save-button'),
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
