import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/dashboard_action_urgency.dart';

Color dashboardActionUrgencyColor(DashboardActionUrgencyTier tier) {
  return switch (tier) {
    DashboardActionUrgencyTier.now => Colors.red,
    DashboardActionUrgencyTier.soon => Colors.orange,
    DashboardActionUrgencyTier.planned => HrisColors.primary,
    DashboardActionUrgencyTier.closed => Colors.green,
  };
}

IconData dashboardActionUrgencyIcon(DashboardActionUrgencyTier tier) {
  return switch (tier) {
    DashboardActionUrgencyTier.now => Icons.notification_important_outlined,
    DashboardActionUrgencyTier.soon => Icons.schedule_rounded,
    DashboardActionUrgencyTier.planned => Icons.event_available_outlined,
    DashboardActionUrgencyTier.closed => Icons.check_circle_outline_rounded,
  };
}
