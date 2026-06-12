import 'incoming_talent_governance_review_readiness_item.dart';

/// Summary of governance review preparation health and workload.
class IncomingTalentGovernanceReviewReadinessSummary {
  final int totalCount;
  final int readyCount;
  final int needsPrepCount;
  final int blockedCount;
  final int attentionCount;
  final int decisionQuestionCount;
  final int totalSignalCount;
  final int totalTimeboxMinutes;
  final double readinessRatio;
  final String nextAction;

  const IncomingTalentGovernanceReviewReadinessSummary({
    required this.totalCount,
    required this.readyCount,
    required this.needsPrepCount,
    required this.blockedCount,
    required this.attentionCount,
    required this.decisionQuestionCount,
    required this.totalSignalCount,
    required this.totalTimeboxMinutes,
    required this.readinessRatio,
    required this.nextAction,
  });

  factory IncomingTalentGovernanceReviewReadinessSummary.fromItems(
    List<IncomingTalentGovernanceReviewReadinessItem> items,
  ) {
    final readyCount = _countByStatus(
      items,
      IncomingTalentGovernanceReviewReadinessStatus.ready,
    );
    final needsPrepCount = _countByStatus(
      items,
      IncomingTalentGovernanceReviewReadinessStatus.needsPrep,
    );
    final blockedCount = _countByStatus(
      items,
      IncomingTalentGovernanceReviewReadinessStatus.blocked,
    );
    final attentionCount = items.where((item) => item.needsAttention).length;
    final decisionQuestionCount = items.fold<int>(
      0,
      (total, item) =>
          total + (item.decisionCount < 1 ? 1 : item.decisionCount),
    );
    final totalSignalCount = items.fold<int>(
      0,
      (total, item) => total + item.signalCount,
    );
    final totalTimeboxMinutes = items.fold<int>(
      0,
      (total, item) => total + item.timeboxMinutes,
    );
    final readinessRatio = items.isEmpty ? 1.0 : readyCount / items.length;

    return IncomingTalentGovernanceReviewReadinessSummary(
      totalCount: items.length,
      readyCount: readyCount,
      needsPrepCount: needsPrepCount,
      blockedCount: blockedCount,
      attentionCount: attentionCount,
      decisionQuestionCount: decisionQuestionCount,
      totalSignalCount: totalSignalCount,
      totalTimeboxMinutes: totalTimeboxMinutes,
      readinessRatio: readinessRatio,
      nextAction: _nextAction(
        totalCount: items.length,
        blockedCount: blockedCount,
        needsPrepCount: needsPrepCount,
        attentionCount: attentionCount,
      ),
    );
  }
}

int _countByStatus(
  List<IncomingTalentGovernanceReviewReadinessItem> items,
  IncomingTalentGovernanceReviewReadinessStatus status,
) {
  return items.where((item) => item.status == status).length;
}

String _nextAction({
  required int totalCount,
  required int blockedCount,
  required int needsPrepCount,
  required int attentionCount,
}) {
  if (totalCount == 0 || attentionCount == 0) {
    return 'Governance review prep is ready.';
  }
  if (blockedCount > 0) {
    return 'Unblock $blockedCount governance review prep ${_plural(blockedCount, 'task')}.';
  }
  if (needsPrepCount > 0) {
    return 'Complete $needsPrepCount governance review prep ${_plural(needsPrepCount, 'task')}.';
  }
  return 'Governance review prep is ready.';
}

String _plural(int count, String noun) {
  return count == 1 ? noun : '${noun}s';
}
