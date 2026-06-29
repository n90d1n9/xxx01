import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/talent_models.dart';

class TalentSummaryGrid extends StatelessWidget {
  final TalentSummary summary;

  const TalentSummaryGrid({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return HrisSummaryGrid(
      metrics: [
        HrisSummaryMetric(
          title: 'Skill gaps',
          value: '${summary.skillGaps}',
          detail: 'roles need coaching',
          icon: Icons.psychology_alt_outlined,
          color: const Color(0xFF7C3AED),
        ),
        HrisSummaryMetric(
          title: 'Learning due',
          value: '${summary.learningDue}',
          detail: 'assignments pending',
          icon: Icons.menu_book_outlined,
          color: const Color(0xFF2563EB),
        ),
        HrisSummaryMetric(
          title: 'Cert risks',
          value: '${summary.certificationRisks}',
          detail: 'expiring or expired',
          icon: Icons.workspace_premium_outlined,
          color: const Color(0xFFD97706),
        ),
        HrisSummaryMetric(
          title: 'Mentoring watch',
          value: '${summary.mentoringWatch}',
          detail:
              '${(summary.averageLearningCompletion * 100).toStringAsFixed(0)}% avg learning',
          icon: Icons.handshake_outlined,
          color: const Color(0xFF0F766E),
        ),
      ],
    );
  }
}
