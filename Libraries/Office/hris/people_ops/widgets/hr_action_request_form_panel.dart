import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/hr_action_models.dart';

class HrActionRequestFormPanel extends StatefulWidget {
  final HrActionFormDraft draft;
  final List<String> departments;
  final ValueChanged<String> onEmployeeNameChanged;
  final ValueChanged<String> onDepartmentChanged;
  final ValueChanged<HrActionType> onActionTypeChanged;
  final ValueChanged<String> onTargetRoleChanged;
  final VoidCallback onSelectEffectiveDate;
  final ValueChanged<String> onManagerNameChanged;
  final ValueChanged<String> onOwnerNameChanged;
  final ValueChanged<String> onReasonChanged;
  final ValueChanged<bool> onPayrollReviewChanged;
  final ValueChanged<HrActionPriority> onPriorityChanged;
  final VoidCallback onSubmit;
  final VoidCallback onClear;

  const HrActionRequestFormPanel({
    super.key,
    required this.draft,
    required this.departments,
    required this.onEmployeeNameChanged,
    required this.onDepartmentChanged,
    required this.onActionTypeChanged,
    required this.onTargetRoleChanged,
    required this.onSelectEffectiveDate,
    required this.onManagerNameChanged,
    required this.onOwnerNameChanged,
    required this.onReasonChanged,
    required this.onPayrollReviewChanged,
    required this.onPriorityChanged,
    required this.onSubmit,
    required this.onClear,
  });

  @override
  State<HrActionRequestFormPanel> createState() =>
      _HrActionRequestFormPanelState();
}

class _HrActionRequestFormPanelState extends State<HrActionRequestFormPanel> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _employeeNameController;
  late final TextEditingController _targetRoleController;
  late final TextEditingController _managerNameController;
  late final TextEditingController _ownerNameController;
  late final TextEditingController _reasonController;

  @override
  void initState() {
    super.initState();
    _employeeNameController = TextEditingController(
      text: widget.draft.employeeName,
    );
    _targetRoleController = TextEditingController(
      text: widget.draft.targetRole,
    );
    _managerNameController = TextEditingController(
      text: widget.draft.managerName,
    );
    _ownerNameController = TextEditingController(text: widget.draft.ownerName);
    _reasonController = TextEditingController(text: widget.draft.reason);
  }

  @override
  void didUpdateWidget(covariant HrActionRequestFormPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync(_employeeNameController, widget.draft.employeeName);
    _sync(_targetRoleController, widget.draft.targetRole);
    _sync(_managerNameController, widget.draft.managerName);
    _sync(_ownerNameController, widget.draft.ownerName);
    _sync(_reasonController, widget.draft.reason);
  }

  @override
  void dispose() {
    _employeeNameController.dispose();
    _targetRoleController.dispose();
    _managerNameController.dispose();
    _ownerNameController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectableDepartments =
        widget.departments.where((department) => department != 'All').toList();
    final selectedDepartment =
        selectableDepartments.contains(widget.draft.department)
            ? widget.draft.department
            : null;
    final errors = widget.draft.validationErrors;

    return HrisSectionPanel(
      icon: Icons.assignment_ind_outlined,
      title: 'HR action form',
      subtitle: 'Submit employee movement, payroll, and lifecycle changes',
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TextInput(
                key: const Key('hr-action-employee-field'),
                controller: _employeeNameController,
                label: 'Employee',
                icon: Icons.person_outline,
                onChanged: widget.onEmployeeNameChanged,
                validator:
                    (value) => HrActionFormDraft.validateRequired(
                      value,
                      'an employee name',
                    ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                key: const Key('hr-action-department-field'),
                initialValue: selectedDepartment,
                decoration: const InputDecoration(
                  labelText: 'Department',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.apartment_outlined),
                ),
                items:
                    selectableDepartments
                        .map(
                          (department) => DropdownMenuItem(
                            value: department,
                            child: Text(department),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  if (value != null) widget.onDepartmentChanged(value);
                },
                validator:
                    (value) => HrActionFormDraft.validateRequired(
                      value,
                      'a department',
                    ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<HrActionType>(
                initialValue: widget.draft.actionType,
                decoration: const InputDecoration(
                  labelText: 'Action type',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.sync_alt_outlined),
                ),
                items:
                    HrActionType.values
                        .map(
                          (type) => DropdownMenuItem(
                            value: type,
                            child: Text(type.label),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  if (value != null) widget.onActionTypeChanged(value);
                },
              ),
              const SizedBox(height: 12),
              _TextInput(
                controller: _targetRoleController,
                label: 'Role or target change',
                icon: Icons.work_outline,
                onChanged: widget.onTargetRoleChanged,
                validator:
                    (value) => HrActionFormDraft.validateRequired(
                      value,
                      'a role or target change',
                    ),
              ),
              const SizedBox(height: 12),
              _EffectiveDateField(
                effectiveDate: widget.draft.effectiveDate,
                asOfDate: widget.draft.asOfDate,
                onTap: widget.onSelectEffectiveDate,
              ),
              const SizedBox(height: 12),
              _TextInput(
                controller: _managerNameController,
                label: 'Manager',
                icon: Icons.supervisor_account_outlined,
                onChanged: widget.onManagerNameChanged,
                validator:
                    (value) =>
                        HrActionFormDraft.validateRequired(value, 'a manager'),
              ),
              const SizedBox(height: 12),
              _TextInput(
                controller: _ownerNameController,
                label: 'HR owner',
                icon: Icons.support_agent_outlined,
                onChanged: widget.onOwnerNameChanged,
                validator:
                    (value) => HrActionFormDraft.validateRequired(
                      value,
                      'an HR owner',
                    ),
              ),
              const SizedBox(height: 12),
              _TextInput(
                controller: _reasonController,
                label: 'Reason',
                icon: Icons.notes_outlined,
                minLines: 3,
                onChanged: widget.onReasonChanged,
                validator: HrActionFormDraft.validateReason,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<HrActionPriority>(
                initialValue: widget.draft.priority,
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.priority_high_outlined),
                ),
                items:
                    HrActionPriority.values
                        .map(
                          (priority) => DropdownMenuItem(
                            value: priority,
                            child: Text(priority.label),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  if (value != null) widget.onPriorityChanged(value);
                },
              ),
              const SizedBox(height: 12),
              HrisListSurface(
                child: SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: widget.draft.payrollReviewRequired,
                  onChanged: widget.onPayrollReviewChanged,
                  title: const Text('Payroll review'),
                  subtitle: const Text('Compensation, tax, or bank impact'),
                ),
              ),
              const SizedBox(height: 12),
              _FormReadiness(
                completionRatio: widget.draft.completionRatio,
                errors: errors,
              ),
              const SizedBox(height: 14),
              _FormActions(
                canSubmit: widget.draft.isReadyToSubmit,
                onClear: widget.onClear,
                onSubmit: _submit,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _submit() {
    final isValid = _formKey.currentState?.validate() == true;
    if (!isValid || !widget.draft.isReadyToSubmit) return;
    widget.onSubmit();
  }

  void _sync(TextEditingController controller, String value) {
    if (controller.text == value) return;
    controller.text = value;
  }
}

class _TextInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final String? Function(String?) validator;
  final int minLines;

  const _TextInput({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.onChanged,
    required this.validator,
    this.minLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      minLines: minLines,
      maxLines: minLines == 1 ? 1 : 4,
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

class _EffectiveDateField extends StatelessWidget {
  final DateTime? effectiveDate;
  final DateTime asOfDate;
  final VoidCallback onTap;

  const _EffectiveDateField({
    required this.effectiveDate,
    required this.asOfDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final error = HrActionFormDraft.validateEffectiveDate(
      effectiveDate,
      asOfDate,
    );

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Effective date',
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.event_available_outlined),
          errorText: error,
        ),
        child: Text(
          effectiveDate == null
              ? 'Select a date'
              : DateFormat('MMM d, yyyy').format(effectiveDate!),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: effectiveDate == null ? HrisColors.muted : HrisColors.ink,
          ),
        ),
      ),
    );
  }
}

class _FormReadiness extends StatelessWidget {
  final double completionRatio;
  final List<String> errors;

  const _FormReadiness({required this.completionRatio, required this.errors});

  @override
  Widget build(BuildContext context) {
    final ready = errors.isEmpty;

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HrisProgressBar(
            value: completionRatio,
            color: ready ? const Color(0xFF15803D) : HrisColors.primary,
            label: '${(completionRatio * 100).round()}% complete',
          ),
          if (errors.isNotEmpty) ...[
            const SizedBox(height: 10),
            for (final error in errors.take(3))
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Color(0xFFDC2626),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(error)),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _FormActions extends StatelessWidget {
  final bool canSubmit;
  final VoidCallback onClear;
  final VoidCallback onSubmit;

  const _FormActions({
    required this.canSubmit,
    required this.onClear,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(onPressed: onClear, child: const Text('Clear')),
        const SizedBox(width: 10),
        FilledButton.icon(
          key: const Key('hr-action-submit-button'),
          onPressed: canSubmit ? onSubmit : null,
          icon: const Icon(Icons.send_outlined),
          label: const Text('Submit action'),
        ),
      ],
    );
  }
}
