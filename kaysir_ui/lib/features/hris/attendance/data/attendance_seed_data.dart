import '../models/attendance_record.dart';

List<AttendanceRecord> buildInitialAttendanceRecords(DateTime asOfDate) {
  return [
    AttendanceRecord(
      id: 'a1',
      checkInTime: asOfDate.subtract(const Duration(days: 1, hours: 1)),
      checkOutTime: asOfDate.subtract(const Duration(days: 1)),
      status: 'present',
    ),
    AttendanceRecord(
      id: 'a2',
      checkInTime: asOfDate.subtract(const Duration(days: 2, hours: 2)),
      checkOutTime: asOfDate.subtract(const Duration(days: 2)),
      status: 'late',
    ),
  ];
}
