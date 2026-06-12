import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_contract_lifecycle_models.dart';

class EmployeeContractChangeForm extends StatelessWidget {
  final EmployeeContractChangeDraft draft;
  final TextEditingController titleController;
  final TextEditingController requestedByController;
  final TextEditingController detailController;
  final ValueChanged<EmployeeContractChangeType> onTypeChanged;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onRequestedByChanged;
  final ValueChanged<String> onDetailChanged;
  final VoidCallback onSelectEffectiveDate;
  final VoidCallback onSubmit;

  const EmployeeContractChangeForm({
    super.key,
    required this.draft,
    required this.titleController,
    required this.requestedByController,
    required this.detailController,
    required this.onTypeChanged,
    required this.onTitleChanged,
    required this.onRequestedByChanged,
    required this.onDetailChanged,
    required this.onSelectEffectiveDate,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final errors = draft.validationErrors;

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<EmployeeContractChangeType>(
                  initialValue: draft.type,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Change type',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.tune_outlined),
                  ),
                  items:
                      EmployeeContractChangeType.values
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
                  onChanged: (value) {
                    if (value != null) onTypeChanged(value);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ContractDateField(
                  date: draft.effectiveDate,
                  onTap: onSelectEffectiveDate,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ContractTextField(
            controller: titleController,
            label: 'Change title',
            icon: Icons.short_text_outlined,
            onChanged: onTitleChanged,
          ),
          const SizedBox(height: 12),
          _ContractTextField(
            controller: requestedByController,
            label: 'Requested by',
            icon: Icons.person_outline,
            onChanged: onRequestedByChanged,
          ),
          const SizedBox(height: 12),
          _ContractTextField(
            controller: detailController,
            label: 'Detail',
            icon: Icons.notes_outlined,
            minLines: 3,
            onChanged: onDetailChanged,
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: draft.completionRatio,
            color:
                draft.isReadyToSubmit
                    ? const Color(0xFF15803D)
                    : HrisColors.primary,
            label: '${(draft.completionRatio * 100).round()}% ready',
          ),
          if (errors.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              errors.first,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFFB91C1C),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: draft.isReadyToSubmit ? onSubmit : null,
              icon: const Icon(Icons.add_task_outlined),
              label: const Text('Add contract change'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContractDateField extends StatelessWidget {
  final DateTime date;
  final VoidCallback onTap;

  const _ContractDateField({required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Effective',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.event_outlined),
        ),
        child: Text(
          DateFormat('MMM d, yyyy').format(date),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _ContractTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final int minLines;

  const _ContractTextField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.onChanged,
    this.minLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: minLines == 1 ? 1 : 4,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
      onChanged: onChanged,
    );
  }
}
