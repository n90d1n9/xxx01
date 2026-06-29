import 'incoming_talent_governance_execution_closure.dart';

/// Aggregates governance execution closures into follow-through health.
class IncomingTalentGovernanceExecutionClosureSummary {
  final int totalCount;
  final int completedCount;
  final int monitorCount;
  final int reopenedCount;
  final int escalatedCount;
  final int attentionCount;
  final int residualRiskCount;
  final int signalCount;
  final int decisionCount;
  final String nextAction;

  const IncomingTalentGovernanceExecutionClosureSummary({
    required this.totalCount,
    required this.completedCount,
    required this.monitorCount,
    required this.reopenedCount,
    required this.escalatedCount,
    required this.attentionCount,
    required this.residualRiskCount,
    required this.signalCount,
    required this.decisionCount,
    required this.nextAction,
  });

  factory IncomingTalentGovernanceExecutionClosureSummary.fromClosures(
    List<IncomingTalentGovernanceExecutionClosure> closures,
  ) {
    final completedCount = _countByOutcome(
      closures,
      IncomingTalentGovernanceExecutionClosureOutcome.completed,
    );
    final monitorCount = _countByOutcome(
      closures,
      IncomingTalentGovernanceExecutionClosureOutcome.monitor,
    );
    final reopenedCount = _countByOutcome(
      closures,
      IncomingTalentGovernanceExecutionClosureOutcome.reopened,
    );
    final escalatedCount = _countByOutcome(
      closures,
      IncomingTalentGovernanceExecutionClosureOutcome.escalated,
    );
    final attentionCount =
        closures.where((closure) => closure.needsAttention).length;
    final residualRiskCount = closures.fold<int>(
      0,
      (total, closure) => total + closure.residualRiskCount,
    );
    final signalCount = closures.fold<int>(
      0,
      (total, closure) => total + closure.signalCount,
    );
    final decisionCount = closures.fold<int>(
      0,
      (total, closure) => total + closure.decisionCount,
    );

    return IncomingTalentGovernanceExecutionClosureSummary(
      totalCount: closures.length,
      completedCount: completedCount,
      monitorCount: monitorCount,
      reopenedCount: reopenedCount,
      escalatedCount: escalatedCount,
      attentionCount: attentionCount,
      residualRiskCount: residualRiskCount,
      signalCount: signalCount,
      decisionCount: decisionCount,
      nextAction: _nextAction(
        totalCount: closures.length,
        completedCount: completedCount,
        monitorCount: monitorCount,
        reopenedCount: reopenedCount,
        escalatedCount: escalatedCount,
        attentionCount: attentionCount,
      ),
    );
  }
}

int _countByOutcome(
  List<IncomingTalentGovernanceExecutionClosure> closures,
  IncomingTalentGovernanceExecutionClosureOutcome outcome,
) {
  return closures.where((closure) => closure.outcome == outcome).length;
}

String _nextAction({
  required int totalCount,
  required int completedCount,
  required int monitorCount,
  required int reopenedCount,
  required int escalatedCount,
  required int attentionCount,
}) {
  if (totalCount == 0) {
    return 'Close governance execution actions with evidence.';
  }
  if (escalatedCount > 0) {
    return 'Escalate $escalatedCount unresolved governance execution ${_plural(escalatedCount, 'closure')}.';
  }
  if (reopenedCount > 0) {
    return 'Reopen $reopenedCount governance execution ${_plural(reopenedCount, 'closure')}.';
  }
  if (monitorCount > 0 || attentionCount > 0) {
    return 'Monitor $attentionCount governance execution ${_plural(attentionCount, 'closure')} with residual risk.';
  }
  return '$completedCount governance execution ${_plural(completedCount, 'closure')} completed.';
}

String _plural(int count, String noun) {
  return count == 1 ? noun : '${noun}s';
}
