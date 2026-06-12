import 'employee.dart';
import 'shift.dart';

class EmployeeDetailSummary {
  final bool isActive;
  final int tenureMonths;
  final int totalShifts;
  final int scheduledShifts;
  final int inProgressShifts;
  final int completedShifts;
  final int missedShifts;
  final String primaryLocation;

  const EmployeeDetailSummary({
    required this.isActive,
    required this.tenureMonths,
    required this.totalShifts,
    required this.scheduledShifts,
    required this.inProgressShifts,
    required this.completedShifts,
    required this.missedShifts,
    required this.primaryLocation,
  });

  factory EmployeeDetailSummary.from({
    required Employee employee,
    required List<Shift> shifts,
    required DateTime asOfDate,
  }) {
    final locationCounts = <String, int>{};
    for (final shift in shifts) {
      locationCounts[shift.location] =
          (locationCounts[shift.location] ?? 0) + 1;
    }

    final primaryLocation =
        locationCounts.entries.isEmpty
            ? 'Not scheduled'
            : locationCounts.entries
                .reduce((best, item) => item.value > best.value ? item : best)
                .key;

    return EmployeeDetailSummary(
      isActive: employee.isActive,
      tenureMonths: _tenureMonths(employee.hireDate, asOfDate),
      totalShifts: shifts.length,
      scheduledShifts:
          shifts.where((shift) => shift.status == 'scheduled').length,
      inProgressShifts:
          shifts.where((shift) => shift.status == 'in_progress').length,
      completedShifts:
          shifts.where((shift) => shift.status == 'completed').length,
      missedShifts: shifts.where((shift) => shift.status == 'missed').length,
      primaryLocation: primaryLocation,
    );
  }
}

int _tenureMonths(DateTime? hireDate, DateTime asOfDate) {
  if (hireDate == null) return 0;
  final monthDelta =
      (asOfDate.year - hireDate.year) * 12 + asOfDate.month - hireDate.month;
  return asOfDate.day >= hireDate.day ? monthDelta : monthDelta - 1;
}
