import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/company_org_unit.dart';

class CompanyOrgUnitFormPanel extends StatefulWidget {
  final CompanyOrgUnitDraft draft;
  final List<String> entities;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onCodeChanged;
  final ValueChanged<String> onEntityChanged;
  final ValueChanged<String> onParentChanged;
  final ValueChanged<String> onManagerChanged;
  final ValueChanged<String> onLocationChanged;
  final ValueChanged<String> onPlannedHeadcountChanged;
  final ValueChanged<String> onActiveHeadcountChanged;
  final ValueChanged<CompanyOrgUnitStatus> onStatusChanged;
  final VoidCallback onSubmit;
  final VoidCallback onClear;

  const CompanyOrgUnitFormPanel({
    super.key,
    required this.draft,
    required this.entities,
    required this.onNameChanged,
    required this.onCodeChanged,
    required this.onEntityChanged,
    required this.onParentChanged,
    required this.onManagerChanged,
    required this.onLocationChanged,
    required this.onPlannedHeadcountChanged,
    required this.onActiveHeadcountChanged,
    required this.onStatusChanged,
    required this.onSubmit,
    required this.onClear,
  });

  @override
  State<CompanyOrgUnitFormPanel> createState() =>
      _CompanyOrgUnitFormPanelState();
}

class _CompanyOrgUnitFormPanelState extends State<CompanyOrgUnitFormPanel> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _codeController;
  late final TextEditingController _parentController;
  late final TextEditingController _managerController;
  late final TextEditingController _locationController;
  late final TextEditingController _plannedController;
  late final TextEditingController _activeController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.draft.name);
    _codeController = TextEditingController(text: widget.draft.code);
    _parentController = TextEditingController(text: widget.draft.parentName);
    _managerController = TextEditingController(text: widget.draft.managerName);
    _locationController = TextEditingController(text: widget.draft.location);
    _plannedController = TextEditingController(
      text: widget.draft.plannedHeadcountText,
    );
    _activeController = TextEditingController(
      text: widget.draft.activeHeadcountText,
    );
  }

  @override
  void didUpdateWidget(covariant CompanyOrgUnitFormPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync(_nameController, widget.draft.name);
    _sync(_codeController, widget.draft.code);
    _sync(_parentController, widget.draft.parentName);
    _sync(_managerController, widget.draft.managerName);
    _sync(_locationController, widget.draft.location);
    _sync(_plannedController, widget.draft.plannedHeadcountText);
    _sync(_activeController, widget.draft.activeHeadcountText);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _parentController.dispose();
    _managerController.dispose();
    _locationController.dispose();
    _plannedController.dispose();
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

    return HrisSectionPanel(
      icon: Icons.account_tree_outlined,
      title: 'Org Unit Form',
      subtitle: 'Create departments, teams, or business units',
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              _TextInput(
                key: const Key('company-org-name-field'),
                controller: _nameController,
                label: 'Unit name',
                icon: Icons.hub_outlined,
                onChanged: widget.onNameChanged,
                validator:
                    (value) => CompanyOrgUnitDraft.validateRequired(
                      value,
                      'unit name',
                    ),
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-org-code-field'),
                controller: _codeController,
                label: 'Org code',
                icon: Icons.tag_outlined,
                onChanged: widget.onCodeChanged,
                validator:
                    (value) =>
                        CompanyOrgUnitDraft.validateRequired(value, 'org code'),
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
                    (value) => CompanyOrgUnitDraft.validateRequired(
                      value,
                      'legal entity',
                    ),
              ),
              const SizedBox(height: 12),
              _TextInput(
                controller: _parentController,
                label: 'Parent unit',
                icon: Icons.account_tree,
                onChanged: widget.onParentChanged,
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-org-manager-field'),
                controller: _managerController,
                label: 'Manager',
                icon: Icons.supervisor_account_outlined,
                onChanged: widget.onManagerChanged,
                validator:
                    (value) =>
                        CompanyOrgUnitDraft.validateRequired(value, 'manager'),
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-org-location-field'),
                controller: _locationController,
                label: 'Location',
                icon: Icons.location_on_outlined,
                onChanged: widget.onLocationChanged,
                validator:
                    (value) =>
                        CompanyOrgUnitDraft.validateRequired(value, 'location'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-org-planned-field'),
                      controller: _plannedController,
                      label: 'Planned',
                      icon: Icons.event_available_outlined,
                      keyboardType: TextInputType.number,
                      onChanged: widget.onPlannedHeadcountChanged,
                      validator: CompanyOrgUnitDraft.validateHeadcount,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-org-active-field'),
                      controller: _activeController,
                      label: 'Active',
                      icon: Icons.groups_2_outlined,
                      keyboardType: TextInputType.number,
                      onChanged: widget.onActiveHeadcountChanged,
                      validator: CompanyOrgUnitDraft.validateHeadcount,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<CompanyOrgUnitStatus>(
                initialValue: widget.draft.status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.flag_outlined),
                ),
                items:
                    CompanyOrgUnitStatus.values
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
                    key: const Key('company-org-save-button'),
                    onPressed: _submit,
                    icon: const Icon(Icons.add),
                    label: const Text('Add unit'),
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
