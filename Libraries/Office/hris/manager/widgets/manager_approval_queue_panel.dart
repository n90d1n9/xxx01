import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../shared/widgets/hris_ui.dart';
import '../models/manager_models.dart';
import 'manager_status_styles.dart';

class ManagerApprovalQueuePanel extends StatelessWidget {
  final List<PendingRequest> requests;
  final ValueChanged<PendingRequest> onApprove;
  final ValueChanged<PendingRequest> onReject;

  const ManagerApprovalQueuePanel({
    super.key,
    required this.requests,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      icon: Icons.approval_outlined,
      title: 'Approval queue',
      subtitle: 'Prioritized manager approvals',
      emptyMessage: 'No approvals match the current view',
      children:
          requests
              .map(
                (request) => _ApprovalRequestTile(
                  request: request,
                  onApprove: () => onApprove(request),
                  onReject: () => onReject(request),
                ),
              )
              .toList(),
    );
  }
}

class _ApprovalRequestTile extends StatelessWidget {
  final PendingRequest request;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _ApprovalRequestTile({
    required this.request,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return HrisListSurface(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final actions = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton.filledTonal(
                tooltip: 'Approve',
                icon: const Icon(Icons.check_rounded),
                onPressed: onApprove,
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                tooltip: 'Reject',
                icon: const Icon(Icons.close_rounded),
                onPressed: onReject,
              ),
            ],
          );
          final content = Row(
            children: [
              CircleAvatar(backgroundImage: NetworkImage(request.avatarUrl)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          request.employeeName,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        HrisStatusPill(
                          label: request.priority.label,
                          color: managerRequestPriorityColor(request.priority),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${request.requestType} • ${request.team}',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('MMM d, h:mm a').format(request.requestDate),
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.labelSmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          );

          if (constraints.maxWidth < 480) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [content, const SizedBox(height: 12), actions],
            );
          }

          return Row(
            children: [
              Expanded(child: content),
              const SizedBox(width: 12),
              actions,
            ],
          );
        },
      ),
    );
  }
}
