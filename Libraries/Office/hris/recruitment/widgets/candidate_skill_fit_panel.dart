import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/candidate_skill_fit_models.dart';
import 'candidate_skill_fit_summary_tile.dart';
import 'candidate_skill_fit_tile.dart';

class CandidateSkillFitPanel extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<CandidateSkillFitProfile> profiles;
  final CandidateSkillFitSummary summary;

  const CandidateSkillFitPanel({
    super.key,
    required this.title,
    required this.subtitle,
    required this.profiles,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      icon: Icons.fact_check_outlined,
      title: title,
      subtitle: subtitle,
      emptyMessage: 'No candidate fit scorecards match filters',
      children: [
        CandidateSkillFitSummaryTile(summary: summary),
        for (final profile in profiles) CandidateSkillFitTile(profile: profile),
      ],
    );
  }
}
