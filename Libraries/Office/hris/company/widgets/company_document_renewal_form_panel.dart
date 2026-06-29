import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/company_document.dart';
import '../models/company_document_renewal.dart';

class CompanyDocumentRenewalFormPanel extends StatefulWidget {
  final CompanyDocumentRenewalDraft draft;
  final List<CompanyDocumentRecord> documents;
  final List<String> entities;
  final ValueChanged<String> onDocumentChanged;
  final ValueChanged<String> onEntityChanged;
  final ValueChanged<String> onOwnerChanged;
  final ValueChanged<String> onDueDateChanged;
  final ValueChanged<String> onReminderLeadDaysChanged;
  final ValueChanged<CompanyDocumentRenewalStatus> onStatusChanged;
  final ValueChanged<String> onActionChanged;
  final VoidCallback onSubmit;
  final VoidCallback onClear;

  const CompanyDocumentRenewalFormPanel({
    super.key,
    required this.draft,
    required this.documents,
    required this.entities,
    required this.onDocumentChanged,
    required this.onEntityChanged,
    required this.onOwnerChanged,
    required this.onDueDateChanged,
    required this.onReminderLeadDaysChanged,
    required this.onStatusChanged,
    required this.onActionChanged,
    required this.onSubmit,
    required this.onClear,
  });

  @override
  State<CompanyDocumentRenewalFormPanel> createState() =>
      _CompanyDocumentRenewalFormPanelState();
}

class _CompanyDocumentRenewalFormPanelState
    extends State<CompanyDocumentRenewalFormPanel> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _ownerController;
  late final TextEditingController _dueDateController;
  late final TextEditingController _leadDaysController;
  late final TextEditingController _actionController;

  @override
  void initState() {
    super.initState();
    _ownerController = TextEditingController(text: widget.draft.ownerName);
    _dueDateController = TextEditingController(text: widget.draft.dueDateText);
    _leadDaysController = TextEditingController(
      text: widget.draft.reminderLeadDaysText,
    );
    _actionController = TextEditingController(text: widget.draft.actionLabel);
  }

  @override
  void didUpdateWidget(covariant CompanyDocumentRenewalFormPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync(_ownerController, widget.draft.ownerName);
    _sync(_dueDateController, widget.draft.dueDateText);
    _sync(_leadDaysController, widget.draft.reminderLeadDaysText);
    _sync(_actionController, widget.draft.actionLabel);
  }

  @override
  void dispose() {
    _ownerController.dispose();
    _dueDateController.dispose();
    _leadDaysController.dispose();
    _actionController.dispose();
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
    final selectedDocumentId =
        widget.documents.any(
              (document) => document.id == widget.draft.documentId,
            )
            ? widget.draft.documentId
            : null;

    return HrisSectionPanel(
      icon: Icons.notification_important_outlined,
      title: 'Document Renewal Form',
      subtitle: 'Schedule renewal reminders and statutory follow-ups',
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                initialValue: selectedDocumentId,
                decoration: const InputDecoration(
                  labelText: 'Document',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                items:
                    widget.documents
                        .map(
                          (document) => DropdownMenuItem(
                            value: document.id,
                            child: Text(document.title),
                          ),
                        )
                        .toList(),
                onChanged: (documentId) {
                  if (documentId != null) widget.onDocumentChanged(documentId);
                },
                validator:
                    (value) => CompanyDocumentRenewalDraft.validateRequired(
                      value,
                      'document',
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
                    (value) => CompanyDocumentRenewalDraft.validateRequired(
                      value,
                      'legal entity',
                    ),
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-renewal-owner-field'),
                controller: _ownerController,
                label: 'Owner',
                icon: Icons.supervisor_account_outlined,
                onChanged: widget.onOwnerChanged,
                validator:
                    (value) => CompanyDocumentRenewalDraft.validateRequired(
                      value,
                      'owner',
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-renewal-due-field'),
                      controller: _dueDateController,
                      label: 'Due date',
                      icon: Icons.event_busy_outlined,
                      keyboardType: TextInputType.datetime,
                      onChanged: widget.onDueDateChanged,
                      validator: CompanyDocumentRenewalDraft.validateDate,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-renewal-lead-field'),
                      controller: _leadDaysController,
                      label: 'Lead days',
                      icon: Icons.notifications_active_outlined,
                      keyboardType: TextInputType.number,
                      onChanged: widget.onReminderLeadDaysChanged,
                      validator: CompanyDocumentRenewalDraft.validateLeadDays,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<CompanyDocumentRenewalStatus>(
                initialValue: widget.draft.status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.flag_outlined),
                ),
                items:
                    CompanyDocumentRenewalStatus.values
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
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-renewal-action-field'),
                controller: _actionController,
                label: 'Next action',
                icon: Icons.task_alt_outlined,
                onChanged: widget.onActionChanged,
                validator:
                    (value) => CompanyDocumentRenewalDraft.validateRequired(
                      value,
                      'next action',
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
                    key: const Key('company-renewal-save-button'),
                    onPressed: _submit,
                    icon: const Icon(Icons.add_alert_outlined),
                    label: const Text('Schedule'),
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
