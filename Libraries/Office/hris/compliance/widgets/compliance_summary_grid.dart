import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/compliance_models.dart';

class ComplianceSummaryGrid extends StatelessWidget {
  final ComplianceSummary summary;

  const ComplianceSummaryGrid({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return HrisSummaryGrid(
      metrics: [
        HrisSummaryMetric(
          title: 'Controls',
          value: '${summary.controlsDue}',
          detail: '${summary.overdueControls} overdue',
          icon: Icons.fact_check_outlined,
          color: const Color(0xFF2563EB),
        ),
        HrisSummaryMetric(
          title: 'Policy pending',
          value: '${summary.pendingAcknowledgements}',
          detail: 'acknowledgements',
          icon: Icons.policy_outlined,
          color: const Color(0xFF7C3AED),
        ),
        HrisSummaryMetric(
          title: 'Documents',
          value: '${summary.documentRisks}',
          detail: 'expiry risks',
          icon: Icons.badge_outlined,
          color: const Color(0xFFB45309),
        ),
        HrisSummaryMetric(
          title: 'Audit findings',
          value: '${summary.openFindings}',
          detail: '${summary.criticalFindings} critical',
          icon: Icons.gpp_maybe_outlined,
          color: const Color(0xFFBE123C),
        ),
      ],
    );
  }
}
