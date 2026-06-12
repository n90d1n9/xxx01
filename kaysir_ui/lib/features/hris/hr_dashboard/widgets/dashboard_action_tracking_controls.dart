import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/dashboard_action_status.dart';
import '../models/dashboard_action_summary.dart';
import 'dashboard_action_style.dart';

class DashboardActionStatusPill extends StatelessWidget {
  final DashboardActionStatus status;

  const DashboardActionStatusPill({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return HrisStatusPill(
      label: status.label,
      color: dashboardActionStatusColor(status),
    );
  }
}

class DashboardActionTrackingControls extends StatelessWidget {
  final DashboardActionRecommendation item;
  final DashboardActionStatus status;
  final ValueChanged<DashboardActionRecommendation>? onStart;
  final ValueChanged<DashboardActionRecommendation>? onComplete;
  final ValueChanged<DashboardActionRecommendation>? onReopen;

  const DashboardActionTrackingControls({
    super.key,
    required this.item,
    required this.status,
    this.onStart,
    this.onComplete,
    this.onReopen,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (status == DashboardActionStatus.open)
          IconButton(
            tooltip: 'Start ${item.title}',
            onPressed: onStart == null ? null : () => onStart!(item),
            icon: const Icon(Icons.play_arrow_rounded),
          ),
        if (status == DashboardActionStatus.inProgress)
          IconButton.filledTonal(
            tooltip: 'Mark ${item.title} done',
            onPressed: onComplete == null ? null : () => onComplete!(item),
            icon: const Icon(Icons.check_rounded),
          ),
        if (status == DashboardActionStatus.done)
          IconButton(
            tooltip: 'Reopen ${item.title}',
            onPressed: onReopen == null ? null : () => onReopen!(item),
            icon: const Icon(Icons.undo_rounded),
          ),
      ],
    );
  }
}
