enum IncomingTalentRiskCouncilAgendaSection {
  clear('Clear checkpoint'),
  leadershipEscalation('Leadership escalation'),
  slaRecovery('SLA recovery'),
  decisionDocket('Decision docket'),
  followUpPlanning('Follow-up planning'),
  ownerConfirmation('Owner confirmation'),
  executionReview('Execution review'),
  commitmentClose('Commitment close');

  final String label;

  const IncomingTalentRiskCouncilAgendaSection(this.label);
}

enum IncomingTalentRiskCouncilAgendaPriority {
  critical('Critical'),
  high('High'),
  normal('Normal'),
  clear('Clear');

  final String label;

  const IncomingTalentRiskCouncilAgendaPriority(this.label);
}

class IncomingTalentRiskCouncilAgendaItem {
  final String id;
  final IncomingTalentRiskCouncilAgendaSection section;
  final IncomingTalentRiskCouncilAgendaPriority priority;
  final String title;
  final String objective;
  final String targetOutcome;
  final String facilitatorName;
  final int timeboxMinutes;
  final int sourceCount;
  final List<String> readinessTaskIds;

  const IncomingTalentRiskCouncilAgendaItem({
    required this.id,
    required this.section,
    required this.priority,
    required this.title,
    required this.objective,
    required this.targetOutcome,
    required this.facilitatorName,
    required this.timeboxMinutes,
    required this.sourceCount,
    required this.readinessTaskIds,
  });

  bool get isCritical {
    return priority == IncomingTalentRiskCouncilAgendaPriority.critical;
  }

  int get urgencyRank {
    return switch (priority) {
      IncomingTalentRiskCouncilAgendaPriority.critical => 0,
      IncomingTalentRiskCouncilAgendaPriority.high => 1,
      IncomingTalentRiskCouncilAgendaPriority.normal => 2,
      IncomingTalentRiskCouncilAgendaPriority.clear => 3,
    };
  }
}
