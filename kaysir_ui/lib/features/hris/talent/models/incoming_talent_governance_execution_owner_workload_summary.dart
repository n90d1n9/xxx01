import 'incoming_talent_governance_execution_owner_workload_item.dart';

/// Summary of owner workload across governance execution actions.
class IncomingTalentGovernanceExecutionOwnerWorkloadSummary {
  final int ownerCount;
  final int criticalOwnerCount;
  final int stretchedOwnerCount;
  final int balancedOwnerCount;
  final int actionCount;
  final int criticalActionCount;
  final int highActionCount;
  final int overdueActionCount;
  final int attentionOwnerCount;
  final int signalCount;
  final int decisionCount;
  final double averageProgressRatio;
  final String nextAction;

  const IncomingTalentGovernanceExecutionOwnerWorkloadSummary({
    required this.ownerCount,
    required this.criticalOwnerCount,
    required this.stretchedOwnerCount,
    required this.balancedOwnerCount,
    required this.actionCount,
    required this.criticalActionCount,
    required this.highActionCount,
    required this.overdueActionCount,
    required this.attentionOwnerCount,
    required this.signalCount,
    required this.decisionCount,
    required this.averageProgressRatio,
    required this.nextAction,
  });

  factory IncomingTalentGovernanceExecutionOwnerWorkloadSummary.fromItems(
    List<IncomingTalentGovernanceExecutionOwnerWorkloadItem> items,
  ) {
    final criticalOwnerCount = _countByLoad(
      items,
      IncomingTalentGovernanceExecutionOwnerLoad.critical,
    );
    final stretchedOwnerCount = _countByLoad(
      items,
      IncomingTalentGovernanceExecutionOwnerLoad.stretched,
    );
    final balancedOwnerCount = _countByLoad(
      items,
      IncomingTalentGovernanceExecutionOwnerLoad.balanced,
    );
    final actionCount = items.fold<int>(
      0,
      (total, item) => total + item.actionCount,
    );
    final criticalActionCount = items.fold<int>(
      0,
      (total, item) => total + item.criticalActionCount,
    );
    final highActionCount = items.fold<int>(
      0,
      (total, item) => total + item.highActionCount,
    );
    final overdueActionCount = items.fold<int>(
      0,
      (total, item) => total + item.overdueActionCount,
    );
    final attentionOwnerCount =
        items.where((item) => item.needsAttention).length;
    final signalCount = items.fold<int>(
      0,
      (total, item) => total + item.signalCount,
    );
    final decisionCount = items.fold<int>(
      0,
      (total, item) => total + item.decisionCount,
    );
    final progressTotal = items.fold<double>(
      0,
      (total, item) => total + item.normalizedAverageProgressRatio,
    );
    final averageProgressRatio =
        items.isEmpty ? 1.0 : progressTotal / items.length;

    return IncomingTalentGovernanceExecutionOwnerWorkloadSummary(
      ownerCount: items.length,
      criticalOwnerCount: criticalOwnerCount,
      stretchedOwnerCount: stretchedOwnerCount,
      balancedOwnerCount: balancedOwnerCount,
      actionCount: actionCount,
      criticalActionCount: criticalActionCount,
      highActionCount: highActionCount,
      overdueActionCount: overdueActionCount,
      attentionOwnerCount: attentionOwnerCount,
      signalCount: signalCount,
      decisionCount: decisionCount,
      averageProgressRatio: averageProgressRatio,
      nextAction: _nextAction(
        ownerCount: items.length,
        criticalOwnerCount: criticalOwnerCount,
        stretchedOwnerCount: stretchedOwnerCount,
        overdueActionCount: overdueActionCount,
        actionCount: actionCount,
      ),
    );
  }
}

int _countByLoad(
  List<IncomingTalentGovernanceExecutionOwnerWorkloadItem> items,
  IncomingTalentGovernanceExecutionOwnerLoad load,
) {
  return items.where((item) => item.load == load).length;
}

String _nextAction({
  required int ownerCount,
  required int criticalOwnerCount,
  required int stretchedOwnerCount,
  required int overdueActionCount,
  required int actionCount,
}) {
  if (ownerCount == 0) {
    return 'Governance execution owner workload is clear.';
  }
  if (overdueActionCount > 0) {
    return 'Rebalance $overdueActionCount overdue governance execution ${_plural(overdueActionCount, 'action')}.';
  }
  if (criticalOwnerCount > 0) {
    return 'Support $criticalOwnerCount critical governance owner ${_plural(criticalOwnerCount, 'workload')}.';
  }
  if (stretchedOwnerCount > 0) {
    return 'Support $stretchedOwnerCount stretched governance owner ${_plural(stretchedOwnerCount, 'workload')}.';
  }
  return 'Track $actionCount governance owner-owned execution ${_plural(actionCount, 'action')}.';
}

String _plural(int count, String noun) {
  return count == 1 ? noun : '${noun}s';
}
