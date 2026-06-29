enum EmployeeTimesheetEntryStatus {
  draft('Draft'),
  submitted('Submitted'),
  approved('Approved'),
  payrollReady('Payroll ready'),
  rejected('Rejected');

  final String label;

  const EmployeeTimesheetEntryStatus(this.label);
}

enum EmployeeTimekeepingExceptionType {
  lateArrival('Late arrival'),
  missingClockOut('Missing clock-out'),
  overtime('Overtime'),
  breakViolation('Break violation'),
  absence('Absence');

  final String label;

  const EmployeeTimekeepingExceptionType(this.label);
}

enum EmployeeTimekeepingExceptionSeverity {
  critical('Critical'),
  high('High'),
  medium('Medium'),
  low('Low');

  final String label;

  const EmployeeTimekeepingExceptionSeverity(this.label);
}

enum EmployeeTimekeepingExceptionStatus {
  open('Open'),
  inReview('In review'),
  resolved('Resolved'),
  waived('Waived');

  final String label;

  const EmployeeTimekeepingExceptionStatus(this.label);
}

class EmployeeTimesheetEntry {
  final String id;
  final String employeeId;
  final DateTime workDate;
  final double scheduledHours;
  final double regularHours;
  final double overtimeHours;
  final int breakMinutes;
  final EmployeeTimesheetEntryStatus status;
  final String approvedBy;
  final String note;

  const EmployeeTimesheetEntry({
    required this.id,
    required this.employeeId,
    required this.workDate,
    required this.scheduledHours,
    required this.regularHours,
    required this.overtimeHours,
    required this.breakMinutes,
    required this.status,
    required this.approvedBy,
    required this.note,
  });

  double get totalHours => regularHours + overtimeHours;

  double get varianceHours => totalHours - scheduledHours;

  bool get hasOvertime => overtimeHours > 0;

  bool get isApproved => status == EmployeeTimesheetEntryStatus.approved;

  bool get isPayrollReady {
    return status == EmployeeTimesheetEntryStatus.payrollReady;
  }

  bool get isClosed => isApproved || isPayrollReady;

  bool get needsApproval {
    return status == EmployeeTimesheetEntryStatus.submitted ||
        status == EmployeeTimesheetEntryStatus.rejected;
  }

  EmployeeTimesheetEntry copyWith({
    double? regularHours,
    double? overtimeHours,
    int? breakMinutes,
    EmployeeTimesheetEntryStatus? status,
    String? approvedBy,
    String? note,
  }) {
    return EmployeeTimesheetEntry(
      id: id,
      employeeId: employeeId,
      workDate: _dateOnly(workDate),
      scheduledHours: scheduledHours,
      regularHours: (regularHours ?? this.regularHours).clamp(0, 24).toDouble(),
      overtimeHours:
          (overtimeHours ?? this.overtimeHours).clamp(0, 16).toDouble(),
      breakMinutes: (breakMinutes ?? this.breakMinutes).clamp(0, 240).toInt(),
      status: status ?? this.status,
      approvedBy: approvedBy ?? this.approvedBy,
      note: note ?? this.note,
    );
  }
}

class EmployeeTimekeepingException {
  final String id;
  final String employeeId;
  final EmployeeTimekeepingExceptionType type;
  final DateTime workDate;
  final EmployeeTimekeepingExceptionSeverity severity;
  final EmployeeTimekeepingExceptionStatus status;
  final String owner;
  final int minutesImpact;
  final bool payrollImpact;
  final String note;

  const EmployeeTimekeepingException({
    required this.id,
    required this.employeeId,
    required this.type,
    required this.workDate,
    required this.severity,
    required this.status,
    required this.owner,
    required this.minutesImpact,
    required this.payrollImpact,
    required this.note,
  });

  bool get isOpen {
    return status == EmployeeTimekeepingExceptionStatus.open ||
        status == EmployeeTimekeepingExceptionStatus.inReview;
  }

  bool get isClosed {
    return status == EmployeeTimekeepingExceptionStatus.resolved ||
        status == EmployeeTimekeepingExceptionStatus.waived;
  }

  bool get isHighSeverity {
    return severity == EmployeeTimekeepingExceptionSeverity.critical ||
        severity == EmployeeTimekeepingExceptionSeverity.high;
  }

  bool isOverdue(DateTime asOfDate) {
    return isOpen &&
        workDate.isBefore(
          _dateOnly(asOfDate).subtract(const Duration(days: 2)),
        );
  }

  bool needsAttention(DateTime asOfDate) {
    return isOpen && (payrollImpact || isHighSeverity || isOverdue(asOfDate));
  }

  EmployeeTimekeepingException copyWith({
    EmployeeTimekeepingExceptionSeverity? severity,
    EmployeeTimekeepingExceptionStatus? status,
    String? owner,
    int? minutesImpact,
    bool? payrollImpact,
    String? note,
  }) {
    return EmployeeTimekeepingException(
      id: id,
      employeeId: employeeId,
      type: type,
      workDate: _dateOnly(workDate),
      severity: severity ?? this.severity,
      status: status ?? this.status,
      owner: owner ?? this.owner,
      minutesImpact:
          (minutesImpact ?? this.minutesImpact).clamp(0, 720).toInt(),
      payrollImpact: payrollImpact ?? this.payrollImpact,
      note: note ?? this.note,
    );
  }
}

class EmployeeTimekeepingProfile {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final DateTime periodStart;
  final DateTime periodEnd;
  final DateTime payrollCutoffDate;
  final List<EmployeeTimesheetEntry> entries;
  final List<EmployeeTimekeepingException> exceptions;

  const EmployeeTimekeepingProfile({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.periodStart,
    required this.periodEnd,
    required this.payrollCutoffDate,
    required this.entries,
    required this.exceptions,
  });

  EmployeeTimekeepingProfile copyWith({
    List<EmployeeTimesheetEntry>? entries,
    List<EmployeeTimekeepingException>? exceptions,
  }) {
    return EmployeeTimekeepingProfile(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      periodStart: periodStart,
      periodEnd: periodEnd,
      payrollCutoffDate: payrollCutoffDate,
      entries: entries ?? this.entries,
      exceptions: exceptions ?? this.exceptions,
    );
  }

  List<EmployeeTimesheetEntry> get sortedEntries {
    final sorted = [...entries];
    sorted.sort((a, b) => b.workDate.compareTo(a.workDate));
    return sorted;
  }

  List<EmployeeTimekeepingException> get sortedExceptions {
    final sorted = [...exceptions];
    sorted.sort((a, b) {
      final aAttention = a.needsAttention(asOfDate);
      final bAttention = b.needsAttention(asOfDate);
      if (aAttention != bAttention) return aAttention ? -1 : 1;
      return b.workDate.compareTo(a.workDate);
    });
    return sorted;
  }

  double get totalRegularHours {
    return entries.fold<double>(
      0,
      (total, entry) => total + entry.regularHours,
    );
  }

  double get totalOvertimeHours {
    return entries.fold<double>(
      0,
      (total, entry) => total + entry.overtimeHours,
    );
  }

  int get submittedEntryCount {
    return entries
        .where(
          (entry) => entry.status == EmployeeTimesheetEntryStatus.submitted,
        )
        .length;
  }

  int get rejectedEntryCount {
    return entries
        .where((entry) => entry.status == EmployeeTimesheetEntryStatus.rejected)
        .length;
  }

  int get payrollReadyCount {
    return entries.where((entry) => entry.isPayrollReady).length;
  }

  int get openExceptionCount {
    return exceptions.where((exception) => exception.isOpen).length;
  }

  int get payrollBlockingExceptionCount {
    return exceptions
        .where((exception) => exception.isOpen && exception.payrollImpact)
        .length;
  }

  int get overdueExceptionCount {
    return exceptions
        .where((exception) => exception.isOverdue(asOfDate))
        .length;
  }

  int get attentionCount {
    return submittedEntryCount +
        rejectedEntryCount +
        payrollBlockingExceptionCount +
        overdueExceptionCount;
  }

  bool get isReadyForPayroll {
    return payrollBlockingExceptionCount == 0 &&
        rejectedEntryCount == 0 &&
        submittedEntryCount == 0 &&
        entries.every((entry) => entry.isClosed);
  }

  String get nextAction {
    if (payrollBlockingExceptionCount > 0) {
      return 'Resolve $payrollBlockingExceptionCount payroll-blocking exception${payrollBlockingExceptionCount == 1 ? '' : 's'}.';
    }
    if (overdueExceptionCount > 0) {
      return 'Review $overdueExceptionCount overdue timekeeping exception${overdueExceptionCount == 1 ? '' : 's'}.';
    }
    if (rejectedEntryCount > 0) {
      return 'Correct $rejectedEntryCount rejected timesheet entr${rejectedEntryCount == 1 ? 'y' : 'ies'}.';
    }
    if (submittedEntryCount > 0) {
      return 'Approve $submittedEntryCount submitted timesheet entr${submittedEntryCount == 1 ? 'y' : 'ies'}.';
    }
    if (isReadyForPayroll) {
      return 'Timesheet period is payroll ready.';
    }
    return 'Review timesheet period before payroll cutoff.';
  }
}

class EmployeeTimekeepingExceptionDraft {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final EmployeeTimekeepingExceptionType type;
  final DateTime? workDate;
  final EmployeeTimekeepingExceptionSeverity severity;
  final String owner;
  final int minutesImpact;
  final bool payrollImpact;
  final String note;

  const EmployeeTimekeepingExceptionDraft({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.type,
    required this.workDate,
    required this.severity,
    required this.owner,
    required this.minutesImpact,
    required this.payrollImpact,
    required this.note,
  });

  EmployeeTimekeepingExceptionDraft copyWith({
    EmployeeTimekeepingExceptionType? type,
    DateTime? workDate,
    EmployeeTimekeepingExceptionSeverity? severity,
    String? owner,
    int? minutesImpact,
    bool? payrollImpact,
    String? note,
  }) {
    return EmployeeTimekeepingExceptionDraft(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      type: type ?? this.type,
      workDate: workDate ?? this.workDate,
      severity: severity ?? this.severity,
      owner: owner ?? this.owner,
      minutesImpact:
          (minutesImpact ?? this.minutesImpact).clamp(0, 720).toInt(),
      payrollImpact: payrollImpact ?? this.payrollImpact,
      note: note ?? this.note,
    );
  }

  List<String> get validationErrors {
    final errors = <String>[];
    if (owner.trim().length < 3) {
      errors.add('Owner is required');
    }
    if (note.trim().length < 10) {
      errors.add('Exception note must be at least 10 characters');
    }
    if (workDate == null) {
      errors.add('Work date is required');
    } else if (workDate!.isAfter(asOfDate)) {
      errors.add('Work date cannot be in the future');
    }
    return errors;
  }

  bool get isReadyToAdd => validationErrors.isEmpty;

  double get completionRatio {
    var complete = 0;
    if (owner.trim().length >= 3) complete++;
    if (note.trim().length >= 10) complete++;
    if (workDate != null && !workDate!.isAfter(asOfDate)) complete++;
    if (minutesImpact > 0) complete++;
    return complete / 4;
  }

  EmployeeTimekeepingException toException({required String id}) {
    if (!isReadyToAdd) {
      throw StateError(validationErrors.first);
    }

    return EmployeeTimekeepingException(
      id: id,
      employeeId: employeeId,
      type: type,
      workDate: _dateOnly(workDate!),
      severity: severity,
      status: EmployeeTimekeepingExceptionStatus.open,
      owner: owner.trim(),
      minutesImpact: minutesImpact,
      payrollImpact: payrollImpact,
      note: note.trim(),
    );
  }
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
