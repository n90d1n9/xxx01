import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/company_governance_contact.dart';

class CompanyGovernanceContactFormPanel extends StatefulWidget {
  final CompanyGovernanceContactDraft draft;
  final List<String> entities;
  final ValueChanged<String> onEntityChanged;
  final ValueChanged<CompanyGovernanceRole> onRoleChanged;
  final ValueChanged<String> onPersonChanged;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onEmailChanged;
  final ValueChanged<String> onPhoneChanged;
  final ValueChanged<String> onBackupChanged;
  final ValueChanged<String> onEscalationChanged;
  final ValueChanged<CompanyGovernanceContactStatus> onStatusChanged;
  final ValueChanged<String> onLastReviewChanged;
  final ValueChanged<String> onNextReviewChanged;
  final VoidCallback onSubmit;
  final VoidCallback onClear;

  const CompanyGovernanceContactFormPanel({
    super.key,
    required this.draft,
    required this.entities,
    required this.onEntityChanged,
    required this.onRoleChanged,
    required this.onPersonChanged,
    required this.onTitleChanged,
    required this.onEmailChanged,
    required this.onPhoneChanged,
    required this.onBackupChanged,
    required this.onEscalationChanged,
    required this.onStatusChanged,
    required this.onLastReviewChanged,
    required this.onNextReviewChanged,
    required this.onSubmit,
    required this.onClear,
  });

  @override
  State<CompanyGovernanceContactFormPanel> createState() =>
      _CompanyGovernanceContactFormPanelState();
}

class _CompanyGovernanceContactFormPanelState
    extends State<CompanyGovernanceContactFormPanel> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _personController;
  late final TextEditingController _titleController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _backupController;
  late final TextEditingController _escalationController;
  late final TextEditingController _lastReviewController;
  late final TextEditingController _nextReviewController;

  @override
  void initState() {
    super.initState();
    _personController = TextEditingController(text: widget.draft.personName);
    _titleController = TextEditingController(text: widget.draft.title);
    _emailController = TextEditingController(text: widget.draft.email);
    _phoneController = TextEditingController(text: widget.draft.phone);
    _backupController = TextEditingController(text: widget.draft.backupName);
    _escalationController = TextEditingController(
      text: widget.draft.escalationChannel,
    );
    _lastReviewController = TextEditingController(
      text: widget.draft.lastReviewedAtText,
    );
    _nextReviewController = TextEditingController(
      text: widget.draft.nextReviewAtText,
    );
  }

  @override
  void didUpdateWidget(covariant CompanyGovernanceContactFormPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync(_personController, widget.draft.personName);
    _sync(_titleController, widget.draft.title);
    _sync(_emailController, widget.draft.email);
    _sync(_phoneController, widget.draft.phone);
    _sync(_backupController, widget.draft.backupName);
    _sync(_escalationController, widget.draft.escalationChannel);
    _sync(_lastReviewController, widget.draft.lastReviewedAtText);
    _sync(_nextReviewController, widget.draft.nextReviewAtText);
  }

  @override
  void dispose() {
    _personController.dispose();
    _titleController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _backupController.dispose();
    _escalationController.dispose();
    _lastReviewController.dispose();
    _nextReviewController.dispose();
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
      icon: Icons.contact_mail_outlined,
      title: 'Governance Contact Form',
      subtitle: 'Assign HRIS owners, backups, and escalation paths',
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
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
                              CompanyGovernanceContactDraft.validateRequired(
                                value,
                                'legal entity',
                              ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<CompanyGovernanceRole>(
                      isExpanded: true,
                      initialValue: widget.draft.role,
                      decoration: const InputDecoration(
                        labelText: 'Role',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.assignment_ind_outlined),
                      ),
                      items:
                          CompanyGovernanceRole.values
                              .map(
                                (role) => DropdownMenuItem(
                                  value: role,
                                  child: Text(
                                    role.label,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (role) {
                        if (role != null) widget.onRoleChanged(role);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-contact-person-field'),
                controller: _personController,
                label: 'Owner name',
                icon: Icons.person_outline,
                onChanged: widget.onPersonChanged,
                validator:
                    (value) => CompanyGovernanceContactDraft.validateRequired(
                      value,
                      'owner name',
                    ),
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-contact-title-field'),
                controller: _titleController,
                label: 'Title',
                icon: Icons.badge_outlined,
                onChanged: widget.onTitleChanged,
                validator:
                    (value) => CompanyGovernanceContactDraft.validateRequired(
                      value,
                      'title',
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-contact-email-field'),
                      controller: _emailController,
                      label: 'Email',
                      icon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: widget.onEmailChanged,
                      validator: CompanyGovernanceContactDraft.validateEmail,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-contact-phone-field'),
                      controller: _phoneController,
                      label: 'Phone',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      onChanged: widget.onPhoneChanged,
                      validator:
                          (value) =>
                              CompanyGovernanceContactDraft.validateRequired(
                                value,
                                'phone',
                              ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-contact-backup-field'),
                controller: _backupController,
                label: 'Backup owner',
                icon: Icons.group_outlined,
                onChanged: widget.onBackupChanged,
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-contact-channel-field'),
                controller: _escalationController,
                label: 'Escalation channel',
                icon: Icons.route_outlined,
                onChanged: widget.onEscalationChanged,
                validator:
                    (value) => CompanyGovernanceContactDraft.validateRequired(
                      value,
                      'escalation channel',
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child:
                        DropdownButtonFormField<CompanyGovernanceContactStatus>(
                          isExpanded: true,
                          initialValue: widget.draft.status,
                          decoration: const InputDecoration(
                            labelText: 'Status',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.flag_outlined),
                          ),
                          items:
                              CompanyGovernanceContactStatus.values
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
                            if (status != null) {
                              widget.onStatusChanged(status);
                            }
                          },
                        ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-contact-last-review-field'),
                      controller: _lastReviewController,
                      label: 'Last review',
                      icon: Icons.event_available_outlined,
                      keyboardType: TextInputType.datetime,
                      onChanged: widget.onLastReviewChanged,
                      validator: CompanyGovernanceContactDraft.validateDate,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-contact-next-review-field'),
                controller: _nextReviewController,
                label: 'Next review',
                icon: Icons.event_busy_outlined,
                keyboardType: TextInputType.datetime,
                onChanged: widget.onNextReviewChanged,
                validator: CompanyGovernanceContactDraft.validateDate,
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
                    key: const Key('company-contact-save-button'),
                    onPressed: _submit,
                    icon: const Icon(Icons.person_add_alt_1_outlined),
                    label: const Text('Add owner'),
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
