import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/candidate_decision_models.dart';
import '../models/candidate_development_calibration_models.dart';
import '../models/candidate_talent_handoff_models.dart';
import '../states/candidate_development_calibration_provider.dart';
import '../states/candidate_talent_handoff_provider.dart';
import 'candidate_talent_handoff_form.dart';
import 'candidate_talent_handoff_summary_tile.dart';
import 'candidate_talent_handoff_tile.dart';

class CandidateTalentHandoffPanel extends ConsumerWidget {
  final String title;
  final String subtitle;
  final List<CandidateDecisionPacket> packets;
  final DateTime asOfDate;

  const CandidateTalentHandoffPanel({
    super.key,
    required this.title,
    required this.subtitle,
    required this.packets,
    required this.asOfDate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviews = _visibleReviews(
      ref.watch(candidateDevelopmentCalibrationReviewsProvider),
    );
    final handoffs = _visibleHandoffs(
      ref.watch(candidateTalentHandoffsProvider),
    );
    final summary = CandidateTalentHandoffSummary.fromHandoffs(handoffs);

    return HrisSectionPanel(
      icon: Icons.hub_outlined,
      title: title,
      subtitle: subtitle,
      children: [
        CandidateTalentHandoffSummaryTile(summary: summary),
        CandidateTalentHandoffForm(reviews: reviews),
        if (reviews.isEmpty)
          const HrisListSurface(
            child: Text('Submit a calibration review before talent handoff.'),
          )
        else if (handoffs.isEmpty)
          const HrisListSurface(
            child: Text('No candidate talent handoffs submitted yet.'),
          )
        else
          for (final handoff in handoffs)
            CandidateTalentHandoffTile(handoff: handoff, asOfDate: asOfDate),
      ],
    );
  }

  List<CandidateDevelopmentCalibrationReview> _visibleReviews(
    List<CandidateDevelopmentCalibrationReview> reviews,
  ) {
    final candidateIds = packets.map((item) => item.candidateId).toSet();
    return reviews
        .where((item) => candidateIds.contains(item.candidateId))
        .toList();
  }

  List<CandidateTalentHandoff> _visibleHandoffs(
    List<CandidateTalentHandoff> handoffs,
  ) {
    final candidateIds = packets.map((item) => item.candidateId).toSet();
    return handoffs
        .where((item) => candidateIds.contains(item.candidateId))
        .toList();
  }
}
