enum EmployeeSchedulePattern {
  standard('Standard'),
  flexible('Flexible'),
  rotating('Rotating'),
  compressed('Compressed');

  final String label;

  const EmployeeSchedulePattern(this.label);
}

enum EmployeeScheduleAdjustmentType {
  shiftChange('Shift change'),
  locationChange('Location change'),
  overtime('Overtime'),
  remoteDay('Remote day');

  final String label;

  const EmployeeScheduleAdjustmentType(this.label);
}

enum EmployeeScheduleAdjustmentStatus {
  pending('Pending'),
  approved('Approved'),
  applied('Applied');

  final String label;

  const EmployeeScheduleAdjustmentStatus(this.label);
}

enum EmployeeAttendanceSignalType {
  lateArrival('Late arrival'),
  absence('Absence'),
  missedClockOut('Missed clock-out'),
  overtimeDrift('Overtime drift');

  final String label;

  const EmployeeAttendanceSignalType(this.label);
}

enum EmployeeAttendanceSignalSeverity {
  low('Low'),
  medium('Medium'),
  high('High');

  final String label;

  const EmployeeAttendanceSignalSeverity(this.label);
}

class EmployeeScheduleAssignment {
  final String employeeId;
  final EmployeeSchedulePattern pattern;
  final List<String> workDays;
  final String startTimeLabel;
  final String endTimeLabel;
  final String location;
  final String timezone;
  final double weeklyHours;
  final DateTime effectiveFrom;

  const EmployeeScheduleAssignment({
    required this.employeeId,
    required this.pattern,
    required this.workDays,
    required this.startTimeLabel,
    required this.endTimeLabel,
    required this.location,
    required this.timezone,
    required this.weeklyHours,
    required this.effectiveFrom,
  });

  String get hoursLabel => '$startTimeLabel - $endTimeLabel';

  String get daysLabel {
    if (workDays.isEmpty) return 'No assigned days';
    if (workDays.length == 5 &&
        workDays.first == 'Mon' &&
        workDays.last == 'Fri') {
      return 'Mon-Fri';
    }
    return workDays.join(', ');
  }
}

class EmployeeAttendanceSignal {
  final String id;
  final String employeeId;
  final DateTime date;
  final EmployeeAttendanceSignalType type;
  final EmployeeAttendanceSignalSeverity severity;
  final int minutesVariance;
  final String note;
  final bool resolved;

  const EmployeeAttendanceSignal({
    required this.id,
    required this.employeeId,
    required this.date,
    required this.type,
    required this.severity,
    required this.minutesVariance,
    required this.note,
    required this.resolved,
  });

  bool get needsAttention => !resolved;

  EmployeeAttendanceSignal copyWith({bool? resolved}) {
    return EmployeeAttendanceSignal(
      id: id,
      employeeId: employeeId,
      date: date,
      type: type,
      severity: severity,
      minutesVariance: minutesVariance,
      note: note,
      resolved: resolved ?? this.resolved,
    );
  }
}

class EmployeeScheduleAdjustmentRequest {
  final String id;
  final String employeeId;
  final EmployeeScheduleAdjustmentType type;
  final DateTime targetDate;
  final String startTimeLabel;
  final String endTimeLabel;
  final String location;
  final String reason;
  final EmployeeScheduleAdjustmentStatus status;
  final DateTime createdAt;

  const EmployeeScheduleAdjustmentRequest({
    required this.id,
    required this.employeeId,
    required this.type,
    required this.targetDate,
    required this.startTimeLabel,
    required this.endTimeLabel,
    required this.location,
    required this.reason,
    required this.status,
    required this.createdAt,
  });

  bool get canApprove => status == EmployeeScheduleAdjustmentStatus.pending;

  bool get canApply => status == EmployeeScheduleAdjustmentStatus.approved;

  EmployeeScheduleAdjustmentRequest copyWith({
    EmployeeScheduleAdjustmentStatus? status,
  }) {
    return EmployeeScheduleAdjustmentRequest(
      id: id,
      employeeId: employeeId,
      type: type,
      targetDate: targetDate,
      startTimeLabel: startTimeLabel,
      endTimeLabel: endTimeLabel,
      location: location,
      reason: reason,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}

class EmployeeScheduleProfile {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final EmployeeScheduleAssignment assignment;
  final List<EmployeeAttendanceSignal> attendanceSignals;
  final List<EmployeeScheduleAdjustmentRequest> adjustments;

  const EmployeeScheduleProfile({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.assignment,
    required this.attendanceSignals,
    required this.adjustments,
  });

  EmployeeScheduleProfile copyWith({
    List<EmployeeAttendanceSignal>? attendanceSignals,
    List<EmployeeScheduleAdjustmentRequest>? adjustments,
  }) {
    return EmployeeScheduleProfile(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      assignment: assignment,
      attendanceSignals: attendanceSignals ?? this.attendanceSignals,
      adjustments: adjustments ?? this.adjustments,
    );
  }

  int get attendanceRiskCount {
    return attendanceSignals.where((signal) => signal.needsAttention).length;
  }

  int get highSeverityCount {
    return attendanceSignals
        .where(
          (signal) =>
              signal.needsAttention &&
              signal.severity == EmployeeAttendanceSignalSeverity.high,
        )
        .length;
  }

  int get pendingAdjustmentCount {
    return adjustments
        .where(
          (request) =>
              request.status == EmployeeScheduleAdjustmentStatus.pending,
        )
        .length;
  }

  int get approvedAdjustmentCount {
    return adjustments
        .where(
          (request) =>
              request.status == EmployeeScheduleAdjustmentStatus.approved,
        )
        .length;
  }

  int get attentionCount {
    return attendanceRiskCount +
        pendingAdjustmentCount +
        approvedAdjustmentCount;
  }

  String get nextAction {
    if (highSeverityCount > 0) {
      return 'Review $highSeverityCount high-risk attendance signal${highSeverityCount == 1 ? '' : 's'}.';
    }
    if (attendanceRiskCount > 0) {
      return 'Review $attendanceRiskCount attendance signal${attendanceRiskCount == 1 ? '' : 's'}.';
    }
    if (approvedAdjustmentCount > 0) {
      return 'Apply $approvedAdjustmentCount approved schedule adjustment${approvedAdjustmentCount == 1 ? '' : 's'}.';
    }
    if (pendingAdjustmentCount > 0) {
      return 'Review $pendingAdjustmentCount schedule adjustment${pendingAdjustmentCount == 1 ? '' : 's'}.';
    }
    return 'Schedule and attendance are aligned.';
  }
}

class EmployeeScheduleAdjustmentDraft {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final EmployeeScheduleAdjustmentType type;
  final DateTime? targetDate;
  final String startTimeLabel;
  final String endTimeLabel;
  final String location;
  final String reason;

  const EmployeeScheduleAdjustmentDraft({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.type,
    required this.targetDate,
    required this.startTimeLabel,
    required this.endTimeLabel,
    required this.location,
    required this.reason,
  });

  EmployeeScheduleAdjustmentDraft copyWith({
    EmployeeScheduleAdjustmentType? type,
    DateTime? targetDate,
    String? startTimeLabel,
    String? endTimeLabel,
    String? location,
    String? reason,
  }) {
    return EmployeeScheduleAdjustmentDraft(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      type: type ?? this.type,
      targetDate: targetDate ?? this.targetDate,
      startTimeLabel: startTimeLabel ?? this.startTimeLabel,
      endTimeLabel: endTimeLabel ?? this.endTimeLabel,
      location: location ?? this.location,
      reason: reason ?? this.reason,
    );
  }

  List<String> get validationErrors {
    final errors = <String>[];
    if (targetDate == null) {
      errors.add('Target date is required');
    } else if (targetDate!.isBefore(asOfDate)) {
      errors.add('Target date cannot be before today');
    }
    if (!_isValidTime(startTimeLabel)) {
      errors.add('Start time must use HH:mm');
    }
    if (!_isValidTime(endTimeLabel)) {
      errors.add('End time must use HH:mm');
    }
    if (_isValidTime(startTimeLabel) &&
        _isValidTime(endTimeLabel) &&
        !_startsBeforeEnd(startTimeLabel, endTimeLabel)) {
      errors.add('End time must be after start time');
    }
    if (location.trim().length < 2) {
      errors.add('Location is required');
    }
    if (reason.trim().length < 12) {
      errors.add('Reason must be at least 12 characters');
    }
    return errors;
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  double get completionRatio {
    final completed =
        [
          targetDate != null && !targetDate!.isBefore(asOfDate),
          _isValidTime(startTimeLabel),
          _isValidTime(endTimeLabel),
          _isValidTime(startTimeLabel) &&
              _isValidTime(endTimeLabel) &&
              _startsBeforeEnd(startTimeLabel, endTimeLabel),
          location.trim().length >= 2,
          reason.trim().length >= 12,
        ].where((item) => item).length;
    return completed / 6;
  }

  EmployeeScheduleAdjustmentRequest toRequest({required String id}) {
    if (!isReadyToSubmit) {
      throw StateError(validationErrors.first);
    }

    return EmployeeScheduleAdjustmentRequest(
      id: id,
      employeeId: employeeId,
      type: type,
      targetDate: targetDate!,
      startTimeLabel: startTimeLabel.trim(),
      endTimeLabel: endTimeLabel.trim(),
      location: location.trim(),
      reason: reason.trim(),
      status: EmployeeScheduleAdjustmentStatus.pending,
      createdAt: asOfDate,
    );
  }
}

bool _isValidTime(String value) {
  final match = RegExp(r'^([01]\d|2[0-3]):[0-5]\d$').firstMatch(value.trim());
  return match != null;
}

bool _startsBeforeEnd(String start, String end) {
  final startParts = start.split(':').map(int.parse).toList();
  final endParts = end.split(':').map(int.parse).toList();
  final startMinutes = startParts.first * 60 + startParts.last;
  final endMinutes = endParts.first * 60 + endParts.last;
  return startMinutes < endMinutes;
}
