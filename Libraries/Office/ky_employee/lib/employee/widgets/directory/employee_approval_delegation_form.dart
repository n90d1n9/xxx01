import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_approval_coverage_models.dart';

class EmployeeApprovalDelegationForm extends StatelessWidget {
  final EmployeeApprovalDelegationDraft draft;
  final TextEditingController primaryController;
  final TextEditingController delegateController;
  final TextEditingController reasonController;
  final ValueChanged<EmployeeApprovalCoverageArea> onAreaChanged;
  final ValueChanged<String> onPrimaryChanged;
  final ValueChanged<String> onDelegateChanged;
  final ValueChanged<EmployeeApprovalCoverageRisk> onRiskChanged;
  final ValueChanged<String> onReasonChanged;
  final VoidCallback onSelectStartDate;
  final VoidCallback onSelectEndDate;
  final VoidCallback onSubmit;

  const EmployeeApprovalDelegationForm({
    super.key,
    required this.draft,
    required this.primaryController,
    required this.delegateController,
    required this.reasonController,
    required this.onAreaChanged,
    required this.onPrimaryChanged,
    required this.onDelegateChanged,
    required this.onRiskChanged,
    required this.onReasonChanged,
    required this.onSelectStartDate,
    required this.onSelectEndDate,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final errors = draft.validationErrors;

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<EmployeeApprovalCoverageArea>(
            initialValue: draft.area,
            decoration: const InputDecoration(
              labelText: 'Coverage area',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.rule_folder_outlined),
            ),
            items:
                EmployeeApprovalCoverageArea.values
                    .map(
                      (area) => DropdownMenuItem(
                        value: area,
                        child: Text(area.label),
                      ),
                    )
                    .toList(),
            onChanged: (value) {
              if (value != null) onAreaChanged(value);
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: primaryController,
            decoration: const InputDecoration(
              labelText: 'Primary approver',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person_outline),
            ),
            onChanged: onPrimaryChanged,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: delegateController,
            decoration: const InputDecoration(
              labelText: 'Delegate approver',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.swap_horizontal_circle_outlined),
            ),
            onChanged: onDelegateChanged,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<EmployeeApprovalCoverageRisk>(
            initialValue: draft.risk,
            decoration: const InputDecoration(
              labelText: 'Risk',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.flag_outlined),
            ),
            items:
                EmployeeApprovalCoverageRisk.values
                    .map(
                      (risk) => DropdownMenuItem(
                        value: risk,
                        child: Text(risk.label),
                      ),
                    )
                    .toList(),
            onChanged: (value) {
              if (value != null) onRiskChanged(value);
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _DateField(
                  label: 'Start date',
                  value: draft.startDate,
                  onTap: onSelectStartDate,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DateField(
                  label: 'End date',
                  value: draft.endDate,
                  onTap: onSelectEndDate,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: reasonController,
            minLines: 2,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Reason',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.notes_outlined),
            ),
            onChanged: onReasonChanged,
          ),
          if (errors.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...errors.map(
              (error) => Text(
                error,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFFB91C1C),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: HrisProgressBar(
                  value: draft.completionRatio,
                  color:
                      draft.isReadyToSubmit
                          ? const Color(0xFF15803D)
                          : HrisColors.primary,
                  label: '${(draft.completionRatio * 100).round()}% ready',
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: onSubmit,
                icon: const Icon(Icons.add_task_outlined),
                label: const Text('Add delegation'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.event_outlined),
        ),
        child: Text(
          value == null ? 'Select date' : DateFormat('MMM d').format(value!),
        ),
      ),
    );
  }
}
