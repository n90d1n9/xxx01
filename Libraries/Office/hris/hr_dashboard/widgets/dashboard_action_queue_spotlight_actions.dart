import 'package:flutter/material.dart';

import '../models/dashboard_action_queue_insight.dart';
import '../models/dashboard_action_summary.dart';

class DashboardActionQueueSpotlightActions extends StatelessWidget {
  final DashboardActionQueueInsight insight;
  final ValueChanged<String>? onFocusOwner;
  final ValueChanged<DashboardActionPriority>? onFocusPriority;

  const DashboardActionQueueSpotlightActions({
    super.key,
    required this.insight,
    this.onFocusOwner,
    this.onFocusPriority,
  });

  bool get hasActions {
    return (insight.ownerLabel != null && onFocusOwner != null) ||
        (insight.priority != null && onFocusPriority != null);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (insight.priority != null && onFocusPriority != null)
          OutlinedButton.icon(
            onPressed: () => onFocusPriority!(insight.priority!),
            icon: const Icon(Icons.flag_outlined, size: 18),
            label: const Text('Focus priority'),
          ),
        if (insight.ownerLabel != null && onFocusOwner != null)
          OutlinedButton.icon(
            onPressed: () => onFocusOwner!(insight.ownerLabel!),
            icon: const Icon(Icons.account_circle_outlined, size: 18),
            label: const Text('Focus owner'),
          ),
      ],
    );
  }
}
