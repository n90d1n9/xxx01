import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/candidate_decision_models.dart';
import '../models/candidate_development_calibration_models.dart';
import '../states/candidate_development_calibration_provider.dart';
import 'candidate_development_calibration_form.dart';
import 'candidate_development_calibration_profile_tile.dart';
import 'candidate_development_calibration_review_tile.dart';
import 'candidate_development_calibration_summary_tile.dart';

class CandidateDevelopmentCalibrationPanel extends ConsumerWidget {
  final String title;
  final String subtitle;
  final List<CandidateDecisionPacket> packets;
  final DateTime asOfDate;

  const CandidateDevelopmentCalibrationPanel({
    super.key,
    required this.title,
    required this.subtitle,
    required this.packets,
    required this.asOfDate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profiles = _visibleProfiles(
      ref.watch(candidateDevelopmentCalibrationProfilesProvider),
    );
    final reviews = _visibleReviews(
      ref.watch(candidateDevelopmentCalibrationReviewsProvider),
      profiles,
    );
    final summary = CandidateDevelopmentCalibrationSummary.fromProfiles(
      profiles,
    );

    return HrisSectionPanel(
      icon: Icons.fact_check_outlined,
      title: title,
      subtitle: subtitle,
      children: [
        CandidateDevelopmentCalibrationSummaryTile(summary: summary),
        CandidateDevelopmentCalibrationForm(profiles: profiles),
        if (profiles.isEmpty)
          const HrisListSurface(
            child: Text(
              'Submit development objectives and check-ins before calibration.',
            ),
          )
        else
          for (final profile in profiles)
            CandidateDevelopmentCalibrationProfileTile(
              profile: profile,
              asOfDate: asOfDate,
              onCalibrate: () => _selectProfile(context, ref, profile),
            ),
        if (reviews.isNotEmpty) ...[
          const HrisListSurface(child: Text('Submitted calibration reviews')),
          for (final review in reviews)
            CandidateDevelopmentCalibrationReviewTile(review: review),
        ],
      ],
    );
  }

  List<CandidateDevelopmentCalibrationProfile> _visibleProfiles(
    List<CandidateDevelopmentCalibrationProfile> profiles,
  ) {
    final candidateIds = packets.map((item) => item.candidateId).toSet();
    return profiles
        .where((item) => candidateIds.contains(item.candidateId))
        .toList();
  }

  List<CandidateDevelopmentCalibrationReview> _visibleReviews(
    List<CandidateDevelopmentCalibrationReview> reviews,
    List<CandidateDevelopmentCalibrationProfile> profiles,
  ) {
    final objectiveIds = profiles.map((item) => item.objectiveId).toSet();
    return reviews
        .where((item) => objectiveIds.contains(item.objectiveId))
        .toList();
  }

  void _selectProfile(
    BuildContext context,
    WidgetRef ref,
    CandidateDevelopmentCalibrationProfile profile,
  ) {
    ref
        .read(candidateDevelopmentCalibrationDraftProvider.notifier)
        .initializeFromProfile(profile);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Calibration loaded for ${profile.candidateName}'),
        ),
      );
  }
}
