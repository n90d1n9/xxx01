import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/company_change_request.dart';

class CompanyChangeRequestFormPanel extends StatefulWidget {
  final CompanyChangeRequestDraft draft;
  final List<String> entities;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onEntityChanged;
  final ValueChanged<String> onOwnerChanged;
  final ValueChanged<CompanyChangeRequestType> onTypeChanged;
  final ValueChanged<CompanyChangeRequestPriority> onPriorityChanged;
  final ValueChanged<CompanyChangeRequestStatus> onStatusChanged;
  final ValueChanged<String> onEffectiveDateChanged;
  final ValueChanged<String> onImpactChanged;
  final ValueChanged<String> onApproverChanged;
  final ValueChanged<String> onLinkedRecordChanged;
  final VoidCallback onSubmit;
  final VoidCallback onClear;

  const CompanyChangeRequestFormPanel({
    super.key,
    required this.draft,
    required this.entities,
    required this.onTitleChanged,
    required this.onEntityChanged,
    required this.onOwnerChanged,
    required this.onTypeChanged,
    required this.onPriorityChanged,
    required this.onStatusChanged,
    required this.onEffectiveDateChanged,
    required this.onImpactChanged,
    required this.onApproverChanged,
    required this.onLinkedRecordChanged,
    required this.onSubmit,
    required this.onClear,
  });

  @override
  State<CompanyChangeRequestFormPanel> createState() =>
      _CompanyChangeRequestFormPanelState();
}

class _CompanyChangeRequestFormPanelState
    extends State<CompanyChangeRequestFormPanel> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _ownerController;
  late final TextEditingController _effectiveDateController;
  late final TextEditingController _impactController;
  late final TextEditingController _approverController;
  late final TextEditingController _linkedRecordController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.draft.title);
    _ownerController = TextEditingController(text: widget.draft.ownerName);
    _effectiveDateController = TextEditingController(
      text: widget.draft.effectiveDateText,
    );
    _impactController = TextEditingController(text: widget.draft.impactSummary);
    _approverController = TextEditingController(
      text: widget.draft.approverRole,
    );
    _linkedRecordController = TextEditingController(
      text: widget.draft.linkedRecord,
    );
  }

  @override
  void didUpdateWidget(covariant CompanyChangeRequestFormPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync(_titleController, widget.draft.title);
    _sync(_ownerController, widget.draft.ownerName);
    _sync(_effectiveDateController, widget.draft.effectiveDateText);
    _sync(_impactController, widget.draft.impactSummary);
    _sync(_approverController, widget.draft.approverRole);
    _sync(_linkedRecordController, widget.draft.linkedRecord);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _ownerController.dispose();
    _effectiveDateController.dispose();
    _impactController.dispose();
    _approverController.dispose();
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
      icon: Icons.sync_alt_outlined,
      title: 'Change Request Form',
      subtitle: 'Plan effective-dated company setup changes',
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              _TextInput(
                key: const Key('company-change-title-field'),
                controller: _titleController,
                label: 'Change title',
                icon: Icons.drive_file_rename_outline,
                onChanged: widget.onTitleChanged,
                validator:
                    (value) => CompanyChangeRequestDraft.validateRequired(
                      value,
                      'change title',
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
                          (value) => CompanyChangeRequestDraft.validateRequired(
                            value,
                            'legal entity',
                          ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<CompanyChangeRequestType>(
                      isExpanded: true,
                      initialValue: widget.draft.type,
                      decoration: const InputDecoration(
                        labelText: 'Change type',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items:
                          CompanyChangeRequestType.values
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
                        DropdownButtonFormField<CompanyChangeRequestPriority>(
                          isExpanded: true,
                          initialValue: widget.draft.priority,
                          decoration: const InputDecoration(
                            labelText: 'Priority',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.priority_high_outlined),
                          ),
                          items:
                              CompanyChangeRequestPriority.values
                                  .map(
                                    (priority) => DropdownMenuItem(
                                      value: priority,
                                      child: Text(
                                        priority.label,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (priority) {
                            if (priority != null) {
                              widget.onPriorityChanged(priority);
                            }
                          },
                        ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<CompanyChangeRequestStatus>(
                      isExpanded: true,
                      initialValue: widget.draft.status,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.flag_outlined),
                      ),
                      items:
                          CompanyChangeRequestStatus.values
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
                      key: const Key('company-change-owner-field'),
                      controller: _ownerController,
                      label: 'Owner',
                      icon: Icons.supervisor_account_outlined,
                      onChanged: widget.onOwnerChanged,
                      validator:
                          (value) => CompanyChangeRequestDraft.validateRequired(
                            value,
                            'owner',
                          ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-change-effective-field'),
                      controller: _effectiveDateController,
                      label: 'Effective date',
                      icon: Icons.event_available_outlined,
                      keyboardType: TextInputType.datetime,
                      onChanged: widget.onEffectiveDateChanged,
                      validator: CompanyChangeRequestDraft.validateDate,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-change-approver-field'),
                controller: _approverController,
                label: 'Approver role',
                icon: Icons.verified_user_outlined,
                onChanged: widget.onApproverChanged,
                validator:
                    (value) => CompanyChangeRequestDraft.validateRequired(
                      value,
                      'approver role',
                    ),
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-change-linked-field'),
                controller: _linkedRecordController,
                label: 'Linked record',
                icon: Icons.link_outlined,
                onChanged: widget.onLinkedRecordChanged,
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-change-impact-field'),
                controller: _impactController,
                label: 'Impact summary',
                icon: Icons.notes_outlined,
                maxLines: 3,
                onChanged: widget.onImpactChanged,
                validator:
                    (value) => CompanyChangeRequestDraft.validateRequired(
                      value,
                      'impact summary',
                    ),
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
                    key: const Key('company-change-save-button'),
                    onPressed: _submit,
                    icon: const Icon(Icons.playlist_add_check_outlined),
                    label: const Text('Add change'),
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
  final int maxLines;
  final ValueChanged<String> onChanged;
  final String? Function(String?)? validator;

  const _TextInput({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.maxLines = 1,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
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
