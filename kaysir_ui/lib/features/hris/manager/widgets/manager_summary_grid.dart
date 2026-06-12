import 'package:flutter/material.dart';

import '../../shared/widgets/hris_ui.dart';
import '../models/manager_models.dart';

class ManagerSummaryGrid extends StatelessWidget {
  final ManagerSelfServiceSummary summary;

  const ManagerSummaryGrid({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return HrisSummaryGrid(
      metrics: [
        HrisSummaryMetric(
          title: 'Team members',
          value: '${summary.teamMemberCount}',
          detail: '${summary.availableCount} available now',
          icon: Icons.groups_2_outlined,
          color: HrisColors.primary,
        ),
        HrisSummaryMetric(
          title: 'Pending approvals',
          value: '${summary.pendingApprovalCount}',
          detail: '${summary.highPriorityApprovals} high priority',
          icon: Icons.approval_outlined,
          color: const Color(0xFFDC2626),
        ),
        HrisSummaryMetric(
          title: 'Avg capacity',
          value: '${summary.averageCapacity}%',
          detail: 'Across selected team',
          icon: Icons.speed_outlined,
          color: const Color(0xFFD97706),
        ),
        HrisSummaryMetric(
          title: 'Team health',
          value: '${summary.teamHealthScore}%',
          detail: '${summary.attentionCount} items need attention',
          icon: Icons.monitor_heart_outlined,
          color: const Color(0xFF15803D),
        ),
      ],
    );
  }
}
