import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_career_path_models.dart';

class IncomingTalentCareerPathReviewDateField extends StatelessWidget {
  final IncomingTalentCareerPathDraft draft;
  final VoidCallback onTap;

  const IncomingTalentCareerPathReviewDateField({
    super.key,
    required this.draft,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final value = draft.reviewDate;

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Review date',
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.event_available_outlined),
          errorText: validateIncomingTalentCareerPathReviewDate(
            value,
            draft.asOfDate,
          ),
        ),
        child: Text(
          value == null
              ? 'Select a date'
              : DateFormat('MMM d, yyyy').format(value),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: value == null ? HrisColors.muted : HrisColors.ink,
          ),
        ),
      ),
    );
  }
}
