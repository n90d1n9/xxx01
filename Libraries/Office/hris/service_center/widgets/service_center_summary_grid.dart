import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/service_center_models.dart';

class ServiceCenterSummaryGrid extends StatelessWidget {
  final ServiceCenterSummary summary;

  const ServiceCenterSummaryGrid({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return HrisSummaryGrid(
      metrics: [
        HrisSummaryMetric(
          title: 'Open cases',
          value: '${summary.openCases}',
          detail: '${summary.slaRisks} SLA risks',
          icon: Icons.support_agent_outlined,
          color: const Color(0xFF2563EB),
        ),
        HrisSummaryMetric(
          title: 'Documents',
          value: '${summary.documentBacklog}',
          detail: 'requests pending',
          icon: Icons.description_outlined,
          color: const Color(0xFF7C3AED),
        ),
        HrisSummaryMetric(
          title: 'Policies',
          value: '${summary.policies}',
          detail: 'articles available',
          icon: Icons.policy_outlined,
          color: const Color(0xFF0F766E),
        ),
        HrisSummaryMetric(
          title: 'Helpful rate',
          value: '${(summary.helpfulRate * 100).toStringAsFixed(0)}%',
          detail: 'knowledge votes',
          icon: Icons.thumb_up_alt_outlined,
          color: const Color(0xFFD97706),
        ),
      ],
    );
  }
}
