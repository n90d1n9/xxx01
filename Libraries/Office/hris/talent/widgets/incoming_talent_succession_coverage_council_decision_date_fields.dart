import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';

class IncomingTalentSuccessionCoverageCouncilDecisionDateFields
    extends StatelessWidget {
  final IncomingTalentSuccessionCoverageCouncilDecisionDraft draft;
  final VoidCallback onSelectDecisionDate;
  final VoidCallback onSelectFollowUpDate;

  const IncomingTalentSuccessionCoverageCouncilDecisionDateFields({
    super.key,
    required this.draft,
    required this.onSelectDecisionDate,
    required this.onSelectFollowUpDate,
  });

  @override
  Widget build(BuildContext context) {
    final decisionDateField = _CouncilDecisionDateField(
      label: 'Decision date',
      icon: Icons.event_note_outlined,
      value: draft.decisionDate,
      error: validateCoverageCouncilDecisionDate(
        draft.decisionDate,
        draft.asOfDate,
      ),
      onTap: onSelectDecisionDate,
    );
    final followUpDateField = _CouncilDecisionDateField(
      label: 'Follow-up date',
      icon: Icons.update_outlined,
      value: draft.followUpDate,
      error: validateCoverageCouncilDecisionFollowUpDate(
        draft.decisionDate,
        draft.followUpDate,
      ),
      onTap: onSelectFollowUpDate,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 620) {
          return Column(
            children: [
              decisionDateField,
              const SizedBox(height: 12),
              followUpDateField,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: decisionDateField),
            const SizedBox(width: 12),
            Expanded(child: followUpDateField),
          ],
        );
      },
    );
  }
}

class _CouncilDecisionDateField extends StatelessWidget {
  final String label;
  final IconData icon;
  final DateTime? value;
  final String? error;
  final VoidCallback onTap;

  const _CouncilDecisionDateField({
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
