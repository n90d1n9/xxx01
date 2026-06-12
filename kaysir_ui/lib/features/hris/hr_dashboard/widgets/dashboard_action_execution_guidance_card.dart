import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/dashboard_action_execution_guidance.dart';
import '../models/dashboard_action_status.dart';
import 'dashboard_action_style.dart';

class DashboardActionExecutionGuidanceCard extends StatelessWidget {
  final DashboardActionExecutionGuidance guidance;
  final DashboardActionStatus status;

  const DashboardActionExecutionGuidanceCard({
    super.key,
    required this.guidance,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final color = dashboardActionStatusColor(status);

    return HrisListSurface(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_iconFor(status), color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    HrisStatusPill(label: guidance.label, color: color),
                    if (guidance.activeStepNumber != null)
                      Text(
                        'Step ${guidance.activeStepNumber}',
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(color: HrisColors.muted),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  guidance.title,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  guidance.description,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(DashboardActionStatus status) {
    return switch (status) {
      DashboardActionStatus.open => Icons.play_arrow_rounded,
      DashboardActionStatus.inProgress => Icons.route_rounded,
      DashboardActionStatus.done => Icons.verified_rounded,
    };
  }
}
