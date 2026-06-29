import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/company_filing.dart';

class CompanyFilingFormPanel extends StatefulWidget {
  final CompanyFilingDraft draft;
  final List<String> entities;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onEntityChanged;
  final ValueChanged<CompanyFilingType> onTypeChanged;
  final ValueChanged<CompanyFilingCadence> onCadenceChanged;
  final ValueChanged<CompanyFilingStatus> onStatusChanged;
  final ValueChanged<String> onOwnerChanged;
  final ValueChanged<String> onAuthorityChanged;
  final ValueChanged<String> onDueDateChanged;
  final ValueChanged<String> onEvidenceChanged;
  final ValueChanged<String> onNextStepChanged;
  final ValueChanged<String> onLinkedRecordChanged;
  final VoidCallback onSubmit;
  final VoidCallback onClear;

  const CompanyFilingFormPanel({
    super.key,
    required this.draft,
    required this.entities,
    required this.onTitleChanged,
    required this.onEntityChanged,
    required this.onTypeChanged,
    required this.onCadenceChanged,
    required this.onStatusChanged,
    required this.onOwnerChanged,
    required this.onAuthorityChanged,
    required this.onDueDateChanged,
    required this.onEvidenceChanged,
    required this.onNextStepChanged,
    required this.onLinkedRecordChanged,
    required this.onSubmit,
    required this.onClear,
  });

  @override
  State<CompanyFilingFormPanel> createState() => _CompanyFilingFormPanelState();
}

class _CompanyFilingFormPanelState extends State<CompanyFilingFormPanel> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _ownerController;
  late final TextEditingController _authorityController;
  late final TextEditingController _dueDateController;
  late final TextEditingController _evidenceController;
  late final TextEditingController _nextStepController;
  late final TextEditingController _linkedRecordController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.draft.title);
    _ownerController = TextEditingController(text: widget.draft.ownerName);
    _authorityController = TextEditingController(
      text: widget.draft.authorityName,
    );
    _dueDateController = TextEditingController(text: widget.draft.dueDateText);
    _evidenceController = TextEditingController(
      text: widget.draft.evidenceSummary,
    );
    _nextStepController = TextEditingController(text: widget.draft.nextStep);
    _linkedRecordController = TextEditingController(
      text: widget.draft.linkedRecord,
    );
  }

  @override
  void didUpdateWidget(covariant CompanyFilingFormPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync(_titleController, widget.draft.title);
    _sync(_ownerController, widget.draft.ownerName);
    _sync(_authorityController, widget.draft.authorityName);
    _sync(_dueDateController, widget.draft.dueDateText);
    _sync(_evidenceController, widget.draft.evidenceSummary);
    _sync(_nextStepController, widget.draft.nextStep);
    _sync(_linkedRecordController, widget.draft.linkedRecord);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _ownerController.dispose();
    _authorityController.dispose();
    _dueDateController.dispose();
    _evidenceController.dispose();
    _nextStepController.dispose();
    _linkedRecordController.dispose();
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

    return HrisSectionPanel(
      icon: Icons.event_note_outlined,
      title: 'Company Filing Form',
      subtitle: 'Schedule tax, BPJS, license, labor, and privacy filings',
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              _TextInput(
                key: const Key('company-filing-title-field'),
                controller: _titleController,
                label: 'Filing title',
                icon: Icons.drive_file_rename_outline,
                onChanged: widget.onTitleChanged,
                validator:
                    (value) => CompanyFilingDraft.validateRequired(
                      value,
                      'filing title',
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
                          (value) => CompanyFilingDraft.validateRequired(
                            value,
                            'legal entity',
                          ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<CompanyFilingType>(
                      isExpanded: true,
                      initialValue: widget.draft.type,
                      decoration: const InputDecoration(
                        labelText: 'Filing type',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items:
                          CompanyFilingType.values
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
                    child: DropdownButtonFormField<CompanyFilingCadence>(
                      isExpanded: true,
                      initialValue: widget.draft.cadence,
                      decoration: const InputDecoration(
                        labelText: 'Cadence',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.repeat_outlined),
                      ),
                      items:
                          CompanyFilingCadence.values
                              .map(
                                (cadence) => DropdownMenuItem(
                                  value: cadence,
                                  child: Text(
                                    cadence.label,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (cadence) {
                        if (cadence != null) widget.onCadenceChanged(cadence);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<CompanyFilingStatus>(
                      isExpanded: true,
                      initialValue: widget.draft.status,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.task_alt_outlined),
                      ),
                      items:
                          CompanyFilingStatus.values
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
                      key: const Key('company-filing-owner-field'),
                      controller: _ownerController,
                      label: 'Owner',
                      icon: Icons.supervisor_account_outlined,
                      onChanged: widget.onOwnerChanged,
                      validator:
                          (value) => CompanyFilingDraft.validateRequired(
                            value,
                            'owner',
                          ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-filing-authority-field'),
                      controller: _authorityController,
                      label: 'Authority',
                      icon: Icons.account_balance_outlined,
                      onChanged: widget.onAuthorityChanged,
                      validator:
                          (value) => CompanyFilingDraft.validateRequired(
                            value,
                            'authority',
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-filing-due-field'),
                controller: _dueDateController,
                label: 'Due date',
                icon: Icons.event_available_outlined,
                keyboardType: TextInputType.datetime,
                onChanged: widget.onDueDateChanged,
                validator: CompanyFilingDraft.validateDate,
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-filing-next-field'),
                controller: _nextStepController,
                label: 'Next step',
                icon: Icons.next_plan_outlined,
                onChanged: widget.onNextStepChanged,
                validator:
                    (value) =>
                        CompanyFilingDraft.validateRequired(value, 'next step'),
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-filing-evidence-field'),
                controller: _evidenceController,
                label: 'Evidence summary',
                icon: Icons.attach_file_outlined,
                onChanged: widget.onEvidenceChanged,
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-filing-linked-field'),
                controller: _linkedRecordController,
                label: 'Linked record',
                icon: Icons.link_outlined,
                onChanged: widget.onLinkedRecordChanged,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: widget.onClear,
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear'),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    key: const Key('company-filing-save-button'),
                    onPressed: _submit,
                    icon: const Icon(Icons.add_task_outlined),
                    label: const Text('Add filing'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSubmit();
    }
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
  final TextInputType? keyboardType;
  final ValueChanged<String> onChanged;
  final String? Function(String?)? validator;

  const _TextInput({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
        hintText: keyboardType == TextInputType.datetime ? 'YYYY-MM-DD' : null,
      ),
      onChanged: onChanged,
      validator: validator,
    );
  }
}
