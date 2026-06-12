import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../states/attendance_provider.dart';
import '../states/user_provider.dart';
import '../widgets/attendance_clock_panel.dart';
import '../widgets/attendance_history_panel.dart';
import '../widgets/attendance_summary_grid.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  Timer? _clockTimer;

  @override
  void initState() {
    super.initState();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      ref.read(currentTimeProvider.notifier).state = DateTime.now();
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final currentTime = ref.watch(currentTimeProvider);
    final isCheckedIn = ref.watch(isCheckedInProvider);
    final todayRecord = ref.watch(todayAttendanceProvider);
    final attendanceHistory = ref.watch(attendanceRecordsProvider);
    final summary = ref.watch(attendanceSummaryProvider);

    return Scaffold(
      backgroundColor: HrisColors.pageBackground,
      appBar: AppBar(
        title: const Text('Attendance'),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No attendance alerts right now')),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AttendanceClockPanel(
                user: currentUser,
                currentTime: currentTime,
                todayRecord: todayRecord,
                isCheckedIn: isCheckedIn,
                onToggle: () {
                  if (isCheckedIn) {
                    ref.read(attendanceRecordsProvider.notifier).checkOut();
                  } else {
                    ref.read(attendanceRecordsProvider.notifier).checkIn();
                  }
                },
              ),
              const SizedBox(height: 16),
              AttendanceSummaryGrid(summary: summary),
              const SizedBox(height: 16),
              AttendanceHistoryPanel(records: attendanceHistory),
            ],
          ),
        ),
      ),
    );
  }
}
