import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';

class IncomingTalentSuccessionCoverageCouncilFollowUpTextInput
    extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final String? Function(String?)? validator;
  final int minLines;

  const IncomingTalentSuccessionCoverageCouncilFollowUpTextInput({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.onChanged,
    this.validator,
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

class IncomingTalentSuccessionCoverageCouncilFollowUpTypeAndDateFields
    extends StatelessWidget {
  final IncomingTalentSuccessionCoverageCouncilFollowUpDraft draft;
  final ValueChanged<IncomingTalentSuccessionCoverageCouncilFollowUpType>
  onTypeChanged;
  final VoidCallback onSelectDueDate;

  const IncomingTalentSuccessionCoverageCouncilFollowUpTypeAndDateFields({
    super.key,
    required this.draft,
    required this.onTypeChanged,
    required this.onSelectDueDate,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final typeField = DropdownButtonFormField<
          IncomingTalentSuccessionCoverageCouncilFollowUpType
        >(
          initialValue: draft.followUpType,
          decoration: const InputDecoration(
            labelText: 'Follow-up type',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.route_outlined),
          ),
          items:
              IncomingTalentSuccessionCoverageCouncilFollowUpType.values
                  .map(
                    (type) =>
                        DropdownMenuItem(value: type, child: Text(type.label)),
                  )
                  .toList(),
          onChanged: (value) {
            if (value != null) onTypeChanged(value);
          },
          validator: validateCoverageCouncilFollowUpType,
        );
        final dueDateField = _DueDateField(
          draft: draft,
          onSelectDueDate: onSelectDueDate,
        );

        if (constraints.maxWidth < 620) {
          return Column(
            children: [typeField, const SizedBox(height: 12), dueDateField],
          );
        }

        return Row(
          children: [
            Expanded(child: typeField),
            const SizedBox(width: 12),
            Expanded(child: dueDateField),
          ],
        );
      },
    );
  }
}

class IncomingTalentSuccessionCoverageCouncilFollowUpDraftReadiness
    extends StatelessWidget {
  final IncomingTalentSuccessionCoverageCouncilFollowUpDraft draft;

  const IncomingTalentSuccessionCoverageCouncilFollowUpDraftReadiness({
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

class _DueDateField extends StatelessWidget {
  final IncomingTalentSuccessionCoverageCouncilFollowUpDraft draft;
  final VoidCallback onSelectDueDate;

  const _DueDateField({required this.draft, required this.onSelectDueDate});

  @override
  Widget build(BuildContext context) {
    final error =
        draft.decisionDate == null
            ? 'Select decision date'
            : validateCoverageCouncilFollowUpDueDate(
              dueDate: draft.dueDate,
              decisionDate: draft.decisionDate!,
              asOfDate: draft.asOfDate,
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
