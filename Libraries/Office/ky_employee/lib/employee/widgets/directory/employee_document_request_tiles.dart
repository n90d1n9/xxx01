import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_document_request_models.dart';
import 'employee_document_request_styles.dart';

class EmployeeDocumentRequestSummaryStrip extends StatelessWidget {
  final EmployeeDocumentRequestProfile profile;

  const EmployeeDocumentRequestSummaryStrip({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(
          label: 'Requested',
          value: '${profile.requestedCount}',
        ),
        HrisMetricStripItem(
          label: 'Reviewing',
          value: '${profile.reviewingCount}',
        ),
        HrisMetricStripItem(
          label: 'Acknowledge',
          value: '${profile.issuedPendingAckCount}',
        ),
        HrisMetricStripItem(label: 'Overdue', value: '${profile.overdueCount}'),
      ],
    );
  }
}

class EmployeeDocumentRequestTile extends StatelessWidget {
  final EmployeeDocumentRequest request;
  final DateTime asOfDate;
  final VoidCallback onReview;
  final VoidCallback onIssue;
  final VoidCallback onAcknowledge;
  final VoidCallback onReject;

  const EmployeeDocumentRequestTile({
    super.key,
    required this.request,
    required this.asOfDate,
    required this.onReview,
    required this.onIssue,
    required this.onAcknowledge,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final overdue = request.isOverdue(asOfDate);
    final color =
        overdue
            ? const Color(0xFFB91C1C)
            : employeeDocumentRequestStatusColor(request.status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  employeeDocumentRequestTypeIcon(request.type),
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.title,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${request.type.label} - ${request.owner}',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              HrisStatusPill(
                label: overdue ? 'Overdue' : request.status.label,
                color: color,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            request.purpose,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaChip(icon: Icons.person_outline, label: request.requestedBy),
              _MetaChip(
                icon: Icons.event_outlined,
                label: 'Due ${DateFormat('MMM d').format(request.dueDate)}',
                color: overdue ? color : null,
              ),
              _MetaChip(
                icon: employeeDocumentDeliveryIcon(request.deliveryMethod),
                label: request.deliveryMethod.label,
              ),
              if (request.requiresAcknowledgement)
                _MetaChip(
                  icon: Icons.task_alt_outlined,
                  label: 'Acknowledgement',
                  color:
                      request.canAcknowledge ? const Color(0xFFB45309) : null,
                ),
            ],
          ),
          if (request.canReview ||
              request.canIssue ||
              request.canAcknowledge ||
              request.canReject) ...[
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 8,
              children: [
                if (request.canReject)
                  OutlinedButton.icon(
                    onPressed: onReject,
                    icon: const Icon(Icons.close_outlined),
                    label: const Text('Reject'),
                  ),
                if (request.canReview)
                  FilledButton.tonalIcon(
                    onPressed: onReview,
                    icon: const Icon(Icons.rate_review_outlined),
                    label: const Text('Review'),
                  ),
                if (request.canIssue)
                  FilledButton.tonalIcon(
                    onPressed: onIssue,
                    icon: const Icon(Icons.upload_file_outlined),
                    label: const Text('Issue'),
                  ),
                if (request.canAcknowledge)
                  FilledButton.icon(
                    onPressed: onAcknowledge,
                    icon: const Icon(Icons.task_alt_outlined),
                    label: const Text('Acknowledge'),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _MetaChip({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? HrisColors.muted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: chipColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: chipColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
