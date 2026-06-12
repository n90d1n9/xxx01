import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/company_operating_readiness.dart';

class CompanyOperatingReadinessFormPanel extends StatefulWidget {
  final CompanyOperatingReadinessDraft draft;
  final List<String> entities;
  final ValueChanged<CompanyOperatingReadinessArea> onAreaChanged;
  final ValueChanged<String> onEntityChanged;
  final ValueChanged<String> onOwnerChanged;
  final ValueChanged<CompanyOperatingReadinessStatus> onStatusChanged;
  final ValueChanged<String> onCoverageChanged;
  final ValueChanged<String> onLastReviewChanged;
  final ValueChanged<String> onNextReviewChanged;
  final ValueChanged<String> onBlockerChanged;
  final ValueChanged<String> onLinkedModuleChanged;
  final VoidCallback onSubmit;
  final VoidCallback onClear;

  const CompanyOperatingReadinessFormPanel({
    super.key,
    required this.draft,
    required this.entities,
    required this.onAreaChanged,
    required this.onEntityChanged,
    required this.onOwnerChanged,
    required this.onStatusChanged,
    required this.onCoverageChanged,
    required this.onLastReviewChanged,
    required this.onNextReviewChanged,
    required this.onBlockerChanged,
    required this.onLinkedModuleChanged,
    required this.onSubmit,
    required this.onClear,
  });

  @override
  State<CompanyOperatingReadinessFormPanel> createState() =>
      _CompanyOperatingReadinessFormPanelState();
}

class _CompanyOperatingReadinessFormPanelState
    extends State<CompanyOperatingReadinessFormPanel> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _ownerController;
  late final TextEditingController _coverageController;
  late final TextEditingController _lastReviewController;
  late final TextEditingController _nextReviewController;
  late final TextEditingController _blockerController;
  late final TextEditingController _moduleController;

  @override
  void initState() {
    super.initState();
    _ownerController = TextEditingController(text: widget.draft.ownerName);
    _coverageController = TextEditingController(
      text: widget.draft.coveragePercentText,
    );
    _lastReviewController = TextEditingController(
      text: widget.draft.lastReviewDateText,
    );
    _nextReviewController = TextEditingController(
      text: widget.draft.nextReviewDateText,
    );
    _blockerController = TextEditingController(text: widget.draft.blocker);
    _moduleController = TextEditingController(text: widget.draft.linkedModule);
  }

  @override
  void didUpdateWidget(covariant CompanyOperatingReadinessFormPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync(_ownerController, widget.draft.ownerName);
    _sync(_coverageController, widget.draft.coveragePercentText);
    _sync(_lastReviewController, widget.draft.lastReviewDateText);
    _sync(_nextReviewController, widget.draft.nextReviewDateText);
    _sync(_blockerController, widget.draft.blocker);
    _sync(_moduleController, widget.draft.linkedModule);
  }

  @override
  void dispose() {
    _ownerController.dispose();
    _coverageController.dispose();
    _lastReviewController.dispose();
    _nextReviewController.dispose();
    _blockerController.dispose();
    _moduleController.dispose();
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
      icon: Icons.settings_suggest_outlined,
      title: 'Operating Readiness Form',
      subtitle: 'Enable HR services per legal entity',
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child:
                        DropdownButtonFormField<CompanyOperatingReadinessArea>(
                          isExpanded: true,
                          initialValue: widget.draft.area,
                          decoration: const InputDecoration(
                            labelText: 'Service area',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.hub_outlined),
                          ),
                          items:
                              CompanyOperatingReadinessArea.values
                                  .map(
                                    (area) => DropdownMenuItem(
                                      value: area,
                                      child: Text(
                                        area.label,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (area) {
                            if (area != null) widget.onAreaChanged(area);
                          },
                        ),
                  ),
                  const SizedBox(width: 12),
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
                              CompanyOperatingReadinessDraft.validateRequired(
                                value,
                                'legal entity',
                              ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-operating-owner-field'),
                controller: _ownerController,
                label: 'Owner',
                icon: Icons.supervisor_account_outlined,
                onChanged: widget.onOwnerChanged,
                validator:
                    (value) => CompanyOperatingReadinessDraft.validateRequired(
                      value,
                      'owner',
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<
                      CompanyOperatingReadinessStatus
                    >(
                      isExpanded: true,
                      initialValue: widget.draft.status,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.flag_outlined),
                      ),
                      items:
                          CompanyOperatingReadinessStatus.values
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
                      key: const Key('company-operating-coverage-field'),
                      controller: _coverageController,
                      label: 'Coverage %',
                      icon: Icons.speed_outlined,
                      keyboardType: TextInputType.number,
                      onChanged: widget.onCoverageChanged,
                      validator: CompanyOperatingReadinessDraft.validatePercent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-operating-last-review-field'),
                      controller: _lastReviewController,
                      label: 'Last review',
                      icon: Icons.event_available_outlined,
                      keyboardType: TextInputType.datetime,
                      onChanged: widget.onLastReviewChanged,
                      validator: CompanyOperatingReadinessDraft.validateDate,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-operating-next-review-field'),
                      controller: _nextReviewController,
                      label: 'Next review',
                      icon: Icons.event_busy_outlined,
                      keyboardType: TextInputType.datetime,
                      onChanged: widget.onNextReviewChanged,
                      validator: CompanyOperatingReadinessDraft.validateDate,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-operating-module-field'),
                controller: _moduleController,
                label: 'Linked module',
                icon: Icons.apps_outlined,
                onChanged: widget.onLinkedModuleChanged,
                validator:
                    (value) => CompanyOperatingReadinessDraft.validateRequired(
                      value,
                      'linked module',
                    ),
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-operating-blocker-field'),
                controller: _blockerController,
                label: 'Blocker',
                icon: Icons.report_problem_outlined,
                onChanged: widget.onBlockerChanged,
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
                    key: const Key('company-operating-save-button'),
                    onPressed: _submit,
                    icon: const Icon(Icons.add_task_outlined),
                    label: const Text('Add service'),
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
