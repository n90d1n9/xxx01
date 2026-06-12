/// Severity tier for cross-HRIS talent operating escalations.
enum IncomingTalentOperatingEscalationSeverity {
  critical('Critical'),
  high('High'),
  watch('Watch');

  final String label;

  const IncomingTalentOperatingEscalationSeverity(this.label);

  int get sortRank {
    return switch (this) {
      IncomingTalentOperatingEscalationSeverity.critical => 0,
      IncomingTalentOperatingEscalationSeverity.high => 1,
      IncomingTalentOperatingEscalationSeverity.watch => 2,
    };
  }
}

/// Origin signal used by the talent operating escalation board.
enum IncomingTalentOperatingEscalationSource {
  cadence('Cadence'),
  ownerRebalance('Owner relief'),
  workstreamPressure('Workstream pressure'),
  inbox('Inbox item');

  final String label;

  const IncomingTalentOperatingEscalationSource(this.label);
}

/// Ranked escalation signal for talent operators to review first.
class IncomingTalentOperatingEscalationItem {
  final IncomingTalentOperatingEscalationSource source;
  final IncomingTalentOperatingEscalationSeverity severity;
  final String title;
  final String detail;
  final String nextAction;
  final int signalCount;
  final DateTime? dueDate;
  final bool overdue;
  final bool dueToday;
  final String? ownerName;
  final String? workstreamLabel;
  final double pressureRatio;
  final List<String> referenceIds;

  const IncomingTalentOperatingEscalationItem({
    required this.source,
    required this.severity,
    required this.title,
    required this.detail,
    required this.nextAction,
    required this.signalCount,
    required this.dueDate,
    required this.overdue,
    required this.dueToday,
    required this.ownerName,
    required this.workstreamLabel,
    required this.pressureRatio,
    required this.referenceIds,
  });

  int get urgencyRank => severity.sortRank;

  bool get hasOwner => ownerName != null && ownerName!.trim().isNotEmpty;

  bool get hasWorkstream {
    return workstreamLabel != null && workstreamLabel!.trim().isNotEmpty;
  }

  double get normalizedPressureRatio {
    if (pressureRatio < 0) return 0;
    if (pressureRatio > 1) return 1;
    return pressureRatio;
  }
}
