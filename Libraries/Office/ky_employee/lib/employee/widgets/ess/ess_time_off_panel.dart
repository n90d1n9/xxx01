import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/employee/models/time_off_request.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

class EssTimeOffPanel extends StatelessWidget {
  final List<TimeOffRequest> requests;
  final VoidCallback onViewAll;

  const EssTimeOffPanel({
    super.key,
    required this.requests,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final recentRequests = [...requests]
      ..sort((a, b) => b.startDate.compareTo(a.startDate));

    return HrisSectionPanel(
      title: 'Time Off Requests',
      icon: Icons.event_available_outlined,
      subtitle: '${requests.length} requests',
      emptyMessage: 'No time-off requests yet',
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: onViewAll,
            child: const Text('View All'),
          ),
        ),
        ...recentRequests
            .take(3)
            .map((request) => _TimeOffRequestTile(request: request)),
      ],
    );
  }
}

class _TimeOffRequestTile extends StatelessWidget {
  final TimeOffRequest request;

  const _TimeOffRequestTile({required this.request});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(request.status);

    return HrisListSurface(
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.event_note_outlined, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.reason,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${DateFormat('MMM d').format(request.startDate)} - ${DateFormat('MMM d, yyyy').format(request.endDate)} (${request.durationDays} days)',
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          HrisStatusPill(label: request.status, color: color),
        ],
      ),
    );
  }
}

Color _statusColor(String status) {
  switch (status) {
    case 'Approved':
      return const Color(0xFF059669);
    case 'Pending':
      return const Color(0xFFD97706);
    case 'Rejected':
      return const Color(0xFFDC2626);
    default:
      return const Color(0xFF6B7280);
  }
}
