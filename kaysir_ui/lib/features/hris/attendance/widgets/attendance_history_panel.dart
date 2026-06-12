import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/attendance_record.dart';
import 'attendance_status_styles.dart';

class AttendanceHistoryPanel extends StatelessWidget {
  final List<AttendanceRecord> records;

  const AttendanceHistoryPanel({super.key, required this.records});

  @override
  Widget build(BuildContext context) {
    final sorted = [...records]
      ..sort((a, b) => b.checkInTime.compareTo(a.checkInTime));

    return HrisSectionPanel(
      title: 'Attendance History',
      icon: Icons.history_outlined,
      subtitle: '${records.length} records',
      emptyMessage: 'No attendance records yet',
      children:
          sorted
              .map((record) => _AttendanceHistoryTile(record: record))
              .toList(),
    );
  }
}

class _AttendanceHistoryTile extends StatelessWidget {
  final AttendanceRecord record;

  const _AttendanceHistoryTile({required this.record});

  @override
  Widget build(BuildContext context) {
    final color = attendanceStatusColor(record.status);
    final checkIn = DateFormat('HH:mm').format(record.checkInTime);
    final checkOut =
        record.checkOutTime == null
            ? '--:--'
            : DateFormat('HH:mm').format(record.checkOutTime!);

    return HrisListSurface(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(attendanceStatusIcon(record.status), color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('MMM d, yyyy').format(record.checkInTime),
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  attendanceStatusLabel(record.status),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$checkIn - $checkOut',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: HrisColors.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                record.isOpen
                    ? 'In progress'
                    : attendanceDurationLabel(record.durationMinutes),
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
