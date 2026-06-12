import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';

class IncomingTalentSuccessionPanelDecisionTextInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final String? Function(String?) validator;
  final int minLines;

  const IncomingTalentSuccessionPanelDecisionTextInput({
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

class IncomingTalentSuccessionPanelOutcomeField extends StatelessWidget {
  final IncomingTalentSuccessionPanelDecisionDraft draft;
  final ValueChanged<IncomingTalentSuccessionPanelOutcome> onChanged;

  const IncomingTalentSuccessionPanelOutcomeField({
    super.key,
    required this.draft,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<IncomingTalentSuccessionPanelOutcome>(
      initialValue: draft.outcome,
      decoration: const InputDecoration(
        labelText: 'Panel outcome',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.fact_check_outlined),
      ),
      items:
          IncomingTalentSuccessionPanelOutcome.values
              .map(
                (outcome) => DropdownMenuItem(
                  value: outcome,
                  child: Text(outcome.label),
                ),
              )
              .toList(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
      validator: IncomingTalentSuccessionPanelDecisionDraft.validateOutcome,
    );
  }
}

class IncomingTalentSuccessionPanelDecisionDateFields extends StatelessWidget {
  final IncomingTalentSuccessionPanelDecisionDraft draft;
  final VoidCallback onSelectDecisionDate;
  final VoidCallback onSelectActivationDate;
  final VoidCallback onSelectNextReviewDate;

  const IncomingTalentSuccessionPanelDecisionDateFields({
    super.key,
    required this.draft,
    required this.onSelectDecisionDate,
    required this.onSelectActivationDate,
    required this.onSelectNextReviewDate,
  });

  @override
  Widget build(BuildContext context) {
    final decisionField = _PanelDecisionDateField(
      label: 'Decision date',
      icon: Icons.event_available_outlined,
      value: draft.decisionDate,
      error: IncomingTalentSuccessionPanelDecisionDraft.validateDecisionDate(
        draft.decisionDate,
        draft.asOfDate,
      ),
      onTap: onSelectDecisionDate,
    );
    final activationField = _PanelDecisionDateField(
      label: 'Activation date',
      icon: Icons.rocket_launch_outlined,
      value: draft.activationDate,
      error: IncomingTalentSuccessionPanelDecisionDraft.validateActivationDate(
        draft.decisionDate,
        draft.activationDate,
      ),
      onTap: onSelectActivationDate,
    );
    final reviewField = _PanelDecisionDateField(
      label: 'Next review',
      icon: Icons.update_outlined,
      value: draft.nextReviewDate,
      error: IncomingTalentSuccessionPanelDecisionDraft.validateNextReviewDate(
        draft.decisionDate,
        draft.nextReviewDate,
      ),
      onTap: onSelectNextReviewDate,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 720) {
          return Column(
            children: [
              decisionField,
              const SizedBox(height: 12),
              activationField,
              const SizedBox(height: 12),
              reviewField,
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: decisionField),
            const SizedBox(width: 12),
            Expanded(child: activationField),
            const SizedBox(width: 12),
            Expanded(child: reviewField),
          ],
        );
      },
    );
  }
}

class IncomingTalentSuccessionPanelDecisionDraftReadiness
    extends StatelessWidget {
  final IncomingTalentSuccessionPanelDecisionDraft draft;

  const IncomingTalentSuccessionPanelDecisionDraftReadiness({
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

class _PanelDecisionDateField extends StatelessWidget {
  final String label;
  final IconData icon;
  final DateTime? value;
  final String? error;
  final VoidCallback onTap;

  const _PanelDecisionDateField({
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
