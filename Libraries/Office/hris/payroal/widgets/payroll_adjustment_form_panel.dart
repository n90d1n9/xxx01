import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/employee/models/employee.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/payroll_management_models.dart';

class PayrollAdjustmentFormPanel extends StatefulWidget {
  final PayrollAdjustmentDraft draft;
  final List<Employee> employees;
  final ValueChanged<int> onEmployeeChanged;
  final ValueChanged<PayrollAdjustmentType> onTypeChanged;
  final ValueChanged<String> onAmountChanged;
  final VoidCallback onSelectEffectiveDate;
  final ValueChanged<String> onCostCenterChanged;
  final ValueChanged<String> onReasonChanged;
  final VoidCallback onSubmit;
  final VoidCallback onClear;

  const PayrollAdjustmentFormPanel({
    super.key,
    required this.draft,
    required this.employees,
    required this.onEmployeeChanged,
    required this.onTypeChanged,
    required this.onAmountChanged,
    required this.onSelectEffectiveDate,
    required this.onCostCenterChanged,
    required this.onReasonChanged,
    required this.onSubmit,
    required this.onClear,
  });

  @override
  State<PayrollAdjustmentFormPanel> createState() =>
      _PayrollAdjustmentFormPanelState();
}

class _PayrollAdjustmentFormPanelState
    extends State<PayrollAdjustmentFormPanel> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _costCenterController;
  late final TextEditingController _reasonController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.draft.amount);
    _costCenterController = TextEditingController(
      text: widget.draft.costCenter,
    );
    _reasonController = TextEditingController(text: widget.draft.reason);
  }

  @override
  void didUpdateWidget(covariant PayrollAdjustmentFormPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync(_amountController, widget.draft.amount);
    _sync(_costCenterController, widget.draft.costCenter);
    _sync(_reasonController, widget.draft.reason);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _costCenterController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedEmployee =
        widget.employees.any(
              (employee) => employee.id == widget.draft.employeeId,
            )
            ? widget.draft.employeeId
            : null;
    final errors = widget.draft.validationErrors;

    return HrisSectionPanel(
      icon: Icons.post_add_outlined,
      title: 'Payroll adjustment form',
      subtitle: 'Bonuses, overtime, reimbursements, and corrections',
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<int>(
                key: const Key('payroll-adjustment-employee-field'),
                initialValue: selectedEmployee,
                decoration: const InputDecoration(
                  labelText: 'Employee',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                items:
                    widget.employees
                        .map(
                          (employee) => DropdownMenuItem(
                            value: employee.id,
                            child: Text(employee.name),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  if (value != null) widget.onEmployeeChanged(value);
                },
                validator: PayrollAdjustmentDraft.validateEmployee,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<PayrollAdjustmentType>(
                initialValue: widget.draft.type,
                decoration: const InputDecoration(
                  labelText: 'Adjustment type',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.tune_outlined),
                ),
                items:
                    PayrollAdjustmentType.values
                        .map(
                          (type) => DropdownMenuItem(
                            value: type,
                            child: Text(type.label),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  if (value != null) widget.onTypeChanged(value);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('payroll-adjustment-amount-field'),
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
                keyboardType: TextInputType.number,
                onChanged: widget.onAmountChanged,
                validator: PayrollAdjustmentDraft.validateAmount,
              ),
              const SizedBox(height: 12),
              _EffectiveDateField(
                effectiveDate: widget.draft.effectiveDate,
                asOfDate: widget.draft.asOfDate,
                onTap: widget.onSelectEffectiveDate,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _costCenterController,
                decoration: const InputDecoration(
                  labelText: 'Cost center',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business_center_outlined),
                ),
                onChanged: widget.onCostCenterChanged,
                validator:
                    (value) => PayrollAdjustmentDraft.validateRequired(
                      value,
                      'a cost center',
                    ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _reasonController,
                minLines: 3,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Reason',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
                onChanged: widget.onReasonChanged,
                validator: PayrollAdjustmentDraft.validateReason,
              ),
              const SizedBox(height: 12),
              _FormReadiness(
                completionRatio: widget.draft.completionRatio,
                errors: errors,
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: widget.onClear,
                    child: const Text('Clear'),
                  ),
                  const SizedBox(width: 10),
                  FilledButton.icon(
                    key: const Key('payroll-adjustment-submit-button'),
                    onPressed: widget.draft.isReadyToSubmit ? _submit : null,
                    icon: const Icon(Icons.send_outlined),
                    label: const Text('Submit adjustment'),
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
    final isValid = _formKey.currentState?.validate() == true;
    if (!isValid || !widget.draft.isReadyToSubmit) return;
    widget.onSubmit();
  }

  void _sync(TextEditingController controller, String value) {
    if (controller.text == value) return;
    controller.text = value;
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
    final error = PayrollAdjustmentDraft.validateEffectiveDate(
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
