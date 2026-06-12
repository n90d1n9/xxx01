import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/company_cost_center.dart';

class CompanyCostCenterFormPanel extends StatefulWidget {
  final CompanyCostCenterDraft draft;
  final List<String> entities;
  final List<String> orgUnits;
  final ValueChanged<String> onCodeChanged;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onEntityChanged;
  final ValueChanged<String> onOrgUnitChanged;
  final ValueChanged<String> onOwnerChanged;
  final ValueChanged<String> onAnnualBudgetChanged;
  final ValueChanged<String> onAllocatedHeadcountChanged;
  final ValueChanged<String> onActiveHeadcountChanged;
  final ValueChanged<CompanyCostCenterStatus> onStatusChanged;
  final VoidCallback onSubmit;
  final VoidCallback onClear;

  const CompanyCostCenterFormPanel({
    super.key,
    required this.draft,
    required this.entities,
    required this.orgUnits,
    required this.onCodeChanged,
    required this.onNameChanged,
    required this.onEntityChanged,
    required this.onOrgUnitChanged,
    required this.onOwnerChanged,
    required this.onAnnualBudgetChanged,
    required this.onAllocatedHeadcountChanged,
    required this.onActiveHeadcountChanged,
    required this.onStatusChanged,
    required this.onSubmit,
    required this.onClear,
  });

  @override
  State<CompanyCostCenterFormPanel> createState() =>
      _CompanyCostCenterFormPanelState();
}

class _CompanyCostCenterFormPanelState
    extends State<CompanyCostCenterFormPanel> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codeController;
  late final TextEditingController _nameController;
  late final TextEditingController _ownerController;
  late final TextEditingController _budgetController;
  late final TextEditingController _allocatedController;
  late final TextEditingController _activeController;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.draft.code);
    _nameController = TextEditingController(text: widget.draft.name);
    _ownerController = TextEditingController(text: widget.draft.ownerName);
    _budgetController = TextEditingController(
      text: widget.draft.annualBudgetText,
    );
    _allocatedController = TextEditingController(
      text: widget.draft.allocatedHeadcountText,
    );
    _activeController = TextEditingController(
      text: widget.draft.activeHeadcountText,
    );
  }

  @override
  void didUpdateWidget(covariant CompanyCostCenterFormPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync(_codeController, widget.draft.code);
    _sync(_nameController, widget.draft.name);
    _sync(_ownerController, widget.draft.ownerName);
    _sync(_budgetController, widget.draft.annualBudgetText);
    _sync(_allocatedController, widget.draft.allocatedHeadcountText);
    _sync(_activeController, widget.draft.activeHeadcountText);
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _ownerController.dispose();
    _budgetController.dispose();
    _allocatedController.dispose();
    _activeController.dispose();
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
    final selectedOrgUnit =
        widget.orgUnits.contains(widget.draft.orgUnitName)
            ? widget.draft.orgUnitName
            : null;

    return HrisSectionPanel(
      icon: Icons.account_balance_wallet_outlined,
      title: 'Cost Center Form',
      subtitle: 'Assign payroll and workforce budget ownership',
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-cost-code-field'),
                      controller: _codeController,
                      label: 'Code',
                      icon: Icons.tag_outlined,
                      onChanged: widget.onCodeChanged,
                      validator:
                          (value) => CompanyCostCenterDraft.validateRequired(
                            value,
                            'code',
                          ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-cost-name-field'),
                      controller: _nameController,
                      label: 'Name',
                      icon: Icons.account_balance_wallet_outlined,
                      onChanged: widget.onNameChanged,
                      validator:
                          (value) => CompanyCostCenterDraft.validateRequired(
                            value,
                            'name',
                          ),
                    ),
                  ),
                ],
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
                    (value) => CompanyCostCenterDraft.validateRequired(
                      value,
                      'legal entity',
                    ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedOrgUnit,
                decoration: const InputDecoration(
                  labelText: 'Org unit',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_tree_outlined),
                ),
                items:
                    widget.orgUnits
                        .map(
                          (unit) =>
                              DropdownMenuItem(value: unit, child: Text(unit)),
                        )
                        .toList(),
                onChanged: (unit) {
                  if (unit != null) widget.onOrgUnitChanged(unit);
                },
                validator:
                    (value) => CompanyCostCenterDraft.validateRequired(
                      value,
                      'org unit',
                    ),
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-cost-owner-field'),
                controller: _ownerController,
                label: 'Owner',
                icon: Icons.supervisor_account_outlined,
                onChanged: widget.onOwnerChanged,
                validator:
                    (value) =>
                        CompanyCostCenterDraft.validateRequired(value, 'owner'),
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-cost-budget-field'),
                controller: _budgetController,
                label: 'Annual budget',
                icon: Icons.payments_outlined,
                keyboardType: TextInputType.number,
                onChanged: widget.onAnnualBudgetChanged,
                validator:
                    (value) => CompanyCostCenterDraft.validatePositiveNumber(
                      value,
                      'annual budget',
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-cost-allocated-field'),
                      controller: _allocatedController,
                      label: 'Allocated HC',
                      icon: Icons.event_available_outlined,
                      keyboardType: TextInputType.number,
                      onChanged: widget.onAllocatedHeadcountChanged,
                      validator: CompanyCostCenterDraft.validateZeroOrGreater,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-cost-active-field'),
                      controller: _activeController,
                      label: 'Active HC',
                      icon: Icons.groups_2_outlined,
                      keyboardType: TextInputType.number,
                      onChanged: widget.onActiveHeadcountChanged,
                      validator: CompanyCostCenterDraft.validateZeroOrGreater,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<CompanyCostCenterStatus>(
                initialValue: widget.draft.status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.flag_outlined),
                ),
                items:
                    CompanyCostCenterStatus.values
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
                    key: const Key('company-cost-save-button'),
                    onPressed: _submit,
                    icon: const Icon(Icons.add),
                    label: const Text('Add center'),
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
      ),
      onChanged: onChanged,
      validator: validator,
    );
  }
}
