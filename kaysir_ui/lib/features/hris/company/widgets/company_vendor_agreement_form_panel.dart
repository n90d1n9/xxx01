import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/company_vendor_agreement.dart';

class CompanyVendorAgreementFormPanel extends StatefulWidget {
  final CompanyVendorAgreementDraft draft;
  final List<String> entities;
  final ValueChanged<String> onVendorChanged;
  final ValueChanged<String> onServiceChanged;
  final ValueChanged<String> onEntityChanged;
  final ValueChanged<CompanyVendorAgreementCategory> onCategoryChanged;
  final ValueChanged<CompanyVendorAgreementStatus> onStatusChanged;
  final ValueChanged<String> onOwnerChanged;
  final ValueChanged<String> onAccountManagerChanged;
  final ValueChanged<String> onContractEndChanged;
  final ValueChanged<String> onSlaChanged;
  final ValueChanged<String> onDataProtectionChanged;
  final ValueChanged<String> onNextActionChanged;
  final ValueChanged<String> onLinkedModuleChanged;
  final VoidCallback onSubmit;
  final VoidCallback onClear;

  const CompanyVendorAgreementFormPanel({
    super.key,
    required this.draft,
    required this.entities,
    required this.onVendorChanged,
    required this.onServiceChanged,
    required this.onEntityChanged,
    required this.onCategoryChanged,
    required this.onStatusChanged,
    required this.onOwnerChanged,
    required this.onAccountManagerChanged,
    required this.onContractEndChanged,
    required this.onSlaChanged,
    required this.onDataProtectionChanged,
    required this.onNextActionChanged,
    required this.onLinkedModuleChanged,
    required this.onSubmit,
    required this.onClear,
  });

  @override
  State<CompanyVendorAgreementFormPanel> createState() =>
      _CompanyVendorAgreementFormPanelState();
}

class _CompanyVendorAgreementFormPanelState
    extends State<CompanyVendorAgreementFormPanel> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _vendorController;
  late final TextEditingController _serviceController;
  late final TextEditingController _ownerController;
  late final TextEditingController _accountManagerController;
  late final TextEditingController _contractEndController;
  late final TextEditingController _slaController;
  late final TextEditingController _dataProtectionController;
  late final TextEditingController _nextActionController;
  late final TextEditingController _linkedModuleController;

  @override
  void initState() {
    super.initState();
    _vendorController = TextEditingController(text: widget.draft.vendorName);
    _serviceController = TextEditingController(text: widget.draft.serviceName);
    _ownerController = TextEditingController(text: widget.draft.ownerName);
    _accountManagerController = TextEditingController(
      text: widget.draft.accountManagerName,
    );
    _contractEndController = TextEditingController(
      text: widget.draft.contractEndDateText,
    );
    _slaController = TextEditingController(text: widget.draft.slaSummary);
    _dataProtectionController = TextEditingController(
      text: widget.draft.dataProtectionSummary,
    );
    _nextActionController = TextEditingController(
      text: widget.draft.nextAction,
    );
    _linkedModuleController = TextEditingController(
      text: widget.draft.linkedModule,
    );
  }

  @override
  void didUpdateWidget(covariant CompanyVendorAgreementFormPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync(_vendorController, widget.draft.vendorName);
    _sync(_serviceController, widget.draft.serviceName);
    _sync(_ownerController, widget.draft.ownerName);
    _sync(_accountManagerController, widget.draft.accountManagerName);
    _sync(_contractEndController, widget.draft.contractEndDateText);
    _sync(_slaController, widget.draft.slaSummary);
    _sync(_dataProtectionController, widget.draft.dataProtectionSummary);
    _sync(_nextActionController, widget.draft.nextAction);
    _sync(_linkedModuleController, widget.draft.linkedModule);
  }

  @override
  void dispose() {
    _vendorController.dispose();
    _serviceController.dispose();
    _ownerController.dispose();
    _accountManagerController.dispose();
    _contractEndController.dispose();
    _slaController.dispose();
    _dataProtectionController.dispose();
    _nextActionController.dispose();
    _linkedModuleController.dispose();
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
      icon: Icons.handshake_outlined,
      title: 'Vendor Agreement Form',
      subtitle: 'Track HR vendors, SLAs, DPAs, renewals, and owners',
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-vendor-name-field'),
                      controller: _vendorController,
                      label: 'Vendor name',
                      icon: Icons.handshake_outlined,
                      onChanged: widget.onVendorChanged,
                      validator:
                          (value) =>
                              CompanyVendorAgreementDraft.validateRequired(
                                value,
                                'vendor name',
                              ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-vendor-service-field'),
                      controller: _serviceController,
                      label: 'Service',
                      icon: Icons.design_services_outlined,
                      onChanged: widget.onServiceChanged,
                      validator:
                          (value) =>
                              CompanyVendorAgreementDraft.validateRequired(
                                value,
                                'service',
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
                          (value) =>
                              CompanyVendorAgreementDraft.validateRequired(
                                value,
                                'legal entity',
                              ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child:
                        DropdownButtonFormField<CompanyVendorAgreementCategory>(
                          isExpanded: true,
                          initialValue: widget.draft.category,
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.category_outlined),
                          ),
                          items:
                              CompanyVendorAgreementCategory.values
                                  .map(
                                    (category) => DropdownMenuItem(
                                      value: category,
                                      child: Text(
                                        category.label,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (category) {
                            if (category != null) {
                              widget.onCategoryChanged(category);
                            }
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
                        DropdownButtonFormField<CompanyVendorAgreementStatus>(
                          isExpanded: true,
                          initialValue: widget.draft.status,
                          decoration: const InputDecoration(
                            labelText: 'Status',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.task_alt_outlined),
                          ),
                          items:
                              CompanyVendorAgreementStatus.values
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
                      key: const Key('company-vendor-contract-end-field'),
                      controller: _contractEndController,
                      label: 'Contract end (YYYY-MM-DD)',
                      icon: Icons.event_outlined,
                      onChanged: widget.onContractEndChanged,
                      validator: CompanyVendorAgreementDraft.validateDate,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-vendor-owner-field'),
                      controller: _ownerController,
                      label: 'Owner',
                      icon: Icons.supervisor_account_outlined,
                      onChanged: widget.onOwnerChanged,
                      validator:
                          (value) =>
                              CompanyVendorAgreementDraft.validateRequired(
                                value,
                                'owner',
                              ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-vendor-account-manager-field'),
                      controller: _accountManagerController,
                      label: 'Account manager',
                      icon: Icons.contact_mail_outlined,
                      onChanged: widget.onAccountManagerChanged,
                      validator:
                          (value) =>
                              CompanyVendorAgreementDraft.validateRequired(
                                value,
                                'account manager',
                              ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-vendor-sla-field'),
                controller: _slaController,
                label: 'SLA summary',
                icon: Icons.speed_outlined,
                onChanged: widget.onSlaChanged,
                validator:
                    (value) => CompanyVendorAgreementDraft.validateRequired(
                      value,
                      'SLA summary',
                    ),
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-vendor-dpa-field'),
                controller: _dataProtectionController,
                label: 'Data protection summary',
                icon: Icons.privacy_tip_outlined,
                onChanged: widget.onDataProtectionChanged,
                validator:
                    (value) => CompanyVendorAgreementDraft.validateRequired(
                      value,
                      'data protection summary',
                    ),
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-vendor-next-field'),
                controller: _nextActionController,
                label: 'Next action',
                icon: Icons.route_outlined,
                onChanged: widget.onNextActionChanged,
                validator:
                    (value) => CompanyVendorAgreementDraft.validateRequired(
                      value,
                      'next action',
                    ),
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-vendor-linked-field'),
                controller: _linkedModuleController,
                label: 'Linked module',
                icon: Icons.link_outlined,
                onChanged: widget.onLinkedModuleChanged,
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
                    key: const Key('company-vendor-save-button'),
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        widget.onSubmit();
                      }
                    },
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Save vendor'),
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
