import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/candidate_talent_handoff_models.dart';

class CandidateTalentHandoffTextInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final String? Function(String?) validator;
  final int minLines;

  const CandidateTalentHandoffTextInput({
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

class CandidateTalentHandoffDateFields extends StatelessWidget {
  final CandidateTalentHandoffDraft draft;
  final VoidCallback onSelectTargetStart;
  final VoidCallback onSelectFirstCheckpoint;

  const CandidateTalentHandoffDateFields({
    super.key,
    required this.draft,
    required this.onSelectTargetStart,
    required this.onSelectFirstCheckpoint,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final targetStartField = _DateField(
          label: 'Target start',
          value: draft.targetStartDate,
          error: CandidateTalentHandoffDraft.validateTargetStartDate(
            draft.targetStartDate,
            draft.asOfDate,
          ),
          onTap: onSelectTargetStart,
        );
        final firstCheckpointField = _DateField(
          label: 'First checkpoint',
          value: draft.firstCheckpointDate,
          error: CandidateTalentHandoffDraft.validateFirstCheckpointDate(
            draft.firstCheckpointDate,
            draft.targetStartDate,
            draft.asOfDate,
          ),
          onTap: onSelectFirstCheckpoint,
        );

        if (constraints.maxWidth < 560) {
          return Column(
            children: [
              targetStartField,
              const SizedBox(height: 10),
              firstCheckpointField,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: targetStartField),
            const SizedBox(width: 10),
            Expanded(child: firstCheckpointField),
          ],
        );
      },
    );
  }
}

class CandidateTalentHandoffDraftReadiness extends StatelessWidget {
  final CandidateTalentHandoffDraft draft;

  const CandidateTalentHandoffDraftReadiness({super.key, required this.draft});

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
