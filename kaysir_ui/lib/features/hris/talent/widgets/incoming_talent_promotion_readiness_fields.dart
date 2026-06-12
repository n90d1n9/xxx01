import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_promotion_readiness_models.dart';
import 'incoming_talent_development_program_form_widgets.dart';

/// Source picker for career paths that already have framework coverage.
class IncomingTalentPromotionReadinessSourcePicker extends StatelessWidget {
  final List<IncomingTalentPromotionReadinessSource> sources;
  final String? selectedSourceId;
  final ValueChanged<String?> onSourceChanged;

  const IncomingTalentPromotionReadinessSourcePicker({
    super.key,
    required this.sources,
    required this.selectedSourceId,
    required this.onSourceChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: selectedSourceId,
      decoration: const InputDecoration(
        labelText: 'Career path + framework',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.workspace_premium_outlined),
      ),
      items:
          sources
              .map(
                (source) => DropdownMenuItem(
                  value: source.id,
                  child: Text(source.label),
                ),
              )
              .toList(),
      onChanged: sources.isEmpty ? null : onSourceChanged,
      validator:
          (value) => validateIncomingTalentPromotionReadinessRequired(
            value,
            'a career path with framework coverage',
          ),
    );
  }
}

/// Rating and status controls for promotion-readiness assessment.
class IncomingTalentPromotionReadinessClassificationFields
    extends StatelessWidget {
  final IncomingTalentPromotionReadinessDraft draft;
  final ValueChanged<IncomingTalentPromotionReadinessRating> onRatingChanged;
  final ValueChanged<IncomingTalentPromotionReadinessStatus> onStatusChanged;

  const IncomingTalentPromotionReadinessClassificationFields({
    super.key,
    required this.draft,
    required this.onRatingChanged,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return IncomingTalentDevelopmentProgramResponsiveRow(
      children: [
        DropdownButtonFormField<IncomingTalentPromotionReadinessRating>(
          initialValue: draft.rating,
          decoration: const InputDecoration(
            labelText: 'Readiness',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.trending_up_outlined),
          ),
          items:
              IncomingTalentPromotionReadinessRating.values
                  .map(
                    (rating) => DropdownMenuItem(
                      value: rating,
                      child: Text(rating.label),
                    ),
                  )
                  .toList(),
          onChanged: (value) {
            if (value != null) onRatingChanged(value);
          },
          validator: validateIncomingTalentPromotionReadinessRating,
        ),
        DropdownButtonFormField<IncomingTalentPromotionReadinessStatus>(
          initialValue: draft.status,
          decoration: const InputDecoration(
            labelText: 'Panel status',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.flag_outlined),
          ),
          items:
              IncomingTalentPromotionReadinessStatus.values
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
          validator: validateIncomingTalentPromotionReadinessStatus,
        ),
      ],
    );
  }
}

/// Date controls for promotion panel review and follow-up.
class IncomingTalentPromotionReadinessDateFields extends StatelessWidget {
  final IncomingTalentPromotionReadinessDraft draft;
  final VoidCallback onSelectReviewDate;
  final VoidCallback onSelectNextReviewDate;

  const IncomingTalentPromotionReadinessDateFields({
    super.key,
    required this.draft,
    required this.onSelectReviewDate,
    required this.onSelectNextReviewDate,
  });

  @override
  Widget build(BuildContext context) {
    return IncomingTalentDevelopmentProgramResponsiveRow(
      children: [
        IncomingTalentDevelopmentProgramDateButton(
          label: 'Review',
          date: draft.reviewDate,
          onTap: onSelectReviewDate,
          error: validateIncomingTalentPromotionReadinessDate(
            draft.reviewDate,
            draft.asOfDate,
          ),
        ),
        IncomingTalentDevelopmentProgramDateButton(
          label: 'Next review',
          date: draft.nextReviewDate,
          onTap: onSelectNextReviewDate,
          error: validateIncomingTalentPromotionReadinessNextReviewDate(
            reviewDate: draft.reviewDate,
            nextReviewDate: draft.nextReviewDate,
          ),
        ),
      ],
    );
  }
}

/// Submit controls and completeness signal for promotion readiness.
class IncomingTalentPromotionReadinessFormActions extends StatelessWidget {
  final double completionRatio;
  final bool canSubmit;
  final VoidCallback onClear;
  final VoidCallback onSubmit;

  const IncomingTalentPromotionReadinessFormActions({
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
          label: canSubmit ? 'Packet ready' : 'Packet draft',
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(onPressed: onClear, child: const Text('Clear')),
            const SizedBox(width: 10),
            FilledButton.icon(
              key: const Key('incoming-talent-promotion-readiness-submit'),
              onPressed: canSubmit ? onSubmit : null,
              icon: const Icon(Icons.workspace_premium_outlined),
              label: const Text('Save packet'),
            ),
          ],
        ),
      ],
    );
  }
}

@Preview(name: 'Talent promotion readiness classification')
Widget incomingTalentPromotionReadinessClassificationFieldsPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: IncomingTalentPromotionReadinessClassificationFields(
          draft: _previewDraft,
          onRatingChanged: (_) {},
          onStatusChanged: (_) {},
        ),
      ),
    ),
  );
}

@Preview(name: 'Talent promotion readiness dates')
Widget incomingTalentPromotionReadinessDateFieldsPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: IncomingTalentPromotionReadinessDateFields(
          draft: _previewDraft,
          onSelectReviewDate: () {},
          onSelectNextReviewDate: () {},
        ),
      ),
    ),
  );
}

@Preview(name: 'Talent promotion readiness actions')
Widget incomingTalentPromotionReadinessFormActionsPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: IncomingTalentPromotionReadinessFormActions(
          completionRatio: 0.9,
          canSubmit: true,
          onClear: () {},
          onSubmit: () {},
        ),
      ),
    ),
  );
}

final _previewDraft = IncomingTalentPromotionReadinessDraft(
  careerPathId: 'career-path-preview',
  frameworkLevelId: 'framework-preview',
  candidateId: 'candidate-preview',
  candidateName: 'Nadia Putri',
  department: 'Engineering',
  currentRole: 'Backend Engineer',
  targetRole: 'Lead Backend Engineer',
  frameworkFamilyName: 'Backend Engineer family',
  frameworkLevelCode: 'L5',
  frameworkScope: null,
  frameworkReviewCadence: null,
  assessorName: 'Engineering HRBP',
  rating: IncomingTalentPromotionReadinessRating.readySoon,
  status: IncomingTalentPromotionReadinessStatus.calibration,
  competencyName: 'Technical leadership',
  evidenceSummary: 'Architecture evidence is ready for calibration.',
  gapSummary: 'One more stakeholder review is required before endorsement.',
  panelRecommendation: 'Schedule calibration after final evidence checkpoint.',
  reviewDate: DateTime(2026, 6, 9),
  nextReviewDate: DateTime(2026, 7, 24),
  sourceCareerPathStatus: null,
  sourceCareerPathPriority: null,
  asOfDate: DateTime(2026, 6, 9),
);
