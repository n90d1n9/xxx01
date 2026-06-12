import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_promotion_decision_models.dart';
import '../models/incoming_talent_promotion_implementation_models.dart';
import '../models/incoming_talent_promotion_readiness_models.dart';
import '../models/incoming_talent_promotion_stabilization_review_models.dart';
import 'incoming_talent_development_program_form_widgets.dart';

/// Picker for completed promotion implementations ready for stabilization review.
class IncomingTalentPromotionStabilizationImplementationPicker
    extends StatelessWidget {
  final List<IncomingTalentPromotionImplementation> implementations;
  final String? selectedImplementationId;
  final ValueChanged<String?> onImplementationChanged;

  const IncomingTalentPromotionStabilizationImplementationPicker({
    super.key,
    required this.implementations,
    required this.selectedImplementationId,
    required this.onImplementationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: selectedImplementationId,
      decoration: const InputDecoration(
        labelText: 'Completed implementation',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.task_alt_outlined),
      ),
      items:
          implementations
              .map(
                (implementation) => DropdownMenuItem(
                  value: implementation.id,
                  child: Text(
                    '${implementation.candidateName} - ${implementation.action.label}',
                  ),
                ),
              )
              .toList(),
      onChanged: implementations.isEmpty ? null : onImplementationChanged,
      validator:
          (value) => validateIncomingTalentPromotionStabilizationRequired(
            value,
            'a promotion implementation',
          ),
    );
  }
}

/// Outcome and status controls for promotion stabilization review.
class IncomingTalentPromotionStabilizationClassificationFields
    extends StatelessWidget {
  final IncomingTalentPromotionStabilizationReviewDraft draft;
  final ValueChanged<IncomingTalentPromotionStabilizationOutcome>
  onOutcomeChanged;
  final ValueChanged<IncomingTalentPromotionStabilizationStatus>
  onStatusChanged;

  const IncomingTalentPromotionStabilizationClassificationFields({
    super.key,
    required this.draft,
    required this.onOutcomeChanged,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return IncomingTalentDevelopmentProgramResponsiveRow(
      children: [
        DropdownButtonFormField<IncomingTalentPromotionStabilizationOutcome>(
          initialValue: draft.outcome,
          decoration: const InputDecoration(
            labelText: 'Outcome',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.insights_outlined),
          ),
          items:
              IncomingTalentPromotionStabilizationOutcome.values
                  .map(
                    (outcome) => DropdownMenuItem(
                      value: outcome,
                      child: Text(outcome.label),
                    ),
                  )
                  .toList(),
          onChanged: (value) {
            if (value != null) onOutcomeChanged(value);
          },
          validator: validateIncomingTalentPromotionStabilizationOutcome,
        ),
        DropdownButtonFormField<IncomingTalentPromotionStabilizationStatus>(
          initialValue: draft.status,
          decoration: const InputDecoration(
            labelText: 'Status',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.flag_outlined),
          ),
          items:
              IncomingTalentPromotionStabilizationStatus.values
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
          validator: validateIncomingTalentPromotionStabilizationStatus,
        ),
      ],
    );
  }
}

/// Review-date, follow-up-date, and confidence controls.
class IncomingTalentPromotionStabilizationSignalFields extends StatelessWidget {
  final IncomingTalentPromotionStabilizationReviewDraft draft;
  final VoidCallback onSelectReviewDate;
  final VoidCallback onSelectFollowUpDate;
  final ValueChanged<int> onConfidenceChanged;
  final TextEditingController confidenceController;

  const IncomingTalentPromotionStabilizationSignalFields({
    super.key,
    required this.draft,
    required this.onSelectReviewDate,
    required this.onSelectFollowUpDate,
    required this.onConfidenceChanged,
    required this.confidenceController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IncomingTalentDevelopmentProgramResponsiveRow(
          children: [
            IncomingTalentDevelopmentProgramDateButton(
              label: 'Review',
              date: draft.reviewDate,
              onTap: onSelectReviewDate,
              error: validateIncomingTalentPromotionStabilizationReviewDate(
                draft.reviewDate,
              ),
            ),
            IncomingTalentDevelopmentProgramDateButton(
              label: 'Follow-up',
              date: draft.followUpDate,
              onTap: onSelectFollowUpDate,
              error: validateIncomingTalentPromotionStabilizationFollowUpDate(
                status: draft.status,
                reviewDate: draft.reviewDate,
                followUpDate: draft.followUpDate,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        IncomingTalentDevelopmentProgramNumberInput(
          controller: confidenceController,
          label: 'Confidence score (1-5)',
          icon: Icons.speed_outlined,
          onChanged: onConfidenceChanged,
          validator: validateIncomingTalentPromotionStabilizationConfidence,
        ),
      ],
    );
  }
}

/// Submit controls and completeness signal for stabilization reviews.
class IncomingTalentPromotionStabilizationFormActions extends StatelessWidget {
  final double completionRatio;
  final bool canSubmit;
  final VoidCallback onClear;
  final VoidCallback onSubmit;

  const IncomingTalentPromotionStabilizationFormActions({
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
          label: canSubmit ? 'Review ready' : 'Review draft',
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(onPressed: onClear, child: const Text('Clear')),
            const SizedBox(width: 10),
            FilledButton.icon(
              key: const Key(
                'incoming-talent-promotion-stabilization-review-submit',
              ),
              onPressed: canSubmit ? onSubmit : null,
              icon: const Icon(Icons.rate_review_outlined),
              label: const Text('Save review'),
            ),
          ],
        ),
      ],
    );
  }
}

@Preview(name: 'Talent promotion stabilization picker')
Widget incomingTalentPromotionStabilizationImplementationPickerPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: IncomingTalentPromotionStabilizationImplementationPicker(
          implementations: [_previewImplementation],
          selectedImplementationId: _previewImplementation.id,
          onImplementationChanged: (_) {},
        ),
      ),
    ),
  );
}

@Preview(name: 'Talent promotion stabilization classification')
Widget incomingTalentPromotionStabilizationClassificationPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: IncomingTalentPromotionStabilizationClassificationFields(
          draft: _previewDraft,
          onOutcomeChanged: (_) {},
          onStatusChanged: (_) {},
        ),
      ),
    ),
  );
}

@Preview(name: 'Talent promotion stabilization signals')
Widget incomingTalentPromotionStabilizationSignalFieldsPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: IncomingTalentPromotionStabilizationSignalFields(
          draft: _previewDraft,
          confidenceController: TextEditingController(text: '4'),
          onSelectReviewDate: () {},
          onSelectFollowUpDate: () {},
          onConfidenceChanged: (_) {},
        ),
      ),
    ),
  );
}

@Preview(name: 'Talent promotion stabilization actions')
Widget incomingTalentPromotionStabilizationFormActionsPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: IncomingTalentPromotionStabilizationFormActions(
          completionRatio: 0.9,
          canSubmit: true,
          onClear: () {},
          onSubmit: () {},
        ),
      ),
    ),
  );
}

final _previewImplementation = IncomingTalentPromotionImplementation(
  id: 'promotion-implementation-preview',
  decisionId: 'promotion-decision-preview',
  readinessId: 'promotion-readiness-preview',
  candidateId: 'candidate-preview',
  candidateName: 'Nadia Putri',
  department: 'Engineering',
  currentRole: 'Backend Engineer',
  newRole: 'Lead Backend Engineer',
  frameworkLevelCode: 'L5',
  ownerName: 'Engineering HRBP',
  approverName: 'Engineering people panel',
  action: IncomingTalentPromotionImplementationAction.titleUpdate,
  status: IncomingTalentPromotionImplementationStatus.completed,
  systemOfRecord: 'HRIS employee profile',
  implementationStep: 'Prepare promotion letter and HRIS title update.',
  evidenceNote: 'Signed letter and HRIS update confirmation captured.',
  blockerNote: 'No open blockers after manager transition.',
  dueDate: DateTime(2026, 7, 9),
  completedDate: DateTime(2026, 7, 7),
  sourceOutcome: IncomingTalentPromotionDecisionOutcome.promoteNow,
  sourceDecisionStatus: IncomingTalentPromotionDecisionStatus.approved,
  sourceReadinessRating: IncomingTalentPromotionReadinessRating.readyNow,
  createdAt: DateTime(2026, 6, 9),
);

final _previewDraft =
    IncomingTalentPromotionStabilizationReviewDraft.fromImplementation(
      implementation: _previewImplementation,
      asOfDate: DateTime(2026, 7, 9),
    );
