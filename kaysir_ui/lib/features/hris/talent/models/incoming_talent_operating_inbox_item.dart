/// Operational stream represented in the talent operating inbox.
enum IncomingTalentOperatingInboxSource {
  riskCouncilDecision('Risk council decision'),
  riskCouncilFollowUp('Risk council follow-up'),
  trainingSession('Training session'),
  careerPathReview('Career path review'),
  successionCoverageFollowUp('Succession coverage follow-up'),
  promotionStabilization('Promotion stabilization');

  final String label;

  const IncomingTalentOperatingInboxSource(this.label);
}

/// Urgency tier used to sort HR operating inbox work.
enum IncomingTalentOperatingInboxPriority {
  critical('Critical'),
  watch('Watch'),
  routine('Routine');

  final String label;

  const IncomingTalentOperatingInboxPriority(this.label);
}

/// Cross-HRIS action item for operators coordinating talent work.
class IncomingTalentOperatingInboxItem {
  final String id;
  final IncomingTalentOperatingInboxSource source;
  final IncomingTalentOperatingInboxPriority priority;
  final String title;
  final String subjectName;
  final String department;
  final String ownerName;
  final String statusLabel;
  final String nextAction;
  final DateTime dueDate;

  const IncomingTalentOperatingInboxItem({
    required this.id,
    required this.source,
    required this.priority,
    required this.title,
    required this.subjectName,
    required this.department,
    required this.ownerName,
    required this.statusLabel,
    required this.nextAction,
    required this.dueDate,
  });

  int daysUntilDue(DateTime asOfDate) {
    final start = DateTime(asOfDate.year, asOfDate.month, asOfDate.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return due.difference(start).inDays;
  }

  bool isOverdue(DateTime asOfDate) {
    return daysUntilDue(asOfDate) < 0;
  }

  bool isDueSoon(DateTime asOfDate) {
    final days = daysUntilDue(asOfDate);
    return days >= 0 && days <= 7;
  }

  int get urgencyRank {
    return switch (priority) {
      IncomingTalentOperatingInboxPriority.critical => 0,
      IncomingTalentOperatingInboxPriority.watch => 1,
      IncomingTalentOperatingInboxPriority.routine => 2,
    };
  }
}
