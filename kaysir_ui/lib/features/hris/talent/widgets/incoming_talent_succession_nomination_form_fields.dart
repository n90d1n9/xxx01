import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';

class IncomingTalentSuccessionNominationTextInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final String? Function(String?) validator;
  final int minLines;

  const IncomingTalentSuccessionNominationTextInput({
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

class IncomingTalentSuccessionNominationTypeFields extends StatelessWidget {
  final IncomingTalentSuccessionNominationDraft draft;
  final ValueChanged<IncomingTalentSuccessionNominationType> onTypeChanged;
  final ValueChanged<IncomingTalentSuccessionNominationStatus> onStatusChanged;

  const IncomingTalentSuccessionNominationTypeFields({
    super.key,
    required this.draft,
    required this.onTypeChanged,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final typeField =
        DropdownButtonFormField<IncomingTalentSuccessionNominationType>(
          initialValue: draft.nominationType,
          decoration: const InputDecoration(
            labelText: 'Nomination type',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.workspace_premium_outlined),
          ),
          items:
              IncomingTalentSuccessionNominationType.values
                  .map(
                    (type) =>
                        DropdownMenuItem(value: type, child: Text(type.label)),
                  )
                  .toList(),
          onChanged: (value) {
            if (value != null) onTypeChanged(value);
          },
          validator:
              IncomingTalentSuccessionNominationDraft.validateNominationType,
        );
    final statusField =
        DropdownButtonFormField<IncomingTalentSuccessionNominationStatus>(
          initialValue: draft.status,
          decoration: const InputDecoration(
            labelText: 'Status',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.fact_check_outlined),
          ),
          items:
              IncomingTalentSuccessionNominationStatus.values
                  .map(
                    (status) => DropdownMenuItem(
                      value: status,
                      child: Text(status.label),
                    ),
                  )
                  .toList(),
          onChanged: (value) {
            if (value != null) onStatusChanged(value);
          },
          validator: IncomingTalentSuccessionNominationDraft.validateStatus,
        );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 620) {
          return Column(
            children: [typeField, const SizedBox(height: 12), statusField],
          );
        }
        return Row(
          children: [
            Expanded(child: typeField),
            const SizedBox(width: 12),
            Expanded(child: statusField),
          ],
        );
      },
    );
  }
}

class IncomingTalentSuccessionNominationDateFields extends StatelessWidget {
  final IncomingTalentSuccessionNominationDraft draft;
  final VoidCallback onSelectNominationDate;
  final VoidCallback onSelectPanelDate;

  const IncomingTalentSuccessionNominationDateFields({
    super.key,
    required this.draft,
    required this.onSelectNominationDate,
    required this.onSelectPanelDate,
  });

  @override
  Widget build(BuildContext context) {
    final nominationField = _NominationDateField(
      label: 'Nomination date',
      icon: Icons.event_available_outlined,
      value: draft.nominationDate,
      error: IncomingTalentSuccessionNominationDraft.validateNominationDate(
        draft.nominationDate,
        draft.asOfDate,
      ),
      onTap: onSelectNominationDate,
    );
    final panelField = _NominationDateField(
      label: 'Panel date',
      icon: Icons.groups_2_outlined,
      value: draft.panelDate,
      error: IncomingTalentSuccessionNominationDraft.validatePanelDate(
        draft.nominationDate,
        draft.panelDate,
      ),
      onTap: onSelectPanelDate,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 620) {
          return Column(
            children: [nominationField, const SizedBox(height: 12), panelField],
          );
        }
        return Row(
          children: [
            Expanded(child: nominationField),
            const SizedBox(width: 12),
            Expanded(child: panelField),
          ],
        );
      },
    );
  }
}

class IncomingTalentSuccessionNominationDraftReadiness extends StatelessWidget {
  final IncomingTalentSuccessionNominationDraft draft;

  const IncomingTalentSuccessionNominationDraftReadiness({
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

class _NominationDateField extends StatelessWidget {
  final String label;
  final IconData icon;
  final DateTime? value;
  final String? error;
  final VoidCallback onTap;

  const _NominationDateField({
    required this.label,
    required this.icon,
    required this.value,
    required this.error,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: Icon(icon),
          errorText: error,
        ),
        child: Text(
          value == null
              ? 'Select a date'
              : DateFormat('MMM d, yyyy').format(value!),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: value == null ? HrisColors.muted : HrisColors.ink,
          ),
        ),
      ),
    );
  }
}
