import 'incoming_talent_operating_assurance_remediation.dart';

/// Execution status for an assurance remediation track.
enum IncomingTalentOperatingAssuranceExecutionStatus {
  blocked('Blocked'),
  recovery('Recovery'),
  dueToday('Due today'),
  inProgress('In progress');

  final String label;

  const IncomingTalentOperatingAssuranceExecutionStatus(this.label);

  int get sortRank {
    return switch (this) {
      IncomingTalentOperatingAssuranceExecutionStatus.blocked => 0,
      IncomingTalentOperatingAssuranceExecutionStatus.recovery => 1,
      IncomingTalentOperatingAssuranceExecutionStatus.dueToday => 2,
      IncomingTalentOperatingAssuranceExecutionStatus.inProgress => 3,
    };
  }
}

/// Due-date health for an assurance remediation execution track.
enum IncomingTalentOperatingAssuranceExecutionDueHealth {
  overdue('Overdue'),
  dueToday('Due today'),
  upcoming('Upcoming');

  final String label;

  const IncomingTalentOperatingAssuranceExecutionDueHealth(this.label);
}

/// Execution track that turns an assurance remediation action into progress work.
class IncomingTalentOperatingAssuranceExecutionTrack {
  final String id;
  final String remediationActionId;
  final IncomingTalentOperatingAssuranceExecutionStatus status;
  final IncomingTalentOperatingAssuranceExecutionDueHealth dueHealth;
  final IncomingTalentOperatingAssuranceRemediationPriority priority;
  final String ownerName;
  final String workstreamLabel;
  final String title;
  final String detail;
  final String blocker;
  final String nextStep;
  final DateTime dueDate;
  final double executionRatio;
  final int openGapCount;
  final int overdueGapCount;
  final int dueTodayGapCount;
  final int linkedEscalationCount;
  final List<String> completionEvidence;
  final List<String> gapIds;

  const IncomingTalentOperatingAssuranceExecutionTrack({
    required this.id,
    required this.remediationActionId,
    required this.status,
    required this.dueHealth,
    required this.priority,
    required this.ownerName,
    required this.workstreamLabel,
    required this.title,
    required this.detail,
    required this.blocker,
    required this.nextStep,
    required this.dueDate,
    required this.executionRatio,
    required this.openGapCount,
    required this.overdueGapCount,
    required this.dueTodayGapCount,
    required this.linkedEscalationCount,
    required this.completionEvidence,
    required this.gapIds,
  });

  bool get needsAttention {
    return status != IncomingTalentOperatingAssuranceExecutionStatus.inProgress;
  }

  double get normalizedExecutionRatio {
    if (executionRatio < 0) return 0;
    if (executionRatio > 1) return 1;
    return executionRatio;
  }
}
