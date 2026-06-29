import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/company_position_control.dart';

class CompanyPositionControlFormPanel extends StatefulWidget {
  final CompanyPositionControlDraft draft;
  final List<String> entities;
  final List<String> orgUnits;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onEntityChanged;
  final ValueChanged<String> onOrgUnitChanged;
  final ValueChanged<CompanyPositionControlType> onTypeChanged;
  final ValueChanged<CompanyPositionControlStatus> onStatusChanged;
  final ValueChanged<String> onOwnerChanged;
  final ValueChanged<String> onAuthorizedSeatsChanged;
  final ValueChanged<String> onFilledSeatsChanged;
  final ValueChanged<String> onFteChanged;
  final ValueChanged<String> onCompensationBandChanged;
  final ValueChanged<String> onNextReviewChanged;
  final ValueChanged<String> onHiringPlanChanged;
  final ValueChanged<String> onLinkedRequisitionChanged;
  final VoidCallback onSubmit;
  final VoidCallback onClear;

  const CompanyPositionControlFormPanel({
    super.key,
    required this.draft,
    required this.entities,
    required this.orgUnits,
    required this.onTitleChanged,
    required this.onEntityChanged,
    required this.onOrgUnitChanged,
    required this.onTypeChanged,
    required this.onStatusChanged,
    required this.onOwnerChanged,
    required this.onAuthorizedSeatsChanged,
    required this.onFilledSeatsChanged,
    required this.onFteChanged,
    required this.onCompensationBandChanged,
    required this.onNextReviewChanged,
    required this.onHiringPlanChanged,
    required this.onLinkedRequisitionChanged,
    required this.onSubmit,
    required this.onClear,
  });

  @override
  State<CompanyPositionControlFormPanel> createState() =>
      _CompanyPositionControlFormPanelState();
}

class _CompanyPositionControlFormPanelState
    extends State<CompanyPositionControlFormPanel> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _ownerController;
  late final TextEditingController _authorizedController;
  late final TextEditingController _filledController;
  late final TextEditingController _fteController;
  late final TextEditingController _bandController;
  late final TextEditingController _reviewController;
  late final TextEditingController _hiringPlanController;
  late final TextEditingController _requisitionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.draft.positionTitle);
    _ownerController = TextEditingController(text: widget.draft.ownerName);
    _authorizedController = TextEditingController(
      text: widget.draft.authorizedSeatsText,
    );
    _filledController = TextEditingController(
      text: widget.draft.filledSeatsText,
    );
    _fteController = TextEditingController(text: widget.draft.fteText);
    _bandController = TextEditingController(
      text: widget.draft.compensationBand,
    );
    _reviewController = TextEditingController(
      text: widget.draft.nextReviewDateText,
    );
    _hiringPlanController = TextEditingController(
      text: widget.draft.hiringPlan,
    );
    _requisitionController = TextEditingController(
      text: widget.draft.linkedRequisition,
    );
  }

  @override
  void didUpdateWidget(covariant CompanyPositionControlFormPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync(_titleController, widget.draft.positionTitle);
    _sync(_ownerController, widget.draft.ownerName);
    _sync(_authorizedController, widget.draft.authorizedSeatsText);
    _sync(_filledController, widget.draft.filledSeatsText);
    _sync(_fteController, widget.draft.fteText);
    _sync(_bandController, widget.draft.compensationBand);
    _sync(_reviewController, widget.draft.nextReviewDateText);
    _sync(_hiringPlanController, widget.draft.hiringPlan);
    _sync(_requisitionController, widget.draft.linkedRequisition);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _ownerController.dispose();
    _authorizedController.dispose();
    _filledController.dispose();
    _fteController.dispose();
    _bandController.dispose();
    _reviewController.dispose();
    _hiringPlanController.dispose();
    _requisitionController.dispose();
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
    final selectableOrgUnits =
        widget.orgUnits.isEmpty ? ['People Operations'] : widget.orgUnits;
    final selectedOrgUnit =
        selectableOrgUnits.contains(widget.draft.orgUnitName)
            ? widget.draft.orgUnitName
            : selectableOrgUnits.firstOrNull;

    return HrisSectionPanel(
      icon: Icons.work_outline,
      title: 'Position Control Form',
      subtitle: 'Authorize seats, FTE, compensation bands, and hiring links',
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              _TextInput(
                key: const Key('company-position-title-field'),
                controller: _titleController,
                label: 'Position title',
                icon: Icons.work_outline,
                onChanged: widget.onTitleChanged,
                validator:
                    (value) => CompanyPositionControlDraft.validateRequired(
                      value,
                      'position title',
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
                              CompanyPositionControlDraft.validateRequired(
                                value,
                                'legal entity',
                              ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: selectedOrgUnit,
                      decoration: const InputDecoration(
                        labelText: 'Org unit',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.account_tree_outlined),
                      ),
                      items:
                          selectableOrgUnits
                              .map(
                                (unit) => DropdownMenuItem(
                                  value: unit,
                                  child: Text(
                                    unit,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (unit) {
                        if (unit != null) widget.onOrgUnitChanged(unit);
                      },
                      validator:
                          (value) =>
                              CompanyPositionControlDraft.validateRequired(
                                value,
                                'org unit',
                              ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<CompanyPositionControlType>(
                      isExpanded: true,
                      initialValue: widget.draft.type,
                      decoration: const InputDecoration(
                        labelText: 'Type',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items:
                          CompanyPositionControlType.values
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
                  const SizedBox(width: 12),
                  Expanded(
                    child:
                        DropdownButtonFormField<CompanyPositionControlStatus>(
                          isExpanded: true,
                          initialValue: widget.draft.status,
                          decoration: const InputDecoration(
                            labelText: 'Status',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.task_alt_outlined),
                          ),
                          items:
                              CompanyPositionControlStatus.values
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
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-position-owner-field'),
                      controller: _ownerController,
                      label: 'Owner',
                      icon: Icons.supervisor_account_outlined,
                      onChanged: widget.onOwnerChanged,
                      validator:
                          (value) =>
                              CompanyPositionControlDraft.validateRequired(
                                value,
                                'owner',
                              ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-position-band-field'),
                      controller: _bandController,
                      label: 'Compensation band',
                      icon: Icons.price_change_outlined,
                      onChanged: widget.onCompensationBandChanged,
                      validator:
                          (value) =>
                              CompanyPositionControlDraft.validateRequired(
                                value,
                                'compensation band',
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
                      key: const Key('company-position-authorized-field'),
                      controller: _authorizedController,
                      label: 'Authorized seats',
                      icon: Icons.event_seat_outlined,
                      keyboardType: TextInputType.number,
                      onChanged: widget.onAuthorizedSeatsChanged,
                      validator:
                          (value) =>
                              CompanyPositionControlDraft.validatePositiveInt(
                                value,
                                'seats',
                              ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-position-filled-field'),
                      controller: _filledController,
                      label: 'Filled seats',
                      icon: Icons.groups_2_outlined,
                      keyboardType: TextInputType.number,
                      onChanged: widget.onFilledSeatsChanged,
                      validator:
                          (value) =>
                              CompanyPositionControlDraft.validateNonNegativeInt(
                                value,
                                'filled seats',
                              ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-position-fte-field'),
                      controller: _fteController,
                      label: 'FTE',
                      icon: Icons.percent_outlined,
                      keyboardType: TextInputType.number,
                      onChanged: widget.onFteChanged,
                      validator:
                          (value) =>
                              CompanyPositionControlDraft.validatePositiveDecimal(
                                value,
                                'FTE',
                              ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-position-review-field'),
                controller: _reviewController,
                label: 'Next review (YYYY-MM-DD)',
                icon: Icons.event_outlined,
                onChanged: widget.onNextReviewChanged,
                validator: CompanyPositionControlDraft.validateDate,
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-position-plan-field'),
                controller: _hiringPlanController,
                label: 'Hiring plan',
                icon: Icons.route_outlined,
                onChanged: widget.onHiringPlanChanged,
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-position-requisition-field'),
                controller: _requisitionController,
                label: 'Linked requisition',
                icon: Icons.link_outlined,
                onChanged: widget.onLinkedRequisitionChanged,
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
                    key: const Key('company-position-save-button'),
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        widget.onSubmit();
                      }
                    },
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Save position'),
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
  final TextInputType? keyboardType;

  const _TextInput({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.onChanged,
    this.validator,
    this.keyboardType,
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
      validator: validator,
      onChanged: onChanged,
    );
  }
}
