import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/dashboard_action_owner_summary.dart';
import '../models/dashboard_action_queue_view.dart';
import '../models/dashboard_action_status.dart';
import '../models/dashboard_action_summary.dart';
import '../models/dashboard_action_urgency.dart';
import 'dashboard_action_queue_sections.dart';

class DashboardActionSummaryPanel extends StatelessWidget {
  final DashboardActionSummary summary;
  final Map<String, DashboardActionStatus> statuses;
  final bool hideCompleted;
  final String selectedOwner;
  final DashboardActionPriority? selectedPriority;
  final DashboardActionUrgencyTier? selectedUrgency;
  final ValueChanged<bool>? onHideCompletedChanged;
  final ValueChanged<String>? onOwnerChanged;
  final ValueChanged<DashboardActionPriority?>? onPriorityChanged;
  final ValueChanged<DashboardActionUrgencyTier?>? onUrgencyChanged;
  final ValueChanged<DashboardActionRecommendation>? onStart;
  final ValueChanged<DashboardActionRecommendation>? onComplete;
  final ValueChanged<DashboardActionRecommendation>? onReopen;

  const DashboardActionSummaryPanel({
    super.key,
    required this.summary,
    this.statuses = const {},
    this.hideCompleted = false,
    this.selectedOwner = dashboardActionAllOwners,
    this.selectedPriority,
    this.selectedUrgency,
    this.onHideCompletedChanged,
    this.onOwnerChanged,
    this.onPriorityChanged,
    this.onUrgencyChanged,
    this.onStart,
    this.onComplete,
    this.onReopen,
  });

  @override
  Widget build(BuildContext context) {
    final queue = DashboardActionQueueView.fromSummary(
      summary: summary,
      statuses: statuses,
      hideCompleted: hideCompleted,
      selectedOwner: selectedOwner,
      selectedPriority: selectedPriority,
      selectedUrgency: selectedUrgency,
    );

    return HrisSectionPanel(
      icon: Icons.auto_awesome_motion_outlined,
      title: 'Next best actions',
      subtitle: 'Recommended from risk, hiring, and KPI movement',
      emptyMessage: 'No recommended actions right now',
      children: buildDashboardActionQueueSections(
        queue: queue,
        hideCompleted: hideCompleted,
        onHideCompletedChanged: onHideCompletedChanged,
        onOwnerChanged: onOwnerChanged,
        onPriorityChanged: onPriorityChanged,
        onUrgencyChanged: onUrgencyChanged,
        onStart: onStart,
        onComplete: onComplete,
        onReopen: onReopen,
      ),
    );
  }
}
