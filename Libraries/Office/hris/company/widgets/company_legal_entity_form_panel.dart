import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/company_legal_entity.dart';

class CompanyLegalEntityFormPanel extends StatefulWidget {
  final CompanyLegalEntityDraft draft;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onRegistrationNumberChanged;
  final ValueChanged<String> onTaxIdChanged;
  final ValueChanged<String> onCountryChanged;
  final ValueChanged<String> onCityChanged;
  final ValueChanged<String> onHrOwnerChanged;
  final ValueChanged<bool> onPayrollEnabledChanged;
  final ValueChanged<CompanyLegalEntityStatus> onStatusChanged;
  final VoidCallback onSubmit;
  final VoidCallback onClear;

  const CompanyLegalEntityFormPanel({
    super.key,
    required this.draft,
    required this.onNameChanged,
    required this.onRegistrationNumberChanged,
    required this.onTaxIdChanged,
    required this.onCountryChanged,
    required this.onCityChanged,
    required this.onHrOwnerChanged,
    required this.onPayrollEnabledChanged,
    required this.onStatusChanged,
    required this.onSubmit,
    required this.onClear,
  });

  @override
  State<CompanyLegalEntityFormPanel> createState() =>
      _CompanyLegalEntityFormPanelState();
}

class _CompanyLegalEntityFormPanelState
    extends State<CompanyLegalEntityFormPanel> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _registrationController;
  late final TextEditingController _taxController;
  late final TextEditingController _countryController;
  late final TextEditingController _cityController;
  late final TextEditingController _ownerController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.draft.name);
    _registrationController = TextEditingController(
      text: widget.draft.registrationNumber,
    );
    _taxController = TextEditingController(text: widget.draft.taxId);
    _countryController = TextEditingController(text: widget.draft.country);
    _cityController = TextEditingController(text: widget.draft.city);
    _ownerController = TextEditingController(text: widget.draft.hrOwner);
  }

  @override
  void didUpdateWidget(covariant CompanyLegalEntityFormPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync(_nameController, widget.draft.name);
    _sync(_registrationController, widget.draft.registrationNumber);
    _sync(_taxController, widget.draft.taxId);
    _sync(_countryController, widget.draft.country);
    _sync(_cityController, widget.draft.city);
    _sync(_ownerController, widget.draft.hrOwner);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _registrationController.dispose();
    _taxController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _ownerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      icon: Icons.business_outlined,
      title: 'Legal Entity Form',
      subtitle: 'Register companies for payroll, tax, and HR scope',
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              _TextInput(
                key: const Key('company-entity-name-field'),
                controller: _nameController,
                label: 'Entity name',
                icon: Icons.business_center_outlined,
                onChanged: widget.onNameChanged,
                validator:
                    (value) => CompanyLegalEntityDraft.validateRequired(
                      value,
                      'entity name',
                    ),
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-entity-registration-field'),
                controller: _registrationController,
                label: 'Registration number',
                icon: Icons.badge_outlined,
                onChanged: widget.onRegistrationNumberChanged,
                validator:
                    (value) => CompanyLegalEntityDraft.validateRequired(
                      value,
                      'registration number',
                    ),
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-entity-tax-field'),
                controller: _taxController,
                label: 'Tax ID',
                icon: Icons.receipt_long_outlined,
                onChanged: widget.onTaxIdChanged,
                validator:
                    (value) => CompanyLegalEntityDraft.validateRequired(
                      value,
                      'tax ID',
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-entity-country-field'),
                      controller: _countryController,
                      label: 'Country',
                      icon: Icons.flag_outlined,
                      onChanged: widget.onCountryChanged,
                      validator:
                          (value) => CompanyLegalEntityDraft.validateRequired(
                            value,
                            'country',
                          ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-entity-city-field'),
                      controller: _cityController,
                      label: 'City',
                      icon: Icons.location_city_outlined,
                      onChanged: widget.onCityChanged,
                      validator:
                          (value) => CompanyLegalEntityDraft.validateRequired(
                            value,
                            'city',
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-entity-owner-field'),
                controller: _ownerController,
                label: 'HR owner',
                icon: Icons.support_agent_outlined,
                onChanged: widget.onHrOwnerChanged,
                validator:
                    (value) => CompanyLegalEntityDraft.validateRequired(
                      value,
                      'HR owner',
                    ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<CompanyLegalEntityStatus>(
                initialValue: widget.draft.status,
                decoration: const InputDecoration(
                  labelText: 'Verification status',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.verified_outlined),
                ),
                items:
                    CompanyLegalEntityStatus.values
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
              HrisListSurface(
                child: Material(
                  color: Colors.transparent,
                  child: SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    value: widget.draft.payrollEnabled,
                    onChanged: widget.onPayrollEnabledChanged,
                    title: const Text('Payroll enabled'),
                    subtitle: const Text(
                      'Entity can run payroll and tax rules',
                    ),
                  ),
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
                    key: const Key('company-entity-save-button'),
                    onPressed: _submit,
                    icon: const Icon(Icons.add_business_outlined),
                    label: const Text('Add entity'),
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
      onChanged: onChanged,
      validator: validator,
    );
  }
}
