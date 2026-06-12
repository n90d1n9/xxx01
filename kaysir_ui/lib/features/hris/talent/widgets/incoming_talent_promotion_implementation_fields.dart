import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_promotion_decision_models.dart';
import '../models/incoming_talent_promotion_implementation_models.dart';
import '../models/incoming_talent_promotion_readiness_models.dart';
import 'incoming_talent_development_program_form_widgets.dart';

/// Picker for promotion decisions that still need implementation work.
class IncomingTalentPromotionImplementationDecisionPicker
    extends StatelessWidget {
  final List<IncomingTalentPromotionDecision> decisions;
  final String? selectedDecisionId;
  final ValueChanged<String?> onDecisionChanged;

  const IncomingTalentPromotionImplementationDecisionPicker({
    super.key,
    required this.decisions,
    required this.selectedDecisionId,
    required this.onDecisionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: selectedDecisionId,
      decoration: const InputDecoration(
        labelText: 'Promotion decision',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.how_to_reg_outlined),
      ),
      items:
          decisions
              .map(
                (decision) => DropdownMenuItem(
                  value: decision.id,
                  child: Text(
                    '${decision.candidateName} · ${decision.outcome.label}',
                  ),
                ),
              )
              .toList(),
      onChanged: decisions.isEmpty ? null : onDecisionChanged,
      validator:
          (value) => validateIncomingTalentPromotionImplementationRequired(
            value,
            'a promotion decision',
          ),
    );
  }
}

/// Action and status controls for promotion implementation tracking.
class IncomingTalentPromotionImplementationClassificationFields
    extends StatelessWidget {
  final IncomingTalentPromotionImplementationDraft draft;
  final ValueChanged<IncomingTalentPromotionImplementationAction>
  onActionChanged;
  final ValueChanged<IncomingTalentPromotionImplementationStatus>
  onStatusChanged;

  const IncomingTalentPromotionImplementationClassificationFields({
    super.key,
    required this.draft,
    required this.onActionChanged,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return IncomingTalentDevelopmentProgramResponsiveRow(
      children: [
        DropdownButtonFormField<IncomingTalentPromotionImplementationAction>(
          initialValue: draft.action,
          decoration: const InputDecoration(
            labelText: 'Action',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.task_alt_outlined),
          ),
          items:
              IncomingTalentPromotionImplementationAction.values
                  .map(
                    (action) => DropdownMenuItem(
                      value: action,
                      child: Text(action.label),
                    ),
                  )
                  .toList(),
          onChanged: (value) {
            if (value != null) onActionChanged(value);
          },
          validator: validateIncomingTalentPromotionImplementationAction,
        ),
        DropdownButtonFormField<IncomingTalentPromotionImplementationStatus>(
          initialValue: draft.status,
          decoration: const InputDecoration(
            labelText: 'Status',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.flag_outlined),
          ),
          items:
              IncomingTalentPromotionImplementationStatus.values
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
          validator: validateIncomingTalentPromotionImplementationStatus,
        ),
      ],
    );
  }
}

/// Due-date and completion-date controls for implementation follow-through.
class IncomingTalentPromotionImplementationDateFields extends StatelessWidget {
  final IncomingTalentPromotionImplementationDraft draft;
  final VoidCallback onSelectDueDate;
  final VoidCallback onSelectCompletedDate;

  const IncomingTalentPromotionImplementationDateFields({
    super.key,
    required this.draft,
    required this.onSelectDueDate,
    required this.onSelectCompletedDate,
  });

  @override
  Widget build(BuildContext context) {
    return IncomingTalentDevelopmentProgramResponsiveRow(
      children: [
        IncomingTalentDevelopmentProgramDateButton(
          label: 'Due',
          date: draft.dueDate,
          onTap: onSelectDueDate,
          error: validateIncomingTalentPromotionImplementationDueDate(
            draft.dueDate,
            draft.asOfDate,
          ),
        ),
        IncomingTalentDevelopmentProgramDateButton(
          label: 'Completed',
          date: draft.completedDate,
          onTap: onSelectCompletedDate,
          error: validateIncomingTalentPromotionImplementationCompletedDate(
            status: draft.status,
            completedDate: draft.completedDate,
            asOfDate: draft.asOfDate,
          ),
        ),
      ],
    );
  }
}

/// Submit controls and completeness signal for implementation work.
class IncomingTalentPromotionImplementationFormActions extends StatelessWidget {
  final double completionRatio;
  final bool canSubmit;
  final VoidCallback onClear;
  final VoidCallback onSubmit;

  const IncomingTalentPromotionImplementationFormActions({
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
          label: canSubmit ? 'Implementation ready' : 'Implementation draft',
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(onPressed: onClear, child: const Text('Clear')),
            const SizedBox(width: 10),
            FilledButton.icon(
              key: const Key('incoming-talent-promotion-implementation-submit'),
              onPressed: canSubmit ? onSubmit : null,
              icon: const Icon(Icons.task_alt_outlined),
              label: const Text('Save implementation'),
            ),
          ],
        ),
      ],
    );
  }
}

@Preview(name: 'Talent promotion implementation picker')
Widget incomingTalentPromotionImplementationDecisionPickerPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: IncomingTalentPromotionImplementationDecisionPicker(
          decisions: [_previewDecision],
          selectedDecisionId: _previewDecision.id,
          onDecisionChanged: (_) {},
        ),
      ),
    ),
  );
}

@Preview(name: 'Talent promotion implementation classification')
Widget incomingTalentPromotionImplementationClassificationFieldsPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: IncomingTalentPromotionImplementationClassificationFields(
          draft: _previewDraft,
          onActionChanged: (_) {},
          onStatusChanged: (_) {},
        ),
      ),
    ),
  );
}

@Preview(name: 'Talent promotion implementation dates')
Widget incomingTalentPromotionImplementationDateFieldsPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: IncomingTalentPromotionImplementationDateFields(
          draft: _previewDraft,
          onSelectDueDate: () {},
          onSelectCompletedDate: () {},
        ),
      ),
    ),
  );
}

@Preview(name: 'Talent promotion implementation actions')
Widget incomingTalentPromotionImplementationFormActionsPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: IncomingTalentPromotionImplementationFormActions(
          completionRatio: 0.9,
          canSubmit: true,
          onClear: () {},
          onSubmit: () {},
        ),
      ),
    ),
  );
}

final _previewDecision = IncomingTalentPromotionDecision(
  id: 'promotion-decision-preview',
  readinessId: 'promotion-readiness-preview',
  careerPathId: 'career-path-preview',
  frameworkLevelId: 'framework-preview',
  candidateId: 'candidate-preview',
  candidateName: 'Nadia Putri',
  department: 'Engineering',
  currentRole: 'Backend Engineer',
  newRole: 'Lead Backend Engineer',
  frameworkLevelCode: 'L5',
  ownerName: 'Engineering HRBP',
  approverName: 'Engineering people panel',
  outcome: IncomingTalentPromotionDecisionOutcome.promoteNow,
  status: IncomingTalentPromotionDecisionStatus.approved,
  compensationBandNote: 'Route L5 title and compensation band for approval.',
  implementationNote: 'Prepare promotion letter and HRIS title update.',
  riskControlNote: 'Confirm manager transition and backfill risk.',
  effectiveDate: DateTime(2026, 7, 9),
  followUpDate: DateTime(2026, 8, 8),
  sourceRating: IncomingTalentPromotionReadinessRating.readyNow,
  sourceReadinessStatus: IncomingTalentPromotionReadinessStatus.endorsed,
  createdAt: DateTime(2026, 6, 9),
);

final _previewDraft = IncomingTalentPromotionImplementationDraft.fromDecision(
  decision: _previewDecision,
  asOfDate: DateTime(2026, 6, 9),
);
