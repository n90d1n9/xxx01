import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/attendance_record.dart';
import 'attendance_status_styles.dart';

class AttendanceSummaryGrid extends StatelessWidget {
  final AttendanceSummary summary;

  const AttendanceSummaryGrid({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return HrisSummaryGrid(
      metrics: [
        HrisSummaryMetric(
          title: 'Present',
          value: '${summary.presentCount}',
          detail: 'on-time records',
          icon: Icons.check_circle_outline,
          color: const Color(0xFF059669),
        ),
        HrisSummaryMetric(
          title: 'Late',
          value: '${summary.lateCount}',
          detail: 'needs follow-up',
          icon: Icons.access_time,
          color: const Color(0xFFD97706),
        ),
        HrisSummaryMetric(
          title: 'Open',
          value: '${summary.openCount}',
          detail: 'active sessions',
          icon: Icons.login,
          color: const Color(0xFF2563EB),
        ),
        HrisSummaryMetric(
          title: 'Avg hours',
          value: attendanceDurationLabel(summary.averageMinutes.round()),
          detail: '${summary.completedCount} completed shifts',
          icon: Icons.timelapse_outlined,
          color: const Color(0xFF7C3AED),
        ),
      ],
    );
  }
}
