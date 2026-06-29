import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/candidate_development_models.dart';

class CandidateDevelopmentTextInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final String? Function(String?) validator;
  final int minLines;

  const CandidateDevelopmentTextInput({
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

class CandidateDevelopmentDateFields extends StatelessWidget {
  final CandidateDevelopmentObjectiveDraft draft;
  final VoidCallback onSelectStart;
  final VoidCallback onSelectDue;

  const CandidateDevelopmentDateFields({
    super.key,
    required this.draft,
    required this.onSelectStart,
    required this.onSelectDue,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final startField = _DateField(
          label: 'Start date',
          value: draft.startDate,
          error: CandidateDevelopmentObjectiveDraft.validateStartDate(
            draft.startDate,
            draft.asOfDate,
          ),
          onTap: onSelectStart,
        );
        final dueField = _DateField(
          label: 'Due date',
          value: draft.dueDate,
          error: CandidateDevelopmentObjectiveDraft.validateDueDate(
            draft.dueDate,
            draft.startDate,
          ),
          onTap: onSelectDue,
        );

        if (constraints.maxWidth < 620) {
          return Column(
            children: [startField, const SizedBox(height: 12), dueField],
          );
        }

        return Row(
          children: [
            Expanded(child: startField),
            const SizedBox(width: 12),
            Expanded(child: dueField),
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
          prefixIcon: const Icon(Icons.event_note_outlined),
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

class CandidateDevelopmentDraftReadiness extends StatelessWidget {
  final CandidateDevelopmentObjectiveDraft draft;

  const CandidateDevelopmentDraftReadiness({super.key, required this.draft});

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
