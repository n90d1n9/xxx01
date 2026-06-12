import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/attendance_seed_data.dart';
import '../models/attendance_record.dart';

final attendanceRecordsProvider =
    StateNotifierProvider<AttendanceNotifier, List<AttendanceRecord>>((ref) {
      return AttendanceNotifier(
        initialRecords: buildInitialAttendanceRecords(
          ref.watch(attendanceSeedDateProvider),
        ),
      );
    });

final todayAttendanceProvider = Provider<AttendanceRecord?>((ref) {
  final records = ref.watch(attendanceRecordsProvider);
  final today = ref.watch(currentTimeProvider);

  return records
      .where(
        (record) =>
            record.checkInTime.year == today.year &&
            record.checkInTime.month == today.month &&
            record.checkInTime.day == today.day,
      )
      .firstOrNull;
});

final isCheckedInProvider = Provider<bool>((ref) {
  return ref.watch(todayAttendanceProvider)?.isOpen ?? false;
});

final currentTimeProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

final attendanceSeedDateProvider = Provider<DateTime>((ref) {
  return DateTime.now();
});

final attendanceSummaryProvider = Provider<AttendanceSummary>((ref) {
  return AttendanceSummary.fromRecords(ref.watch(attendanceRecordsProvider));
});

final attendanceRiskSummaryProvider = Provider<AttendanceRiskSummary>((ref) {
  return AttendanceRiskSummary.fromRecords(
    ref.watch(attendanceRecordsProvider),
  );
});

// Notifiers
class AttendanceNotifier extends StateNotifier<List<AttendanceRecord>> {
  AttendanceNotifier({required List<AttendanceRecord> initialRecords})
    : super(initialRecords);

  void checkIn({DateTime? at}) {
    final now = at ?? DateTime.now();
    final isLate = now.hour > 9 || (now.hour == 9 && now.minute > 15);

    state = [
      ...state,
      AttendanceRecord(
        id: 'a${state.length + 1}',
        checkInTime: now,
        status: isLate ? 'late' : 'present',
      ),
    ];
  }

  void checkOut({DateTime? at}) {
    final now = at ?? DateTime.now();
    final todayRecord = state.lastWhere(
      (record) => _isSameDay(record.checkInTime, now) && record.isOpen,
      orElse: () => throw Exception('No check-in record found for today'),
    );

    state = [
      ...state.where((record) => record.id != todayRecord.id),
      AttendanceRecord(
        id: todayRecord.id,
        checkInTime: todayRecord.checkInTime,
        checkOutTime: now,
        status: todayRecord.status,
      ),
    ];
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
