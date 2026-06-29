import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/compensation_models.dart';
import 'compensation_meta_label.dart';
import 'compensation_status_styles.dart';

class BenefitEnrollmentPanel extends StatelessWidget {
  final List<BenefitEnrollment> benefits;

  const BenefitEnrollmentPanel({super.key, required this.benefits});

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      title: 'Benefits Enrollment',
      icon: Icons.health_and_safety_outlined,
      subtitle: '${benefits.length} enrollments',
      emptyMessage: 'No benefit enrollments match filters',
      children:
          benefits.map((benefit) => _BenefitTile(benefit: benefit)).toList(),
    );
  }
}

class _BenefitTile extends StatelessWidget {
  final BenefitEnrollment benefit;

  const _BenefitTile({required this.benefit});

  @override
  Widget build(BuildContext context) {
    final color = benefitStatusColor(benefit.status);

    return HrisListSurface(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.health_and_safety_outlined, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        benefit.employeeName,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    HrisStatusPill(
                      label: benefitStatusLabel(benefit.status),
                      color: color,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${benefit.planName} - ${benefit.coverage}',
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
                const SizedBox(height: 8),
                CompensationMetaLabel(
                  icon: Icons.calendar_today_outlined,
                  label:
                      'Deadline ${DateFormat('MMM d').format(benefit.deadline)}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
