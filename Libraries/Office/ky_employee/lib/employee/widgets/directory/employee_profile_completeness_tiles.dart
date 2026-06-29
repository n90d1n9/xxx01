import 'package:flutter/material.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_profile_completeness_models.dart';
import 'employee_profile_completeness_styles.dart';

class EmployeeProfileCompletenessScoreCard extends StatelessWidget {
  final EmployeeProfileCompletenessProfile profile;

  const EmployeeProfileCompletenessScoreCard({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final scoreColor = employeeProfileCompletenessScoreColor(profile.score);

    return HrisListSurface(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final scoreBlock = Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: scoreColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${profile.score}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: scoreColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HrisStatusPill(
                      label: employeeProfileCompletenessScoreLabel(
                        profile.score,
                      ),
                      color: scoreColor,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      profile.nextAction,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );

          final progress = HrisProgressBar(
            value: profile.score / 100,
            color: scoreColor,
            label:
                '${profile.completeCount}/${profile.items.length} areas complete',
          );

          if (constraints.maxWidth < 700) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [scoreBlock, const SizedBox(height: 12), progress],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: scoreBlock),
              const SizedBox(width: 16),
              Expanded(child: progress),
            ],
          );
        },
      ),
    );
  }
}

class EmployeeProfileCompletenessSummaryStrip extends StatelessWidget {
  final EmployeeProfileCompletenessProfile profile;

  const EmployeeProfileCompletenessSummaryStrip({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(
          label: 'Complete',
          value: '${profile.completeCount}',
        ),
        HrisMetricStripItem(label: 'Open', value: '${profile.openCount}'),
        HrisMetricStripItem(
          label: 'Action',
          value: '${profile.actionRequiredCount}',
        ),
        HrisMetricStripItem(label: 'Missing', value: '${profile.missingCount}'),
      ],
    );
  }
}

class EmployeeProfileCompletenessItemTile extends StatelessWidget {
  final EmployeeProfileCompletenessItem item;

  const EmployeeProfileCompletenessItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final color = employeeProfileCompletenessStatusColor(item.status);

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
              employeeProfileCompletenessAreaIcon(item.area),
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
                        item.area.label,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: HrisColors.ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    HrisStatusPill(label: item.status.label, color: color),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.detail,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
                if (item.isOpen) ...[
                  const SizedBox(height: 6),
                  Text(
                    item.nextAction,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: HrisColors.ink,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
