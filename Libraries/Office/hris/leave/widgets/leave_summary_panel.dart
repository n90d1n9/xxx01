import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/leave_request.dart';

class LeaveSummaryPanel extends StatelessWidget {
  final LeaveSummary summary;
  final VoidCallback onRequestLeave;

  const LeaveSummaryPanel({
    super.key,
    required this.summary,
    required this.onRequestLeave,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: hrisPanelDecoration(),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 640;
              final heading = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Leave Balance Center',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: HrisColors.ink,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${summary.remainingBalance} of ${summary.balanceDays} days available',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: HrisColors.muted),
                  ),
                ],
              );
              final action = FilledButton.icon(
                onPressed: onRequestLeave,
                icon: const Icon(Icons.add),
                label: const Text('Request Leave'),
              );

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    heading,
                    const SizedBox(height: 16),
                    SizedBox(width: double.infinity, child: action),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: heading),
                  const SizedBox(width: 16),
                  action,
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        HrisSummaryGrid(
          metrics: [
            HrisSummaryMetric(
              title: 'Available',
              value: '${summary.remainingBalance}',
              detail: 'days remaining',
              icon: Icons.event_available_outlined,
              color: const Color(0xFF0F766E),
            ),
            HrisSummaryMetric(
              title: 'Pending',
              value: '${summary.pendingCount}',
              detail: '${summary.pendingDays} days requested',
              icon: Icons.pending_actions_outlined,
              color: const Color(0xFFD97706),
            ),
            HrisSummaryMetric(
              title: 'Approved',
              value: '${summary.approvedCount}',
              detail: '${summary.approvedDays} days booked',
              icon: Icons.check_circle_outline,
              color: const Color(0xFF2563EB),
            ),
            HrisSummaryMetric(
              title: 'Rejected',
              value: '${summary.rejectedCount}',
              detail: 'requests declined',
              icon: Icons.cancel_outlined,
              color: const Color(0xFFDC2626),
            ),
          ],
        ),
      ],
    );
  }
}
