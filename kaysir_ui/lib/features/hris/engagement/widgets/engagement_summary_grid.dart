import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/engagement_models.dart';

class EngagementSummaryGrid extends StatelessWidget {
  final EngagementSummary summary;

  const EngagementSummaryGrid({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return HrisSummaryGrid(
      metrics: [
        HrisSummaryMetric(
          title: 'Surveys',
          value: '${summary.liveSurveys}',
          detail: 'live right now',
          icon: Icons.fact_check_outlined,
          color: const Color(0xFF2563EB),
        ),
        HrisSummaryMetric(
          title: 'Pulse score',
          value: summary.averagePulseScore.toStringAsFixed(0),
          detail: '${summary.actionItems} action items',
          icon: Icons.favorite_border,
          color: const Color(0xFFBE123C),
        ),
        HrisSummaryMetric(
          title: 'Wellbeing',
          value: '${summary.highRisks}',
          detail: 'high risks',
          icon: Icons.spa_outlined,
          color: const Color(0xFFD97706),
        ),
        HrisSummaryMetric(
          title: 'Recognition',
          value: '${summary.recognitionCount}',
          detail: 'recent moments',
          icon: Icons.celebration_outlined,
          color: const Color(0xFF7C3AED),
        ),
      ],
    );
  }
}
