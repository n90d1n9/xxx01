import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_compensation_models.dart';
import 'employee_compensation_styles.dart';

class EmployeeCompensationImpactPreview extends StatelessWidget {
  final EmployeeCompensationImpact impact;
  final String currencyCode;

  const EmployeeCompensationImpactPreview({
    super.key,
    required this.impact,
    required this.currencyCode,
  });

  @override
  Widget build(BuildContext context) {
    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ImpactRow(
            label: 'Increase',
            value:
                '${formatCompensationMoney(impact.increaseAmount, currencyCode)} (${formatCompensationPercent(impact.increasePercent)})',
          ),
          _ImpactRow(
            label: 'New base',
            value: formatCompensationMoney(
              impact.proposedBaseSalary,
              currencyCode,
            ),
          ),
          _ImpactRow(
            label: 'Compa',
            value: formatCompensationPercent(impact.proposedCompaRatio),
          ),
        ],
      ),
    );
  }
}

class EmployeeCompensationReviewRequestTile extends StatelessWidget {
  final EmployeeCompensationReviewRequest request;
  final VoidCallback onApprove;
  final VoidCallback onApply;

  const EmployeeCompensationReviewRequestTile({
    super.key,
    required this.request,
    required this.onApprove,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = employeeCompensationReviewStatusColor(request.status);

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
                  employeeCompensationReviewTypeIcon(request.reviewType),
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
                      '${request.id} - ${request.reviewType.label}',
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
          EmployeeCompensationImpactPreview(
            impact: request.impact,
            currencyCode: request.currencyCode,
          ),
          const SizedBox(height: 10),
          Text(
            request.justification,
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
                  icon: const Icon(Icons.price_check_outlined),
                  label: const Text('Apply pay'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

String formatCompensationMoney(double amount, String currencyCode) {
  final formatter = NumberFormat.decimalPattern();
  return '$currencyCode ${formatter.format(amount.round())}';
}

String formatCompensationPercent(double value) {
  return '${(value * 100).toStringAsFixed(1)}%';
}

class _ImpactRow extends StatelessWidget {
  final String label;
  final String value;

  const _ImpactRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 82,
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: HrisColors.muted,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
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
