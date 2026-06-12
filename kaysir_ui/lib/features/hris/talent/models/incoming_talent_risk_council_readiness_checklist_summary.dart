import 'incoming_talent_risk_council_readiness_checklist_item.dart';

class IncomingTalentRiskCouncilReadinessChecklistSummary {
  final int totalCount;
  final int readyCount;
  final int needsPrepCount;
  final int blockedCount;
  final int overdueCount;
  final int attentionCount;
  final double readinessRatio;
  final String nextAction;

  const IncomingTalentRiskCouncilReadinessChecklistSummary({
    required this.totalCount,
    required this.readyCount,
    required this.needsPrepCount,
    required this.blockedCount,
    required this.overdueCount,
    required this.attentionCount,
    required this.readinessRatio,
    required this.nextAction,
  });

  factory IncomingTalentRiskCouncilReadinessChecklistSummary.fromItems(
    List<IncomingTalentRiskCouncilReadinessChecklistItem> items,
  ) {
    final readyCount = _countByStatus(
      items,
      IncomingTalentRiskCouncilReadinessChecklistStatus.ready,
    );
    final needsPrepCount = _countByStatus(
      items,
      IncomingTalentRiskCouncilReadinessChecklistStatus.needsPrep,
    );
    final blockedCount = _countByStatus(
      items,
      IncomingTalentRiskCouncilReadinessChecklistStatus.blocked,
    );
    final overdueCount = _countByStatus(
      items,
      IncomingTalentRiskCouncilReadinessChecklistStatus.overdue,
    );
    final attentionCount = items.where((item) => item.needsAttention).length;
    final readinessRatio = items.isEmpty ? 1.0 : readyCount / items.length;

    return IncomingTalentRiskCouncilReadinessChecklistSummary(
      totalCount: items.length,
      readyCount: readyCount,
      needsPrepCount: needsPrepCount,
      blockedCount: blockedCount,
      overdueCount: overdueCount,
      attentionCount: attentionCount,
      readinessRatio: readinessRatio,
      nextAction: _nextAction(
        totalCount: items.length,
        needsPrepCount: needsPrepCount,
        blockedCount: blockedCount,
        overdueCount: overdueCount,
        attentionCount: attentionCount,
      ),
    );
  }
}

int _countByStatus(
  List<IncomingTalentRiskCouncilReadinessChecklistItem> items,
  IncomingTalentRiskCouncilReadinessChecklistStatus status,
) {
  return items.where((item) => item.status == status).length;
}

String _nextAction({
  required int totalCount,
  required int needsPrepCount,
  required int blockedCount,
  required int overdueCount,
  required int attentionCount,
}) {
  if (totalCount == 0 || attentionCount == 0) {
    return 'Council readiness checklist is clear.';
  }
  if (blockedCount > 0) {
    return 'Unblock $blockedCount council readiness ${_plural(blockedCount, 'task')}.';
  }
  if (overdueCount > 0) {
    return 'Recover $overdueCount overdue readiness ${_plural(overdueCount, 'task')}.';
  }
  if (needsPrepCount > 0) {
    return 'Complete $needsPrepCount council prep ${_plural(needsPrepCount, 'task')}.';
  }
  return 'Council readiness checklist is clear.';
}

String _plural(int count, String noun) {
  return count == 1 ? noun : '${noun}s';
}
