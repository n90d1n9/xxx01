import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_growth_alignment_models.dart';
import '../states/incoming_talent_growth_alignment_provider.dart';
import 'incoming_talent_growth_alignment_tile.dart';

/// Dashboard panel that connects IDP portfolios with training and career paths.
class IncomingTalentGrowthAlignmentPanel extends ConsumerWidget {
  const IncomingTalentGrowthAlignmentPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(incomingTalentGrowthAlignmentItemsProvider);
    final summary = ref.watch(incomingTalentGrowthAlignmentSummaryProvider);

    return HrisSectionPanel(
      icon: Icons.route_outlined,
      title: 'Training and career alignment',
      subtitle: summary.nextAction,
      emptyMessage: 'No growth alignment data',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Aligned',
              value: '${summary.alignedCount}',
            ),
            HrisMetricStripItem(
              label: 'Training',
              value: '${summary.trainingGapCount}',
            ),
            HrisMetricStripItem(
              label: 'Career',
              value: '${summary.careerGapCount}',
            ),
            HrisMetricStripItem(
              label: 'Evidence',
              value: '${summary.evidenceGapCount}',
            ),
          ],
        ),
        HrisProgressBar(
          value: summary.alignmentRatio,
          color: HrisColors.primary,
          label:
              '${(summary.alignmentRatio * 100).round()}% training and career coverage',
        ),
        if (items.isEmpty)
          const HrisListSurface(
            child: Text('No IDP portfolios ready for growth alignment yet.'),
          )
        else ...[
          for (final item in items.take(5))
            IncomingTalentGrowthAlignmentTile(item: item),
          if (items.length > 5)
            HrisListSurface(
              child: Text(
                '${items.length - 5} more growth alignments included in this view.',
              ),
            ),
        ],
      ],
    );
  }
}

@Preview(name: 'Talent growth alignment panel')
Widget incomingTalentGrowthAlignmentPanelPreview() {
  final items = [_previewPanelAlignmentItem];

  return ProviderScope(
    overrides: [
      incomingTalentGrowthAlignmentItemsProvider.overrideWithValue(items),
      incomingTalentGrowthAlignmentSummaryProvider.overrideWithValue(
        IncomingTalentGrowthAlignmentSummary.fromItems(items),
      ),
    ],
    child: const MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: IncomingTalentGrowthAlignmentPanel(),
        ),
      ),
    ),
  );
}

final _previewPanelAlignmentItem = IncomingTalentGrowthAlignmentItem(
  id: 'growth-alignment-preview',
  portfolioId: 'idp-preview',
  candidateName: 'Mira Lestari',
  department: 'Finance',
  currentRole: 'Finance Operations Analyst',
  targetRole: 'Finance Operations Lead',
  ownerName: 'Finance HRBP',
  mentorName: 'Dimas Wardhana',
  competencyFocus: 'Month-end close leadership',
  trainingTitle: 'Finance recovery academy',
  trainingStatusLabel: 'Active',
  careerStatusLabel: 'Missing',
  evidencePlan: 'Collect close checklist and stakeholder feedback.',
  nextAction: 'Create a career path from Mira Lestari\'s IDP evidence.',
  status: IncomingTalentGrowthAlignmentStatus.needsCareerPath,
  focus: IncomingTalentGrowthAlignmentFocus.careerPath,
  nextReviewDate: DateTime(2026, 6, 21),
  sourceReadinessScore: 64,
  trainingProgressScore: 72,
  levelGap: 0,
  hasTrainingEnrollment: true,
  hasCareerPath: false,
  sourceCount: 3,
);
