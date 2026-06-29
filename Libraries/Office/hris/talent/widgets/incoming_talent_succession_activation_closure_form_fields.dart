import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';

class IncomingTalentSuccessionActivationClosureTextInput
    extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final String? Function(String?) validator;
  final int minLines;

  const IncomingTalentSuccessionActivationClosureTextInput({
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

class IncomingTalentSuccessionActivationClosureControlFields
    extends StatelessWidget {
  final IncomingTalentSuccessionActivationClosureDraft draft;
  final ValueChanged<IncomingTalentSuccessionActivationClosureType>
  onTypeChanged;
  final ValueChanged<IncomingTalentSuccessionActivationClosureStatus>
  onStatusChanged;
  final VoidCallback onSelectEffectiveDate;

  const IncomingTalentSuccessionActivationClosureControlFields({
    super.key,
    required this.draft,
    required this.onTypeChanged,
    required this.onStatusChanged,
    required this.onSelectEffectiveDate,
  });

  @override
  Widget build(BuildContext context) {
    final typeField =
        DropdownButtonFormField<IncomingTalentSuccessionActivationClosureType>(
          initialValue: draft.closureType,
          decoration: const InputDecoration(
            labelText: 'Closure type',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.work_outline),
          ),
          items:
              IncomingTalentSuccessionActivationClosureType.values
                  .map(
                    (type) =>
                        DropdownMenuItem(value: type, child: Text(type.label)),
                  )
                  .toList(),
          onChanged: (value) {
            if (value != null) onTypeChanged(value);
          },
          validator:
              IncomingTalentSuccessionActivationClosureDraft
                  .validateClosureType,
        );
    final statusField = DropdownButtonFormField<
      IncomingTalentSuccessionActivationClosureStatus
    >(
      initialValue: draft.status,
      decoration: const InputDecoration(
        labelText: 'Status',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.flag_circle_outlined),
      ),
      items:
          IncomingTalentSuccessionActivationClosureStatus.values
              .map(
                (status) =>
                    DropdownMenuItem(value: status, child: Text(status.label)),
              )
              .toList(),
      onChanged: (value) {
        if (value != null) onStatusChanged(value);
      },
      validator: IncomingTalentSuccessionActivationClosureDraft.validateStatus,
    );
    final dateField = _ClosureEffectiveDateField(
      draft: draft,
      onSelectEffectiveDate: onSelectEffectiveDate,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 760) {
          return Column(
            children: [
              typeField,
              const SizedBox(height: 12),
              statusField,
              const SizedBox(height: 12),
              dateField,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: typeField),
            const SizedBox(width: 12),
            Expanded(child: statusField),
            const SizedBox(width: 12),
            Expanded(child: dateField),
          ],
        );
      },
    );
  }
}

class IncomingTalentSuccessionActivationClosureDraftReadiness
    extends StatelessWidget {
  final IncomingTalentSuccessionActivationClosureDraft draft;

  const IncomingTalentSuccessionActivationClosureDraftReadiness({
    super.key,
    required this.draft,
  });

  @override
  Widget build(BuildContext context) {
    final errors = draft.validationErrors;
    final ready = errors.isEmpty;

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HrisProgressBar(
            value: draft.completionRatio,
            color: ready ? const Color(0xFF15803D) : HrisColors.primary,
            label: '${(draft.completionRatio * 100).round()}% complete',
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

class _ClosureEffectiveDateField extends StatelessWidget {
  final IncomingTalentSuccessionActivationClosureDraft draft;
  final VoidCallback onSelectEffectiveDate;

  const _ClosureEffectiveDateField({
    required this.draft,
    required this.onSelectEffectiveDate,
  });

  @override
  Widget build(BuildContext context) {
    final error =
        IncomingTalentSuccessionActivationClosureDraft.validateEffectiveDate(
          draft.effectiveDate,
          draft.asOfDate,
        );

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onSelectEffectiveDate,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Effective date',
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.event_available_outlined),
          errorText: error,
        ),
        child: Text(
          draft.effectiveDate == null
              ? 'Select a date'
              : DateFormat('MMM d, yyyy').format(draft.effectiveDate!),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color:
                draft.effectiveDate == null ? HrisColors.muted : HrisColors.ink,
          ),
        ),
      ),
    );
  }
}
