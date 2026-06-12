import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/company_entity_lifecycle.dart';

class CompanyEntityLifecycleFormPanel extends StatefulWidget {
  final CompanyEntityLifecycleDraft draft;
  final List<String> entities;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onEntityChanged;
  final ValueChanged<CompanyEntityLifecycleType> onTypeChanged;
  final ValueChanged<CompanyEntityLifecycleStatus> onStatusChanged;
  final ValueChanged<String> onOwnerChanged;
  final ValueChanged<String> onTargetDateChanged;
  final ValueChanged<String> onProgressChanged;
  final ValueChanged<String> onDependencyChanged;
  final ValueChanged<String> onBlockerChanged;
  final ValueChanged<String> onNextMilestoneChanged;
  final VoidCallback onSubmit;
  final VoidCallback onClear;

  const CompanyEntityLifecycleFormPanel({
    super.key,
    required this.draft,
    required this.entities,
    required this.onTitleChanged,
    required this.onEntityChanged,
    required this.onTypeChanged,
    required this.onStatusChanged,
    required this.onOwnerChanged,
    required this.onTargetDateChanged,
    required this.onProgressChanged,
    required this.onDependencyChanged,
    required this.onBlockerChanged,
    required this.onNextMilestoneChanged,
    required this.onSubmit,
    required this.onClear,
  });

  @override
  State<CompanyEntityLifecycleFormPanel> createState() =>
      _CompanyEntityLifecycleFormPanelState();
}

class _CompanyEntityLifecycleFormPanelState
    extends State<CompanyEntityLifecycleFormPanel> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _ownerController;
  late final TextEditingController _targetDateController;
  late final TextEditingController _progressController;
  late final TextEditingController _dependencyController;
  late final TextEditingController _blockerController;
  late final TextEditingController _nextMilestoneController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.draft.title);
    _ownerController = TextEditingController(text: widget.draft.ownerName);
    _targetDateController = TextEditingController(
      text: widget.draft.targetDateText,
    );
    _progressController = TextEditingController(
      text: widget.draft.progressPercentText,
    );
    _dependencyController = TextEditingController(
      text: widget.draft.dependencySummary,
    );
    _blockerController = TextEditingController(text: widget.draft.blocker);
    _nextMilestoneController = TextEditingController(
      text: widget.draft.nextMilestone,
    );
  }

  @override
  void didUpdateWidget(covariant CompanyEntityLifecycleFormPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync(_titleController, widget.draft.title);
    _sync(_ownerController, widget.draft.ownerName);
    _sync(_targetDateController, widget.draft.targetDateText);
    _sync(_progressController, widget.draft.progressPercentText);
    _sync(_dependencyController, widget.draft.dependencySummary);
    _sync(_blockerController, widget.draft.blocker);
    _sync(_nextMilestoneController, widget.draft.nextMilestone);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _ownerController.dispose();
    _targetDateController.dispose();
    _progressController.dispose();
    _dependencyController.dispose();
    _blockerController.dispose();
    _nextMilestoneController.dispose();
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
      icon: Icons.timeline_outlined,
      title: 'Entity Lifecycle Form',
      subtitle: 'Plan openings, activations, restructures, and closures',
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              _TextInput(
                key: const Key('company-lifecycle-title-field'),
                controller: _titleController,
                label: 'Milestone title',
                icon: Icons.drive_file_rename_outline,
                onChanged: widget.onTitleChanged,
                validator:
                    (value) => CompanyEntityLifecycleDraft.validateRequired(
                      value,
                      'milestone title',
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
                              CompanyEntityLifecycleDraft.validateRequired(
                                value,
                                'legal entity',
                              ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<CompanyEntityLifecycleType>(
                      isExpanded: true,
                      initialValue: widget.draft.type,
                      decoration: const InputDecoration(
                        labelText: 'Lifecycle type',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.flag_outlined),
                      ),
                      items:
                          CompanyEntityLifecycleType.values
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
                        DropdownButtonFormField<CompanyEntityLifecycleStatus>(
                          isExpanded: true,
                          initialValue: widget.draft.status,
                          decoration: const InputDecoration(
                            labelText: 'Status',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.task_alt_outlined),
                          ),
                          items:
                              CompanyEntityLifecycleStatus.values
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
                      key: const Key('company-lifecycle-progress-field'),
                      controller: _progressController,
                      label: 'Progress %',
                      icon: Icons.speed_outlined,
                      keyboardType: TextInputType.number,
                      onChanged: widget.onProgressChanged,
                      validator: CompanyEntityLifecycleDraft.validatePercent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-lifecycle-owner-field'),
                      controller: _ownerController,
                      label: 'Owner',
                      icon: Icons.supervisor_account_outlined,
                      onChanged: widget.onOwnerChanged,
                      validator:
                          (value) =>
                              CompanyEntityLifecycleDraft.validateRequired(
                                value,
                                'owner',
                              ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-lifecycle-target-field'),
                      controller: _targetDateController,
                      label: 'Target date',
                      icon: Icons.event_available_outlined,
                      keyboardType: TextInputType.datetime,
                      onChanged: widget.onTargetDateChanged,
                      validator: CompanyEntityLifecycleDraft.validateDate,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-lifecycle-dependency-field'),
                controller: _dependencyController,
                label: 'Dependencies',
                icon: Icons.account_tree_outlined,
                onChanged: widget.onDependencyChanged,
                validator:
                    (value) => CompanyEntityLifecycleDraft.validateRequired(
                      value,
                      'dependencies',
                    ),
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-lifecycle-next-field'),
                controller: _nextMilestoneController,
                label: 'Next milestone',
                icon: Icons.next_plan_outlined,
                onChanged: widget.onNextMilestoneChanged,
                validator:
                    (value) => CompanyEntityLifecycleDraft.validateRequired(
                      value,
                      'next milestone',
                    ),
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-lifecycle-blocker-field'),
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
                    key: const Key('company-lifecycle-save-button'),
                    onPressed: _submit,
                    icon: const Icon(Icons.add_task_outlined),
                    label: const Text('Add milestone'),
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
