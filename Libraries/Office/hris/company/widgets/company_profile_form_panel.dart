import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/company_profile.dart';
import 'company_status_styles.dart';

class CompanyProfileFormPanel extends StatefulWidget {
  final CompanyProfile profile;
  final CompanyProfileDraft draft;
  final ValueChanged<String> onLegalNameChanged;
  final ValueChanged<String> onDisplayNameChanged;
  final ValueChanged<String> onRegistrationNumberChanged;
  final ValueChanged<String> onTaxIdChanged;
  final ValueChanged<String> onIndustryChanged;
  final ValueChanged<String> onWebsiteChanged;
  final ValueChanged<String> onHeadquartersChanged;
  final ValueChanged<String> onPrimaryContactChanged;
  final ValueChanged<CompanyStatus> onStatusChanged;
  final ValueChanged<String> onEmployeeCountChanged;
  final VoidCallback onSave;
  final VoidCallback onReset;

  const CompanyProfileFormPanel({
    super.key,
    required this.profile,
    required this.draft,
    required this.onLegalNameChanged,
    required this.onDisplayNameChanged,
    required this.onRegistrationNumberChanged,
    required this.onTaxIdChanged,
    required this.onIndustryChanged,
    required this.onWebsiteChanged,
    required this.onHeadquartersChanged,
    required this.onPrimaryContactChanged,
    required this.onStatusChanged,
    required this.onEmployeeCountChanged,
    required this.onSave,
    required this.onReset,
  });

  @override
  State<CompanyProfileFormPanel> createState() =>
      _CompanyProfileFormPanelState();
}

class _CompanyProfileFormPanelState extends State<CompanyProfileFormPanel> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _legalNameController;
  late final TextEditingController _displayNameController;
  late final TextEditingController _registrationNumberController;
  late final TextEditingController _taxIdController;
  late final TextEditingController _industryController;
  late final TextEditingController _websiteController;
  late final TextEditingController _headquartersController;
  late final TextEditingController _primaryContactController;
  late final TextEditingController _employeeCountController;

  @override
  void initState() {
    super.initState();
    _legalNameController = TextEditingController(text: widget.draft.legalName);
    _displayNameController = TextEditingController(
      text: widget.draft.displayName,
    );
    _registrationNumberController = TextEditingController(
      text: widget.draft.registrationNumber,
    );
    _taxIdController = TextEditingController(text: widget.draft.taxId);
    _industryController = TextEditingController(text: widget.draft.industry);
    _websiteController = TextEditingController(text: widget.draft.website);
    _headquartersController = TextEditingController(
      text: widget.draft.headquarters,
    );
    _primaryContactController = TextEditingController(
      text: widget.draft.primaryContact,
    );
    _employeeCountController = TextEditingController(
      text: widget.draft.employeeCountText,
    );
  }

  @override
  void didUpdateWidget(covariant CompanyProfileFormPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync(_legalNameController, widget.draft.legalName);
    _sync(_displayNameController, widget.draft.displayName);
    _sync(_registrationNumberController, widget.draft.registrationNumber);
    _sync(_taxIdController, widget.draft.taxId);
    _sync(_industryController, widget.draft.industry);
    _sync(_websiteController, widget.draft.website);
    _sync(_headquartersController, widget.draft.headquarters);
    _sync(_primaryContactController, widget.draft.primaryContact);
    _sync(_employeeCountController, widget.draft.employeeCountText);
  }

  @override
  void dispose() {
    _legalNameController.dispose();
    _displayNameController.dispose();
    _registrationNumberController.dispose();
    _taxIdController.dispose();
    _industryController.dispose();
    _websiteController.dispose();
    _headquartersController.dispose();
    _primaryContactController.dispose();
    _employeeCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      icon: Icons.domain_outlined,
      title: 'Company Profile',
      subtitle: '${widget.profile.title} - ${widget.profile.status.label}',
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HrisStatusPill(
                label: widget.profile.status.label,
                color: companyProfileStatusColor(widget.profile.status),
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-legal-name-field'),
                controller: _legalNameController,
                label: 'Legal name',
                icon: Icons.business_outlined,
                onChanged: widget.onLegalNameChanged,
                validator:
                    (value) => CompanyProfileDraft.validateRequired(
                      value,
                      'legal name',
                    ),
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-display-name-field'),
                controller: _displayNameController,
                label: 'Trade name',
                icon: Icons.storefront_outlined,
                onChanged: widget.onDisplayNameChanged,
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-registration-field'),
                controller: _registrationNumberController,
                label: 'Registration number',
                icon: Icons.badge_outlined,
                onChanged: widget.onRegistrationNumberChanged,
                validator:
                    (value) => CompanyProfileDraft.validateRequired(
                      value,
                      'registration number',
                    ),
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-tax-field'),
                controller: _taxIdController,
                label: 'Tax ID / NPWP',
                icon: Icons.receipt_long_outlined,
                onChanged: widget.onTaxIdChanged,
                validator:
                    (value) =>
                        CompanyProfileDraft.validateRequired(value, 'tax ID'),
              ),
              const SizedBox(height: 12),
              _TextInput(
                controller: _industryController,
                label: 'Industry',
                icon: Icons.category_outlined,
                onChanged: widget.onIndustryChanged,
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-website-field'),
                controller: _websiteController,
                label: 'Website',
                icon: Icons.language_outlined,
                onChanged: widget.onWebsiteChanged,
                validator:
                    (value) =>
                        CompanyProfileDraft.validateRequired(value, 'website'),
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-headquarters-field'),
                controller: _headquartersController,
                label: 'Headquarters',
                icon: Icons.location_city_outlined,
                onChanged: widget.onHeadquartersChanged,
                validator:
                    (value) => CompanyProfileDraft.validateRequired(
                      value,
                      'headquarters',
                    ),
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-contact-field'),
                controller: _primaryContactController,
                label: 'Primary contact',
                icon: Icons.support_agent_outlined,
                onChanged: widget.onPrimaryContactChanged,
                validator:
                    (value) => CompanyProfileDraft.validateRequired(
                      value,
                      'primary contact',
                    ),
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-employee-count-field'),
                controller: _employeeCountController,
                label: 'Employee count',
                icon: Icons.groups_2_outlined,
                keyboardType: TextInputType.number,
                onChanged: widget.onEmployeeCountChanged,
                validator: CompanyProfileDraft.validateEmployeeCount,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<CompanyStatus>(
                initialValue: widget.draft.status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.verified_outlined),
                ),
                items:
                    CompanyStatus.values
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
              HrisProgressBar(
                value: widget.draft.completionRatio,
                color: widget.draft.isReady ? Colors.green : HrisColors.primary,
                label:
                    '${(widget.draft.completionRatio * 100).round()}% profile readiness',
              ),
              if (widget.draft.issues.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  widget.draft.issues.map((issue) => issue.label).join(' - '),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.orange[800],
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: widget.onReset,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset'),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    key: const Key('company-profile-save-button'),
                    onPressed: _submit,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Save profile'),
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
      widget.onSave();
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
      ),
      onChanged: onChanged,
      validator: validator,
    );
  }
}
