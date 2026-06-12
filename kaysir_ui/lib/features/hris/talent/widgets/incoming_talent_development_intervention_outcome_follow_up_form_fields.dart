import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_development_intervention_outcome_follow_up_models.dart';
import '../models/incoming_talent_development_intervention_outcome_models.dart';
import 'talent_meta_label.dart';

class IncomingTalentDevelopmentInterventionOutcomeFollowUpPicker
    extends StatelessWidget {
  final IncomingTalentDevelopmentInterventionOutcomeFollowUpDraft draft;
  final List<IncomingTalentDevelopmentInterventionOutcome> outcomes;
  final ValueChanged<String?> onChanged;

  const IncomingTalentDevelopmentInterventionOutcomeFollowUpPicker({
    super.key,
    required this.draft,
    required this.outcomes,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selected =
        outcomes.any((item) => item.id == draft.outcomeId)
            ? draft.outcomeId
            : null;

    return DropdownButtonFormField<String>(
      key: ValueKey('intervention-outcome-follow-up-${draft.outcomeId}'),
      initialValue: selected,
      decoration: const InputDecoration(
        labelText: 'Intervention outcome',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.health_and_safety_outlined),
      ),
      items:
          outcomes
              .map(
                (item) => DropdownMenuItem(
                  value: item.id,
                  child: Text(
                    '${item.candidateName} - ${item.decision.label}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
      onChanged: outcomes.isEmpty ? null : onChanged,
      validator:
          (value) =>
              IncomingTalentDevelopmentInterventionOutcomeFollowUpDraft.validateRequired(
                value,
                'an intervention outcome',
              ),
    );
  }
}

class IncomingTalentDevelopmentInterventionOutcomeFollowUpTextInput
    extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final String? Function(String?) validator;
  final int minLines;

  const IncomingTalentDevelopmentInterventionOutcomeFollowUpTextInput({
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

class IncomingTalentDevelopmentInterventionOutcomeFollowUpControls
    extends StatelessWidget {
  final IncomingTalentDevelopmentInterventionOutcomeFollowUpDraft draft;
  final VoidCallback onSelectDueDate;
  final ValueChanged<IncomingTalentDevelopmentInterventionOutcomeFollowUpStatus>
  onStatusChanged;

  const IncomingTalentDevelopmentInterventionOutcomeFollowUpControls({
    super.key,
    required this.draft,
    required this.onSelectDueDate,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final dateField = _DateInput(
      label: 'Follow-up due',
      value: draft.dueDate,
      errorText:
          IncomingTalentDevelopmentInterventionOutcomeFollowUpDraft.validateDueDate(
            draft.outcomeReviewDate,
            draft.dueDate,
          ),
      onTap: onSelectDueDate,
    );
    final statusField = DropdownButtonFormField<
      IncomingTalentDevelopmentInterventionOutcomeFollowUpStatus
    >(
      initialValue: draft.status,
      decoration: const InputDecoration(
        labelText: 'Status',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.flag_outlined),
      ),
      items:
          IncomingTalentDevelopmentInterventionOutcomeFollowUpStatus.values
              .map(
                (item) =>
                    DropdownMenuItem(value: item, child: Text(item.label)),
              )
              .toList(),
      onChanged: (value) {
        if (value != null) onStatusChanged(value);
      },
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 620) {
          return Column(
            children: [dateField, const SizedBox(height: 12), statusField],
          );
        }
        return Row(
          children: [
            Expanded(child: dateField),
            const SizedBox(width: 12),
            Expanded(child: statusField),
          ],
        );
      },
    );
  }
}

class IncomingTalentDevelopmentInterventionOutcomeFollowUpReadiness
    extends StatelessWidget {
  final IncomingTalentDevelopmentInterventionOutcomeFollowUpDraft draft;

  const IncomingTalentDevelopmentInterventionOutcomeFollowUpReadiness({
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
          if (draft.outcomeId.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: [
                TalentMetaLabel(
                  icon: Icons.rule_folder_outlined,
                  label: draft.sourceDecision?.label ?? 'Outcome',
                ),
                TalentMetaLabel(
                  icon: Icons.trending_up_outlined,
                  label: '${draft.confidenceAfter}/5 confidence',
                ),
                if (draft.remainingReleaseRiskCount > 0)
                  TalentMetaLabel(
                    icon: Icons.report_problem_outlined,
                    label:
                        '${draft.remainingReleaseRiskCount} release risks left',
                  ),
              ],
            ),
          ],
          if (!ready) ...[
            const SizedBox(height: 10),
            Text(
              errors.first,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFFDC2626),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DateInput extends StatelessWidget {
  final String label;
  final DateTime? value;
  final String? errorText;
  final VoidCallback onTap;

  const _DateInput({
    required this.label,
    required this.value,
    required this.errorText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.event_available_outlined),
          errorText: errorText,
        ),
        child: Text(
          value == null
              ? 'Choose date'
              : DateFormat('MMM d, yyyy').format(value!),
        ),
      ),
    );
  }
}
