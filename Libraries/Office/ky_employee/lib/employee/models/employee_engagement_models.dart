enum EmployeeEngagementStatus {
  thriving('Thriving'),
  steady('Steady'),
  watch('Watch'),
  critical('Critical');

  final String label;

  const EmployeeEngagementStatus(this.label);
}

enum EmployeeEngagementSentiment {
  energized('Energized'),
  steady('Steady'),
  strained('Strained'),
  disengaged('Disengaged');

  final String label;

  const EmployeeEngagementSentiment(this.label);
}

enum EmployeeRetentionSignalType {
  growth('Growth'),
  workload('Workload'),
  compensation('Compensation'),
  managerSupport('Manager support'),
  belonging('Belonging');

  final String label;

  const EmployeeRetentionSignalType(this.label);
}

enum EmployeeRetentionSignalStatus {
  open('Open'),
  inProgress('In progress'),
  resolved('Resolved');

  final String label;

  const EmployeeRetentionSignalStatus(this.label);
}

enum EmployeeRecognitionImpact {
  customer('Customer'),
  craft('Craft'),
  teamwork('Teamwork'),
  leadership('Leadership');

  final String label;

  const EmployeeRecognitionImpact(this.label);
}

class EmployeeEngagementPulse {
  final String id;
  final String employeeId;
  final DateTime date;
  final EmployeeEngagementSentiment sentiment;
  final int score;
  final String summary;
  final String nextStep;

  const EmployeeEngagementPulse({
    required this.id,
    required this.employeeId,
    required this.date,
    required this.sentiment,
    required this.score,
    required this.summary,
    required this.nextStep,
  });

  double get scoreRatio => (score / 5).clamp(0, 1).toDouble();

  bool get needsAttention {
    return score <= 3 ||
        sentiment == EmployeeEngagementSentiment.strained ||
        sentiment == EmployeeEngagementSentiment.disengaged;
  }
}

class EmployeeRetentionSignal {
  final String id;
  final String employeeId;
  final EmployeeRetentionSignalType type;
  final String title;
  final String owner;
  final DateTime dueDate;
  final int severity;
  final EmployeeRetentionSignalStatus status;

  const EmployeeRetentionSignal({
    required this.id,
    required this.employeeId,
    required this.type,
    required this.title,
    required this.owner,
    required this.dueDate,
    required this.severity,
    required this.status,
  });

  bool get isResolved => status == EmployeeRetentionSignalStatus.resolved;

  bool isOverdue(DateTime asOfDate) {
    return !isResolved && dueDate.isBefore(_dateOnly(asOfDate));
  }

  bool needsAttention(DateTime asOfDate) {
    return !isResolved && (severity >= 4 || isOverdue(asOfDate));
  }

  EmployeeRetentionSignal copyWith({
    DateTime? dueDate,
    int? severity,
    EmployeeRetentionSignalStatus? status,
  }) {
    return EmployeeRetentionSignal(
      id: id,
      employeeId: employeeId,
      type: type,
      title: title,
      owner: owner,
      dueDate: dueDate ?? this.dueDate,
      severity: (severity ?? this.severity).clamp(1, 5).toInt(),
      status: status ?? this.status,
    );
  }
}

class EmployeeRecognitionNote {
  final String id;
  final String employeeId;
  final String title;
  final String from;
  final DateTime date;
  final EmployeeRecognitionImpact impact;

  const EmployeeRecognitionNote({
    required this.id,
    required this.employeeId,
    required this.title,
    required this.from,
    required this.date,
    required this.impact,
  });
}

class EmployeeEngagementPlan {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final EmployeeEngagementStatus status;
  final List<EmployeeEngagementPulse> pulses;
  final List<EmployeeRetentionSignal> signals;
  final List<EmployeeRecognitionNote> recognition;

  const EmployeeEngagementPlan({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.status,
    required this.pulses,
    required this.signals,
    required this.recognition,
  });

  EmployeeEngagementPlan copyWith({
    EmployeeEngagementStatus? status,
    List<EmployeeEngagementPulse>? pulses,
    List<EmployeeRetentionSignal>? signals,
    List<EmployeeRecognitionNote>? recognition,
  }) {
    return EmployeeEngagementPlan(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      status: status ?? this.status,
      pulses: pulses ?? this.pulses,
      signals: signals ?? this.signals,
      recognition: recognition ?? this.recognition,
    );
  }

  double get averagePulseScore {
    if (pulses.isEmpty) return 0;
    return pulses.fold<double>(0, (total, pulse) => total + pulse.score) /
        pulses.length;
  }

  int get openSignalCount {
    return signals.where((signal) => !signal.isResolved).length;
  }

  int get criticalSignalCount {
    return signals
        .where((signal) => !signal.isResolved && signal.severity >= 4)
        .length;
  }

  int get overdueSignalCount {
    return signals.where((signal) => signal.isOverdue(asOfDate)).length;
  }

  int get recognitionCount => recognition.length;

  String get nextAction {
    if (criticalSignalCount > 0) {
      return 'Prioritize $criticalSignalCount critical retention signal${criticalSignalCount == 1 ? '' : 's'}.';
    }
    if (overdueSignalCount > 0) {
      return 'Follow up on $overdueSignalCount overdue retention action${overdueSignalCount == 1 ? '' : 's'}.';
    }
    if (openSignalCount > 0) {
      return 'Follow through on $openSignalCount open retention signal${openSignalCount == 1 ? '' : 's'}.';
    }
    if (averagePulseScore < 4) {
      return 'Schedule a pulse check-in this week.';
    }
    return 'Engagement plan is healthy.';
  }
}

class EmployeeEngagementPulseDraft {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final EmployeeEngagementSentiment sentiment;
  final int score;
  final String summary;
  final String nextStep;

  const EmployeeEngagementPulseDraft({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.sentiment,
    required this.score,
    required this.summary,
    required this.nextStep,
  });

  EmployeeEngagementPulseDraft copyWith({
    EmployeeEngagementSentiment? sentiment,
    int? score,
    String? summary,
    String? nextStep,
  }) {
    return EmployeeEngagementPulseDraft(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      sentiment: sentiment ?? this.sentiment,
      score: (score ?? this.score).clamp(1, 5).toInt(),
      summary: summary ?? this.summary,
      nextStep: nextStep ?? this.nextStep,
    );
  }

  List<String> get validationErrors {
    final errors = <String>[];
    if (summary.trim().length < 12) {
      errors.add('Pulse summary must be at least 12 characters');
    }
    if (nextStep.trim().length < 6) {
      errors.add('Follow-up action is required');
    }
    return errors;
  }

  bool get isReadyToAdd => validationErrors.isEmpty;

  double get completionRatio {
    var complete = 0;
    if (summary.trim().length >= 12) complete++;
    if (nextStep.trim().length >= 6) complete++;
    if (score >= 1 && score <= 5) complete++;
    return complete / 3;
  }

  EmployeeEngagementPulse toPulse({required String id}) {
    if (!isReadyToAdd) {
      throw StateError(validationErrors.first);
    }

    return EmployeeEngagementPulse(
      id: id,
      employeeId: employeeId,
      date: asOfDate,
      sentiment: sentiment,
      score: score,
      summary: summary.trim(),
      nextStep: nextStep.trim(),
    );
  }
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
