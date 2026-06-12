import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/dashboard_action_detail.dart';
import 'dashboard_action_style.dart';

class DashboardActionDetailHeader extends StatelessWidget {
  final DashboardActionDetail detail;

  const DashboardActionDetailHeader({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    final action = detail.action;
    final color = dashboardActionPriorityColor(action.priority);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(action.icon, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Action detail',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: HrisColors.muted,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                action.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: HrisColors.ink,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  HrisStatusPill(label: action.priority.label, color: color),
                  HrisStatusPill(
                    label: detail.status.label,
                    color: dashboardActionStatusColor(detail.status),
                  ),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Close action detail',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close_rounded),
        ),
      ],
    );
  }
}
