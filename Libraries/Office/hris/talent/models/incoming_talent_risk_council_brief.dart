import 'incoming_talent_risk_council_brief_insight.dart';
import 'incoming_talent_risk_council_decision.dart';
import 'incoming_talent_risk_council_follow_up.dart';
import 'incoming_talent_risk_council_queue_item.dart';
import 'incoming_talent_risk_council_sla_item.dart';
import 'incoming_talent_risk_council_sla_summary.dart';

enum IncomingTalentRiskCouncilBriefStatus {
  clear('Clear'),
  watch('Watch'),
  critical('Critical');

  final String label;

  const IncomingTalentRiskCouncilBriefStatus(this.label);
}

class IncomingTalentRiskCouncilBrief {
  final IncomingTalentRiskCouncilBriefStatus status;
  final int pendingDecisionCount;
  final int criticalDecisionCount;
  final int decisionCount;
  final int openFollowUpCount;
  final int completedFollowUpCount;
  final int blockedSlaCount;
  final int escalatedSlaCount;
  final int overdueSlaCount;
  final int dueSoonSlaCount;
  final int waitingFollowUpCount;
  final int activeFollowUpCount;
  final double readinessRatio;
  final String nextAction;
  final List<IncomingTalentRiskCouncilBriefInsight> insights;

  const IncomingTalentRiskCouncilBrief({
    required this.status,
    required this.pendingDecisionCount,
    required this.criticalDecisionCount,
    required this.decisionCount,
    required this.openFollowUpCount,
    required this.completedFollowUpCount,
    required this.blockedSlaCount,
    required this.escalatedSlaCount,
    required this.overdueSlaCount,
    required this.dueSoonSlaCount,
    required this.waitingFollowUpCount,
    required this.activeFollowUpCount,
    required this.readinessRatio,
    required this.nextAction,
    required this.insights,
  });

  factory IncomingTalentRiskCouncilBrief.fromSignals({
    required List<IncomingTalentRiskCouncilQueueItem> queueItems,
    required List<IncomingTalentRiskCouncilDecision> decisions,
    required List<IncomingTalentRiskCouncilFollowUp> followUps,
    required List<IncomingTalentRiskCouncilSlaItem> slaItems,
    required IncomingTalentRiskCouncilSlaSummary slaSummary,
  }) {
    final pendingDecisionCount = queueItems.length;
    final criticalDecisionCount =
        queueItems.where((item) => item.isCritical).length;
    final openFollowUpCount =
        followUps.where((followUp) => followUp.isOpen).length;
    final completedFollowUpCount =
        followUps.where((followUp) => !followUp.isOpen).length;
    final readinessRatio = _readinessRatio(
      pendingDecisionCount: pendingDecisionCount,
      waitingFollowUpCount: slaSummary.waitingFollowUpCount,
      openFollowUpCount: openFollowUpCount,
      completedFollowUpCount: completedFollowUpCount,
    );
    final status = _status(
      criticalDecisionCount: criticalDecisionCount,
      blockedSlaCount: slaSummary.blockedCount,
      escalatedSlaCount: slaSummary.escalatedCount,
      overdueSlaCount: slaSummary.overdueCount,
      dueSoonSlaCount: slaSummary.dueSoonCount,
      pendingDecisionCount: pendingDecisionCount,
      openFollowUpCount: openFollowUpCount,
    );

    return IncomingTalentRiskCouncilBrief(
      status: status,
      pendingDecisionCount: pendingDecisionCount,
      criticalDecisionCount: criticalDecisionCount,
      decisionCount: decisions.length,
      openFollowUpCount: openFollowUpCount,
      completedFollowUpCount: completedFollowUpCount,
      blockedSlaCount: slaSummary.blockedCount,
      escalatedSlaCount: slaSummary.escalatedCount,
      overdueSlaCount: slaSummary.overdueCount,
      dueSoonSlaCount: slaSummary.dueSoonCount,
      waitingFollowUpCount: slaSummary.waitingFollowUpCount,
      activeFollowUpCount: slaSummary.activeFollowUpCount,
      readinessRatio: readinessRatio,
      nextAction: _nextAction(
        pendingDecisionCount: pendingDecisionCount,
        blockedSlaCount: slaSummary.blockedCount,
        escalatedSlaCount: slaSummary.escalatedCount,
        overdueSlaCount: slaSummary.overdueCount,
        dueSoonSlaCount: slaSummary.dueSoonCount,
        waitingFollowUpCount: slaSummary.waitingFollowUpCount,
        openFollowUpCount: openFollowUpCount,
      ),
      insights: _insights(
        queueItems: queueItems,
        slaItems: slaItems,
        pendingDecisionCount: pendingDecisionCount,
        criticalDecisionCount: criticalDecisionCount,
        blockedSlaCount: slaSummary.blockedCount,
        escalatedSlaCount: slaSummary.escalatedCount,
        overdueSlaCount: slaSummary.overdueCount,
        dueSoonSlaCount: slaSummary.dueSoonCount,
        waitingFollowUpCount: slaSummary.waitingFollowUpCount,
        openFollowUpCount: openFollowUpCount,
      ),
    );
  }
}

IncomingTalentRiskCouncilBriefStatus _status({
  required int criticalDecisionCount,
  required int blockedSlaCount,
  required int escalatedSlaCount,
  required int overdueSlaCount,
  required int dueSoonSlaCount,
  required int pendingDecisionCount,
  required int openFollowUpCount,
}) {
  if (criticalDecisionCount > 0 ||
      blockedSlaCount > 0 ||
      escalatedSlaCount > 0 ||
      overdueSlaCount > 0) {
    return IncomingTalentRiskCouncilBriefStatus.critical;
  }
  if (dueSoonSlaCount > 0 ||
      pendingDecisionCount > 0 ||
      openFollowUpCount > 0) {
    return IncomingTalentRiskCouncilBriefStatus.watch;
  }
  return IncomingTalentRiskCouncilBriefStatus.clear;
}

double _readinessRatio({
  required int pendingDecisionCount,
  required int waitingFollowUpCount,
  required int openFollowUpCount,
  required int completedFollowUpCount,
}) {
  final total =
      pendingDecisionCount +
      waitingFollowUpCount +
      openFollowUpCount +
      completedFollowUpCount;
  if (total == 0) return 1;
  return completedFollowUpCount / total;
}

String _nextAction({
  required int pendingDecisionCount,
  required int blockedSlaCount,
  required int escalatedSlaCount,
  required int overdueSlaCount,
  required int dueSoonSlaCount,
  required int waitingFollowUpCount,
  required int openFollowUpCount,
}) {
  if (blockedSlaCount > 0) {
    return 'Unblock $blockedSlaCount talent risk ${_plural(blockedSlaCount, 'SLA item')} before council.';
  }
  if (escalatedSlaCount > 0) {
    return 'Prepare $escalatedSlaCount people-leadership ${_plural(escalatedSlaCount, 'escalation')} for council.';
  }
  if (overdueSlaCount > 0) {
    return 'Recover $overdueSlaCount overdue talent risk ${_plural(overdueSlaCount, 'SLA item')}.';
  }
  if (pendingDecisionCount > 0) {
    return 'Resolve $pendingDecisionCount pending talent risk council ${_plural(pendingDecisionCount, 'decision')}.';
  }
  if (waitingFollowUpCount > 0) {
    return 'Create $waitingFollowUpCount council ${_plural(waitingFollowUpCount, 'follow-up')} from recorded decisions.';
  }
  if (dueSoonSlaCount > 0) {
    return 'Close $dueSoonSlaCount talent risk ${_plural(dueSoonSlaCount, 'SLA item')} due soon.';
  }
  if (openFollowUpCount > 0) {
    return 'Track $openFollowUpCount active talent risk ${_plural(openFollowUpCount, 'follow-up')} through completion.';
  }
  return 'Talent risk council brief is clear.';
}

List<IncomingTalentRiskCouncilBriefInsight> _insights({
  required List<IncomingTalentRiskCouncilQueueItem> queueItems,
  required List<IncomingTalentRiskCouncilSlaItem> slaItems,
  required int pendingDecisionCount,
  required int criticalDecisionCount,
  required int blockedSlaCount,
  required int escalatedSlaCount,
  required int overdueSlaCount,
  required int dueSoonSlaCount,
  required int waitingFollowUpCount,
  required int openFollowUpCount,
}) {
  final leadershipCount = blockedSlaCount + escalatedSlaCount;
  final insights = <IncomingTalentRiskCouncilBriefInsight>[
    if (leadershipCount > 0)
      IncomingTalentRiskCouncilBriefInsight(
        type: IncomingTalentRiskCouncilBriefInsightType.leadershipAttention,
        tone: IncomingTalentRiskCouncilBriefInsightTone.critical,
        title: 'Leadership attention',
        detail:
            '$leadershipCount blocked or escalated talent risk ${_plural(leadershipCount, 'SLA item')} need council attention.',
        count: leadershipCount,
      ),
    if (overdueSlaCount > 0)
      IncomingTalentRiskCouncilBriefInsight(
        type: IncomingTalentRiskCouncilBriefInsightType.slaRecovery,
        tone: IncomingTalentRiskCouncilBriefInsightTone.critical,
        title: 'SLA recovery',
        detail:
            '$overdueSlaCount talent risk ${_plural(overdueSlaCount, 'SLA item')} are overdue.',
        count: overdueSlaCount,
      ),
    if (pendingDecisionCount > 0)
      IncomingTalentRiskCouncilBriefInsight(
        type: IncomingTalentRiskCouncilBriefInsightType.decisionQueue,
        tone:
            criticalDecisionCount > 0
                ? IncomingTalentRiskCouncilBriefInsightTone.critical
                : IncomingTalentRiskCouncilBriefInsightTone.watch,
        title: 'Decision queue',
        detail:
            '$pendingDecisionCount talent ${_plural(pendingDecisionCount, 'risk')} still need council decision; $criticalDecisionCount are critical.',
        count: pendingDecisionCount,
      ),
    if (waitingFollowUpCount > 0)
      IncomingTalentRiskCouncilBriefInsight(
        type: IncomingTalentRiskCouncilBriefInsightType.followUpCreation,
        tone: IncomingTalentRiskCouncilBriefInsightTone.watch,
        title: 'Follow-up creation',
        detail:
            '$waitingFollowUpCount recorded ${_plural(waitingFollowUpCount, 'decision')} still need a follow-up owner plan.',
        count: waitingFollowUpCount,
      ),
    if (dueSoonSlaCount > 0)
      IncomingTalentRiskCouncilBriefInsight(
        type: IncomingTalentRiskCouncilBriefInsightType.dueSoon,
        tone: IncomingTalentRiskCouncilBriefInsightTone.watch,
        title: 'Due soon',
        detail:
            '$dueSoonSlaCount talent risk ${_plural(dueSoonSlaCount, 'SLA item')} are due within seven days.',
        count: dueSoonSlaCount,
      ),
    if (openFollowUpCount > 0)
      IncomingTalentRiskCouncilBriefInsight(
        type: IncomingTalentRiskCouncilBriefInsightType.execution,
        tone: IncomingTalentRiskCouncilBriefInsightTone.watch,
        title: 'Execution follow-through',
        detail:
            '$openFollowUpCount active talent risk ${_plural(openFollowUpCount, 'follow-up')} need owner updates.',
        count: openFollowUpCount,
      ),
  ];

  if (insights.isNotEmpty) return insights;

  final coveredSignals = queueItems.length + slaItems.length;
  return [
    IncomingTalentRiskCouncilBriefInsight(
      type: IncomingTalentRiskCouncilBriefInsightType.clear,
      tone: IncomingTalentRiskCouncilBriefInsightTone.positive,
      title: 'Council clear',
      detail:
          coveredSignals == 0
              ? 'No active talent risk council signals need leadership attention.'
              : 'Talent risk council signals are covered and ready for monitoring.',
      count: coveredSignals,
    ),
  ];
}

String _plural(int count, String noun) {
  return count == 1 ? noun : '${noun}s';
}
