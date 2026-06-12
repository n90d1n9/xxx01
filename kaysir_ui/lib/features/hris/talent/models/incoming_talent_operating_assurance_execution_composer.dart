import 'incoming_talent_operating_assurance_execution.dart';
import 'incoming_talent_operating_assurance_remediation.dart';

/// Builds execution tracks from owner-assigned assurance remediation actions.
List<IncomingTalentOperatingAssuranceExecutionTrack>
buildIncomingTalentOperatingAssuranceExecutionTracks({
  required List<IncomingTalentOperatingAssuranceRemediationAction> actions,
  required DateTime asOfDate,
}) {
  final tracks =
      actions.map((action) {
          final status = _statusFor(action);
          final completionEvidence = _completionEvidenceFor(action);

          return IncomingTalentOperatingAssuranceExecutionTrack(
            id: 'assurance-execution-${action.id}',
            remediationActionId: action.id,
            status: status,
            dueHealth: _dueHealthFor(action: action, asOfDate: asOfDate),
            priority: action.priority,
            ownerName: action.ownerName,
            workstreamLabel: action.workstreamLabel,
            title: '${action.ownerName} execution - ${action.workstreamLabel}',
            detail:
                '${action.gapCount} open ${_plural(action.gapCount, 'gap')} with ${completionEvidence.length} completion ${_plural(completionEvidence.length, 'proof')} required',
            blocker: _blockerFor(action: action, status: status),
            nextStep: _nextStepFor(action: action, status: status),
            dueDate: action.nextDueDate,
            executionRatio: _executionRatioFor(action: action, status: status),
            openGapCount: action.gapCount,
            overdueGapCount: action.overdueGapCount,
            dueTodayGapCount: action.dueTodayGapCount,
            linkedEscalationCount: action.linkedEscalationCount,
            completionEvidence: completionEvidence,
            gapIds: action.gapIds,
          );
        }).toList()
        ..sort(_compareTracks);

  return tracks;
}

IncomingTalentOperatingAssuranceExecutionStatus _statusFor(
  IncomingTalentOperatingAssuranceRemediationAction action,
) {
  if (action.priority ==
          IncomingTalentOperatingAssuranceRemediationPriority.critical &&
      action.linkedEscalationCount > 0) {
    return IncomingTalentOperatingAssuranceExecutionStatus.blocked;
  }
  if (action.overdueGapCount > 0) {
    return IncomingTalentOperatingAssuranceExecutionStatus.recovery;
  }
  if (action.dueTodayGapCount > 0) {
    return IncomingTalentOperatingAssuranceExecutionStatus.dueToday;
  }
  return IncomingTalentOperatingAssuranceExecutionStatus.inProgress;
}

IncomingTalentOperatingAssuranceExecutionDueHealth _dueHealthFor({
  required IncomingTalentOperatingAssuranceRemediationAction action,
  required DateTime asOfDate,
}) {
  if (action.overdueGapCount > 0 ||
      _isBeforeDate(action.nextDueDate, asOfDate)) {
    return IncomingTalentOperatingAssuranceExecutionDueHealth.overdue;
  }
  if (action.dueTodayGapCount > 0 || _sameDate(action.nextDueDate, asOfDate)) {
    return IncomingTalentOperatingAssuranceExecutionDueHealth.dueToday;
  }
  return IncomingTalentOperatingAssuranceExecutionDueHealth.upcoming;
}

String _blockerFor({
  required IncomingTalentOperatingAssuranceRemediationAction action,
  required IncomingTalentOperatingAssuranceExecutionStatus status,
}) {
  return switch (status) {
    IncomingTalentOperatingAssuranceExecutionStatus.blocked =>
      '${action.linkedEscalationCount} linked ${_plural(action.linkedEscalationCount, 'escalation')} must be cleared before assurance closure.',
    IncomingTalentOperatingAssuranceExecutionStatus.recovery =>
      '${action.overdueGapCount} overdue ${_plural(action.overdueGapCount, 'gap')} needs evidence recovery.',
    IncomingTalentOperatingAssuranceExecutionStatus.dueToday =>
      '${action.dueTodayGapCount} due-today ${_plural(action.dueTodayGapCount, 'gap')} needs same-day proof.',
    IncomingTalentOperatingAssuranceExecutionStatus.inProgress =>
      'No blocker detected; keep evidence collection moving.',
  };
}

String _nextStepFor({
  required IncomingTalentOperatingAssuranceRemediationAction action,
  required IncomingTalentOperatingAssuranceExecutionStatus status,
}) {
  final workstream = action.workstreamLabel.toLowerCase();
  return switch (status) {
    IncomingTalentOperatingAssuranceExecutionStatus.blocked =>
      'Unblock linked $workstream escalations with ${action.ownerName}.',
    IncomingTalentOperatingAssuranceExecutionStatus.recovery =>
      'Recover overdue $workstream evidence and attach closure proof.',
    IncomingTalentOperatingAssuranceExecutionStatus.dueToday =>
      'Close due-today $workstream evidence before the HRIS cut-off.',
    IncomingTalentOperatingAssuranceExecutionStatus.inProgress =>
      'Collect the $workstream audit pack and confirm owner acceptance.',
  };
}

double _executionRatioFor({
  required IncomingTalentOperatingAssuranceRemediationAction action,
  required IncomingTalentOperatingAssuranceExecutionStatus status,
}) {
  final base = switch (status) {
    IncomingTalentOperatingAssuranceExecutionStatus.blocked => 0.18,
    IncomingTalentOperatingAssuranceExecutionStatus.recovery => 0.34,
    IncomingTalentOperatingAssuranceExecutionStatus.dueToday => 0.52,
    IncomingTalentOperatingAssuranceExecutionStatus.inProgress => 0.68,
  };
  final ratio = base + ((1 - action.normalizedPressureRatio) * 0.2);

  if (ratio < 0) return 0;
  if (ratio > 1) return 1;
  return ratio;
}

List<String> _completionEvidenceFor(
  IncomingTalentOperatingAssuranceRemediationAction action,
) {
  final evidence = <String>[
    ...action.evidenceRequests,
    'Owner confirmation for ${action.gapCount} ${_plural(action.gapCount, 'gap')}.',
    'HRIS closure note for ${action.workstreamLabel.toLowerCase()} assurance.',
  ];

  return evidence.toSet().toList();
}

int _compareTracks(
  IncomingTalentOperatingAssuranceExecutionTrack left,
  IncomingTalentOperatingAssuranceExecutionTrack right,
) {
  final status = left.status.sortRank.compareTo(right.status.sortRank);
  if (status != 0) return status;

  final priority = left.priority.sortRank.compareTo(right.priority.sortRank);
  if (priority != 0) return priority;

  final dueDate = left.dueDate.compareTo(right.dueDate);
  if (dueDate != 0) return dueDate;

  final openGaps = right.openGapCount.compareTo(left.openGapCount);
  if (openGaps != 0) return openGaps;

  return left.title.compareTo(right.title);
}

bool _isBeforeDate(DateTime left, DateTime right) {
  return DateTime(
    left.year,
    left.month,
    left.day,
  ).isBefore(DateTime(right.year, right.month, right.day));
}

bool _sameDate(DateTime left, DateTime right) {
  return left.year == right.year &&
      left.month == right.month &&
      left.day == right.day;
}

String _plural(int count, String noun) {
  return count == 1 ? noun : '${noun}s';
}
