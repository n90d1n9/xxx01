import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../../employee/models/employee.dart';
import '../models/payroll_management_models.dart';
import 'payroll_formatters.dart';

class PayrollOffCycleRunPanel extends StatefulWidget {
  final PayrollOffCycleRunDraft draft;
  final PayrollOffCycleRunSummary summary;
  final List<Employee> employees;
  final ValueChanged<int?> onEmployeeChanged;
  final ValueChanged<PayrollOffCycleRunType> onTypeChanged;
  final ValueChanged<String> onGrossAmountChanged;
  final VoidCallback onSelectPayDate;
  final ValueChanged<String> onReasonChanged;
  final ValueChanged<String> onEvidenceReferenceChanged;
  final ValueChanged<bool> onGrossUpChanged;
  final VoidCallback onSubmit;
  final VoidCallback onClear;
  final ValueChanged<String> onApprove;
  final ValueChanged<String> onReject;
  final ValueChanged<String> onRelease;
  final ValueChanged<String> onReopen;

  const PayrollOffCycleRunPanel({
    super.key,
    required this.draft,
    required this.summary,
    required this.employees,
    required this.onEmployeeChanged,
    required this.onTypeChanged,
    required this.onGrossAmountChanged,
    required this.onSelectPayDate,
    required this.onReasonChanged,
    required this.onEvidenceReferenceChanged,
    required this.onGrossUpChanged,
    required this.onSubmit,
    required this.onClear,
    required this.onApprove,
    required this.onReject,
    required this.onRelease,
    required this.onReopen,
  });

  @override
  State<PayrollOffCycleRunPanel> createState() =>
      _PayrollOffCycleRunPanelState();
}

class _PayrollOffCycleRunPanelState extends State<PayrollOffCycleRunPanel> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _reasonController;
  late final TextEditingController _evidenceController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.draft.grossAmount);
    _reasonController = TextEditingController(text: widget.draft.reason);
    _evidenceController = TextEditingController(
      text: widget.draft.evidenceReference,
    );
  }

  @override
  void didUpdateWidget(covariant PayrollOffCycleRunPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync(_amountController, widget.draft.grossAmount);
    _sync(_reasonController, widget.draft.reason);
    _sync(_evidenceController, widget.draft.evidenceReference);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _reasonController.dispose();
    _evidenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      icon: Icons.flash_on_outlined,
      title: 'Off-cycle payroll',
      subtitle: 'Corrections, termination payouts, reimbursements, and bonuses',
      children: [
        _OffCycleSummaryStrip(summary: widget.summary),
        Form(
          key: _formKey,
          child: Column(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final fields = [
                    DropdownButtonFormField<int>(
                      initialValue: widget.draft.employeeId,
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
                      onChanged: widget.onEmployeeChanged,
                      validator:
                          (value) =>
                              value == null ? 'Select an employee' : null,
                    ),
                    DropdownButtonFormField<PayrollOffCycleRunType>(
                      initialValue: widget.draft.type,
                      decoration: const InputDecoration(
                        labelText: 'Run type',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items:
                          PayrollOffCycleRunType.values
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
                  ];

                  if (constraints.maxWidth < 760) {
                    return Column(
                      children:
                          fields
                              .map(
                                (field) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: field,
                                ),
                              )
                              .toList(),
                    );
                  }

                  return Row(
                    children: [
                      Expanded(child: fields[0]),
                      const SizedBox(width: 12),
                      Expanded(child: fields[1]),
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final amountField = TextFormField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Gross amount',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.payments_outlined),
                    ),
                    onChanged: widget.onGrossAmountChanged,
                    validator: PayrollOffCycleRunDraft.validateGrossAmount,
                  );
                  final dateField = _PayDateField(
                    value: widget.draft.payDate,
                    onTap: widget.onSelectPayDate,
                    errorText: PayrollOffCycleRunDraft.validatePayDate(
                      widget.draft.payDate,
                      widget.draft.asOfDate,
                    ),
                  );

                  if (constraints.maxWidth < 760) {
                    return Column(
                      children: [
                        amountField,
                        const SizedBox(height: 12),
                        dateField,
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(child: amountField),
                      const SizedBox(width: 12),
                      Expanded(child: dateField),
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _evidenceController,
                decoration: const InputDecoration(
                  labelText: 'Evidence reference',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attachment_outlined),
                ),
                onChanged: widget.onEvidenceReferenceChanged,
                validator: PayrollOffCycleRunDraft.validateEvidenceReference,
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
                validator: PayrollOffCycleRunDraft.validateReason,
              ),
              const SizedBox(height: 12),
              HrisListSurface(
                child: Row(
                  children: [
                    Expanded(
                      child: HrisProgressBar(
                        value: widget.draft.completionRatio,
                        color:
                            widget.draft.isReadyToSubmit
                                ? const Color(0xFF15803D)
                                : const Color(0xFFB45309),
                        label:
                            '${(widget.draft.completionRatio * 100).round()}% request readiness',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Switch.adaptive(
                      value: widget.draft.grossUp,
                      onChanged: widget.onGrossUpChanged,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Gross-up',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
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
                    onPressed: widget.draft.isReadyToSubmit ? _submit : null,
                    icon: const Icon(Icons.add_task_outlined),
                    label: const Text('Submit request'),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (widget.summary.requests.isEmpty)
          const HrisEmptyState(message: 'No off-cycle payroll requests yet')
        else
          for (final request in widget.summary.requests)
            _OffCycleRequestTile(
              request: request,
              onApprove: widget.onApprove,
              onReject: widget.onReject,
              onRelease: widget.onRelease,
              onReopen: widget.onReopen,
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

class _OffCycleSummaryStrip extends StatelessWidget {
  final PayrollOffCycleRunSummary summary;

  const _OffCycleSummaryStrip({required this.summary});

  @override
  Widget build(BuildContext context) {
    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(
                label: 'Submitted',
                value: '${summary.submittedCount}',
              ),
              HrisMetricStripItem(
                label: 'Approved',
                value: '${summary.approvedCount}',
              ),
              HrisMetricStripItem(
                label: 'Released',
                value: payrollCurrencyFormat.format(summary.releasedNetAmount),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.flag_circle_outlined,
                color: HrisColors.primary,
                size: 19,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  summary.nextAction,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OffCycleRequestTile extends StatelessWidget {
  final PayrollOffCycleRunRequest request;
  final ValueChanged<String> onApprove;
  final ValueChanged<String> onReject;
  final ValueChanged<String> onRelease;
  final ValueChanged<String> onReopen;

  const _OffCycleRequestTile({
    required this.request,
    required this.onApprove,
    required this.onReject,
    required this.onRelease,
    required this.onReopen,
  });

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(request.status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_typeIcon(request.type), color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          request.employeeName,
                          style: Theme.of(
                            context,
                          ).textTheme.titleSmall?.copyWith(
                            color: HrisColors.ink,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        HrisStatusPill(
                          label: request.status.label,
                          color: color,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${request.type.label} - ${request.department}',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _MetaChip(
                icon: Icons.payments_outlined,
                label: payrollCurrencyFormat.format(request.grossAmount),
              ),
              _MetaChip(
                icon: Icons.account_balance_wallet_outlined,
                label: payrollCurrencyFormat.format(request.netAmount),
              ),
              _MetaChip(
                icon: Icons.event_outlined,
                label: DateFormat('MMM d').format(request.payDate),
              ),
              _MetaChip(
                icon: Icons.attachment_outlined,
                label: request.evidenceReference,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (request.status == PayrollOffCycleRunStatus.submitted) ...[
                TextButton(
                  onPressed: () => onReject(request.id),
                  child: const Text('Reject'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: () => onApprove(request.id),
                  icon: const Icon(Icons.verified_outlined),
                  label: const Text('Approve'),
                ),
              ] else if (request.status ==
                  PayrollOffCycleRunStatus.approved) ...[
                TextButton(
                  onPressed: () => onReopen(request.id),
                  child: const Text('Reopen'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: () => onRelease(request.id),
                  icon: const Icon(Icons.send_outlined),
                  label: const Text('Release'),
                ),
              ] else if (request.status == PayrollOffCycleRunStatus.rejected)
                TextButton(
                  onPressed: () => onReopen(request.id),
                  child: const Text('Reopen'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PayDateField extends StatelessWidget {
  final DateTime? value;
  final VoidCallback onTap;
  final String? errorText;

  const _PayDateField({
    required this.value,
    required this.onTap,
    required this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Pay date',
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.event_outlined),
          errorText: errorText,
        ),
        child: Text(
          value == null
              ? 'Select pay date'
              : DateFormat('MMM d, yyyy').format(value!),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: HrisColors.ink,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 17, color: HrisColors.primary),
        const SizedBox(width: 6),
        Text(
          label,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: HrisColors.ink,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

Color _statusColor(PayrollOffCycleRunStatus status) {
  return switch (status) {
    PayrollOffCycleRunStatus.submitted => const Color(0xFF2563EB),
    PayrollOffCycleRunStatus.approved => const Color(0xFF7C3AED),
    PayrollOffCycleRunStatus.rejected => const Color(0xFFB91C1C),
    PayrollOffCycleRunStatus.released => const Color(0xFF15803D),
  };
}

IconData _typeIcon(PayrollOffCycleRunType type) {
  return switch (type) {
    PayrollOffCycleRunType.correction => Icons.tune_outlined,
    PayrollOffCycleRunType.termination => Icons.exit_to_app_outlined,
    PayrollOffCycleRunType.bonus => Icons.stars_outlined,
    PayrollOffCycleRunType.reimbursement => Icons.receipt_outlined,
    PayrollOffCycleRunType.retroPay => Icons.history_outlined,
  };
}
