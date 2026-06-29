import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';

class IncomingTalentMobilityTextInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final String? Function(String?)? validator;
  final int minLines;

  const IncomingTalentMobilityTextInput({
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

class IncomingTalentMobilityTypeAndStatusFields extends StatelessWidget {
  final IncomingTalentMobilityMatchDraft draft;
  final ValueChanged<IncomingTalentMobilityMoveType> onMoveTypeChanged;
  final ValueChanged<IncomingTalentMobilityMatchStatus> onStatusChanged;

  const IncomingTalentMobilityTypeAndStatusFields({
    super.key,
    required this.draft,
    required this.onMoveTypeChanged,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final moveTypeField =
        DropdownButtonFormField<IncomingTalentMobilityMoveType>(
          initialValue: draft.moveType,
          decoration: const InputDecoration(
            labelText: 'Move type',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.compare_arrows_outlined),
          ),
          items:
              IncomingTalentMobilityMoveType.values
                  .map(
                    (type) =>
                        DropdownMenuItem(value: type, child: Text(type.label)),
                  )
                  .toList(),
          onChanged: (value) {
            if (value != null) onMoveTypeChanged(value);
          },
          validator: validateIncomingTalentMobilityMoveType,
        );
    final statusField =
        DropdownButtonFormField<IncomingTalentMobilityMatchStatus>(
          initialValue: draft.status,
          decoration: const InputDecoration(
            labelText: 'Match status',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.track_changes_outlined),
          ),
          items:
              IncomingTalentMobilityMatchStatus.values
                  .map(
                    (status) => DropdownMenuItem(
                      value: status,
                      child: Text(status.label),
                    ),
                  )
                  .toList(),
          onChanged: (value) {
            if (value != null) onStatusChanged(value);
          },
          validator: validateIncomingTalentMobilityStatus,
        );

    return _ResponsivePair(left: moveTypeField, right: statusField);
  }
}

class IncomingTalentMobilityDateFields extends StatelessWidget {
  final IncomingTalentMobilityMatchDraft draft;
  final VoidCallback onSelectStartDate;
  final VoidCallback onSelectReviewDate;

  const IncomingTalentMobilityDateFields({
    super.key,
    required this.draft,
    required this.onSelectStartDate,
    required this.onSelectReviewDate,
  });

  @override
  Widget build(BuildContext context) {
    return _ResponsivePair(
      left: _DateField(
        label: 'Start date',
        value: draft.startDate,
        error: validateIncomingTalentMobilityStartDate(
          draft.startDate,
          draft.asOfDate,
        ),
        onTap: onSelectStartDate,
      ),
      right: _DateField(
        label: 'Review date',
        value: draft.reviewDate,
        error: validateIncomingTalentMobilityReviewDate(
          draft.startDate,
          draft.reviewDate,
        ),
        onTap: onSelectReviewDate,
      ),
    );
  }
}

class IncomingTalentMobilityFitField extends StatelessWidget {
  final IncomingTalentMobilityMatchDraft draft;
  final ValueChanged<double> onChanged;

  const IncomingTalentMobilityFitField({
    super.key,
    required this.draft,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HrisProgressBar(
            value: draft.fitScore / 100,
            color:
                draft.fitScore >= 75
                    ? const Color(0xFF15803D)
                    : HrisColors.primary,
            label: '${draft.fitScore}% fit score',
          ),
          Slider(
            value: draft.fitScore.toDouble(),
            min: 0,
            max: 100,
            divisions: 20,
            label: '${draft.fitScore}',
            onChanged: onChanged,
          ),
          if (validateIncomingTalentMobilityFitScore(draft.fitScore)
              case final error?)
            Text(
              error,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFFDC2626),
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }
}

class IncomingTalentMobilityDraftReadiness extends StatelessWidget {
  final IncomingTalentMobilityMatchDraft draft;

  const IncomingTalentMobilityDraftReadiness({super.key, required this.draft});

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

class _ResponsivePair extends StatelessWidget {
  final Widget left;
  final Widget right;

  const _ResponsivePair({required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 620) {
          return Column(children: [left, const SizedBox(height: 12), right]);
        }

        return Row(
          children: [
            Expanded(child: left),
            const SizedBox(width: 12),
            Expanded(child: right),
          ],
        );
      },
    );
  }
}
