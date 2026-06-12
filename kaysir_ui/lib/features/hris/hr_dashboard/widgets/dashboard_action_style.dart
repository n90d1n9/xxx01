import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/dashboard_action_status.dart';
import '../models/dashboard_action_summary.dart';

Color dashboardActionPriorityColor(DashboardActionPriority priority) {
  return switch (priority) {
    DashboardActionPriority.critical => Colors.red,
    DashboardActionPriority.high => Colors.orange,
    DashboardActionPriority.medium => HrisColors.primary,
    DashboardActionPriority.low => Colors.green,
  };
}

Color dashboardActionStatusColor(DashboardActionStatus status) {
  return switch (status) {
    DashboardActionStatus.open => HrisColors.muted,
    DashboardActionStatus.inProgress => HrisColors.primary,
    DashboardActionStatus.done => Colors.green,
  };
}
