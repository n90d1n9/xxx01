import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../../employee/models/employee.dart';
import '../models/payroll_management_models.dart';
import 'payroll_formatters.dart';

class PayrollDisputeCenterPanel extends StatefulWidget {
  final PayrollDisputeSummary summary;
  final List<Employee> employees;
  final ValueChanged<int?> onEmployeeChanged;
  final ValueChanged<PayrollDisputeType> onTypeChanged;
  final ValueChanged<String> onClaimAmountChanged;
  final ValueChanged<String> onEvidenceReferenceChanged;
  final ValueChanged<String> onDescriptionChanged;
  final VoidCallback onSubmit;
  final VoidCallback onClear;
  final ValueChanged<String> onStartReview;
  final ValueChanged<String> onApproveCorrection;
  final ValueChanged<String> onReject;
  final ValueChanged<String> onClose;

  const PayrollDisputeCenterPanel({
    super.key,
    required this.summary,
    required this.employees,
    required this.onEmployeeChanged,
    required this.onTypeChanged,
    required this.onClaimAmountChanged,
    required this.onEvidenceReferenceChanged,
    required this.onDescriptionChanged,
    required this.onSubmit,
    required this.onClear,
    required this.onStartReview,
    required this.onApproveCorrection,
    required this.onReject,
    required this.onClose,
  });

  @override
  State<PayrollDisputeCenterPanel> createState() =>
      _PayrollDisputeCenterPanelState();
}

class _PayrollDisputeCenterPanelState extends State<PayrollDisputeCenterPanel> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _evidenceController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.summary.draft.claimAmount,
    );
    _evidenceController = TextEditingController(
      text: widget.summary.draft.evidenceReference,
    );
    _descriptionController = TextEditingController(
      text: widget.summary.draft.description,
    );
  }

  @override
  void didUpdateWidget(covariant PayrollDisputeCenterPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync(_amountController, widget.summary.draft.claimAmount);
    _sync(_evidenceController, widget.summary.draft.evidenceReference);
    _sync(_descriptionController, widget.summary.draft.description);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _evidenceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = widget.summary.draft;

    return HrisSectionPanel(
      icon: Icons.support_agent_outlined,
      title: 'Payroll dispute center',
      subtitle: 'Track employee disputes, evidence, and corrections',
      children: [
        _DisputeSummaryStrip(summary: widget.summary),
        Form(
          key: _formKey,
          child: Column(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final employeeField = DropdownButtonFormField<int>(
                    initialValue: draft.employeeId,
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
                        (value) => value == null ? 'Select an employee' : null,
                  );
                  final typeField = DropdownButtonFormField<PayrollDisputeType>(
                    initialValue: draft.type,
                    decoration: const InputDecoration(
                      labelText: 'Dispute type',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    items:
                        PayrollDisputeType.values
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
                  );

                  if (constraints.maxWidth < 760) {
                    return Column(
                      children: [
                        employeeField,
                        const SizedBox(height: 12),
                        typeField,
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(child: employeeField),
                      const SizedBox(width: 12),
                      Expanded(child: typeField),
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Claim amount',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
                onChanged: widget.onClaimAmountChanged,
                validator: PayrollDisputeDraft.validateClaimAmount,
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
                validator: PayrollDisputeDraft.validateEvidenceReference,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                minLines: 3,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Dispute details',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
                onChanged: widget.onDescriptionChanged,
                validator: PayrollDisputeDraft.validateDescription,
              ),
              const SizedBox(height: 12),
              HrisProgressBar(
                value: draft.completionRatio,
                color:
                    draft.isReadyToSubmit
                        ? const Color(0xFF15803D)
                        : const Color(0xFFB45309),
                label:
                    '${(draft.completionRatio * 100).round()}% dispute intake readiness',
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
                    onPressed: draft.isReadyToSubmit ? _submit : null,
                    icon: const Icon(Icons.add_task_outlined),
                    label: const Text('Submit dispute'),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (widget.summary.visibleCases.isEmpty)
          const HrisEmptyState(message: 'No payroll disputes to review')
        else
          for (final item in widget.summary.visibleCases)
            _DisputeCaseTile(
              item: item,
              onStartReview: widget.onStartReview,
              onApproveCorrection: widget.onApproveCorrection,
              onReject: widget.onReject,
              onClose: widget.onClose,
            ),
      ],
    );
  }

  void _submit() {
    final isValid = _formKey.currentState?.validate() == true;
    if (!isValid || !widget.summary.draft.isReadyToSubmit) return;
    widget.onSubmit();
  }

  void _sync(TextEditingController controller, String value) {
    if (controller.text == value) return;
    controller.text = value;
  }
}

class _DisputeSummaryStrip extends StatelessWidget {
  final PayrollDisputeSummary summary;

  const _DisputeSummaryStrip({required this.summary});

  @override
  Widget build(BuildContext context) {
    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(label: 'Open', value: '${summary.openCount}'),
              HrisMetricStripItem(
                label: 'Exposure',
                value: payrollCurrencyFormat.format(summary.openExposure),
              ),
              HrisMetricStripItem(
                label: 'Correction',
                value: payrollCurrencyFormat.format(
                  summary.approvedCorrectionAmount,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.flag_circle_outlined, color: HrisColors.primary),
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

class _DisputeCaseTile extends StatelessWidget {
  final PayrollDisputeCase item;
  final ValueChanged<String> onStartReview;
  final ValueChanged<String> onApproveCorrection;
  final ValueChanged<String> onReject;
  final ValueChanged<String> onClose;

  const _DisputeCaseTile({
    required this.item,
    required this.onStartReview,
    required this.onApproveCorrection,
    required this.onReject,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(item.status);

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
                child: Icon(_typeIcon(item.type), color: color),
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
                          item.employeeName,
                          style: Theme.of(
                            context,
                          ).textTheme.titleSmall?.copyWith(
                            color: HrisColors.ink,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        HrisStatusPill(label: item.status.label, color: color),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.type.label} - ${item.department}',
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
                label: payrollCurrencyFormat.format(item.claimAmount),
              ),
              _MetaChip(
                icon: Icons.event_outlined,
                label: DateFormat('MMM d').format(item.submittedAt),
              ),
              _MetaChip(
                icon: Icons.attachment_outlined,
                label: item.evidenceReference,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (item.canReject)
                TextButton(
                  onPressed: () => onReject(item.id),
                  child: const Text('Reject'),
                ),
              if (item.canReview) ...[
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: () => onStartReview(item.id),
                  icon: const Icon(Icons.rate_review_outlined),
                  label: const Text('Review'),
                ),
              ] else if (item.canApproveCorrection) ...[
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: () => onApproveCorrection(item.id),
                  icon: const Icon(Icons.verified_outlined),
                  label: const Text('Approve correction'),
                ),
              ] else if (item.canClose) ...[
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: () => onClose(item.id),
                  icon: const Icon(Icons.task_alt_outlined),
                  label: const Text('Close'),
                ),
              ],
            ],
          ),
        ],
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

Color _statusColor(PayrollDisputeStatus status) {
  return switch (status) {
    PayrollDisputeStatus.submitted => const Color(0xFF2563EB),
    PayrollDisputeStatus.inReview => const Color(0xFF7C3AED),
    PayrollDisputeStatus.correctionApproved => const Color(0xFF0F766E),
    PayrollDisputeStatus.rejected => const Color(0xFFB91C1C),
    PayrollDisputeStatus.resolved => const Color(0xFF15803D),
  };
}

IconData _typeIcon(PayrollDisputeType type) {
  return switch (type) {
    PayrollDisputeType.missingPay => Icons.payments_outlined,
    PayrollDisputeType.incorrectDeduction => Icons.remove_circle_outline,
    PayrollDisputeType.payslipQuestion => Icons.description_outlined,
    PayrollDisputeType.bankFailure => Icons.account_balance_outlined,
    PayrollDisputeType.taxWithholding => Icons.policy_outlined,
  };
}
