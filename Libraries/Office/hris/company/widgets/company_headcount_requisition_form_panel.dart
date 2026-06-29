import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/company_headcount_requisition.dart';

/// Intake form for creating structured headcount requisitions.
class CompanyHeadcountRequisitionFormPanel extends StatefulWidget {
  final CompanyHeadcountRequisitionDraft draft;
  final List<String> entities;
  final List<String> orgUnits;
  final List<String> positionControlIds;
  final List<String> jobProfileCodes;
  final List<String> costCenterCodes;
  final ValueChanged<String> onRoleTitleChanged;
  final ValueChanged<String> onEntityChanged;
  final ValueChanged<String> onOrgUnitChanged;
  final ValueChanged<String> onHiringManagerChanged;
  final ValueChanged<String> onPositionControlChanged;
  final ValueChanged<String> onJobProfileChanged;
  final ValueChanged<String> onCostCenterChanged;
  final ValueChanged<CompanyHeadcountRequisitionType> onTypeChanged;
  final ValueChanged<CompanyHeadcountRequisitionPriority> onPriorityChanged;
  final ValueChanged<CompanyHeadcountRequisitionStatus> onStatusChanged;
  final ValueChanged<String> onRequestedSeatsChanged;
  final ValueChanged<String> onTargetStartChanged;
  final ValueChanged<String> onBusinessCaseChanged;
  final ValueChanged<String> onBudgetImpactChanged;
  final ValueChanged<String> onApproverChanged;
  final VoidCallback onSubmit;
  final VoidCallback onClear;

  const CompanyHeadcountRequisitionFormPanel({
    super.key,
    required this.draft,
    required this.entities,
    required this.orgUnits,
    required this.positionControlIds,
    required this.jobProfileCodes,
    required this.costCenterCodes,
    required this.onRoleTitleChanged,
    required this.onEntityChanged,
    required this.onOrgUnitChanged,
    required this.onHiringManagerChanged,
    required this.onPositionControlChanged,
    required this.onJobProfileChanged,
    required this.onCostCenterChanged,
    required this.onTypeChanged,
    required this.onPriorityChanged,
    required this.onStatusChanged,
    required this.onRequestedSeatsChanged,
    required this.onTargetStartChanged,
    required this.onBusinessCaseChanged,
    required this.onBudgetImpactChanged,
    required this.onApproverChanged,
    required this.onSubmit,
    required this.onClear,
  });

  @override
  State<CompanyHeadcountRequisitionFormPanel> createState() =>
      _CompanyHeadcountRequisitionFormPanelState();
}

/// State holder for the requisition form controllers.
class _CompanyHeadcountRequisitionFormPanelState
    extends State<CompanyHeadcountRequisitionFormPanel> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _roleTitleController;
  late final TextEditingController _hiringManagerController;
  late final TextEditingController _requestedSeatsController;
  late final TextEditingController _targetStartController;
  late final TextEditingController _businessCaseController;
  late final TextEditingController _budgetImpactController;
  late final TextEditingController _approverController;

  @override
  void initState() {
    super.initState();
    _roleTitleController = TextEditingController(text: widget.draft.roleTitle);
    _hiringManagerController = TextEditingController(
      text: widget.draft.hiringManagerName,
    );
    _requestedSeatsController = TextEditingController(
      text: widget.draft.requestedSeatsText,
    );
    _targetStartController = TextEditingController(
      text: widget.draft.targetStartDateText,
    );
    _businessCaseController = TextEditingController(
      text: widget.draft.businessCase,
    );
    _budgetImpactController = TextEditingController(
      text: widget.draft.budgetImpact,
    );
    _approverController = TextEditingController(
      text: widget.draft.approverRole,
    );
  }

  @override
  void didUpdateWidget(
    covariant CompanyHeadcountRequisitionFormPanel oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);
    _sync(_roleTitleController, widget.draft.roleTitle);
    _sync(_hiringManagerController, widget.draft.hiringManagerName);
    _sync(_requestedSeatsController, widget.draft.requestedSeatsText);
    _sync(_targetStartController, widget.draft.targetStartDateText);
    _sync(_businessCaseController, widget.draft.businessCase);
    _sync(_budgetImpactController, widget.draft.budgetImpact);
    _sync(_approverController, widget.draft.approverRole);
  }

  @override
  void dispose() {
    _roleTitleController.dispose();
    _hiringManagerController.dispose();
    _requestedSeatsController.dispose();
    _targetStartController.dispose();
    _businessCaseController.dispose();
    _budgetImpactController.dispose();
    _approverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectableEntities =
        widget.entities.where((entity) => entity != 'All').toList();

    return HrisSectionPanel(
      icon: Icons.person_add_alt_1_outlined,
      title: 'Headcount Requisition Form',
      subtitle: 'Capture hiring demand before offer approval',
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              _TextInput(
                key: const Key('company-headcount-role-field'),
                controller: _roleTitleController,
                label: 'Role title',
                icon: Icons.work_outline,
                onChanged: widget.onRoleTitleChanged,
                validator:
                    (value) =>
                        CompanyHeadcountRequisitionDraft.validateRequired(
                          value,
                          'role title',
                        ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StringDropdown(
                      label: 'Legal entity',
                      icon: Icons.business_outlined,
                      value: widget.draft.entityName,
                      options: selectableEntities,
                      onChanged: widget.onEntityChanged,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StringDropdown(
                      label: 'Org unit',
                      icon: Icons.account_tree_outlined,
                      value: widget.draft.orgUnitName,
                      options: widget.orgUnits,
                      onChanged: widget.onOrgUnitChanged,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<
                      CompanyHeadcountRequisitionType
                    >(
                      isExpanded: true,
                      initialValue: widget.draft.type,
                      decoration: const InputDecoration(
                        labelText: 'Reason',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items:
                          CompanyHeadcountRequisitionType.values
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
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<
                      CompanyHeadcountRequisitionPriority
                    >(
                      isExpanded: true,
                      initialValue: widget.draft.priority,
                      decoration: const InputDecoration(
                        labelText: 'Priority',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.priority_high_outlined),
                      ),
                      items:
                          CompanyHeadcountRequisitionPriority.values
                              .map(
                                (priority) => DropdownMenuItem(
                                  value: priority,
                                  child: Text(priority.label),
                                ),
                              )
                              .toList(),
                      onChanged: (priority) {
                        if (priority != null) {
                          widget.onPriorityChanged(priority);
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
                    child: DropdownButtonFormField<
                      CompanyHeadcountRequisitionStatus
                    >(
                      isExpanded: true,
                      initialValue: widget.draft.status,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.flag_outlined),
                      ),
                      items:
                          CompanyHeadcountRequisitionStatus.values
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
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-headcount-manager-field'),
                      controller: _hiringManagerController,
                      label: 'Hiring manager',
                      icon: Icons.supervisor_account_outlined,
                      onChanged: widget.onHiringManagerChanged,
                      validator:
                          (value) =>
                              CompanyHeadcountRequisitionDraft.validateRequired(
                                value,
                                'hiring manager',
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
                      key: const Key('company-headcount-seats-field'),
                      controller: _requestedSeatsController,
                      label: 'Requested seats',
                      icon: Icons.event_seat_outlined,
                      keyboardType: TextInputType.number,
                      onChanged: widget.onRequestedSeatsChanged,
                      validator:
                          (value) =>
                              CompanyHeadcountRequisitionDraft.validatePositiveInt(
                                value,
                                'requested seats',
                              ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TextInput(
                      key: const Key('company-headcount-start-field'),
                      controller: _targetStartController,
                      label: 'Target start (YYYY-MM-DD)',
                      icon: Icons.event_outlined,
                      onChanged: widget.onTargetStartChanged,
                      validator: CompanyHeadcountRequisitionDraft.validateDate,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StringDropdown(
                      label: 'Job profile',
                      icon: Icons.badge_outlined,
                      value: widget.draft.jobProfileCode,
                      options: widget.jobProfileCodes,
                      onChanged: widget.onJobProfileChanged,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StringDropdown(
                      label: 'Cost center',
                      icon: Icons.account_balance_wallet_outlined,
                      value: widget.draft.costCenterCode,
                      options: widget.costCenterCodes,
                      onChanged: widget.onCostCenterChanged,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _StringDropdown(
                label: 'Position control',
                icon: Icons.assignment_ind_outlined,
                value: widget.draft.positionControlId,
                options: widget.positionControlIds,
                onChanged: widget.onPositionControlChanged,
                required: false,
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-headcount-approver-field'),
                controller: _approverController,
                label: 'Approver role',
                icon: Icons.verified_user_outlined,
                onChanged: widget.onApproverChanged,
                validator:
                    (value) =>
                        CompanyHeadcountRequisitionDraft.validateRequired(
                          value,
                          'approver role',
                        ),
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-headcount-case-field'),
                controller: _businessCaseController,
                label: 'Business case',
                icon: Icons.notes_outlined,
                minLines: 2,
                maxLines: 4,
                onChanged: widget.onBusinessCaseChanged,
                validator:
                    (value) =>
                        CompanyHeadcountRequisitionDraft.validateRequired(
                          value,
                          'business case',
                        ),
              ),
              const SizedBox(height: 12),
              _TextInput(
                key: const Key('company-headcount-budget-field'),
                controller: _budgetImpactController,
                label: 'Budget impact',
                icon: Icons.payments_outlined,
                minLines: 2,
                maxLines: 4,
                onChanged: widget.onBudgetImpactChanged,
                validator:
                    (value) =>
                        CompanyHeadcountRequisitionDraft.validateRequired(
                          value,
                          'budget impact',
                        ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: widget.onClear,
                    icon: const Icon(Icons.refresh_outlined),
                    label: const Text('Clear'),
                  ),
                  const SizedBox(width: 10),
                  FilledButton.icon(
                    key: const Key('company-headcount-submit-button'),
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        widget.onSubmit();
                      }
                    },
                    icon: const Icon(Icons.send_outlined),
                    label: const Text('Submit requisition'),
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

/// Dropdown helper for string-backed requisition links.
class _StringDropdown extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;
  final bool required;

  const _StringDropdown({
    required this.label,
    required this.icon,
    required this.value,
    required this.options,
    required this.onChanged,
    this.required = true,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedOptions =
        options.where((option) => option.trim().isNotEmpty).toSet().toList()
          ..sort();
    final selectedValue = normalizedOptions.contains(value) ? value : null;

    return DropdownButtonFormField<String>(
      isExpanded: true,
      initialValue: selectedValue,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
      items:
          normalizedOptions
              .map(
                (option) => DropdownMenuItem(
                  value: option,
                  child: Text(option, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
      onChanged: (option) {
        if (option != null) onChanged(option);
      },
      validator:
          required
              ? (option) => CompanyHeadcountRequisitionDraft.validateRequired(
                option,
                label.toLowerCase(),
              )
              : null,
    );
  }
}

/// Text input helper for requisition fields.
class _TextInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final int minLines;
  final int maxLines;

  const _TextInput({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.onChanged,
    this.validator,
    this.keyboardType,
    this.minLines = 1,
    this.maxLines = 1,
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
      minLines: minLines,
      maxLines: maxLines,
      keyboardType: keyboardType,
      onChanged: onChanged,
      validator: validator,
    );
  }
}

@Preview(name: 'Company headcount requisition form')
Widget companyHeadcountRequisitionFormPanelPreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: CompanyHeadcountRequisitionFormPanel(
          draft: CompanyHeadcountRequisitionDraft.empty(
            orgUnitName: 'Product & Commerce',
          ).copyWith(
            roleTitle: 'Product Engineer',
            hiringManagerName: 'Fajar Prakoso',
            jobProfileCode: 'ENG-JP-04',
            costCenterCode: 'CC-PROD',
            targetStartDateText: '2026-07-01',
            businessCase: 'Add delivery capacity for commerce roadmap.',
            budgetImpact: 'Uses approved Product & Commerce hiring plan.',
            approverRole: 'Head of Product',
          ),
          entities: const ['All', 'PT Kaysir Nusantara'],
          orgUnits: const ['Product & Commerce', 'People Operations'],
          positionControlIds: const ['position-product-engineer'],
          jobProfileCodes: const ['ENG-JP-04'],
          costCenterCodes: const ['CC-PROD'],
          onRoleTitleChanged: _previewTextChanged,
          onEntityChanged: _previewTextChanged,
          onOrgUnitChanged: _previewTextChanged,
          onHiringManagerChanged: _previewTextChanged,
          onPositionControlChanged: _previewTextChanged,
          onJobProfileChanged: _previewTextChanged,
          onCostCenterChanged: _previewTextChanged,
          onTypeChanged: _previewTypeChanged,
          onPriorityChanged: _previewPriorityChanged,
          onStatusChanged: _previewStatusChanged,
          onRequestedSeatsChanged: _previewTextChanged,
          onTargetStartChanged: _previewTextChanged,
          onBusinessCaseChanged: _previewTextChanged,
          onBudgetImpactChanged: _previewTextChanged,
          onApproverChanged: _previewTextChanged,
          onSubmit: _previewSubmit,
          onClear: _previewSubmit,
        ),
      ),
    ),
  );
}

void _previewTextChanged(String value) {}

void _previewTypeChanged(CompanyHeadcountRequisitionType value) {}

void _previewPriorityChanged(CompanyHeadcountRequisitionPriority value) {}

void _previewStatusChanged(CompanyHeadcountRequisitionStatus value) {}

void _previewSubmit() {}
