import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/company_change_request.dart';
import 'company_status_styles.dart';

class CompanyChangeRequestBoard extends StatelessWidget {
  final List<CompanyChangeRequest> requests;
  final DateTime asOfDate;
  final ValueChanged<String> onSchedule;
  final ValueChanged<String> onImplement;

  const CompanyChangeRequestBoard({
    super.key,
    required this.requests,
    required this.asOfDate,
    required this.onSchedule,
    required this.onImplement,
  });

  @override
  Widget build(BuildContext context) {
    final openRequests =
        requests
            .where(
              (request) =>
                  request.status != CompanyChangeRequestStatus.implemented,
            )
            .length;

    return HrisSectionPanel(
      icon: Icons.sync_alt_outlined,
      title: 'Change Request Board',
      subtitle: '$openRequests open of ${requests.length} changes',
      emptyMessage: 'No matching company change requests',
      children:
          requests
              .map(
                (request) => _ChangeRequestTile(
                  request: request,
                  asOfDate: asOfDate,
                  onSchedule: () => onSchedule(request.id),
                  onImplement: () => onImplement(request.id),
                ),
              )
              .toList(),
    );
  }
}

class _ChangeRequestTile extends StatelessWidget {
  final CompanyChangeRequest request;
  final DateTime asOfDate;
  final VoidCallback onSchedule;
  final VoidCallback onImplement;

  const _ChangeRequestTile({
    required this.request,
    required this.asOfDate,
    required this.onSchedule,
    required this.onImplement,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = companyChangeRequestStatusColor(request.status);
    final priorityColor = companyChangeRequestPriorityColor(request.priority);
    final issues = request.issues(asOfDate);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${request.entityName} - ${request.type.label}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                alignment: WrapAlignment.end,
                children: [
                  HrisStatusPill(
                    label: request.priority.label,
                    color: priorityColor,
                  ),
                  HrisStatusPill(
                    label: request.status.label,
                    color: statusColor,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(label: 'Owner', value: request.ownerName),
              HrisMetricStripItem(
                label: 'Effective',
                value: _effectiveLabel(request),
              ),
              HrisMetricStripItem(
                label: 'Approver',
                value: request.approverRole,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            request.impactSummary,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: HrisColors.ink),
          ),
          if (request.linkedRecord.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            HrisStatusPill(label: request.linkedRecord, color: Colors.blueGrey),
          ],
          if (issues.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  issues
                      .map(
                        (issue) => HrisStatusPill(
                          label: issue.label,
                          color: Colors.orange,
                        ),
                      )
                      .toList(),
            ),
          ],
          if (request.status != CompanyChangeRequestStatus.implemented) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.end,
              children: [
                if (request.status != CompanyChangeRequestStatus.scheduled)
                  OutlinedButton.icon(
                    onPressed: onSchedule,
                    icon: const Icon(Icons.event_available_outlined),
                    label: const Text('Schedule'),
                  ),
                FilledButton.icon(
                  onPressed: onImplement,
                  icon: const Icon(Icons.task_alt_outlined),
                  label: const Text('Implement'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _effectiveLabel(CompanyChangeRequest request) {
    final days = request.daysUntilEffective(asOfDate);
    if (days < 0) return 'Overdue ${days.abs()}d';
    if (days == 0) return 'Today';
    return '${_formatDate(request.effectiveDate)} (${days}d)';
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
