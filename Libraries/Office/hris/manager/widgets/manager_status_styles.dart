import 'package:flutter/material.dart';

import '../models/manager_models.dart';

Color managerTeamStatusColor(TeamMemberStatus status) {
  switch (status) {
    case TeamMemberStatus.available:
      return const Color(0xFF15803D);
    case TeamMemberStatus.busy:
      return const Color(0xFFD97706);
    case TeamMemberStatus.onLeave:
      return const Color(0xFF6D28D9);
  }
}

Color managerRequestPriorityColor(ManagerRequestPriority priority) {
  switch (priority) {
    case ManagerRequestPriority.standard:
      return const Color(0xFF2563EB);
    case ManagerRequestPriority.urgent:
      return const Color(0xFFDC2626);
  }
}
