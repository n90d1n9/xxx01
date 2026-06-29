import '../models/employee_directory_models.dart';
import '../models/employee_engagement_models.dart';

EmployeeEngagementPlan buildEmployeeEngagementPlan({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
}) {
  final today = _dateOnly(asOfDate);
  final pulses = _pulsesFor(member, today);
  final signals = _signalsFor(member, today);

  return EmployeeEngagementPlan(
    employeeId: member.id,
    employeeName: member.name,
    asOfDate: today,
    status: _statusFor(member, pulses, signals, today),
    pulses: pulses,
    signals: signals,
    recognition: _recognitionFor(member, today),
  );
}

EmployeeEngagementPulseDraft buildEmployeeEngagementPulseDraft({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
}) {
  return EmployeeEngagementPulseDraft(
    employeeId: member.id,
    employeeName: member.name,
    asOfDate: _dateOnly(asOfDate),
    sentiment:
        member.status == EmployeeDirectoryStatus.watchlist
            ? EmployeeEngagementSentiment.strained
            : EmployeeEngagementSentiment.steady,
    score: member.status == EmployeeDirectoryStatus.watchlist ? 3 : 4,
    summary: '',
    nextStep: '',
  );
}

List<EmployeeEngagementPulse> _pulsesFor(
  EmployeeDirectoryMember member,
  DateTime today,
) {
  final watchlist = member.status == EmployeeDirectoryStatus.watchlist;
  final highPerformer = member.isHighPerformer;

  return [
    EmployeeEngagementPulse(
      id: '${member.id}-pulse-current',
      employeeId: member.id,
      date: today.subtract(const Duration(days: 7)),
      sentiment:
          watchlist
              ? EmployeeEngagementSentiment.strained
              : highPerformer
              ? EmployeeEngagementSentiment.energized
              : EmployeeEngagementSentiment.steady,
      score:
          watchlist
              ? 3
              : highPerformer
              ? 5
              : 4,
      summary:
          watchlist
              ? 'Momentum is uneven and support expectations need clarity.'
              : 'Employee reports steady momentum and clear manager support.',
      nextStep:
          watchlist
              ? 'Run stay conversation and clarify weekly support rhythm.'
              : 'Maintain weekly manager touchpoint.',
    ),
    EmployeeEngagementPulse(
      id: '${member.id}-pulse-previous',
      employeeId: member.id,
      date: today.subtract(const Duration(days: 35)),
      sentiment:
          watchlist
              ? EmployeeEngagementSentiment.strained
              : EmployeeEngagementSentiment.steady,
      score: watchlist ? 3 : 4,
      summary: 'Previous pulse captured workload and growth expectations.',
      nextStep: 'Review progress in the next one-on-one.',
    ),
  ];
}

List<EmployeeRetentionSignal> _signalsFor(
  EmployeeDirectoryMember member,
  DateTime today,
) {
  if (member.status == EmployeeDirectoryStatus.watchlist) {
    return [
      EmployeeRetentionSignal(
        id: '${member.id}-signal-growth',
        employeeId: member.id,
        type: EmployeeRetentionSignalType.growth,
        title: 'Growth path clarity',
        owner: member.manager,
        dueDate: today.subtract(const Duration(days: 1)),
        severity: 4,
        status: EmployeeRetentionSignalStatus.open,
      ),
      EmployeeRetentionSignal(
        id: '${member.id}-signal-workload',
        employeeId: member.id,
        type: EmployeeRetentionSignalType.workload,
        title: 'Workload rebalancing',
        owner: 'People Partner',
        dueDate: today.add(const Duration(days: 6)),
        severity: 3,
        status: EmployeeRetentionSignalStatus.inProgress,
      ),
    ];
  }

  if (member.status == EmployeeDirectoryStatus.onboarding) {
    return [
      EmployeeRetentionSignal(
        id: '${member.id}-signal-manager-support',
        employeeId: member.id,
        type: EmployeeRetentionSignalType.managerSupport,
        title: 'Manager support cadence',
        owner: member.manager,
        dueDate: today.add(const Duration(days: 5)),
        severity: 3,
        status: EmployeeRetentionSignalStatus.open,
      ),
    ];
  }

  if (member.isHighPerformer) {
    return [
      EmployeeRetentionSignal(
        id: '${member.id}-signal-growth',
        employeeId: member.id,
        type: EmployeeRetentionSignalType.growth,
        title: 'Career path clarity',
        owner: member.manager,
        dueDate: today.add(const Duration(days: 14)),
        severity: 3,
        status: EmployeeRetentionSignalStatus.open,
      ),
    ];
  }

  return const [];
}

List<EmployeeRecognitionNote> _recognitionFor(
  EmployeeDirectoryMember member,
  DateTime today,
) {
  final notes = <EmployeeRecognitionNote>[
    EmployeeRecognitionNote(
      id: '${member.id}-recognition-team',
      employeeId: member.id,
      title: '${_departmentImpact(member.department)} contribution',
      from: member.manager,
      date: today.subtract(const Duration(days: 18)),
      impact: EmployeeRecognitionImpact.teamwork,
    ),
  ];

  if (member.isHighPerformer) {
    notes.add(
      EmployeeRecognitionNote(
        id: '${member.id}-recognition-craft',
        employeeId: member.id,
        title: 'Raised quality bar for the team',
        from: 'People Leadership',
        date: today.subtract(const Duration(days: 42)),
        impact: EmployeeRecognitionImpact.craft,
      ),
    );
  }

  if (member.status == EmployeeDirectoryStatus.watchlist) {
    return const [];
  }

  return notes;
}

EmployeeEngagementStatus _statusFor(
  EmployeeDirectoryMember member,
  List<EmployeeEngagementPulse> pulses,
  List<EmployeeRetentionSignal> signals,
  DateTime asOfDate,
) {
  final criticalSignals = signals.where(
    (signal) => !signal.isResolved && signal.severity >= 4,
  );
  final averageScore =
      pulses.isEmpty
          ? 0
          : pulses.fold<double>(0, (total, pulse) => total + pulse.score) /
              pulses.length;

  if (criticalSignals.isNotEmpty || averageScore < 3) {
    return EmployeeEngagementStatus.critical;
  }
  if (signals.any((signal) => signal.needsAttention(asOfDate)) ||
      member.status == EmployeeDirectoryStatus.onboarding) {
    return EmployeeEngagementStatus.watch;
  }
  if (member.isHighPerformer && averageScore >= 4.5) {
    return EmployeeEngagementStatus.thriving;
  }
  return EmployeeEngagementStatus.steady;
}

String _departmentImpact(String department) {
  return switch (department) {
    'Engineering' => 'Platform reliability',
    'Design' => 'Product experience',
    'Product' => 'Roadmap execution',
    'Human Resources' => 'People operations',
    _ => 'Team delivery',
  };
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
