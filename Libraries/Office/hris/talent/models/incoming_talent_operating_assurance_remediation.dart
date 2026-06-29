import 'incoming_talent_operating_assurance.dart';

/// Priority tier for an assurance remediation action.
enum IncomingTalentOperatingAssuranceRemediationPriority {
  critical('Critical'),
  high('High'),
  standard('Standard');

  final String label;

  const IncomingTalentOperatingAssuranceRemediationPriority(this.label);

  int get sortRank {
    return switch (this) {
      IncomingTalentOperatingAssuranceRemediationPriority.critical => 0,
      IncomingTalentOperatingAssuranceRemediationPriority.high => 1,
      IncomingTalentOperatingAssuranceRemediationPriority.standard => 2,
    };
  }
}

/// Remediation action type for missing talent assurance evidence.
enum IncomingTalentOperatingAssuranceRemediationType {
  recoverOverdueEvidence('Recover overdue'),
  clearLinkedEscalation('Clear escalation'),
  closeDueToday('Close today'),
  prepareAuditPack('Prepare audit pack');

  final String label;

  const IncomingTalentOperatingAssuranceRemediationType(this.label);
}

/// Owner-assigned remediation action for talent assurance gaps.
class IncomingTalentOperatingAssuranceRemediationAction {
  final String id;
  final IncomingTalentOperatingAssuranceRemediationType type;
  final IncomingTalentOperatingAssuranceRemediationPriority priority;
  final IncomingTalentOperatingAssuranceLevel assuranceLevel;
  final String ownerName;
  final String workstreamLabel;
  final String title;
  final String detail;
  final String nextAction;
  final int gapCount;
  final int criticalGapCount;
  final int highGapCount;
  final int overdueGapCount;
  final int dueTodayGapCount;
  final int linkedEscalationCount;
  final DateTime nextDueDate;
  final double pressureRatio;
  final List<String> evidenceRequests;
  final List<String> gapIds;

  const IncomingTalentOperatingAssuranceRemediationAction({
    required this.id,
    required this.type,
    required this.priority,
    required this.assuranceLevel,
    required this.ownerName,
    required this.workstreamLabel,
    required this.title,
    required this.detail,
    required this.nextAction,
    required this.gapCount,
    required this.criticalGapCount,
    required this.highGapCount,
    required this.overdueGapCount,
    required this.dueTodayGapCount,
    required this.linkedEscalationCount,
    required this.nextDueDate,
    required this.pressureRatio,
    required this.evidenceRequests,
    required this.gapIds,
  });

  int get urgencyRank => priority.sortRank;

  double get normalizedPressureRatio {
    if (pressureRatio < 0) return 0;
    if (pressureRatio > 1) return 1;
    return pressureRatio;
  }
}
