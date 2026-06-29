import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_data_correction_models.dart';
import 'employee_data_correction_styles.dart';

class EmployeeDataCorrectionSummaryStrip extends StatelessWidget {
  final EmployeeDataCorrectionProfile profile;

  const EmployeeDataCorrectionSummaryStrip({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(label: 'Open', value: '${profile.openCount}'),
        HrisMetricStripItem(label: 'Review', value: '${profile.inReviewCount}'),
        HrisMetricStripItem(
          label: 'Approved',
          value: '${profile.approvedCount}',
        ),
        HrisMetricStripItem(label: 'Overdue', value: '${profile.overdueCount}'),
      ],
    );
  }
}

class EmployeeDataCorrectionRequestTile extends StatelessWidget {
  final EmployeeDataCorrectionRequest request;
  final DateTime asOfDate;
  final VoidCallback onStartReview;
  final VoidCallback onApprove;
  final VoidCallback onApply;
  final VoidCallback onReject;
  final VoidCallback onCancel;
  final VoidCallback onReopen;

  const EmployeeDataCorrectionRequestTile({
    super.key,
    required this.request,
    required this.asOfDate,
    required this.onStartReview,
    required this.onApprove,
    required this.onApply,
    required this.onReject,
    required this.onCancel,
    required this.onReopen,
  });

  @override
  Widget build(BuildContext context) {
    final overdue = request.isOverdue(asOfDate);
    final statusColor =
        overdue
            ? const Color(0xFFB91C1C)
            : employeeDataCorrectionStatusColor(request.status);
    final severityColor = employeeDataCorrectionSeverityColor(request.severity);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  employeeDataCorrectionStatusIcon(request.status),
                  color: statusColor,
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.field,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      request.issueTitle,
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
                color: statusColor,
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 700) {
                return Column(
                  children: [
                    _ValueBlock(
                      label: 'Current',
                      value: request.currentValue,
                      color: HrisColors.muted,
                    ),
                    const SizedBox(height: 8),
                    _ValueBlock(
                      label: 'Proposed',
                      value: request.proposedValue,
                      color: severityColor,
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: _ValueBlock(
                      label: 'Current',
                      value: request.currentValue,
                      color: HrisColors.muted,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ValueBlock(
                      label: 'Proposed',
                      value: request.proposedValue,
                      color: severityColor,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 10),
          Text(
            request.rationale,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.ink),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaChip(
                icon: Icons.priority_high_outlined,
                label: request.severity.label,
                color: severityColor,
              ),
              _MetaChip(
                icon: Icons.person_add_alt_outlined,
                label: request.requester,
              ),
              _MetaChip(
                icon: Icons.verified_user_outlined,
                label: request.reviewer,
              ),
              _MetaChip(
                icon: Icons.event_outlined,
                label: 'Due ${DateFormat('MMM d').format(request.dueDate)}',
                color: overdue ? const Color(0xFFB91C1C) : null,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 8,
              children: _actions(),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _actions() {
    if (!request.isOpen) {
      return [
        OutlinedButton.icon(
          onPressed: onReopen,
          icon: const Icon(Icons.replay_outlined),
          label: const Text('Reopen'),
        ),
      ];
    }

    return [
      OutlinedButton.icon(
        onPressed: request.canReview ? onStartReview : null,
        icon: const Icon(Icons.rate_review_outlined),
        label: const Text('Review'),
      ),
      OutlinedButton.icon(
        onPressed: request.canReject ? onReject : null,
        icon: const Icon(Icons.cancel_outlined),
        label: const Text('Reject'),
      ),
      OutlinedButton.icon(
        onPressed: request.canCancel ? onCancel : null,
        icon: const Icon(Icons.do_not_disturb_on_outlined),
        label: const Text('Cancel'),
      ),
      FilledButton.tonalIcon(
        onPressed: request.canApprove ? onApprove : null,
        icon: const Icon(Icons.verified_outlined),
        label: const Text('Approve'),
      ),
      FilledButton.icon(
        onPressed: request.canApply ? onApply : null,
        icon: const Icon(Icons.task_alt_outlined),
        label: const Text('Apply'),
      ),
    ];
  }
}

class _ValueBlock extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ValueBlock({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
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
    final resolvedColor = color ?? HrisColors.muted;

    return Container(
      constraints: const BoxConstraints(maxWidth: 230),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: resolvedColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: resolvedColor),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: resolvedColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
