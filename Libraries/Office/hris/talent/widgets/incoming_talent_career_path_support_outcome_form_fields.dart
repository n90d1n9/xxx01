import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_career_path_support_outcome_models.dart';

class IncomingTalentCareerPathSupportOutcomeTextInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final String? Function(String?)? validator;
  final int minLines;

  const IncomingTalentCareerPathSupportOutcomeTextInput({
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

class IncomingTalentCareerPathSupportOutcomeSignalFields
    extends StatelessWidget {
  final IncomingTalentCareerPathSupportOutcomeDraft draft;
  final ValueChanged<IncomingTalentCareerPathSupportOutcomeDecision>
  onDecisionChanged;
  final ValueChanged<IncomingTalentCareerPathSupportOutcomeResidualRisk>
  onResidualRiskChanged;
  final ValueChanged<int> onVerifiedLevelChanged;

  const IncomingTalentCareerPathSupportOutcomeSignalFields({
    super.key,
    required this.draft,
    required this.onDecisionChanged,
    required this.onResidualRiskChanged,
    required this.onVerifiedLevelChanged,
  });

  @override
  Widget build(BuildContext context) {
    final decisionField =
        DropdownButtonFormField<IncomingTalentCareerPathSupportOutcomeDecision>(
          initialValue: draft.decision,
          decoration: const InputDecoration(
            labelText: 'Outcome',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.insights_outlined),
          ),
          items:
              IncomingTalentCareerPathSupportOutcomeDecision.values
                  .map(
                    (decision) => DropdownMenuItem(
                      value: decision,
                      child: Text(decision.label),
                    ),
                  )
                  .toList(),
          onChanged: (value) {
            if (value != null) onDecisionChanged(value);
          },
          validator: validateIncomingTalentCareerPathSupportOutcomeDecision,
        );
    final riskField = DropdownButtonFormField<
      IncomingTalentCareerPathSupportOutcomeResidualRisk
    >(
      initialValue: draft.residualRisk,
      decoration: const InputDecoration(
        labelText: 'Residual risk',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.shield_outlined),
      ),
      items:
          IncomingTalentCareerPathSupportOutcomeResidualRisk.values
              .map(
                (risk) =>
                    DropdownMenuItem(value: risk, child: Text(risk.label)),
              )
              .toList(),
      onChanged: (value) {
        if (value != null) onResidualRiskChanged(value);
      },
      validator: validateIncomingTalentCareerPathSupportOutcomeResidualRisk,
    );
    final levelField = DropdownButtonFormField<int>(
      initialValue:
          draft.verifiedLevel >= 1 && draft.verifiedLevel <= 5
              ? draft.verifiedLevel
              : null,
      decoration: const InputDecoration(
        labelText: 'Verified level',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.trending_up_outlined),
      ),
      items:
          [1, 2, 3, 4, 5]
              .map(
                (level) =>
                    DropdownMenuItem(value: level, child: Text('$level / 5')),
              )
              .toList(),
      onChanged: (value) {
        if (value != null) onVerifiedLevelChanged(value);
      },
      validator:
          (value) =>
              validateIncomingTalentCareerPathSupportOutcomeVerifiedLevel(
                value ?? 0,
              ),
    );

    return _ResponsiveFields(children: [decisionField, riskField, levelField]);
  }
}

class IncomingTalentCareerPathSupportOutcomeDateFields extends StatelessWidget {
  final IncomingTalentCareerPathSupportOutcomeDraft draft;
  final VoidCallback onSelectOutcomeDate;
  final VoidCallback onSelectNextReviewDate;

  const IncomingTalentCareerPathSupportOutcomeDateFields({
    super.key,
    required this.draft,
    required this.onSelectOutcomeDate,
    required this.onSelectNextReviewDate,
  });

  @override
  Widget build(BuildContext context) {
    return _ResponsiveFields(
      children: [
        _OutcomeDateField(
          label: 'Outcome date',
          icon: Icons.event_available_outlined,
          value: draft.outcomeDate,
          error: validateIncomingTalentCareerPathSupportOutcomeDate(
            draft.outcomeDate,
            draft.asOfDate,
          ),
          onTap: onSelectOutcomeDate,
        ),
        _OutcomeDateField(
          label: 'Next review',
          icon: Icons.update_outlined,
          value: draft.nextReviewDate,
          error: validateIncomingTalentCareerPathSupportOutcomeNextReviewDate(
            draft.outcomeDate,
            draft.nextReviewDate,
          ),
          onTap: onSelectNextReviewDate,
        ),
      ],
    );
  }
}

class _OutcomeDateField extends StatelessWidget {
  final String label;
  final IconData icon;
  final DateTime? value;
  final String? error;
  final VoidCallback onTap;

  const _OutcomeDateField({
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

class _ResponsiveFields extends StatelessWidget {
  final List<Widget> children;

  const _ResponsiveFields({required this.children});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 720) {
          return Column(
            children: [
              for (var index = 0; index < children.length; index++) ...[
                if (index > 0) const SizedBox(height: 12),
                children[index],
              ],
            ],
          );
        }

        return Row(
          children: [
            for (var index = 0; index < children.length; index++) ...[
              if (index > 0) const SizedBox(width: 12),
              Expanded(child: children[index]),
            ],
          ],
        );
      },
    );
  }
}
