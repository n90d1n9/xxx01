import 'incoming_talent_governance_decision_ledger_item.dart';

/// Summary of executive talent governance decision ledger publication health.
class IncomingTalentGovernanceDecisionLedgerSummary {
  final int totalCount;
  final int clearCount;
  final int readyToPublishCount;
  final int blockedCount;
  final int needsDecisionCount;
  final int needsEvidenceCount;
  final int needsOwnerCount;
  final int attentionCount;
  final int decisionCount;
  final int signalCount;
  final int totalTimeboxMinutes;
  final double publishableRatio;
  final String nextAction;

  const IncomingTalentGovernanceDecisionLedgerSummary({
    required this.totalCount,
    required this.clearCount,
    required this.readyToPublishCount,
    required this.blockedCount,
    required this.needsDecisionCount,
    required this.needsEvidenceCount,
    required this.needsOwnerCount,
    required this.attentionCount,
    required this.decisionCount,
    required this.signalCount,
    required this.totalTimeboxMinutes,
    required this.publishableRatio,
    required this.nextAction,
  });

  factory IncomingTalentGovernanceDecisionLedgerSummary.fromItems(
    List<IncomingTalentGovernanceDecisionLedgerItem> items,
  ) {
    final clearCount = _countByStatus(
      items,
      IncomingTalentGovernanceDecisionLedgerStatus.clear,
    );
    final readyToPublishCount = _countByStatus(
      items,
      IncomingTalentGovernanceDecisionLedgerStatus.readyToPublish,
    );
    final blockedCount = _countByStatus(
      items,
      IncomingTalentGovernanceDecisionLedgerStatus.blocked,
    );
    final needsDecisionCount = _countByStatus(
      items,
      IncomingTalentGovernanceDecisionLedgerStatus.needsDecision,
    );
    final needsEvidenceCount = _countByStatus(
      items,
      IncomingTalentGovernanceDecisionLedgerStatus.needsEvidence,
    );
    final needsOwnerCount = _countByStatus(
      items,
      IncomingTalentGovernanceDecisionLedgerStatus.needsOwner,
    );
    final attentionCount = items.where((item) => item.needsAttention).length;
    final decisionCount = items.fold<int>(
      0,
      (total, item) =>
          total + (item.decisionCount < 1 ? 1 : item.decisionCount),
    );
    final signalCount = items.fold<int>(
      0,
      (total, item) => total + item.signalCount,
    );
    final totalTimeboxMinutes = items.fold<int>(
      0,
      (total, item) => total + item.timeboxMinutes,
    );
    final publishableCount = clearCount + readyToPublishCount;
    final publishableRatio =
        items.isEmpty ? 1.0 : publishableCount / items.length;

    return IncomingTalentGovernanceDecisionLedgerSummary(
      totalCount: items.length,
      clearCount: clearCount,
      readyToPublishCount: readyToPublishCount,
      blockedCount: blockedCount,
      needsDecisionCount: needsDecisionCount,
      needsEvidenceCount: needsEvidenceCount,
      needsOwnerCount: needsOwnerCount,
      attentionCount: attentionCount,
      decisionCount: decisionCount,
      signalCount: signalCount,
      totalTimeboxMinutes: totalTimeboxMinutes,
      publishableRatio: publishableRatio,
      nextAction: _nextAction(
        totalCount: items.length,
        attentionCount: attentionCount,
        blockedCount: blockedCount,
        needsDecisionCount: needsDecisionCount,
        needsEvidenceCount: needsEvidenceCount,
        needsOwnerCount: needsOwnerCount,
      ),
    );
  }
}

int _countByStatus(
  List<IncomingTalentGovernanceDecisionLedgerItem> items,
  IncomingTalentGovernanceDecisionLedgerStatus status,
) {
  return items.where((item) => item.status == status).length;
}

String _nextAction({
  required int totalCount,
  required int attentionCount,
  required int blockedCount,
  required int needsDecisionCount,
  required int needsEvidenceCount,
  required int needsOwnerCount,
}) {
  if (totalCount == 0 || attentionCount == 0) {
    return 'Talent governance decision ledger is ready to publish.';
  }
  if (blockedCount > 0) {
    return 'Resolve $blockedCount blocked governance ${_plural(blockedCount, 'decision')} before publishing.';
  }
  if (needsDecisionCount > 0) {
    return 'Capture $needsDecisionCount governance ${_plural(needsDecisionCount, 'decision')} before publishing.';
  }
  if (needsEvidenceCount > 0) {
    return 'Attach evidence for $needsEvidenceCount governance ${_plural(needsEvidenceCount, 'decision')}.';
  }
  if (needsOwnerCount > 0) {
    return 'Confirm owners for $needsOwnerCount governance ${_plural(needsOwnerCount, 'decision')}.';
  }
  return 'Talent governance decision ledger is ready to publish.';
}

String _plural(int count, String noun) {
  return count == 1 ? noun : '${noun}s';
}
