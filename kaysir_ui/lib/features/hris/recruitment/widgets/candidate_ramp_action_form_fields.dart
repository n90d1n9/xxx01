import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/candidate_ramp_action_models.dart';

class CandidateRampActionTextInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final String? Function(String?) validator;
  final int minLines;

  const CandidateRampActionTextInput({
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

class CandidateRampActionDateFields extends StatelessWidget {
  final CandidateRampActionDraft draft;
  final VoidCallback onSelectKickoff;
  final VoidCallback onSelectReadiness;

  const CandidateRampActionDateFields({
    super.key,
    required this.draft,
    required this.onSelectKickoff,
    required this.onSelectReadiness,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final kickoffField = _DateField(
          label: 'Kickoff date',
          value: draft.kickoffDate,
          error: CandidateRampActionDraft.validateKickoffDate(
            draft.kickoffDate,
            draft.asOfDate,
          ),
          onTap: onSelectKickoff,
        );
        final readinessField = _DateField(
          label: 'Readiness date',
          value: draft.readinessDate,
          error: CandidateRampActionDraft.validateReadinessDate(
            draft.readinessDate,
            draft.kickoffDate,
          ),
          onTap: onSelectReadiness,
        );

        if (constraints.maxWidth < 620) {
          return Column(
            children: [
              kickoffField,
              const SizedBox(height: 12),
              readinessField,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: kickoffField),
            const SizedBox(width: 12),
            Expanded(child: readinessField),
          ],
        );
      },
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final String? error;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
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
          prefixIcon: const Icon(Icons.event_available_outlined),
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

class CandidateRampActionDraftReadiness extends StatelessWidget {
  final CandidateRampActionDraft draft;

  const CandidateRampActionDraftReadiness({super.key, required this.draft});

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
