import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_record_action_models.dart';
import 'employee_record_action_status_styles.dart';

class EmployeeRecordActionImpactPreview extends StatelessWidget {
  final List<EmployeeRecordActionImpact> impacts;
  final String emptyMessage;

  const EmployeeRecordActionImpactPreview({
    super.key,
    required this.impacts,
    this.emptyMessage = 'Choose a record change to preview the impact.',
  });

  @override
  Widget build(BuildContext context) {
    final changedImpacts = impacts.where((impact) => impact.hasChange).toList();

    return HrisListSurface(
      child:
          changedImpacts.isEmpty
              ? Text(
                emptyMessage,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
              )
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    changedImpacts
                        .map((impact) => _ImpactRow(impact: impact))
                        .toList(),
              ),
    );
  }
}

class EmployeeRecordActionRequestTile extends StatelessWidget {
  final EmployeeRecordActionRequest request;
  final VoidCallback onApprove;
  final VoidCallback onApply;

  const EmployeeRecordActionRequestTile({
    super.key,
    required this.request,
    required this.onApprove,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = employeeRecordActionStatusColor(request.status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  employeeRecordActionTypeIcon(request.actionType),
                  color: statusColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${request.id} - ${request.actionType.label}',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Effective ${DateFormat('MMM d, yyyy').format(request.effectiveDate)}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(label: request.status.label, color: statusColor),
            ],
          ),
          const SizedBox(height: 10),
          EmployeeRecordActionImpactPreview(
            impacts: request.impacts,
            emptyMessage: 'No employee fields changed.',
          ),
          const SizedBox(height: 10),
          Text(
            request.reason,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (request.canApprove)
                FilledButton.tonalIcon(
                  onPressed: onApprove,
                  icon: const Icon(Icons.verified_outlined),
                  label: const Text('Approve'),
                ),
              if (request.canApply)
                FilledButton.icon(
                  onPressed: onApply,
                  icon: const Icon(Icons.assignment_turned_in_outlined),
                  label: const Text('Apply change'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ImpactRow extends StatelessWidget {
  final EmployeeRecordActionImpact impact;

  const _ImpactRow({required this.impact});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            child: Text(
              impact.label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: HrisColors.muted,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '${impact.fromValue} -> ${impact.toValue}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: HrisColors.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
