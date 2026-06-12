class AttendanceRecord {
  final String id;
  final DateTime checkInTime;
  final DateTime? checkOutTime;
  final String status; // "present", "late", "absent"

  AttendanceRecord({
    required this.id,
    required this.checkInTime,
    this.checkOutTime,
    required this.status,
  });

  bool get isOpen => checkOutTime == null;

  int get durationMinutes {
    final end = checkOutTime;
    if (end == null) return 0;
    final value = end.difference(checkInTime).inMinutes;
    return value < 0 ? 0 : value;
  }
}

class AttendanceSummary {
  final int totalRecords;
  final int presentCount;
  final int lateCount;
  final int absentCount;
  final int openCount;
  final int completedCount;
  final int totalMinutes;

  const AttendanceSummary({
    required this.totalRecords,
    required this.presentCount,
    required this.lateCount,
    required this.absentCount,
    required this.openCount,
    required this.completedCount,
    required this.totalMinutes,
  });

  factory AttendanceSummary.fromRecords(List<AttendanceRecord> records) {
    return AttendanceSummary(
      totalRecords: records.length,
      presentCount:
          records.where((record) => record.status == 'present').length,
      lateCount: records.where((record) => record.status == 'late').length,
      absentCount: records.where((record) => record.status == 'absent').length,
      openCount: records.where((record) => record.isOpen).length,
      completedCount: records.where((record) => !record.isOpen).length,
      totalMinutes: records.fold<int>(
        0,
        (total, record) => total + record.durationMinutes,
      ),
    );
  }

  double get averageMinutes {
    if (completedCount == 0) return 0;
    return totalMinutes / completedCount;
  }
}

class AttendanceRiskSummary {
  final int openRecords;
  final int lateRecords;
  final int absentRecords;
  final int longShifts;
  final int completedRecords;

  const AttendanceRiskSummary({
    required this.openRecords,
    required this.lateRecords,
    required this.absentRecords,
    required this.longShifts,
    required this.completedRecords,
  });

  int get totalRisks => openRecords + lateRecords + absentRecords + longShifts;

  factory AttendanceRiskSummary.fromRecords(List<AttendanceRecord> records) {
    return AttendanceRiskSummary(
      openRecords: records.where((record) => record.isOpen).length,
      lateRecords: records.where((record) => record.status == 'late').length,
      absentRecords:
          records.where((record) => record.status == 'absent').length,
      longShifts:
          records.where((record) => record.durationMinutes > 10 * 60).length,
      completedRecords: records.where((record) => !record.isOpen).length,
    );
  }
}
