import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/ess_history_models.dart';

class TimeOffHistorySummaryGrid extends StatelessWidget {
  final TimeOffHistorySummary summary;

  const TimeOffHistorySummaryGrid({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return HrisSummaryGrid(
      metrics: [
        HrisSummaryMetric(
          title: 'Requests',
          value: '${summary.requestCount}',
          detail: '${summary.totalRequestedDays} total days requested',
          icon: Icons.event_note_outlined,
          color: HrisColors.primary,
        ),
        HrisSummaryMetric(
          title: 'Approved',
          value: '${summary.approvedCount}',
          detail: '${summary.approvedDays} approved days',
          icon: Icons.check_circle_outline,
          color: const Color(0xFF15803D),
        ),
        HrisSummaryMetric(
          title: 'Pending',
          value: '${summary.pendingCount}',
          detail:
              summary.nextPendingDate == null
                  ? 'No pending start date'
                  : 'Next ${DateFormat('MMM d').format(summary.nextPendingDate!)}',
          icon: Icons.pending_actions_outlined,
          color: const Color(0xFFD97706),
        ),
        HrisSummaryMetric(
          title: 'Rejected',
          value: '${summary.rejectedCount}',
          detail: 'Closed exceptions',
          icon: Icons.cancel_outlined,
          color: const Color(0xFFDC2626),
        ),
      ],
    );
  }
}
