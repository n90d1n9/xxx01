import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/hr_action_models.dart';
import 'people_ops_meta_label.dart';

class HrActionQueuePanel extends StatelessWidget {
  final List<HrActionRequest> requests;
  final HrActionQueueSummary summary;
  final DateTime asOfDate;
  final ValueChanged<String> onAdvance;
  final ValueChanged<String> onBlock;

  const HrActionQueuePanel({
    super.key,
    required this.requests,
    required this.summary,
    required this.asOfDate,
    required this.onAdvance,
    required this.onBlock,
  });

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      icon: Icons.manage_accounts_outlined,
      title: 'HR action queue',
      subtitle: '${summary.openCount} open of ${summary.totalCount} actions',
      emptyMessage: 'No HR actions match filters',
      children: [
        _ActionQueueSummary(summary: summary),
        for (final request in requests)
          _ActionRequestTile(
            request: request,
            asOfDate: asOfDate,
            onAdvance: onAdvance,
            onBlock: onBlock,
          ),
      ],
    );
  }
}

class _ActionQueueSummary extends StatelessWidget {
  final HrActionQueueSummary summary;

  const _ActionQueueSummary({required this.summary});

  @override
  Widget build(BuildContext context) {
    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.flag_circle_outlined, color: HrisColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Next HR action',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: HrisColors.muted,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      summary.nextAction,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _QueueStat(label: 'Blocked', value: '${summary.blockedCount}'),
              _QueueStat(
                label: 'Payroll',
                value: '${summary.payrollReviewCount}',
              ),
              _QueueStat(label: 'Urgent', value: '${summary.urgentCount}'),
              _QueueStat(
                label: 'Due week',
                value: '${summary.dueThisWeekCount}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QueueStat extends StatelessWidget {
  final String label;
  final String value;

  const _QueueStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 92),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: HrisColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: HrisColors.muted),
          ),
        ],
      ),
    );
  }
}

class _ActionRequestTile extends StatelessWidget {
  final HrActionRequest request;
  final DateTime asOfDate;
  final ValueChanged<String> onAdvance;
  final ValueChanged<String> onBlock;

  const _ActionRequestTile({
    required this.request,
    required this.asOfDate,
    required this.onAdvance,
    required this.onBlock,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(request.status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final heading = Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _actionIcon(request.actionType),
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.employeeName,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(
                            context,
                          ).textTheme.titleSmall?.copyWith(
                            color: HrisColors.ink,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '${request.id} - ${request.actionType.label}',
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: HrisColors.muted),
                        ),
                      ],
                    ),
                  ),
                ],
              );

              final status = HrisStatusPill(
                label: request.status.label,
                color: statusColor,
              );

              if (constraints.maxWidth < 700) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [heading, const SizedBox(height: 10), status],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: heading),
                  const SizedBox(width: 12),
                  status,
                ],
              );
            },
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              PeopleOpsMetaLabel(
                icon: Icons.apartment_outlined,
                label: request.department,
              ),
              PeopleOpsMetaLabel(
                icon: Icons.event_available_outlined,
                label: _effectiveLabel(request, asOfDate),
              ),
              PeopleOpsMetaLabel(
                icon: Icons.supervisor_account_outlined,
                label: request.managerName,
              ),
              PeopleOpsMetaLabel(
                icon: Icons.support_agent_outlined,
                label: request.ownerName,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            request.targetRole,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            request.reason,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          const SizedBox(height: 12),
          _ActionFooter(
            request: request,
            onAdvance: onAdvance,
            onBlock: onBlock,
          ),
        ],
      ),
    );
  }
}

class _ActionFooter extends StatelessWidget {
  final HrActionRequest request;
  final ValueChanged<String> onAdvance;
  final ValueChanged<String> onBlock;

  const _ActionFooter({
    required this.request,
    required this.onAdvance,
    required this.onBlock,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        HrisStatusPill(
          label: request.priority.label,
          color: _priorityColor(request.priority),
        ),
        if (request.payrollReviewRequired)
          const HrisStatusPill(
            label: 'Payroll review',
            color: Color(0xFF7C3AED),
          ),
        if (request.status != HrActionStatus.approved)
          FilledButton.tonalIcon(
            onPressed: () => onAdvance(request.id),
            icon: const Icon(Icons.arrow_forward_outlined),
            label: Text(_advanceLabel(request.status)),
          ),
        if (request.status != HrActionStatus.blocked &&
            request.status != HrActionStatus.approved)
          OutlinedButton.icon(
            onPressed: () => onBlock(request.id),
            icon: const Icon(Icons.block_outlined),
            label: const Text('Block'),
          ),
      ],
    );
  }
}

String _effectiveLabel(HrActionRequest request, DateTime asOfDate) {
  final days = request.daysUntilEffective(asOfDate);
  final date = DateFormat('MMM d').format(request.effectiveDate);
  if (days == 0) return '$date - today';
  if (days < 0) return '$date - overdue';
  return '$date - ${days}d';
}

String _advanceLabel(HrActionStatus status) {
  return switch (status) {
    HrActionStatus.submitted => 'Review',
    HrActionStatus.inReview => 'Approve',
    HrActionStatus.blocked => 'Reopen',
    HrActionStatus.approved => 'Approved',
  };
}

IconData _actionIcon(HrActionType type) {
  return switch (type) {
    HrActionType.newHire => Icons.person_add_alt_1_outlined,
    HrActionType.promotion => Icons.trending_up_outlined,
    HrActionType.transfer => Icons.swap_horiz_outlined,
    HrActionType.compensationChange => Icons.payments_outlined,
    HrActionType.leaveChange => Icons.event_note_outlined,
    HrActionType.offboarding => Icons.person_remove_outlined,
  };
}

Color _statusColor(HrActionStatus status) {
  return switch (status) {
    HrActionStatus.submitted => const Color(0xFF2563EB),
    HrActionStatus.inReview => const Color(0xFFB45309),
    HrActionStatus.approved => const Color(0xFF15803D),
    HrActionStatus.blocked => const Color(0xFFB91C1C),
  };
}

Color _priorityColor(HrActionPriority priority) {
  return switch (priority) {
    HrActionPriority.standard => const Color(0xFF0F766E),
    HrActionPriority.urgent => const Color(0xFFB45309),
    HrActionPriority.critical => const Color(0xFFB91C1C),
  };
}
