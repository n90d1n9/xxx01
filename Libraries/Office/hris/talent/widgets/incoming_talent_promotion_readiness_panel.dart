import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_career_framework_level_models.dart';
import '../models/incoming_talent_career_path_models.dart';
import '../models/incoming_talent_promotion_readiness_models.dart';
import '../states/incoming_talent_promotion_readiness_provider.dart';
import 'incoming_talent_promotion_readiness_form.dart';
import 'incoming_talent_promotion_readiness_tile.dart';

/// Panel for promotion readiness packets and calibration outcomes.
class IncomingTalentPromotionReadinessPanel extends ConsumerWidget {
  const IncomingTalentPromotionReadinessPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packets = ref.watch(filteredIncomingTalentPromotionReadinessProvider);
    final summary = ref.watch(incomingTalentPromotionReadinessSummaryProvider);

    return HrisSectionPanel(
      icon: Icons.workspace_premium_outlined,
      title: 'Promotion readiness',
      subtitle: summary.nextAction,
      emptyMessage: 'No promotion readiness data',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Ready',
              value: '${summary.readyNowCount}',
            ),
            HrisMetricStripItem(
              label: 'Soon',
              value: '${summary.readySoonCount}',
            ),
            HrisMetricStripItem(
              label: 'Blocked',
              value: '${summary.blockedCount}',
            ),
            HrisMetricStripItem(
              label: 'Attention',
              value: '${summary.attentionCount}',
            ),
          ],
        ),
        HrisProgressBar(
          value: summary.averageReadinessScore,
          color: HrisColors.primary,
          label:
              '${(summary.averageReadinessScore * 100).round()}% average readiness',
        ),
        const IncomingTalentPromotionReadinessForm(),
        if (packets.isEmpty)
          const HrisListSurface(
            child: Text('No promotion readiness packets saved yet.'),
          )
        else
          for (final packet in packets)
            IncomingTalentPromotionReadinessTile(packet: packet),
      ],
    );
  }
}

@Preview(name: 'Talent promotion readiness panel')
Widget incomingTalentPromotionReadinessPanelPreview() {
  final packets = [_previewPanelPacket];

  return ProviderScope(
    overrides: [
      filteredIncomingTalentPromotionReadinessProvider.overrideWithValue(
        packets,
      ),
      incomingTalentPromotionReadinessSummaryProvider.overrideWithValue(
        IncomingTalentPromotionReadinessSummary.fromReadinessPackets(packets),
      ),
    ],
    child: const MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: IncomingTalentPromotionReadinessPanel(),
        ),
      ),
    ),
  );
}

final _previewPanelPacket = IncomingTalentPromotionReadiness(
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
  rating: IncomingTalentPromotionReadinessRating.readySoon,
  status: IncomingTalentPromotionReadinessStatus.calibration,
  competencyName: 'Technical leadership',
  evidenceSummary: 'Architecture evidence is ready for calibration.',
  gapSummary: 'One more stakeholder review is required before endorsement.',
  panelRecommendation: 'Schedule calibration after final evidence checkpoint.',
  reviewDate: DateTime(2026, 6, 9),
  nextReviewDate: DateTime(2026, 7, 24),
  sourceCareerPathStatus: IncomingTalentCareerPathStatus.active,
  sourceCareerPathPriority: IncomingTalentCareerPathPriority.accelerated,
  createdAt: DateTime(2026, 6, 9),
);
