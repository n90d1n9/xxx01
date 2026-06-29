import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_career_framework_level_models.dart';
import '../models/incoming_talent_career_path_models.dart';
import '../models/incoming_talent_promotion_decision_models.dart';
import '../models/incoming_talent_promotion_readiness_models.dart';
import 'incoming_talent_development_program_form_widgets.dart';

/// Picker for readiness packets that can receive final promotion decisions.
class IncomingTalentPromotionDecisionReadinessPicker extends StatelessWidget {
  final List<IncomingTalentPromotionReadiness> packets;
  final String? selectedReadinessId;
  final ValueChanged<String?> onReadinessChanged;

  const IncomingTalentPromotionDecisionReadinessPicker({
    super.key,
    required this.packets,
    required this.selectedReadinessId,
    required this.onReadinessChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: selectedReadinessId,
      decoration: const InputDecoration(
        labelText: 'Promotion readiness packet',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.workspace_premium_outlined),
      ),
      items:
          packets
              .map(
                (packet) => DropdownMenuItem(
                  value: packet.id,
                  child: Text(
                    '${packet.candidateName} · ${packet.rating.label}',
                  ),
                ),
              )
              .toList(),
      onChanged: packets.isEmpty ? null : onReadinessChanged,
      validator:
          (value) => validateIncomingTalentPromotionDecisionRequired(
            value,
            'a promotion readiness packet',
          ),
    );
  }
}

/// Outcome and operational status fields for promotion decisions.
class IncomingTalentPromotionDecisionClassificationFields
    extends StatelessWidget {
  final IncomingTalentPromotionDecisionDraft draft;
  final ValueChanged<IncomingTalentPromotionDecisionOutcome> onOutcomeChanged;
  final ValueChanged<IncomingTalentPromotionDecisionStatus> onStatusChanged;

  const IncomingTalentPromotionDecisionClassificationFields({
    super.key,
    required this.draft,
    required this.onOutcomeChanged,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return IncomingTalentDevelopmentProgramResponsiveRow(
      children: [
        DropdownButtonFormField<IncomingTalentPromotionDecisionOutcome>(
          initialValue: draft.outcome,
          decoration: const InputDecoration(
            labelText: 'Outcome',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.how_to_reg_outlined),
          ),
          items:
              IncomingTalentPromotionDecisionOutcome.values
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
          validator: validateIncomingTalentPromotionDecisionOutcome,
        ),
        DropdownButtonFormField<IncomingTalentPromotionDecisionStatus>(
          initialValue: draft.status,
          decoration: const InputDecoration(
            labelText: 'Status',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.flag_outlined),
          ),
          items:
              IncomingTalentPromotionDecisionStatus.values
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
          validator: validateIncomingTalentPromotionDecisionStatus,
        ),
      ],
    );
  }
}

/// Date controls for decision effective date and implementation follow-up.
class IncomingTalentPromotionDecisionDateFields extends StatelessWidget {
  final IncomingTalentPromotionDecisionDraft draft;
  final VoidCallback onSelectEffectiveDate;
  final VoidCallback onSelectFollowUpDate;

  const IncomingTalentPromotionDecisionDateFields({
    super.key,
    required this.draft,
    required this.onSelectEffectiveDate,
    required this.onSelectFollowUpDate,
  });

  @override
  Widget build(BuildContext context) {
    return IncomingTalentDevelopmentProgramResponsiveRow(
      children: [
        IncomingTalentDevelopmentProgramDateButton(
          label: 'Effective',
          date: draft.effectiveDate,
          onTap: onSelectEffectiveDate,
          error: validateIncomingTalentPromotionDecisionEffectiveDate(
            draft.effectiveDate,
            draft.asOfDate,
          ),
        ),
        IncomingTalentDevelopmentProgramDateButton(
          label: 'Follow-up',
          date: draft.followUpDate,
          onTap: onSelectFollowUpDate,
          error: validateIncomingTalentPromotionDecisionFollowUpDate(
            effectiveDate: draft.effectiveDate,
            followUpDate: draft.followUpDate,
          ),
        ),
      ],
    );
  }
}

/// Submit controls and completeness signal for promotion decisions.
class IncomingTalentPromotionDecisionFormActions extends StatelessWidget {
  final double completionRatio;
  final bool canSubmit;
  final VoidCallback onClear;
  final VoidCallback onSubmit;

  const IncomingTalentPromotionDecisionFormActions({
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
          label: canSubmit ? 'Decision ready' : 'Decision draft',
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(onPressed: onClear, child: const Text('Clear')),
            const SizedBox(width: 10),
            FilledButton.icon(
              key: const Key('incoming-talent-promotion-decision-submit'),
              onPressed: canSubmit ? onSubmit : null,
              icon: const Icon(Icons.how_to_reg_outlined),
              label: const Text('Save decision'),
            ),
          ],
        ),
      ],
    );
  }
}

@Preview(name: 'Talent promotion decision picker')
Widget incomingTalentPromotionDecisionReadinessPickerPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: IncomingTalentPromotionDecisionReadinessPicker(
          packets: [_previewReadiness],
          selectedReadinessId: _previewReadiness.id,
          onReadinessChanged: (_) {},
        ),
      ),
    ),
  );
}

@Preview(name: 'Talent promotion decision classification')
Widget incomingTalentPromotionDecisionClassificationFieldsPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: IncomingTalentPromotionDecisionClassificationFields(
          draft: _previewDraft,
          onOutcomeChanged: (_) {},
          onStatusChanged: (_) {},
        ),
      ),
    ),
  );
}

@Preview(name: 'Talent promotion decision dates')
Widget incomingTalentPromotionDecisionDateFieldsPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: IncomingTalentPromotionDecisionDateFields(
          draft: _previewDraft,
          onSelectEffectiveDate: () {},
          onSelectFollowUpDate: () {},
        ),
      ),
    ),
  );
}

@Preview(name: 'Talent promotion decision actions')
Widget incomingTalentPromotionDecisionFormActionsPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: IncomingTalentPromotionDecisionFormActions(
          completionRatio: 0.95,
          canSubmit: true,
          onClear: () {},
          onSubmit: () {},
        ),
      ),
    ),
  );
}

final _previewReadiness = IncomingTalentPromotionReadiness(
  id: 'promotion-readiness-preview',
  careerPathId: 'career-path-preview',
  frameworkLevelId: 'framework-preview',
  candidateId: 'candidate-preview',
  candidateName: 'Nadia Putri',
  department: 'Engineering',
  currentRole: 'Backend Engineer',
  targetRole: 'Lead Backend Engineer',
  frameworkFamilyName: 'Backend Engineer family',
  frameworkLevelCode: 'L5',
  frameworkScope: IncomingTalentCareerFrameworkLevelScope.peopleLeadership,
  frameworkReviewCadence: IncomingTalentCareerFrameworkReviewCadence.quarterly,
  assessorName: 'Engineering HRBP',
  rating: IncomingTalentPromotionReadinessRating.readyNow,
  status: IncomingTalentPromotionReadinessStatus.endorsed,
  competencyName: 'Technical leadership',
  evidenceSummary: 'Architecture evidence is ready for promotion.',
  gapSummary: 'No critical promotion gaps remain open.',
  panelRecommendation: 'Endorse for promotion calibration.',
  reviewDate: DateTime(2026, 6, 9),
  nextReviewDate: DateTime(2026, 9, 7),
  sourceCareerPathStatus: IncomingTalentCareerPathStatus.active,
  sourceCareerPathPriority: IncomingTalentCareerPathPriority.accelerated,
  createdAt: DateTime(2026, 6, 9),
);

final _previewDraft = IncomingTalentPromotionDecisionDraft.fromReadiness(
  readiness: _previewReadiness,
  asOfDate: DateTime(2026, 6, 9),
);
