import 'incoming_talent_risk_council_sla_item.dart';

class IncomingTalentRiskCouncilSlaSummary {
  final int totalCount;
  final int blockedCount;
  final int escalatedCount;
  final int overdueCount;
  final int dueSoonCount;
  final int waitingDecisionCount;
  final int waitingFollowUpCount;
  final int activeFollowUpCount;
  final String nextAction;

  const IncomingTalentRiskCouncilSlaSummary({
    required this.totalCount,
    required this.blockedCount,
    required this.escalatedCount,
    required this.overdueCount,
    required this.dueSoonCount,
    required this.waitingDecisionCount,
    required this.waitingFollowUpCount,
    required this.activeFollowUpCount,
    required this.nextAction,
  });

  factory IncomingTalentRiskCouncilSlaSummary.fromItems(
    List<IncomingTalentRiskCouncilSlaItem> items,
  ) {
    final blockedCount = _countByStatus(
      items,
      IncomingTalentRiskCouncilSlaStatus.blocked,
    );
    final escalatedCount = _countByStatus(
      items,
      IncomingTalentRiskCouncilSlaStatus.escalated,
    );
    final overdueCount = _countByStatus(
      items,
      IncomingTalentRiskCouncilSlaStatus.overdue,
    );
    final dueSoonCount = _countByStatus(
      items,
      IncomingTalentRiskCouncilSlaStatus.dueSoon,
    );
    final waitingDecisionCount = _countBySource(
      items,
      IncomingTalentRiskCouncilSlaSource.councilDecision,
    );
    final waitingFollowUpCount = _countBySource(
      items,
      IncomingTalentRiskCouncilSlaSource.councilFollowUp,
    );
    final activeFollowUpCount = _countBySource(
      items,
      IncomingTalentRiskCouncilSlaSource.followUpExecution,
    );

    return IncomingTalentRiskCouncilSlaSummary(
      totalCount: items.length,
      blockedCount: blockedCount,
      escalatedCount: escalatedCount,
      overdueCount: overdueCount,
      dueSoonCount: dueSoonCount,
      waitingDecisionCount: waitingDecisionCount,
      waitingFollowUpCount: waitingFollowUpCount,
      activeFollowUpCount: activeFollowUpCount,
      nextAction: _nextAction(
        totalCount: items.length,
        blockedCount: blockedCount,
        escalatedCount: escalatedCount,
        overdueCount: overdueCount,
        dueSoonCount: dueSoonCount,
        waitingDecisionCount: waitingDecisionCount,
        waitingFollowUpCount: waitingFollowUpCount,
        activeFollowUpCount: activeFollowUpCount,
      ),
    );
  }
}

int _countByStatus(
  List<IncomingTalentRiskCouncilSlaItem> items,
  IncomingTalentRiskCouncilSlaStatus status,
) {
  return items.where((item) => item.status == status).length;
}

int _countBySource(
  List<IncomingTalentRiskCouncilSlaItem> items,
  IncomingTalentRiskCouncilSlaSource source,
) {
  return items.where((item) => item.source == source).length;
}

String _nextAction({
  required int totalCount,
  required int blockedCount,
  required int escalatedCount,
  required int overdueCount,
  required int dueSoonCount,
  required int waitingDecisionCount,
  required int waitingFollowUpCount,
  required int activeFollowUpCount,
}) {
  if (totalCount == 0) return 'Talent risk SLAs are clear.';
  if (blockedCount > 0) {
    return 'Unblock $blockedCount talent risk SLA ${_plural(blockedCount, 'item')}.';
  }
  if (escalatedCount > 0) {
    return 'Track $escalatedCount escalated talent risk SLA ${_plural(escalatedCount, 'item')}.';
  }
  if (overdueCount > 0) {
    return 'Recover $overdueCount overdue talent risk SLA ${_plural(overdueCount, 'item')}.';
  }
  if (dueSoonCount > 0) {
    return 'Close $dueSoonCount talent risk SLA ${_plural(dueSoonCount, 'item')} due soon.';
  }
  if (waitingDecisionCount > 0) {
    return 'Prepare $waitingDecisionCount talent risk council ${_plural(waitingDecisionCount, 'decision')}.';
  }
  if (waitingFollowUpCount > 0) {
    return 'Create $waitingFollowUpCount talent risk ${_plural(waitingFollowUpCount, 'follow-up')}.';
  }
  if (activeFollowUpCount > 0) {
    return 'Track $activeFollowUpCount active risk ${_plural(activeFollowUpCount, 'follow-up')}.';
  }
  return 'Monitor $totalCount active talent risk SLA ${_plural(totalCount, 'item')}.';
}

String _plural(int count, String noun) {
  return count == 1 ? noun : '${noun}s';
}
