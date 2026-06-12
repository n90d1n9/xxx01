import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_career_framework_level_models.dart';
import '../models/incoming_talent_career_path_models.dart';
import '../models/incoming_talent_development_portfolio_models.dart';
import 'incoming_talent_development_program_form_widgets.dart';

/// Career path picker used to seed framework levels from active paths.
class IncomingTalentCareerFrameworkLevelCareerPathPicker
    extends StatelessWidget {
  final List<IncomingTalentCareerPath> careerPaths;
  final String? selectedCareerPathId;
  final ValueChanged<String?> onCareerPathChanged;

  const IncomingTalentCareerFrameworkLevelCareerPathPicker({
    super.key,
    required this.careerPaths,
    required this.selectedCareerPathId,
    required this.onCareerPathChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: selectedCareerPathId,
      decoration: const InputDecoration(
        labelText: 'Career path source',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.account_tree_outlined),
      ),
      items:
          careerPaths
              .map(
                (careerPath) => DropdownMenuItem(
                  value: careerPath.id,
                  child: Text(careerPath.targetRole),
                ),
              )
              .toList(),
      onChanged: careerPaths.isEmpty ? null : onCareerPathChanged,
    );
  }
}

/// Dropdown controls for ladder scope, lifecycle status, and review cadence.
class IncomingTalentCareerFrameworkLevelClassificationFields
    extends StatelessWidget {
  final IncomingTalentCareerFrameworkLevelDraft draft;
  final ValueChanged<IncomingTalentCareerFrameworkLevelScope> onScopeChanged;
  final ValueChanged<IncomingTalentCareerFrameworkLevelStatus> onStatusChanged;
  final ValueChanged<IncomingTalentCareerFrameworkReviewCadence>
  onReviewCadenceChanged;

  const IncomingTalentCareerFrameworkLevelClassificationFields({
    super.key,
    required this.draft,
    required this.onScopeChanged,
    required this.onStatusChanged,
    required this.onReviewCadenceChanged,
  });

  @override
  Widget build(BuildContext context) {
    return IncomingTalentDevelopmentProgramResponsiveRow(
      children: [
        DropdownButtonFormField<IncomingTalentCareerFrameworkLevelScope>(
          initialValue: draft.scope,
          decoration: const InputDecoration(
            labelText: 'Scope',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.work_outline),
          ),
          items:
              IncomingTalentCareerFrameworkLevelScope.values
                  .map(
                    (scope) => DropdownMenuItem(
                      value: scope,
                      child: Text(scope.label),
                    ),
                  )
                  .toList(),
          onChanged: (value) {
            if (value != null) onScopeChanged(value);
          },
          validator: validateIncomingTalentCareerFrameworkScope,
        ),
        DropdownButtonFormField<IncomingTalentCareerFrameworkLevelStatus>(
          initialValue: draft.status,
          decoration: const InputDecoration(
            labelText: 'Status',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.flag_outlined),
          ),
          items:
              IncomingTalentCareerFrameworkLevelStatus.values
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
          validator: validateIncomingTalentCareerFrameworkStatus,
        ),
        DropdownButtonFormField<IncomingTalentCareerFrameworkReviewCadence>(
          initialValue: draft.reviewCadence,
          decoration: const InputDecoration(
            labelText: 'Review',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.event_repeat_outlined),
          ),
          items:
              IncomingTalentCareerFrameworkReviewCadence.values
                  .map(
                    (cadence) => DropdownMenuItem(
                      value: cadence,
                      child: Text(cadence.label),
                    ),
                  )
                  .toList(),
          onChanged: (value) {
            if (value != null) onReviewCadenceChanged(value);
          },
          validator: validateIncomingTalentCareerFrameworkReviewCadence,
        ),
      ],
    );
  }
}

/// Submit controls and draft-readiness indicator for framework levels.
class IncomingTalentCareerFrameworkLevelFormActions extends StatelessWidget {
  final double completionRatio;
  final bool canSubmit;
  final VoidCallback onClear;
  final VoidCallback onSubmit;

  const IncomingTalentCareerFrameworkLevelFormActions({
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
          label: canSubmit ? 'Framework ready' : 'Framework draft',
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(onPressed: onClear, child: const Text('Clear')),
            const SizedBox(width: 10),
            FilledButton.icon(
              key: const Key('incoming-talent-career-framework-level-submit'),
              onPressed: canSubmit ? onSubmit : null,
              icon: const Icon(Icons.account_tree_outlined),
              label: const Text('Add level'),
            ),
          ],
        ),
      ],
    );
  }
}

@Preview(name: 'Talent career framework source picker')
Widget incomingTalentCareerFrameworkLevelCareerPathPickerPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: IncomingTalentCareerFrameworkLevelCareerPathPicker(
          careerPaths: [_previewCareerPath],
          selectedCareerPathId: _previewCareerPath.id,
          onCareerPathChanged: (_) {},
        ),
      ),
    ),
  );
}

@Preview(name: 'Talent career framework classification')
Widget incomingTalentCareerFrameworkLevelClassificationFieldsPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: IncomingTalentCareerFrameworkLevelClassificationFields(
          draft: _previewDraft,
          onScopeChanged: (_) {},
          onStatusChanged: (_) {},
          onReviewCadenceChanged: (_) {},
        ),
      ),
    ),
  );
}

@Preview(name: 'Talent career framework actions')
Widget incomingTalentCareerFrameworkLevelFormActionsPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: IncomingTalentCareerFrameworkLevelFormActions(
          completionRatio: 0.92,
          canSubmit: true,
          onClear: () {},
          onSubmit: () {},
        ),
      ),
    ),
  );
}

final _previewCareerPath = IncomingTalentCareerPath(
  id: 'career-path-preview',
  portfolioId: 'portfolio-preview',
  roadmapId: 'roadmap-preview',
  candidateId: 'candidate-preview',
  candidateName: 'Nadia Putri',
  department: 'Engineering',
  currentRole: 'Backend Engineer',
  targetRole: 'Lead Backend Engineer',
  ownerName: 'Engineering HRBP',
  mentorName: 'Ari Wibowo',
  competencyName: 'Technical leadership',
  currentLevel: 3,
  targetLevel: 5,
  status: IncomingTalentCareerPathStatus.active,
  priority: IncomingTalentCareerPathPriority.accelerated,
  developmentAction: 'Lead architecture review and mentor junior engineers.',
  evidenceRequirement:
      'Submit peer feedback and architecture decision records.',
  reviewDate: DateTime(2026, 7, 9),
  sourcePortfolioPriority:
      IncomingTalentDevelopmentPortfolioPriority.accelerated,
  sourcePortfolioStage: IncomingTalentDevelopmentPortfolioStage.active,
  createdAt: DateTime(2026, 6, 9),
);

final _previewDraft = IncomingTalentCareerFrameworkLevelDraft.fromCareerPath(
  careerPath: _previewCareerPath,
  asOfDate: DateTime(2026, 6, 9),
);
