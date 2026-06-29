import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/attendance_record.dart';
import '../states/user_provider.dart';

class AttendanceClockPanel extends StatelessWidget {
  final User user;
  final DateTime currentTime;
  final AttendanceRecord? todayRecord;
  final bool isCheckedIn;
  final VoidCallback onToggle;

  const AttendanceClockPanel({
    super.key,
    required this.user,
    required this.currentTime,
    required this.todayRecord,
    required this.isCheckedIn,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final timeString = DateFormat('HH:mm:ss').format(currentTime);
    final dateString = DateFormat('EEEE, MMMM d, yyyy').format(currentTime);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: hrisPanelDecoration(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 760;
          final userBlock = Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: HrisColors.primary.withValues(alpha: 0.12),
                child: Text(
                  _initials(user.name),
                  style: const TextStyle(
                    color: HrisColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.role,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          );

          final clockBlock = Column(
            crossAxisAlignment:
                isNarrow ? CrossAxisAlignment.start : CrossAxisAlignment.end,
            children: [
              Text(
                timeString,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: HrisColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                dateString,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: HrisColors.muted),
              ),
              if (todayRecord != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Checked in at ${DateFormat('HH:mm').format(todayRecord!.checkInTime)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: HrisColors.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          );

          final action = FilledButton.icon(
            onPressed: onToggle,
            icon: Icon(isCheckedIn ? Icons.logout : Icons.login),
            label: Text(isCheckedIn ? 'Check Out' : 'Check In'),
          );

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                userBlock,
                const SizedBox(height: 18),
                clockBlock,
                const SizedBox(height: 18),
                SizedBox(width: double.infinity, child: action),
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: userBlock),
              const SizedBox(width: 18),
              clockBlock,
              const SizedBox(width: 18),
              action,
            ],
          );
        },
      ),
    );
  }
}

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty || parts.first.isEmpty) return '?';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
      .toUpperCase();
}
