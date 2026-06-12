import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/company_headcount_requisition.dart';

/// Board for reviewing and advancing company headcount requisitions.
class CompanyHeadcountRequisitionBoard extends StatelessWidget {
  final List<CompanyHeadcountRequisition> requisitions;
  final DateTime asOfDate;
  final ValueChanged<String> onApprove;
  final ValueChanged<String> onOpenRecruiting;
  final ValueChanged<String> onMarkFilled;

  const CompanyHeadcountRequisitionBoard({
    super.key,
    required this.requisitions,
    required this.asOfDate,
    required this.onApprove,
    required this.onOpenRecruiting,
    required this.onMarkFilled,
  });

  @override
  Widget build(BuildContext context) {
    final openCount =
        requisitions
            .where(
              (request) =>
                  request.status != CompanyHeadcountRequisitionStatus.filled &&
                  request.status != CompanyHeadcountRequisitionStatus.cancelled,
            )
            .length;

    return HrisSectionPanel(
      icon: Icons.assignment_add,
      title: 'Headcount Requisition Board',
      subtitle: '$openCount open of ${requisitions.length} requisitions',
      emptyMessage: 'No matching headcount requisitions',
      children:
          requisitions
              .map(
                (request) => _HeadcountRequisitionTile(
                  request: request,
                  asOfDate: asOfDate,
                  onApprove: () => onApprove(request.id),
                  onOpenRecruiting: () => onOpenRecruiting(request.id),
                  onMarkFilled: () => onMarkFilled(request.id),
                ),
              )
              .toList(),
    );
  }
}

/// One requisition card in the approval and recruiting queue.
class _HeadcountRequisitionTile extends StatelessWidget {
  final CompanyHeadcountRequisition request;
  final DateTime asOfDate;
  final VoidCallback onApprove;
  final VoidCallback onOpenRecruiting;
  final VoidCallback onMarkFilled;

  const _HeadcountRequisitionTile({
    required this.request,
    required this.asOfDate,
    required this.onApprove,
    required this.onOpenRecruiting,
    required this.onMarkFilled,
  });

  @override
  Widget build(BuildContext context) {
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
                      request.roleTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${request.entityName} - ${request.orgUnitName}',
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
                    color: _priorityColor(request.priority),
                  ),
                  HrisStatusPill(
                    label: request.status.label,
                    color: _statusColor(request.status),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(
                label: 'Seats',
                value: '${request.requestedSeats}',
              ),
              HrisMetricStripItem(label: 'Start', value: _targetLabel()),
              HrisMetricStripItem(
                label: 'Manager',
                value: request.hiringManagerName,
              ),
            ],
          ),
          const SizedBox(height: 12),
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(label: 'Type', value: request.type.label),
              HrisMetricStripItem(
                label: 'Profile',
                value: request.jobProfileCode,
              ),
              HrisMetricStripItem(
                label: 'Cost center',
                value: request.costCenterCode,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            request.businessCase,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            request.budgetImpact,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          if (request.positionControlId.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            HrisStatusPill(
              label: request.positionControlId,
              color: Colors.blueGrey,
            ),
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
                          color:
                              issue ==
                                          CompanyHeadcountRequisitionIssue
                                              .overdueTargetStart ||
                                      issue ==
                                          CompanyHeadcountRequisitionIssue
                                              .criticalPriority
                                  ? Colors.red
                                  : Colors.orange,
                        ),
                      )
                      .toList(),
            ),
          ],
          if (_hasActions) ...[
            const SizedBox(height: 12),
            _HeadcountRequisitionActions(
              request: request,
              onApprove: onApprove,
              onOpenRecruiting: onOpenRecruiting,
              onMarkFilled: onMarkFilled,
            ),
          ],
        ],
      ),
    );
  }

  bool get _hasActions {
    return request.status ==
            CompanyHeadcountRequisitionStatus.awaitingApproval ||
        request.status == CompanyHeadcountRequisitionStatus.approved ||
        request.status == CompanyHeadcountRequisitionStatus.recruiting;
  }

  String _targetLabel() {
    final days = request.daysUntilTargetStart(asOfDate);
    if (days < 0) return 'Overdue ${days.abs()}d';
    if (days == 0) return 'Today';
    final month = request.targetStartDate.month.toString().padLeft(2, '0');
    final day = request.targetStartDate.day.toString().padLeft(2, '0');
    return '${request.targetStartDate.year}-$month-$day (${days}d)';
  }
}

/// Action row for one headcount requisition.
class _HeadcountRequisitionActions extends StatelessWidget {
  final CompanyHeadcountRequisition request;
  final VoidCallback onApprove;
  final VoidCallback onOpenRecruiting;
  final VoidCallback onMarkFilled;

  const _HeadcountRequisitionActions({
    required this.request,
    required this.onApprove,
    required this.onOpenRecruiting,
    required this.onMarkFilled,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.end,
        children: [
          if (request.status ==
              CompanyHeadcountRequisitionStatus.awaitingApproval)
            FilledButton.icon(
              key: Key('company-headcount-approve-${request.id}'),
              onPressed: onApprove,
              icon: const Icon(Icons.verified_outlined),
              label: const Text('Approve'),
            ),
          if (request.status == CompanyHeadcountRequisitionStatus.approved)
            FilledButton.icon(
              key: Key('company-headcount-recruiting-${request.id}'),
              onPressed: onOpenRecruiting,
              icon: const Icon(Icons.campaign_outlined),
              label: const Text('Open recruiting'),
            ),
          if (request.status == CompanyHeadcountRequisitionStatus.recruiting)
            FilledButton.icon(
              key: Key('company-headcount-filled-${request.id}'),
              onPressed: onMarkFilled,
              icon: const Icon(Icons.task_alt_outlined),
              label: const Text('Mark filled'),
            ),
        ],
      ),
    );
  }
}

Color _statusColor(CompanyHeadcountRequisitionStatus status) {
  switch (status) {
    case CompanyHeadcountRequisitionStatus.draft:
      return Colors.blueGrey;
    case CompanyHeadcountRequisitionStatus.awaitingApproval:
      return Colors.orange;
    case CompanyHeadcountRequisitionStatus.approved:
      return Colors.indigo;
    case CompanyHeadcountRequisitionStatus.recruiting:
      return Colors.blue;
    case CompanyHeadcountRequisitionStatus.filled:
      return Colors.green;
    case CompanyHeadcountRequisitionStatus.rejected:
      return Colors.red;
    case CompanyHeadcountRequisitionStatus.cancelled:
      return Colors.grey;
  }
}

Color _priorityColor(CompanyHeadcountRequisitionPriority priority) {
  switch (priority) {
    case CompanyHeadcountRequisitionPriority.low:
      return Colors.blueGrey;
    case CompanyHeadcountRequisitionPriority.medium:
      return Colors.blue;
    case CompanyHeadcountRequisitionPriority.high:
      return Colors.orange;
    case CompanyHeadcountRequisitionPriority.critical:
      return Colors.red;
  }
}

@Preview(name: 'Company headcount requisition board')
Widget companyHeadcountRequisitionBoardPreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: CompanyHeadcountRequisitionBoard(
          requisitions: [
            CompanyHeadcountRequisition(
              id: 'hreq-product-engineer',
              roleTitle: 'Product Engineer',
              entityName: 'PT Kaysir Nusantara',
              orgUnitName: 'Product & Commerce',
              hiringManagerName: 'Fajar Prakoso',
              positionControlId: 'position-product-engineer',
              jobProfileCode: 'ENG-JP-04',
              costCenterCode: 'CC-PROD',
              type: CompanyHeadcountRequisitionType.growth,
              priority: CompanyHeadcountRequisitionPriority.high,
              status: CompanyHeadcountRequisitionStatus.recruiting,
              requestedSeats: 2,
              targetStartDate: DateTime(2026, 7, 1),
              businessCase: 'Add delivery capacity for commerce roadmap.',
              budgetImpact: 'Requires product budget review before offers.',
              approverRole: 'Head of Product',
            ),
          ],
          asOfDate: DateTime(2026, 6, 12),
          onApprove: _previewAction,
          onOpenRecruiting: _previewAction,
          onMarkFilled: _previewAction,
        ),
      ),
    ),
  );
}

void _previewAction(String id) {}
