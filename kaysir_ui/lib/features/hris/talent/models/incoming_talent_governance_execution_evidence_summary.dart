import 'incoming_talent_governance_execution_evidence_item.dart';

/// Summary of governance execution evidence audit readiness.
class IncomingTalentGovernanceExecutionEvidenceSummary {
  final int totalCount;
  final int missingCount;
  final int acceptedCount;
  final int monitorCount;
  final int reopenedCount;
  final int escalatedCount;
  final int attentionCount;
  final int residualRiskCount;
  final int signalCount;
  final int decisionCount;
  final double averageReadinessRatio;
  final String nextAction;

  const IncomingTalentGovernanceExecutionEvidenceSummary({
    required this.totalCount,
    required this.missingCount,
    required this.acceptedCount,
    required this.monitorCount,
    required this.reopenedCount,
    required this.escalatedCount,
    required this.attentionCount,
    required this.residualRiskCount,
    required this.signalCount,
    required this.decisionCount,
    required this.averageReadinessRatio,
    required this.nextAction,
  });

  factory IncomingTalentGovernanceExecutionEvidenceSummary.fromItems(
    List<IncomingTalentGovernanceExecutionEvidenceItem> items,
  ) {
    final missingCount = _countByStatus(
      items,
      IncomingTalentGovernanceExecutionEvidenceStatus.missing,
    );
    final acceptedCount = _countByStatus(
      items,
      IncomingTalentGovernanceExecutionEvidenceStatus.accepted,
    );
    final monitorCount = _countByStatus(
      items,
      IncomingTalentGovernanceExecutionEvidenceStatus.monitor,
    );
    final reopenedCount = _countByStatus(
      items,
      IncomingTalentGovernanceExecutionEvidenceStatus.reopened,
    );
    final escalatedCount = _countByStatus(
      items,
      IncomingTalentGovernanceExecutionEvidenceStatus.escalated,
    );
    final attentionCount = items.where((item) => item.needsAttention).length;
    final residualRiskCount = items.fold<int>(
      0,
      (total, item) => total + item.residualRiskCount,
    );
    final signalCount = items.fold<int>(
      0,
      (total, item) => total + item.signalCount,
    );
    final decisionCount = items.fold<int>(
      0,
      (total, item) => total + item.decisionCount,
    );
    final readinessTotal = items.fold<double>(
      0,
      (total, item) => total + item.normalizedReadinessRatio,
    );
    final averageReadinessRatio =
        items.isEmpty ? 1.0 : readinessTotal / items.length;

    return IncomingTalentGovernanceExecutionEvidenceSummary(
      totalCount: items.length,
      missingCount: missingCount,
      acceptedCount: acceptedCount,
      monitorCount: monitorCount,
      reopenedCount: reopenedCount,
      escalatedCount: escalatedCount,
      attentionCount: attentionCount,
      residualRiskCount: residualRiskCount,
      signalCount: signalCount,
      decisionCount: decisionCount,
      averageReadinessRatio: averageReadinessRatio,
      nextAction: _nextAction(
        totalCount: items.length,
        missingCount: missingCount,
        monitorCount: monitorCount,
        reopenedCount: reopenedCount,
        escalatedCount: escalatedCount,
        attentionCount: attentionCount,
      ),
    );
  }
}

int _countByStatus(
  List<IncomingTalentGovernanceExecutionEvidenceItem> items,
  IncomingTalentGovernanceExecutionEvidenceStatus status,
) {
  return items.where((item) => item.status == status).length;
}

String _nextAction({
  required int totalCount,
  required int missingCount,
  required int monitorCount,
  required int reopenedCount,
  required int escalatedCount,
  required int attentionCount,
}) {
  if (totalCount == 0) {
    return 'Governance execution evidence register is clear.';
  }
  if (escalatedCount > 0) {
    return 'Escalate $escalatedCount governance evidence ${_plural(escalatedCount, 'record')}.';
  }
  if (reopenedCount > 0) {
    return 'Reopen $reopenedCount governance evidence ${_plural(reopenedCount, 'record')}.';
  }
  if (missingCount > 0) {
    return 'Attach evidence for $missingCount governance execution ${_plural(missingCount, 'action')}.';
  }
  if (monitorCount > 0 || attentionCount > 0) {
    return 'Review $attentionCount governance evidence ${_plural(attentionCount, 'record')} with residual risk.';
  }
  return 'Governance execution evidence is audit-ready.';
}

String _plural(int count, String noun) {
  return count == 1 ? noun : '${noun}s';
}
