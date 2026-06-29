import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../../models/employee_detail_summary.dart';

class EmployeeDetailSummaryGrid extends StatelessWidget {
  final EmployeeDetailSummary summary;

  const EmployeeDetailSummaryGrid({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return HrisSummaryGrid(
      metrics: [
        HrisSummaryMetric(
          title: 'Employment',
          value: summary.isActive ? 'Active' : 'Inactive',
          detail: '${summary.tenureMonths} months tenure',
          icon: Icons.verified_user_outlined,
          color:
              summary.isActive
                  ? const Color(0xFF15803D)
                  : const Color(0xFF6B7280),
        ),
        HrisSummaryMetric(
          title: 'Shift load',
          value: '${summary.totalShifts}',
          detail: '${summary.scheduledShifts} scheduled',
          icon: Icons.event_note_outlined,
          color: HrisColors.primary,
        ),
        HrisSummaryMetric(
          title: 'Completed',
          value: '${summary.completedShifts}',
          detail: '${summary.missedShifts} missed shifts',
          icon: Icons.task_alt_outlined,
          color: const Color(0xFF0F766E),
        ),
        HrisSummaryMetric(
          title: 'Primary site',
          value: summary.primaryLocation,
          detail: '${summary.inProgressShifts} currently in progress',
          icon: Icons.location_on_outlined,
          color: const Color(0xFFD97706),
        ),
      ],
    );
  }
}
