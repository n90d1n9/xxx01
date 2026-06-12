import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';

class IncomingTalentSuccessionActivationTextInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final String? Function(String?) validator;
  final int minLines;

  const IncomingTalentSuccessionActivationTextInput({
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

class IncomingTalentSuccessionActivationStatusField extends StatelessWidget {
  final IncomingTalentSuccessionActivationPlanDraft draft;
  final ValueChanged<IncomingTalentSuccessionActivationStatus> onChanged;

  const IncomingTalentSuccessionActivationStatusField({
    super.key,
    required this.draft,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<IncomingTalentSuccessionActivationStatus>(
      initialValue: draft.status,
      decoration: const InputDecoration(
        labelText: 'Activation status',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.rocket_launch_outlined),
      ),
      items:
          IncomingTalentSuccessionActivationStatus.values
              .map(
                (status) =>
                    DropdownMenuItem(value: status, child: Text(status.label)),
              )
              .toList(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
      validator: IncomingTalentSuccessionActivationPlanDraft.validateStatus,
    );
  }
}

class IncomingTalentSuccessionActivationDateFields extends StatelessWidget {
  final IncomingTalentSuccessionActivationPlanDraft draft;
  final VoidCallback onSelectStartDate;
  final VoidCallback onSelectMilestoneDate;
  final VoidCallback onSelectFirstReviewDate;

  const IncomingTalentSuccessionActivationDateFields({
    super.key,
    required this.draft,
    required this.onSelectStartDate,
    required this.onSelectMilestoneDate,
    required this.onSelectFirstReviewDate,
  });

  @override
  Widget build(BuildContext context) {
    final startField = _ActivationDateField(
      label: 'Start date',
      icon: Icons.event_available_outlined,
      value: draft.startDate,
      error: IncomingTalentSuccessionActivationPlanDraft.validateStartDate(
        draft.startDate,
        draft.asOfDate,
      ),
      onTap: onSelectStartDate,
    );
    final milestoneField = _ActivationDateField(
      label: 'Milestone date',
      icon: Icons.flag_outlined,
      value: draft.milestoneDate,
      error: IncomingTalentSuccessionActivationPlanDraft.validateMilestoneDate(
        draft.startDate,
        draft.milestoneDate,
      ),
      onTap: onSelectMilestoneDate,
    );
    final reviewField = _ActivationDateField(
      label: 'First review',
      icon: Icons.update_outlined,
      value: draft.firstReviewDate,
      error:
          IncomingTalentSuccessionActivationPlanDraft.validateFirstReviewDate(
            draft.startDate,
            draft.firstReviewDate,
          ),
      onTap: onSelectFirstReviewDate,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 720) {
          return Column(
            children: [
              startField,
              const SizedBox(height: 12),
              milestoneField,
              const SizedBox(height: 12),
              reviewField,
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: startField),
            const SizedBox(width: 12),
            Expanded(child: milestoneField),
            const SizedBox(width: 12),
            Expanded(child: reviewField),
          ],
        );
      },
    );
  }
}

class IncomingTalentSuccessionActivationDraftReadiness extends StatelessWidget {
  final IncomingTalentSuccessionActivationPlanDraft draft;

  const IncomingTalentSuccessionActivationDraftReadiness({
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

class _ActivationDateField extends StatelessWidget {
  final String label;
  final IconData icon;
  final DateTime? value;
  final String? error;
  final VoidCallback onTap;

  const _ActivationDateField({
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
