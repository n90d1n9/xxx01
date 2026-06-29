import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/leave_request.dart';
import 'leave_meta_label.dart';
import 'leave_status_styles.dart';

class LeaveRequestList extends StatelessWidget {
  final List<LeaveRequest> requests;
  final ValueChanged<LeaveRequest> onCancel;

  const LeaveRequestList({
    super.key,
    required this.requests,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      title: 'Your Leave Requests',
      icon: Icons.event_note_outlined,
      subtitle: '${requests.length} requests',
      emptyMessage: 'No leave requests yet',
      children:
          requests
              .map(
                (request) =>
                    _LeaveRequestCard(request: request, onCancel: onCancel),
              )
              .toList(),
    );
  }
}

class _LeaveRequestCard extends StatelessWidget {
  final LeaveRequest request;
  final ValueChanged<LeaveRequest> onCancel;

  const _LeaveRequestCard({required this.request, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final typeColor = leaveTypeColor(request.leaveType);
    final statusColor = leaveStatusColor(request.status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(leaveTypeIcon(request.leaveType), color: typeColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  request.leaveType,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              HrisStatusPill(
                label: leaveStatusLabel(request.status),
                color: statusColor,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              LeaveMetaLabel(
                icon: Icons.date_range_outlined,
                label:
                    '${DateFormat('MMM d').format(request.startDate)} - ${DateFormat('MMM d, yyyy').format(request.endDate)}',
              ),
              LeaveMetaLabel(
                icon: Icons.timelapse_outlined,
                label: '${request.durationDays} days',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            request.reason,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: HrisColors.ink),
          ),
          if (request.status == LeaveStatus.pending) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: () => onCancel(request),
                icon: const Icon(Icons.close),
                label: const Text('Cancel'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
