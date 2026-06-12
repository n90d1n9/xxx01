import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/company_document.dart';

class CompanyDocumentFormPanel extends StatefulWidget {
  final CompanyDocumentDraft draft;
  final List<String> entities;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onDocumentNumberChanged;
  final ValueChanged<String> onEntityChanged;
  final ValueChanged<String> onOwnerChanged;
  final ValueChanged<CompanyDocumentType> onTypeChanged;
  final ValueChanged<String> onIssuedDateChanged;
  final ValueChanged<String> onExpiryDateChanged;
  final ValueChanged<CompanyDocumentStatus> onStatusChanged;
  final ValueChanged<String> onLinkedModuleChanged;
  final VoidCallback onSubmit;
  final VoidCallback onClear;

  const CompanyDocumentFormPanel({
    super.key,
    required this.draft,
    required this.entities,
    required this.onTitleChanged,
    required this.onDocumentNumberChanged,
    required this.onEntityChanged,
    required this.onOwnerChanged,
    required this.onTypeChanged,
    required this.onIssuedDateChanged,
    required this.onExpiryDateChanged,
    required this.onStatusChanged,
    required this.onLinkedModuleChanged,
    required this.onSubmit,
    required this.onClear,
  });

  @override
  State<CompanyDocumentFormPanel> createState() =>
      _CompanyDocumentFormPanelState();
}

class _CompanyDocumentFormPanelState extends State<CompanyDocumentFormPanel> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _numberController;
  late final TextEditingController _ownerController;
  late final TextEditingController _issuedController;
  late final TextEditingController _expiryController;
  late final TextEditingController _moduleController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.draft.title);
    _numberController = TextEditingController(
      text: widget.draft.documentNumber,
    );
    _ownerController = TextEditingController(text: widget.draft.ownerName);
    _issuedController = TextEditingController(
      text: widget.draft.issuedDateText,
    );
    _expiryController = TextEditingController(
      text: widget.draft.expiryDateText,
    );
    _moduleController = TextEditingController(text: widget.draft.linkedModule);
  }

  @override
  void didUpdateWidget(covariant CompanyDocumentFormPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync(_titleController, widget.draft.title);
    _sync(_numberController, widget.draft.documentNumber);
    _sync(_ownerController, widget.draft.ownerName);
    _sync(_issuedController, widget.draft.issuedDateText);
    _sync(_expiryController, widget.draft.expiryDateText);
    _sync(_moduleController, widget.draft.linkedModule);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _numberController.dispose();
    _ownerController.dispose();
    _issuedController.dispose();
    _expiryController.dispose();
    _moduleController.dispose();
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
      icon: Icons.description_outlined,
      title: 'Company Document Form',
      subtitle: 'Track statutory, payroll, lease, and policy documents',
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              _TextInput(
                key: const Key('company-document-title-field'),
                controller: _titleController,
                label: 'Document title',
                icon: Icons.article_outlined,
                onChanged: widget.onTitleChanged,
                validator:
                    (value) => CompanyDocumentDraft.validateRequired(
                      value,
                      'document title',
                    ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
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
                            child: Text(entity),
                          ),
                        )
                        .toList(),
                onChanged: (entity) {
                  if (entity != null) widget.onEntityChanged(entity);
                },
                validator:
                    (value) => CompanyDocumentDraft.validateRequired(
                      value,
                      'legal entity',
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<CompanyDocumentType>(
                      initialValue: widget.draft.type,
                      decoration: const InputDecoration(
                        labelText: 'Type',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items:
                          CompanyDocumentType.values
                              .map(
                                (type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(type.label),
                                ),
                              )
                              .toList(),
                      onChanged: (type) {
                        if (type != null) widget.onTypeChanged(type);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<CompanyDocumentStatus>(
                      initialValue: widget.draft.status,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.flag_outlined),
                      ),
                      items:
                          CompanyDocumentStatus.values
                              .map(
                                (status) => DropdownMenuItem(
                                  value: status,
                                  child: Text(status.label),
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
              _TextInput(
                key: const Key('company-document-number-field'),
                controller: _numberController,
                label: 'Document number',
                icon: Icons.confirmation_number_outlined,
                onChanged: widget.onDocumentNumberChanged,
                validator:
                    (value) => CompanyDocumentDraft.validateDocumentNumber(
                      value,
                      widget.draft.status,
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-document-owner-field'),
                      controller: _ownerController,
                      label: 'Owner',
                      icon: Icons.supervisor_account_outlined,
                      onChanged: widget.onOwnerChanged,
                      validator:
                          (value) => CompanyDocumentDraft.validateRequired(
                            value,
                            'owner',
                          ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-document-module-field'),
                      controller: _moduleController,
                      label: 'Linked module',
                      icon: Icons.hub_outlined,
                      onChanged: widget.onLinkedModuleChanged,
                      validator:
                          (value) => CompanyDocumentDraft.validateRequired(
                            value,
                            'linked module',
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
                      key: const Key('company-document-issued-field'),
                      controller: _issuedController,
                      label: 'Issued date',
                      icon: Icons.event_outlined,
                      keyboardType: TextInputType.datetime,
                      onChanged: widget.onIssuedDateChanged,
                      validator: CompanyDocumentDraft.validateOptionalDate,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-document-expiry-field'),
                      controller: _expiryController,
                      label: 'Expiry date',
                      icon: Icons.event_busy_outlined,
                      keyboardType: TextInputType.datetime,
                      onChanged: widget.onExpiryDateChanged,
                      validator: CompanyDocumentDraft.validateOptionalDate,
                    ),
                  ),
                ],
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
                    key: const Key('company-document-save-button'),
                    onPressed: _submit,
                    icon: const Icon(Icons.note_add_outlined),
                    label: const Text('Add document'),
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
