import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/dashboard_action_detail.dart';
import '../models/dashboard_action_summary.dart';
import 'dashboard_action_tracking_controls.dart';

class DashboardActionDetailFooter extends StatelessWidget {
  final DashboardActionDetail detail;
  final ValueChanged<DashboardActionRecommendation>? onStart;
  final ValueChanged<DashboardActionRecommendation>? onComplete;
  final ValueChanged<DashboardActionRecommendation>? onReopen;

  const DashboardActionDetailFooter({
    super.key,
    required this.detail,
    this.onStart,
    this.onComplete,
    this.onReopen,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              DashboardActionTrackingControls(
                item: detail.action,
                status: detail.status,
                onStart: onStart,
                onComplete: onComplete,
                onReopen: onReopen,
              ),
              OutlinedButton.icon(
                onPressed:
                    detail.action.route == null
                        ? null
                        : () {
                          final router = GoRouter.of(context);
                          Navigator.of(context).pop();
                          router.go(detail.action.route!);
                        },
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: Text(detail.action.actionLabel),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
