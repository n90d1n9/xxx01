import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/dashboard_action_detail.dart';
import '../models/dashboard_action_status.dart';
import '../models/dashboard_action_summary.dart';
import '../models/dashboard_action_urgency.dart';
import 'dashboard_action_detail_launcher.dart';
import 'dashboard_action_priority_pill.dart';
import 'dashboard_action_recommendation_layouts.dart';
import 'dashboard_action_style.dart';
import 'dashboard_action_tile_elements.dart';
import 'dashboard_action_tracking_controls.dart';
import 'dashboard_action_urgency_chip.dart';

class DashboardActionRecommendationTile extends StatelessWidget {
  final DashboardActionRecommendation item;
  final DashboardActionStatus status;
  final bool isNextUp;
  final bool ownerFocused;
  final bool priorityFocused;
  final bool urgencyFocused;
  final ValueChanged<String>? onFocusOwner;
  final ValueChanged<DashboardActionPriority>? onFocusPriority;
  final ValueChanged<DashboardActionUrgencyTier>? onFocusUrgency;
  final VoidCallback? onClearOwnerFocus;
  final VoidCallback? onClearPriorityFocus;
  final VoidCallback? onClearUrgencyFocus;
  final ValueChanged<DashboardActionRecommendation>? onStart;
  final ValueChanged<DashboardActionRecommendation>? onComplete;
  final ValueChanged<DashboardActionRecommendation>? onReopen;

  const DashboardActionRecommendationTile({
    super.key,
    required this.item,
    required this.status,
    this.isNextUp = false,
    this.ownerFocused = false,
    this.priorityFocused = false,
    this.urgencyFocused = false,
    this.onFocusOwner,
    this.onFocusPriority,
    this.onFocusUrgency,
    this.onClearOwnerFocus,
    this.onClearPriorityFocus,
    this.onClearUrgencyFocus,
    this.onStart,
    this.onComplete,
    this.onReopen,
  });

  @override
  Widget build(BuildContext context) {
    final color = dashboardActionPriorityColor(item.priority);

    return HrisListSurface(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final copy = DashboardActionCopy(
            item: item,
            isNextUp: isNextUp,
            ownerFocused: ownerFocused,
            onOwnerSelected: onFocusOwner,
            onOwnerCleared: onClearOwnerFocus,
          );
          final metric = DashboardActionMetric(item: item, color: color);
          final priorityPill = DashboardActionPriorityPill(
            priority: item.priority,
            color: color,
            selected: priorityFocused,
            onSelected: onFocusPriority,
            onClearSelected: onClearPriorityFocus,
          );
          final detail = DashboardActionDetail.fromRecommendation(
            action: item,
            status: status,
          );
          final statusPill = DashboardActionStatusPill(status: status);
          final urgencyChip = DashboardActionUrgencyChip(
            urgency: DashboardActionUrgency.fromAction(
              action: item,
              status: status,
            ),
            selected: urgencyFocused,
            onSelected: onFocusUrgency,
            onClearSelected: onClearUrgencyFocus,
          );
          final tracker = DashboardActionTrackingControls(
            item: item,
            status: status,
            onStart: onStart,
            onComplete: onComplete,
            onReopen: onReopen,
          );
          final detailsButton = DashboardActionDetailsButton(
            detail: detail,
            onStart: onStart,
            onComplete: onComplete,
            onReopen: onReopen,
          );
          final action = DashboardActionRouteButton(item: item);

          if (constraints.maxWidth < 1120) {
            return DashboardCompactActionLayout(
              item: item,
              color: color,
              copy: copy,
              metric: metric,
              priorityPill: priorityPill,
              statusPill: statusPill,
              urgencyChip: urgencyChip,
              tracker: tracker,
              detailsButton: detailsButton,
              action: action,
            );
          }

          return DashboardWideActionLayout(
            item: item,
            color: color,
            copy: copy,
            metric: metric,
            priorityPill: priorityPill,
            statusPill: statusPill,
            urgencyChip: urgencyChip,
            tracker: tracker,
            detailsButton: detailsButton,
            action: action,
          );
        },
      ),
    );
  }
}
