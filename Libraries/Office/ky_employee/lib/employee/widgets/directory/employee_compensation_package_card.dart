import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_compensation_models.dart';
import 'employee_compensation_tiles.dart';

class EmployeeCompensationSummaryStrip extends StatelessWidget {
  final EmployeeCompensationPackage package;
  final EmployeeCompensationReviewSummary summary;

  const EmployeeCompensationSummaryStrip({
    super.key,
    required this.package,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(
          label: 'Base',
          value: formatCompensationMoney(
            package.baseSalary,
            package.currencyCode,
          ),
        ),
        HrisMetricStripItem(
          label: 'Compa',
          value: formatCompensationPercent(package.compaRatio),
        ),
        HrisMetricStripItem(
          label: 'Pending',
          value: formatCompensationMoney(
            summary.pendingAnnualBudget,
            package.currencyCode,
          ),
        ),
      ],
    );
  }
}

class EmployeeCompensationPackageCard extends StatelessWidget {
  final EmployeeCompensationPackage package;
  final DateTime asOfDate;

  const EmployeeCompensationPackageCard({
    super.key,
    required this.package,
    required this.asOfDate,
  });

  @override
  Widget build(BuildContext context) {
    final isDue = package.isReviewDue(asOfDate);
    final isDueSoon = package.isReviewDueSoon(asOfDate);
    final color =
        isDue
            ? const Color(0xFFB91C1C)
            : isDueSoon
            ? const Color(0xFFB45309)
            : const Color(0xFF15803D);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${package.payCycle} payroll band',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              HrisStatusPill(
                label:
                    isDue
                        ? 'Review due'
                        : isDueSoon
                        ? 'Due soon'
                        : 'On track',
                color: color,
              ),
            ],
          ),
          const SizedBox(height: 10),
          HrisProgressBar(
            value: package.bandPosition,
            color: HrisColors.primary,
            label:
                'Band position ${(package.bandPosition * 100).round()}% of range',
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _PackageChip(
                label: 'Min',
                value: formatCompensationMoney(
                  package.bandMin,
                  package.currencyCode,
                ),
              ),
              _PackageChip(
                label: 'Mid',
                value: formatCompensationMoney(
                  package.bandMid,
                  package.currencyCode,
                ),
              ),
              _PackageChip(
                label: 'Max',
                value: formatCompensationMoney(
                  package.bandMax,
                  package.currencyCode,
                ),
              ),
              _PackageChip(
                label: 'Next review',
                value: DateFormat('MMM d').format(package.nextReviewDate),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PackageChip extends StatelessWidget {
  final String label;
  final String value;

  const _PackageChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 116),
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
            label,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: HrisColors.muted),
          ),
          Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
