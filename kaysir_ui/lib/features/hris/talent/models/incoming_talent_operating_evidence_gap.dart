/// Evidence category needed to close a talent operating item cleanly.
enum IncomingTalentOperatingEvidenceGapType {
  riskCouncilEvidence('Risk council evidence'),
  learningEvidence('Learning evidence'),
  careerPathEvidence('Career path evidence'),
  successionEvidence('Succession evidence'),
  promotionEvidence('Promotion evidence');

  final String label;

  const IncomingTalentOperatingEvidenceGapType(this.label);
}

/// Risk tier for an evidence gap in the talent operating inbox.
enum IncomingTalentOperatingEvidenceGapRisk {
  critical('Critical'),
  high('High'),
  watch('Watch');

  final String label;

  const IncomingTalentOperatingEvidenceGapRisk(this.label);

  int get sortRank {
    return switch (this) {
      IncomingTalentOperatingEvidenceGapRisk.critical => 0,
      IncomingTalentOperatingEvidenceGapRisk.high => 1,
      IncomingTalentOperatingEvidenceGapRisk.watch => 2,
    };
  }
}

/// Auditable evidence gap for an active cross-HRIS talent action.
class IncomingTalentOperatingEvidenceGap {
  final String id;
  final IncomingTalentOperatingEvidenceGapType type;
  final IncomingTalentOperatingEvidenceGapRisk risk;
  final String title;
  final String subjectName;
  final String ownerName;
  final String workstreamLabel;
  final String statusLabel;
  final String evidenceRequest;
  final String nextAction;
  final DateTime dueDate;
  final int daysUntilDue;
  final bool overdue;
  final bool dueToday;
  final int linkedEscalationCount;
  final double pressureRatio;
  final List<String> referenceIds;

  const IncomingTalentOperatingEvidenceGap({
    required this.id,
    required this.type,
    required this.risk,
    required this.title,
    required this.subjectName,
    required this.ownerName,
    required this.workstreamLabel,
    required this.statusLabel,
    required this.evidenceRequest,
    required this.nextAction,
    required this.dueDate,
    required this.daysUntilDue,
    required this.overdue,
    required this.dueToday,
    required this.linkedEscalationCount,
    required this.pressureRatio,
    required this.referenceIds,
  });

  int get urgencyRank => risk.sortRank;

  bool get hasEscalationLink => linkedEscalationCount > 0;

  double get normalizedPressureRatio {
    if (pressureRatio < 0) return 0;
    if (pressureRatio > 1) return 1;
    return pressureRatio;
  }
}
