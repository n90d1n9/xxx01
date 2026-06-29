enum IncomingTalentRiskCouncilBriefInsightTone {
  positive('Clear'),
  watch('Watch'),
  critical('Critical');

  final String label;

  const IncomingTalentRiskCouncilBriefInsightTone(this.label);
}

enum IncomingTalentRiskCouncilBriefInsightType {
  leadershipAttention,
  slaRecovery,
  decisionQueue,
  followUpCreation,
  dueSoon,
  execution,
  clear,
}

class IncomingTalentRiskCouncilBriefInsight {
  final IncomingTalentRiskCouncilBriefInsightType type;
  final IncomingTalentRiskCouncilBriefInsightTone tone;
  final String title;
  final String detail;
  final int count;

  const IncomingTalentRiskCouncilBriefInsight({
    required this.type,
    required this.tone,
    required this.title,
    required this.detail,
    required this.count,
  });
}
