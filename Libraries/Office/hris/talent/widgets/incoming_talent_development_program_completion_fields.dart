import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_development_program_models.dart';
import 'incoming_talent_development_program_form_widgets.dart';

class IncomingTalentDevelopmentProgramCompletionMilestonePicker
    extends StatelessWidget {
  final List<IncomingTalentDevelopmentProgramMilestone> milestones;
  final String? selectedMilestoneId;
  final ValueChanged<String?> onChanged;

  const IncomingTalentDevelopmentProgramCompletionMilestonePicker({
    super.key,
    required this.milestones,
    required this.selectedMilestoneId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: selectedMilestoneId,
      decoration: const InputDecoration(
        labelText: 'Accepted milestone',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.workspace_premium_outlined),
      ),
      items:
          milestones
              .map(
                (milestone) => DropdownMenuItem(
                  value: milestone.id,
                  child: Text(milestone.candidateName),
                ),
              )
              .toList(),
      onChanged: onChanged,
    );
  }
}

class IncomingTalentDevelopmentProgramCompletionDecisionFields
    extends StatelessWidget {
  final IncomingTalentDevelopmentProgramCompletionDraft draft;
  final TextEditingController scoreController;
  final ValueChanged<IncomingTalentDevelopmentProgramCompletionDecision>
  onDecisionChanged;
  final ValueChanged<IncomingTalentDevelopmentProgramCredentialLevel>
  onCredentialLevelChanged;
  final ValueChanged<int> onScoreChanged;

  const IncomingTalentDevelopmentProgramCompletionDecisionFields({
    super.key,
    required this.draft,
    required this.scoreController,
    required this.onDecisionChanged,
    required this.onCredentialLevelChanged,
    required this.onScoreChanged,
  });

  @override
  Widget build(BuildContext context) {
    return IncomingTalentDevelopmentProgramResponsiveRow(
      children: [
        DropdownButtonFormField<
          IncomingTalentDevelopmentProgramCompletionDecision
        >(
          initialValue: draft.decision,
          decoration: const InputDecoration(
            labelText: 'Completion decision',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.flag_outlined),
          ),
          items:
              IncomingTalentDevelopmentProgramCompletionDecision.values
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
          validator: validateIncomingTalentProgramCompletionDecision,
        ),
        DropdownButtonFormField<
          IncomingTalentDevelopmentProgramCredentialLevel
        >(
          initialValue: draft.credentialLevel,
          decoration: const InputDecoration(
            labelText: 'Credential level',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.verified_outlined),
          ),
          items:
              IncomingTalentDevelopmentProgramCredentialLevel.values
                  .map(
                    (level) => DropdownMenuItem(
                      value: level,
                      child: Text(level.label),
                    ),
                  )
                  .toList(),
          onChanged: (value) {
            if (value != null) onCredentialLevelChanged(value);
          },
          validator: validateIncomingTalentProgramCredentialLevel,
        ),
        IncomingTalentDevelopmentProgramNumberInput(
          controller: scoreController,
          label: 'Credential score',
          icon: Icons.percent_outlined,
          onChanged: onScoreChanged,
          validator: validateIncomingTalentProgramCompletionScore,
        ),
      ],
    );
  }
}

class IncomingTalentDevelopmentProgramCompletionFormActions
    extends StatelessWidget {
  final double completionRatio;
  final bool canSubmit;
  final VoidCallback onClear;
  final VoidCallback onSubmit;

  const IncomingTalentDevelopmentProgramCompletionFormActions({
    super.key,
    required this.completionRatio,
    required this.canSubmit,
    required this.onClear,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        HrisProgressBar(
          value: completionRatio,
          color: canSubmit ? const Color(0xFF059669) : const Color(0xFFD97706),
          label: canSubmit ? 'Completion ready' : 'Completion draft',
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(onPressed: onClear, child: const Text('Clear')),
            const SizedBox(width: 10),
            FilledButton.icon(
              key: const Key('incoming-talent-program-completion-submit'),
              onPressed: canSubmit ? onSubmit : null,
              icon: const Icon(Icons.workspace_premium_outlined),
              label: const Text('Create completion'),
            ),
          ],
        ),
      ],
    );
  }
}
