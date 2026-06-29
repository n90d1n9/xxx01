import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/company_signatory.dart';

class CompanySignatoryFormPanel extends StatefulWidget {
  final CompanySignatoryDraft draft;
  final List<String> entities;
  final ValueChanged<String> onPersonChanged;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onEntityChanged;
  final ValueChanged<CompanySignatoryScope> onScopeChanged;
  final ValueChanged<CompanySignatoryAuthorityLevel> onAuthorityChanged;
  final ValueChanged<CompanySignatoryStatus> onStatusChanged;
  final ValueChanged<String> onEffectiveDateChanged;
  final ValueChanged<String> onExpiryDateChanged;
  final ValueChanged<String> onBackupChanged;
  final ValueChanged<String> onEvidenceChanged;
  final ValueChanged<String> onNotesChanged;
  final VoidCallback onSubmit;
  final VoidCallback onClear;

  const CompanySignatoryFormPanel({
    super.key,
    required this.draft,
    required this.entities,
    required this.onPersonChanged,
    required this.onTitleChanged,
    required this.onEntityChanged,
    required this.onScopeChanged,
    required this.onAuthorityChanged,
    required this.onStatusChanged,
    required this.onEffectiveDateChanged,
    required this.onExpiryDateChanged,
    required this.onBackupChanged,
    required this.onEvidenceChanged,
    required this.onNotesChanged,
    required this.onSubmit,
    required this.onClear,
  });

  @override
  State<CompanySignatoryFormPanel> createState() =>
      _CompanySignatoryFormPanelState();
}

class _CompanySignatoryFormPanelState extends State<CompanySignatoryFormPanel> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _personController;
  late final TextEditingController _titleController;
  late final TextEditingController _effectiveController;
  late final TextEditingController _expiryController;
  late final TextEditingController _backupController;
  late final TextEditingController _evidenceController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _personController = TextEditingController(text: widget.draft.personName);
    _titleController = TextEditingController(text: widget.draft.title);
    _effectiveController = TextEditingController(
      text: widget.draft.effectiveDateText,
    );
    _expiryController = TextEditingController(
      text: widget.draft.expiryDateText,
    );
    _backupController = TextEditingController(
      text: widget.draft.backupSignerName,
    );
    _evidenceController = TextEditingController(
      text: widget.draft.evidenceSummary,
    );
    _notesController = TextEditingController(
      text: widget.draft.delegationNotes,
    );
  }

  @override
  void didUpdateWidget(covariant CompanySignatoryFormPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync(_personController, widget.draft.personName);
    _sync(_titleController, widget.draft.title);
    _sync(_effectiveController, widget.draft.effectiveDateText);
    _sync(_expiryController, widget.draft.expiryDateText);
    _sync(_backupController, widget.draft.backupSignerName);
    _sync(_evidenceController, widget.draft.evidenceSummary);
    _sync(_notesController, widget.draft.delegationNotes);
  }

  @override
  void dispose() {
    _personController.dispose();
    _titleController.dispose();
    _effectiveController.dispose();
    _expiryController.dispose();
    _backupController.dispose();
    _evidenceController.dispose();
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

    return HrisSectionPanel(
      icon: Icons.assignment_ind_outlined,
      title: 'Signatory Delegation Form',
      subtitle: 'Capture authorized signers, backups, evidence, and expiry',
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-signatory-person-field'),
                      controller: _personController,
                      label: 'Signer name',
                      icon: Icons.person_outline,
                      onChanged: widget.onPersonChanged,
                      validator:
                          (value) => CompanySignatoryDraft.validateRequired(
                            value,
                            'signer name',
                          ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-signatory-title-field'),
                      controller: _titleController,
                      label: 'Title',
                      icon: Icons.badge_outlined,
                      onChanged: widget.onTitleChanged,
                      validator:
                          (value) => CompanySignatoryDraft.validateRequired(
                            value,
                            'title',
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
                          (value) => CompanySignatoryDraft.validateRequired(
                            value,
                            'legal entity',
                          ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<CompanySignatoryScope>(
                      isExpanded: true,
                      initialValue: widget.draft.scope,
                      decoration: const InputDecoration(
                        labelText: 'Scope',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.rule_folder_outlined),
                      ),
                      items:
                          CompanySignatoryScope.values
                              .map(
                                (scope) => DropdownMenuItem(
                                  value: scope,
                                  child: Text(
                                    scope.label,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (scope) {
                        if (scope != null) widget.onScopeChanged(scope);
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
                        DropdownButtonFormField<CompanySignatoryAuthorityLevel>(
                          isExpanded: true,
                          initialValue: widget.draft.authorityLevel,
                          decoration: const InputDecoration(
                            labelText: 'Authority',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.verified_user_outlined),
                          ),
                          items:
                              CompanySignatoryAuthorityLevel.values
                                  .map(
                                    (level) => DropdownMenuItem(
                                      value: level,
                                      child: Text(
                                        level.label,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (level) {
                            if (level != null) widget.onAuthorityChanged(level);
                          },
                        ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<CompanySignatoryStatus>(
                      isExpanded: true,
                      initialValue: widget.draft.status,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.task_alt_outlined),
                      ),
                      items:
                          CompanySignatoryStatus.values
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
                      key: const Key('company-signatory-effective-field'),
                      controller: _effectiveController,
                      label: 'Effective date',
                      icon: Icons.event_available_outlined,
                      keyboardType: TextInputType.datetime,
                      onChanged: widget.onEffectiveDateChanged,
                      validator: CompanySignatoryDraft.validateDate,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-signatory-expiry-field'),
                      controller: _expiryController,
                      label: 'Expiry date',
                      icon: Icons.event_busy_outlined,
                      keyboardType: TextInputType.datetime,
                      onChanged: widget.onExpiryDateChanged,
                      validator: CompanySignatoryDraft.validateDate,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-signatory-backup-field'),
                controller: _backupController,
                label: 'Backup signer',
                icon: Icons.group_add_outlined,
                onChanged: widget.onBackupChanged,
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-signatory-evidence-field'),
                controller: _evidenceController,
                label: 'Evidence summary',
                icon: Icons.attach_file_outlined,
                onChanged: widget.onEvidenceChanged,
                validator:
                    (value) => CompanySignatoryDraft.validateRequired(
                      value,
                      'evidence summary',
                    ),
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-signatory-notes-field'),
                controller: _notesController,
                label: 'Delegation notes',
                icon: Icons.notes_outlined,
                onChanged: widget.onNotesChanged,
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
                    key: const Key('company-signatory-save-button'),
                    onPressed: _submit,
                    icon: const Icon(Icons.add_task_outlined),
                    label: const Text('Add signer'),
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
