import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/company_work_location.dart';

class CompanyWorkLocationFormPanel extends StatefulWidget {
  final CompanyWorkLocationDraft draft;
  final List<String> entities;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onEntityChanged;
  final ValueChanged<CompanyWorkLocationType> onTypeChanged;
  final ValueChanged<String> onCityChanged;
  final ValueChanged<String> onRegionChanged;
  final ValueChanged<String> onAddressChanged;
  final ValueChanged<String> onCoverageOwnerChanged;
  final ValueChanged<String> onCapacityChanged;
  final ValueChanged<String> onAssignedHeadcountChanged;
  final ValueChanged<bool> onAttendancePolicyLinkedChanged;
  final ValueChanged<CompanyWorkLocationStatus> onStatusChanged;
  final VoidCallback onSubmit;
  final VoidCallback onClear;

  const CompanyWorkLocationFormPanel({
    super.key,
    required this.draft,
    required this.entities,
    required this.onNameChanged,
    required this.onEntityChanged,
    required this.onTypeChanged,
    required this.onCityChanged,
    required this.onRegionChanged,
    required this.onAddressChanged,
    required this.onCoverageOwnerChanged,
    required this.onCapacityChanged,
    required this.onAssignedHeadcountChanged,
    required this.onAttendancePolicyLinkedChanged,
    required this.onStatusChanged,
    required this.onSubmit,
    required this.onClear,
  });

  @override
  State<CompanyWorkLocationFormPanel> createState() =>
      _CompanyWorkLocationFormPanelState();
}

class _CompanyWorkLocationFormPanelState
    extends State<CompanyWorkLocationFormPanel> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _cityController;
  late final TextEditingController _regionController;
  late final TextEditingController _addressController;
  late final TextEditingController _ownerController;
  late final TextEditingController _capacityController;
  late final TextEditingController _assignedController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.draft.name);
    _cityController = TextEditingController(text: widget.draft.city);
    _regionController = TextEditingController(text: widget.draft.region);
    _addressController = TextEditingController(text: widget.draft.address);
    _ownerController = TextEditingController(text: widget.draft.coverageOwner);
    _capacityController = TextEditingController(
      text: widget.draft.capacityText,
    );
    _assignedController = TextEditingController(
      text: widget.draft.assignedHeadcountText,
    );
  }

  @override
  void didUpdateWidget(covariant CompanyWorkLocationFormPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync(_nameController, widget.draft.name);
    _sync(_cityController, widget.draft.city);
    _sync(_regionController, widget.draft.region);
    _sync(_addressController, widget.draft.address);
    _sync(_ownerController, widget.draft.coverageOwner);
    _sync(_capacityController, widget.draft.capacityText);
    _sync(_assignedController, widget.draft.assignedHeadcountText);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _regionController.dispose();
    _addressController.dispose();
    _ownerController.dispose();
    _capacityController.dispose();
    _assignedController.dispose();
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
      icon: Icons.location_city_outlined,
      title: 'Work Location Form',
      subtitle: 'Create offices, stores, hubs, and remote scopes',
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              _TextInput(
                key: const Key('company-location-name-field'),
                controller: _nameController,
                label: 'Location name',
                icon: Icons.store_mall_directory_outlined,
                onChanged: widget.onNameChanged,
                validator:
                    (value) => CompanyWorkLocationDraft.validateRequired(
                      value,
                      'location name',
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
                    (value) => CompanyWorkLocationDraft.validateRequired(
                      value,
                      'legal entity',
                    ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<CompanyWorkLocationType>(
                initialValue: widget.draft.type,
                decoration: const InputDecoration(
                  labelText: 'Type',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items:
                    CompanyWorkLocationType.values
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
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-location-city-field'),
                      controller: _cityController,
                      label: 'City',
                      icon: Icons.location_city_outlined,
                      onChanged: widget.onCityChanged,
                      validator:
                          (value) => CompanyWorkLocationDraft.validateRequired(
                            value,
                            'city',
                          ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-location-region-field'),
                      controller: _regionController,
                      label: 'Region',
                      icon: Icons.map_outlined,
                      onChanged: widget.onRegionChanged,
                      validator:
                          (value) => CompanyWorkLocationDraft.validateRequired(
                            value,
                            'region',
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-location-address-field'),
                controller: _addressController,
                label: 'Address',
                icon: Icons.place_outlined,
                onChanged: widget.onAddressChanged,
                validator:
                    (value) => CompanyWorkLocationDraft.validateRequired(
                      value,
                      'address',
                    ),
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-location-owner-field'),
                controller: _ownerController,
                label: 'Coverage owner',
                icon: Icons.support_agent_outlined,
                onChanged: widget.onCoverageOwnerChanged,
                validator:
                    (value) => CompanyWorkLocationDraft.validateRequired(
                      value,
                      'coverage owner',
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-location-capacity-field'),
                      controller: _capacityController,
                      label: 'Capacity',
                      icon: Icons.event_seat_outlined,
                      keyboardType: TextInputType.number,
                      onChanged: widget.onCapacityChanged,
                      validator:
                          (value) =>
                              CompanyWorkLocationDraft.validatePositiveNumber(
                                value,
                                'capacity',
                              ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-location-assigned-field'),
                      controller: _assignedController,
                      label: 'Assigned',
                      icon: Icons.groups_2_outlined,
                      keyboardType: TextInputType.number,
                      onChanged: widget.onAssignedHeadcountChanged,
                      validator: CompanyWorkLocationDraft.validateZeroOrGreater,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<CompanyWorkLocationStatus>(
                initialValue: widget.draft.status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.flag_outlined),
                ),
                items:
                    CompanyWorkLocationStatus.values
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
                    value: widget.draft.attendancePolicyLinked,
                    onChanged: widget.onAttendancePolicyLinkedChanged,
                    title: const Text('Attendance linked'),
                    subtitle: const Text('Location is ready for time tracking'),
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
                    key: const Key('company-location-save-button'),
                    onPressed: _submit,
                    icon: const Icon(Icons.add_location_alt_outlined),
                    label: const Text('Add location'),
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
