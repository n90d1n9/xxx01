import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/candidate_talent_handoff_checklist_models.dart';

class CandidateTalentHandoffChecklistTextInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final String? Function(String?) validator;
  final int minLines;

  const CandidateTalentHandoffChecklistTextInput({
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

class CandidateTalentHandoffChecklistDueField extends StatelessWidget {
  final CandidateTalentHandoffChecklistDraft draft;
  final VoidCallback onSelectDueDate;

  const CandidateTalentHandoffChecklistDueField({
    super.key,
    required this.draft,
    required this.onSelectDueDate,
  });

  @override
  Widget build(BuildContext context) {
    final error = CandidateTalentHandoffChecklistDraft.validateDueDate(
      draft.dueDate,
      draft.asOfDate,
    );

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onSelectDueDate,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Due date',
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.event_available_outlined),
          errorText: error,
        ),
        child: Text(
          draft.dueDate == null
              ? 'Select a date'
              : DateFormat('MMM d, yyyy').format(draft.dueDate!),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: draft.dueDate == null ? HrisColors.muted : HrisColors.ink,
          ),
        ),
      ),
    );
  }
}

class CandidateTalentHandoffChecklistDraftReadiness extends StatelessWidget {
  final CandidateTalentHandoffChecklistDraft draft;

  const CandidateTalentHandoffChecklistDraftReadiness({
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
