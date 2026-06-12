import 'incoming_talent_risk_council_commitment_log_item.dart';

class IncomingTalentRiskCouncilCommitmentLogSummary {
  final int totalCount;
  final int clearCount;
  final int readyToPublishCount;
  final int blockedCount;
  final int needsDecisionCount;
  final int needsEvidenceCount;
  final int needsOwnerCount;
  final int attentionCount;
  final double publishableRatio;
  final String nextAction;

  const IncomingTalentRiskCouncilCommitmentLogSummary({
    required this.totalCount,
    required this.clearCount,
    required this.readyToPublishCount,
    required this.blockedCount,
    required this.needsDecisionCount,
    required this.needsEvidenceCount,
    required this.needsOwnerCount,
    required this.attentionCount,
    required this.publishableRatio,
    required this.nextAction,
  });

  factory IncomingTalentRiskCouncilCommitmentLogSummary.fromItems(
    List<IncomingTalentRiskCouncilCommitmentLogItem> items,
  ) {
    final clearCount = _countByStatus(
      items,
      IncomingTalentRiskCouncilCommitmentLogStatus.clear,
    );
    final readyToPublishCount = _countByStatus(
      items,
      IncomingTalentRiskCouncilCommitmentLogStatus.readyToPublish,
    );
    final blockedCount = _countByStatus(
      items,
      IncomingTalentRiskCouncilCommitmentLogStatus.blocked,
    );
    final needsDecisionCount = _countByStatus(
      items,
      IncomingTalentRiskCouncilCommitmentLogStatus.needsDecision,
    );
    final needsEvidenceCount = _countByStatus(
      items,
      IncomingTalentRiskCouncilCommitmentLogStatus.needsEvidence,
    );
    final needsOwnerCount = _countByStatus(
      items,
      IncomingTalentRiskCouncilCommitmentLogStatus.needsOwner,
    );
    final attentionCount = items.where((item) => item.needsAttention).length;
    final publishableCount = clearCount + readyToPublishCount;
    final publishableRatio =
        items.isEmpty ? 1.0 : publishableCount / items.length;

    return IncomingTalentRiskCouncilCommitmentLogSummary(
      totalCount: items.length,
      clearCount: clearCount,
      readyToPublishCount: readyToPublishCount,
      blockedCount: blockedCount,
      needsDecisionCount: needsDecisionCount,
      needsEvidenceCount: needsEvidenceCount,
      needsOwnerCount: needsOwnerCount,
      attentionCount: attentionCount,
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
  List<IncomingTalentRiskCouncilCommitmentLogItem> items,
  IncomingTalentRiskCouncilCommitmentLogStatus status,
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
    return 'Commitment log is ready to publish.';
  }
  if (blockedCount > 0) {
    return 'Resolve $blockedCount blocked council ${_plural(blockedCount, 'commitment')} before publishing.';
  }
  if (needsDecisionCount > 0) {
    return 'Capture $needsDecisionCount council ${_plural(needsDecisionCount, 'decision')} before publishing.';
  }
  if (needsEvidenceCount > 0) {
    return 'Attach evidence for $needsEvidenceCount council ${_plural(needsEvidenceCount, 'commitment')}.';
  }
  if (needsOwnerCount > 0) {
    return 'Confirm owners for $needsOwnerCount council ${_plural(needsOwnerCount, 'commitment')}.';
  }
  return 'Commitment log is ready to publish.';
}

String _plural(int count, String noun) {
  return count == 1 ? noun : '${noun}s';
}
