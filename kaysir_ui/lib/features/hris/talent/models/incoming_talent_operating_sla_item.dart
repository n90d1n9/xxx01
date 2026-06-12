/// SLA source category for cross-HRIS talent operating actions.
enum IncomingTalentOperatingSlaSource {
  recruitment('Recruitment'),
  training('Training'),
  careerPath('Career path'),
  succession('Succession'),
  promotion('Promotion'),
  assurance('Assurance');

  final String label;

  const IncomingTalentOperatingSlaSource(this.label);
}

/// SLA status for active talent operating work.
enum IncomingTalentOperatingSlaStatus {
  overdue('Overdue'),
  dueToday('Due today'),
  atRisk('At risk'),
  onTrack('On track');

  final String label;

  const IncomingTalentOperatingSlaStatus(this.label);

  int get sortRank {
    return switch (this) {
      IncomingTalentOperatingSlaStatus.overdue => 0,
      IncomingTalentOperatingSlaStatus.dueToday => 1,
      IncomingTalentOperatingSlaStatus.atRisk => 2,
      IncomingTalentOperatingSlaStatus.onTrack => 3,
    };
  }
}

/// Normalized SLA item for recruitment, training, career, succession, and assurance work.
class IncomingTalentOperatingSlaItem {
  final String id;
  final String referenceId;
  final IncomingTalentOperatingSlaSource source;
  final IncomingTalentOperatingSlaStatus status;
  final String title;
  final String subjectName;
  final String department;
  final String ownerName;
  final String workstreamLabel;
  final String priorityLabel;
  final String nextAction;
  final DateTime dueDate;
  final int daysUntilDue;
  final double slaPressureRatio;
  final int evidenceCount;
  final List<String> referenceIds;

  const IncomingTalentOperatingSlaItem({
    required this.id,
    required this.referenceId,
    required this.source,
    required this.status,
    required this.title,
    required this.subjectName,
    required this.department,
    required this.ownerName,
    required this.workstreamLabel,
    required this.priorityLabel,
    required this.nextAction,
    required this.dueDate,
    required this.daysUntilDue,
    required this.slaPressureRatio,
    required this.evidenceCount,
    required this.referenceIds,
  });

  bool get needsAttention {
    return status != IncomingTalentOperatingSlaStatus.onTrack;
  }

  double get normalizedSlaPressureRatio {
    if (slaPressureRatio < 0) return 0;
    if (slaPressureRatio > 1) return 1;
    return slaPressureRatio;
  }

  int get urgencyRank => status.sortRank;
}
