import 'package:flutter/material.dart';

import '../models/dashboard_action_detail.dart';
import '../models/dashboard_action_summary.dart';
import 'dashboard_action_detail_drawer.dart';

Future<void> showDashboardActionDetailDrawer({
  required BuildContext context,
  required DashboardActionDetail detail,
  ValueChanged<DashboardActionRecommendation>? onStart,
  ValueChanged<DashboardActionRecommendation>? onComplete,
  ValueChanged<DashboardActionRecommendation>? onReopen,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder:
        (context) => DashboardActionDetailDrawer(
          detail: detail,
          onStart: onStart,
          onComplete: onComplete,
          onReopen: onReopen,
        ),
  );
}

class DashboardActionDetailsButton extends StatelessWidget {
  final DashboardActionDetail detail;
  final ValueChanged<DashboardActionRecommendation>? onStart;
  final ValueChanged<DashboardActionRecommendation>? onComplete;
  final ValueChanged<DashboardActionRecommendation>? onReopen;

  const DashboardActionDetailsButton({
    super.key,
    required this.detail,
    this.onStart,
    this.onComplete,
    this.onReopen,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'View ${detail.action.title} details',
      child: TextButton.icon(
        onPressed:
            () => showDashboardActionDetailDrawer(
              context: context,
              detail: detail,
              onStart: onStart,
              onComplete: onComplete,
              onReopen: onReopen,
            ),
        icon: const Icon(Icons.info_outline_rounded, size: 18),
        label: const Text('Details'),
      ),
    );
  }
}
