import '../../employee/models/employee.dart';

enum PayrollAttendanceSignalType {
  overtime('Overtime'),
  lateDeduction('Late deduction'),
  unpaidAbsence('Unpaid absence'),
  shiftPremium('Shift premium');

  final String label;

  const PayrollAttendanceSignalType(this.label);
}

enum PayrollAttendanceBridgeStatus {
  blocked('Blocked'),
  pending('Pending'),
  approved('Approved'),
  applied('Applied');

  final String label;

  const PayrollAttendanceBridgeStatus(this.label);
}

class PayrollAttendanceSignal {
  final String id;
  final int employeeId;
  final PayrollAttendanceSignalType type;
  final DateTime workDate;
  final double units;
  final double rate;
  final String sourceLabel;
  final bool hasManagerApproval;
  final bool hasPayrollEvidence;

  const PayrollAttendanceSignal({
    required this.id,
    required this.employeeId,
    required this.type,
    required this.workDate,
    required this.units,
    required this.rate,
    required this.sourceLabel,
    required this.hasManagerApproval,
    required this.hasPayrollEvidence,
  });
}

class PayrollAttendanceBridgeLine {
  final PayrollAttendanceSignal signal;
  final Employee? employee;
  final bool isApproved;
  final bool isApplied;

  const PayrollAttendanceBridgeLine({
    required this.signal,
    required this.employee,
    required this.isApproved,
    required this.isApplied,
  });

  String get id => signal.id;

  String get employeeName => employee?.name ?? 'Unknown employee';

  String get position => employee?.position ?? 'Employee';

  double get amount {
    final value = signal.units * signal.rate;
    return switch (signal.type) {
      PayrollAttendanceSignalType.lateDeduction ||
      PayrollAttendanceSignalType.unpaidAbsence => -value,
      PayrollAttendanceSignalType.overtime ||
      PayrollAttendanceSignalType.shiftPremium => value,
    };
  }

  List<String> get blockers {
    return [
      if (employee == null) 'Employee is unavailable',
      if (signal.units <= 0) 'Missing attendance units',
      if (signal.rate <= 0) 'Missing payroll rate',
      if (!signal.hasManagerApproval) 'Missing manager approval',
      if (!signal.hasPayrollEvidence) 'Missing payroll evidence',
    ];
  }

  bool get hasBlockers => blockers.isNotEmpty;

  PayrollAttendanceBridgeStatus get status {
    if (hasBlockers) return PayrollAttendanceBridgeStatus.blocked;
    if (isApplied) return PayrollAttendanceBridgeStatus.applied;
    if (isApproved) return PayrollAttendanceBridgeStatus.approved;
    return PayrollAttendanceBridgeStatus.pending;
  }

  bool get canApprove => status == PayrollAttendanceBridgeStatus.pending;

  bool get canApply => status == PayrollAttendanceBridgeStatus.approved;

  String get nextAction {
    if (hasBlockers) return blockers.first;
    if (isApplied) return 'Attendance impact is applied to payroll.';
    if (isApproved) return 'Apply approved attendance impact to payroll.';
    return 'Review and approve attendance impact.';
  }
}

class PayrollAttendanceBridgeSummary {
  final List<PayrollAttendanceBridgeLine> lines;
  final int? selectedEmployeeId;

  const PayrollAttendanceBridgeSummary({
    required this.lines,
    required this.selectedEmployeeId,
  });

  factory PayrollAttendanceBridgeSummary.fromSignals({
    required List<PayrollAttendanceSignal> signals,
    required List<Employee> employees,
    required Set<String> approvedSignalIds,
    required Set<String> appliedSignalIds,
    required int? selectedEmployeeId,
  }) {
    return PayrollAttendanceBridgeSummary(
      selectedEmployeeId: selectedEmployeeId,
      lines:
          signals
              .map(
                (signal) => PayrollAttendanceBridgeLine(
                  signal: signal,
                  employee: _findEmployee(employees, signal.employeeId),
                  isApproved: approvedSignalIds.contains(signal.id),
                  isApplied: appliedSignalIds.contains(signal.id),
                ),
              )
              .toList(),
    );
  }

  List<PayrollAttendanceBridgeLine> get visibleLines {
    if (selectedEmployeeId == null) return lines;
    return lines
        .where((line) => line.signal.employeeId == selectedEmployeeId)
        .toList();
  }

  int get blockedCount => _count(PayrollAttendanceBridgeStatus.blocked);

  int get pendingCount => _count(PayrollAttendanceBridgeStatus.pending);

  int get approvedCount => _count(PayrollAttendanceBridgeStatus.approved);

  int get appliedCount => _count(PayrollAttendanceBridgeStatus.applied);

  double get totalImpact => lines.fold(0, (total, line) => total + line.amount);

  double get appliedImpact => lines
      .where((line) => line.status == PayrollAttendanceBridgeStatus.applied)
      .fold(0, (total, line) => total + line.amount);

  double get readinessRate {
    if (lines.isEmpty) return 0;
    return (approvedCount + appliedCount) / lines.length;
  }

  bool get canApprove => lines.any((line) => line.canApprove);

  bool get canApply => lines.any((line) => line.canApply);

  PayrollAttendanceBridgeStatus get status {
    if (blockedCount > 0) return PayrollAttendanceBridgeStatus.blocked;
    if (pendingCount > 0) return PayrollAttendanceBridgeStatus.pending;
    if (approvedCount > 0) return PayrollAttendanceBridgeStatus.approved;
    return PayrollAttendanceBridgeStatus.applied;
  }

  String get nextAction {
    if (blockedCount > 0) {
      return 'Resolve $blockedCount attendance payroll blockers.';
    }
    if (pendingCount > 0) {
      return 'Approve $pendingCount attendance payroll impacts.';
    }
    if (approvedCount > 0) {
      return 'Apply $approvedCount attendance impacts to payroll.';
    }
    return 'All attendance payroll impacts are applied.';
  }

  int _count(PayrollAttendanceBridgeStatus target) {
    return lines.where((line) => line.status == target).length;
  }

  static Employee? _findEmployee(List<Employee> employees, int employeeId) {
    for (final employee in employees) {
      if (employee.id == employeeId) return employee;
    }
    return null;
  }
}
