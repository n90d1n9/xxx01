import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_position_control_models.dart';
import 'employee_position_control_styles.dart';

class EmployeePositionControlSummaryStrip extends StatelessWidget {
  final EmployeePositionControlProfile profile;

  const EmployeePositionControlSummaryStrip({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(
          label: 'Approved',
          value: profile.position.approvedFte.toStringAsFixed(1),
        ),
        HrisMetricStripItem(
          label: 'Filled',
          value: profile.position.filledFte.toStringAsFixed(1),
        ),
        HrisMetricStripItem(
          label: 'Vacant',
          value: profile.position.vacantFte.toStringAsFixed(1),
        ),
        HrisMetricStripItem(
          label: 'Open reqs',
          value: '${profile.openRequisitionCount}',
        ),
      ],
    );
  }
}

class EmployeePositionControlCard extends StatelessWidget {
  final EmployeePositionControlRecord position;
  final DateTime asOfDate;
  final VoidCallback onFreeze;
  final VoidCallback onUnfreeze;
  final VoidCallback onClearBudget;

  const EmployeePositionControlCard({
    super.key,
    required this.position,
    required this.asOfDate,
    required this.onFreeze,
    required this.onUnfreeze,
    required this.onClearBudget,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = employeePositionStatusColor(position.status);
    final budgetColor = employeePositionBudgetStatusColor(
      position.budgetStatus,
    );
    final criticalityColor = employeePositionCriticalityColor(
      position.criticality,
    );

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${position.positionCode} - ${position.title}',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${position.department} / ${position.costCenter}',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(label: position.status.label, color: statusColor),
            ],
          ),
          const SizedBox(height: 10),
          HrisProgressBar(
            value: position.fillRatio,
            color: statusColor,
            label:
                '${position.filledFte.toStringAsFixed(1)} of ${position.approvedFte.toStringAsFixed(1)} FTE filled',
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaChip(
                icon: Icons.payments_outlined,
                label:
                    'Budget ${NumberFormat.compactCurrency(symbol: r'$').format(position.budgetedMonthlyCost)}',
                color: budgetColor,
              ),
              _MetaChip(
                icon: Icons.trending_up_outlined,
                label:
                    'Variance ${NumberFormat.compactCurrency(symbol: r'$').format(position.budgetVariance)}',
                color:
                    position.isOverBudget
                        ? const Color(0xFFB91C1C)
                        : const Color(0xFF15803D),
              ),
              _MetaChip(
                icon: Icons.priority_high_outlined,
                label: position.criticality.label,
                color: criticalityColor,
              ),
              _MetaChip(
                icon: Icons.person_outline,
                label: position.hiringManager,
              ),
              _MetaChip(
                icon: Icons.event_available_outlined,
                label: DateFormat('MMM d').format(position.nextReviewDate),
                color:
                    position.isReviewDue(asOfDate)
                        ? const Color(0xFFB91C1C)
                        : null,
              ),
              OutlinedButton.icon(
                onPressed: position.isFrozen ? onUnfreeze : onFreeze,
                icon: Icon(
                  position.isFrozen
                      ? Icons.lock_open_outlined
                      : Icons.lock_outline,
                ),
                label: Text(position.isFrozen ? 'Unfreeze' : 'Freeze'),
              ),
              FilledButton.tonalIcon(
                onPressed: position.isOverBudget ? onClearBudget : null,
                icon: const Icon(Icons.price_check_outlined),
                label: const Text('Clear budget'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class EmployeePositionRequisitionTile extends StatelessWidget {
  final EmployeePositionRequisition requisition;
  final DateTime asOfDate;
  final VoidCallback onApprove;
  final VoidCallback onOpen;
  final VoidCallback onFill;
  final VoidCallback onCancel;

  const EmployeePositionRequisitionTile({
    super.key,
    required this.requisition,
    required this.asOfDate,
    required this.onApprove,
    required this.onOpen,
    required this.onFill,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final overdue = requisition.isOverdue(asOfDate);
    final color =
        overdue
            ? const Color(0xFFB91C1C)
            : employeePositionRequisitionStatusColor(requisition.status);

    return HrisListSurface(
      child: Row(
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
              employeePositionRequisitionTypeIcon(requisition.type),
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        requisition.title,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: HrisColors.ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    HrisStatusPill(
                      label: overdue ? 'Overdue' : requisition.status.label,
                      color: color,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  requisition.businessCase,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _MetaChip(
                      icon: Icons.person_outline,
                      label: requisition.owner,
                    ),
                    _MetaChip(
                      icon: Icons.groups_outlined,
                      label:
                          '${requisition.requestedFte.toStringAsFixed(1)} FTE',
                    ),
                    _MetaChip(
                      icon: Icons.route_outlined,
                      label: requisition.type.label,
                    ),
                    _MetaChip(
                      icon: Icons.event_outlined,
                      label: DateFormat(
                        'MMM d',
                      ).format(requisition.targetStartDate),
                      color: overdue ? const Color(0xFFB91C1C) : null,
                    ),
                    OutlinedButton.icon(
                      onPressed: requisition.canApprove ? onApprove : null,
                      icon: const Icon(Icons.thumb_up_alt_outlined),
                      label: const Text('Approve'),
                    ),
                    OutlinedButton.icon(
                      onPressed: requisition.canOpen ? onOpen : null,
                      icon: const Icon(Icons.campaign_outlined),
                      label: const Text('Open'),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: requisition.canFill ? onFill : null,
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Fill'),
                    ),
                    TextButton.icon(
                      onPressed: requisition.isClosed ? null : onCancel,
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text('Cancel'),
                    ),
                  ],
                ),
              ],
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: resolvedColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: resolvedColor.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: resolvedColor),
          const SizedBox(width: 5),
          Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: resolvedColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
