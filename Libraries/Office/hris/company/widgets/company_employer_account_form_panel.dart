import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/company_employer_account.dart';

class CompanyEmployerAccountFormPanel extends StatefulWidget {
  final CompanyEmployerAccountDraft draft;
  final List<String> entities;
  final ValueChanged<String> onAccountNameChanged;
  final ValueChanged<String> onEntityChanged;
  final ValueChanged<CompanyEmployerAccountType> onTypeChanged;
  final ValueChanged<CompanyEmployerAccountStatus> onStatusChanged;
  final ValueChanged<String> onAccountNumberChanged;
  final ValueChanged<String> onOwnerChanged;
  final ValueChanged<String> onCredentialOwnerChanged;
  final ValueChanged<String> onNextReviewDateChanged;
  final ValueChanged<String> onEvidenceChanged;
  final ValueChanged<String> onNextActionChanged;
  final ValueChanged<String> onLinkedFilingChanged;
  final VoidCallback onSubmit;
  final VoidCallback onClear;

  const CompanyEmployerAccountFormPanel({
    super.key,
    required this.draft,
    required this.entities,
    required this.onAccountNameChanged,
    required this.onEntityChanged,
    required this.onTypeChanged,
    required this.onStatusChanged,
    required this.onAccountNumberChanged,
    required this.onOwnerChanged,
    required this.onCredentialOwnerChanged,
    required this.onNextReviewDateChanged,
    required this.onEvidenceChanged,
    required this.onNextActionChanged,
    required this.onLinkedFilingChanged,
    required this.onSubmit,
    required this.onClear,
  });

  @override
  State<CompanyEmployerAccountFormPanel> createState() =>
      _CompanyEmployerAccountFormPanelState();
}

class _CompanyEmployerAccountFormPanelState
    extends State<CompanyEmployerAccountFormPanel> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _accountNameController;
  late final TextEditingController _accountNumberController;
  late final TextEditingController _ownerController;
  late final TextEditingController _credentialOwnerController;
  late final TextEditingController _nextReviewController;
  late final TextEditingController _evidenceController;
  late final TextEditingController _nextActionController;
  late final TextEditingController _linkedFilingController;

  @override
  void initState() {
    super.initState();
    _accountNameController = TextEditingController(
      text: widget.draft.accountName,
    );
    _accountNumberController = TextEditingController(
      text: widget.draft.accountNumber,
    );
    _ownerController = TextEditingController(text: widget.draft.ownerName);
    _credentialOwnerController = TextEditingController(
      text: widget.draft.credentialOwnerName,
    );
    _nextReviewController = TextEditingController(
      text: widget.draft.nextReviewDateText,
    );
    _evidenceController = TextEditingController(
      text: widget.draft.evidenceSummary,
    );
    _nextActionController = TextEditingController(
      text: widget.draft.nextAction,
    );
    _linkedFilingController = TextEditingController(
      text: widget.draft.linkedFiling,
    );
  }

  @override
  void didUpdateWidget(covariant CompanyEmployerAccountFormPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync(_accountNameController, widget.draft.accountName);
    _sync(_accountNumberController, widget.draft.accountNumber);
    _sync(_ownerController, widget.draft.ownerName);
    _sync(_credentialOwnerController, widget.draft.credentialOwnerName);
    _sync(_nextReviewController, widget.draft.nextReviewDateText);
    _sync(_evidenceController, widget.draft.evidenceSummary);
    _sync(_nextActionController, widget.draft.nextAction);
    _sync(_linkedFilingController, widget.draft.linkedFiling);
  }

  @override
  void dispose() {
    _accountNameController.dispose();
    _accountNumberController.dispose();
    _ownerController.dispose();
    _credentialOwnerController.dispose();
    _nextReviewController.dispose();
    _evidenceController.dispose();
    _nextActionController.dispose();
    _linkedFilingController.dispose();
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
      icon: Icons.account_balance_outlined,
      title: 'Employer Account Form',
      subtitle: 'Register payroll tax, BPJS, bank, and portal accounts',
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              _TextInput(
                key: const Key('company-employer-account-name-field'),
                controller: _accountNameController,
                label: 'Account name',
                icon: Icons.account_balance_outlined,
                onChanged: widget.onAccountNameChanged,
                validator:
                    (value) => CompanyEmployerAccountDraft.validateRequired(
                      value,
                      'account name',
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
                              CompanyEmployerAccountDraft.validateRequired(
                                value,
                                'legal entity',
                              ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<CompanyEmployerAccountType>(
                      isExpanded: true,
                      initialValue: widget.draft.type,
                      decoration: const InputDecoration(
                        labelText: 'Account type',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items:
                          CompanyEmployerAccountType.values
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
                        DropdownButtonFormField<CompanyEmployerAccountStatus>(
                          isExpanded: true,
                          initialValue: widget.draft.status,
                          decoration: const InputDecoration(
                            labelText: 'Status',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.task_alt_outlined),
                          ),
                          items:
                              CompanyEmployerAccountStatus.values
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
                    child: _TextInput(
                      key: const Key('company-employer-account-number-field'),
                      controller: _accountNumberController,
                      label: 'Account number',
                      icon: Icons.confirmation_number_outlined,
                      onChanged: widget.onAccountNumberChanged,
                      validator:
                          (value) =>
                              CompanyEmployerAccountDraft.validateRequired(
                                value,
                                'account number',
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
                      key: const Key('company-employer-account-owner-field'),
                      controller: _ownerController,
                      label: 'Business owner',
                      icon: Icons.supervisor_account_outlined,
                      onChanged: widget.onOwnerChanged,
                      validator:
                          (value) =>
                              CompanyEmployerAccountDraft.validateRequired(
                                value,
                                'business owner',
                              ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TextInput(
                      key: const Key(
                        'company-employer-account-credential-owner-field',
                      ),
                      controller: _credentialOwnerController,
                      label: 'Credential owner',
                      icon: Icons.key_outlined,
                      onChanged: widget.onCredentialOwnerChanged,
                      validator:
                          (value) =>
                              CompanyEmployerAccountDraft.validateRequired(
                                value,
                                'credential owner',
                              ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-employer-account-review-field'),
                controller: _nextReviewController,
                label: 'Next review date (YYYY-MM-DD)',
                icon: Icons.event_outlined,
                onChanged: widget.onNextReviewDateChanged,
                validator: CompanyEmployerAccountDraft.validateDate,
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-employer-account-evidence-field'),
                controller: _evidenceController,
                label: 'Evidence summary',
                icon: Icons.fact_check_outlined,
                onChanged: widget.onEvidenceChanged,
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-employer-account-next-field'),
                controller: _nextActionController,
                label: 'Next action',
                icon: Icons.route_outlined,
                onChanged: widget.onNextActionChanged,
                validator:
                    (value) => CompanyEmployerAccountDraft.validateRequired(
                      value,
                      'next action',
                    ),
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-employer-account-linked-field'),
                controller: _linkedFilingController,
                label: 'Linked filing or payroll run',
                icon: Icons.link_outlined,
                onChanged: widget.onLinkedFilingChanged,
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
                    key: const Key('company-employer-account-save-button'),
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        widget.onSubmit();
                      }
                    },
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Save account'),
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

  const _TextInput({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
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
