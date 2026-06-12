import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_career_framework_level_models.dart';
import '../states/incoming_talent_career_framework_level_provider.dart';
import 'incoming_talent_career_framework_level_form.dart';
import 'incoming_talent_career_framework_level_tile.dart';

/// Panel for managing career ladders and role-family coverage.
class IncomingTalentCareerFrameworkLevelPanel extends ConsumerWidget {
  const IncomingTalentCareerFrameworkLevelPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final levels = ref.watch(
      filteredIncomingTalentCareerFrameworkLevelsProvider,
    );
    final summary = ref.watch(
      incomingTalentCareerFrameworkLevelSummaryProvider,
    );

    return HrisSectionPanel(
      icon: Icons.schema_outlined,
      title: 'Career frameworks',
      subtitle: summary.nextAction,
      emptyMessage: 'No career framework data',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Families',
              value: '${summary.familyCount}',
            ),
            HrisMetricStripItem(
              label: 'Active',
              value: '${summary.activeCount}',
            ),
            HrisMetricStripItem(
              label: 'Review',
              value: '${summary.reviewCount}',
            ),
            HrisMetricStripItem(
              label: 'Unmapped',
              value: '${summary.unmappedCareerPathCount}',
            ),
          ],
        ),
        HrisProgressBar(
          value: summary.mappingRatio,
          color: HrisColors.primary,
          label: '${(summary.mappingRatio * 100).round()}% career paths mapped',
        ),
        const IncomingTalentCareerFrameworkLevelForm(),
        if (levels.isEmpty)
          const HrisListSurface(
            child: Text('No career framework levels defined yet.'),
          )
        else
          for (final level in levels)
            IncomingTalentCareerFrameworkLevelTile(level: level),
      ],
    );
  }
}

@Preview(name: 'Talent career framework panel')
Widget incomingTalentCareerFrameworkLevelPanelPreview() {
  final levels = [_previewPanelLevel];

  return ProviderScope(
    overrides: [
      filteredIncomingTalentCareerFrameworkLevelsProvider.overrideWithValue(
        levels,
      ),
      incomingTalentCareerFrameworkLevelSummaryProvider.overrideWithValue(
        IncomingTalentCareerFrameworkLevelSummary.fromLevels(
          levels: levels,
          careerPaths: const [],
        ),
      ),
    ],
    child: const MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: IncomingTalentCareerFrameworkLevelPanel(),
        ),
      ),
    ),
  );
}

final _previewPanelLevel = IncomingTalentCareerFrameworkLevel(
  id: 'career-framework-preview',
  sourceCareerPathId: 'career-path-preview',
  department: 'Engineering',
  familyName: 'Backend Engineer family',
  levelCode: 'L5',
  roleTitle: 'Lead Backend Engineer',
  scope: IncomingTalentCareerFrameworkLevelScope.peopleLeadership,
  status: IncomingTalentCareerFrameworkLevelStatus.review,
  ownerName: 'Engineering HRBP',
  competencyName: 'Technical leadership',
  successCriteria:
      'Leads cross-team architecture decisions with clear tradeoffs.',
  evidenceRequirement:
      'Submit architecture decision records and peer feedback.',
  reviewCadence: IncomingTalentCareerFrameworkReviewCadence.quarterly,
  createdAt: DateTime(2026, 6, 9),
);
