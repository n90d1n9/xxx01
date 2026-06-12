import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/candidate_development_check_in_models.dart';

class CandidateDevelopmentCheckInTextInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final String? Function(String?) validator;
  final int minLines;

  const CandidateDevelopmentCheckInTextInput({
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

class CandidateDevelopmentCheckInReviewField extends StatelessWidget {
  final CandidateDevelopmentCheckInDraft draft;
  final VoidCallback onSelectReviewDate;

  const CandidateDevelopmentCheckInReviewField({
    super.key,
    required this.draft,
    required this.onSelectReviewDate,
  });

  @override
  Widget build(BuildContext context) {
    final error = CandidateDevelopmentCheckInDraft.validateNextReviewDate(
      draft.nextReviewDate,
      draft.asOfDate,
    );

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onSelectReviewDate,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Next review',
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.event_repeat_outlined),
          errorText: error,
        ),
        child: Text(
          draft.nextReviewDate == null
              ? 'Select a date'
              : DateFormat('MMM d, yyyy').format(draft.nextReviewDate!),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color:
                draft.nextReviewDate == null
                    ? HrisColors.muted
                    : HrisColors.ink,
          ),
        ),
      ),
    );
  }
}

class CandidateDevelopmentCheckInDraftReadiness extends StatelessWidget {
  final CandidateDevelopmentCheckInDraft draft;

  const CandidateDevelopmentCheckInDraftReadiness({
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
