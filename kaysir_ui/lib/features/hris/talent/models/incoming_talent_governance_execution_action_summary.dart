import 'incoming_talent_governance_execution_action.dart';

/// Summary of owner-ready governance execution actions.
class IncomingTalentGovernanceExecutionActionSummary {
  final int actionCount;
  final int criticalActionCount;
  final int highActionCount;
  final int standardActionCount;
  final int overdueActionCount;
  final int ownerCount;
  final int signalCount;
  final int decisionCount;
  final double averageProgressRatio;
  final String nextAction;

  const IncomingTalentGovernanceExecutionActionSummary({
    required this.actionCount,
    required this.criticalActionCount,
    required this.highActionCount,
    required this.standardActionCount,
    required this.overdueActionCount,
    required this.ownerCount,
    required this.signalCount,
    required this.decisionCount,
    required this.averageProgressRatio,
    required this.nextAction,
  });

  factory IncomingTalentGovernanceExecutionActionSummary.fromActions(
    List<IncomingTalentGovernanceExecutionAction> actions,
  ) {
    final criticalActionCount = _countByPriority(
      actions,
      IncomingTalentGovernanceExecutionActionPriority.critical,
    );
    final highActionCount = _countByPriority(
      actions,
      IncomingTalentGovernanceExecutionActionPriority.high,
    );
    final standardActionCount = _countByPriority(
      actions,
      IncomingTalentGovernanceExecutionActionPriority.standard,
    );
    final overdueActionCount = actions.where((action) => action.overdue).length;
    final ownerCount = actions.map((action) => action.ownerName).toSet().length;
    final signalCount = actions.fold<int>(
      0,
      (total, action) => total + action.signalCount,
    );
    final decisionCount = actions.fold<int>(
      0,
      (total, action) => total + action.decisionCount,
    );
    final progressTotal = actions.fold<double>(
      0,
      (total, action) => total + action.normalizedProgressRatio,
    );
    final averageProgressRatio =
        actions.isEmpty ? 1.0 : progressTotal / actions.length;

    return IncomingTalentGovernanceExecutionActionSummary(
      actionCount: actions.length,
      criticalActionCount: criticalActionCount,
      highActionCount: highActionCount,
      standardActionCount: standardActionCount,
      overdueActionCount: overdueActionCount,
      ownerCount: ownerCount,
      signalCount: signalCount,
      decisionCount: decisionCount,
      averageProgressRatio: averageProgressRatio,
      nextAction: _nextAction(
        actionCount: actions.length,
        criticalActionCount: criticalActionCount,
        highActionCount: highActionCount,
        overdueActionCount: overdueActionCount,
      ),
    );
  }
}

int _countByPriority(
  List<IncomingTalentGovernanceExecutionAction> actions,
  IncomingTalentGovernanceExecutionActionPriority priority,
) {
  return actions.where((action) => action.priority == priority).length;
}

String _nextAction({
  required int actionCount,
  required int criticalActionCount,
  required int highActionCount,
  required int overdueActionCount,
}) {
  if (actionCount == 0) {
    return 'Governance execution action board is clear.';
  }
  if (criticalActionCount > 0) {
    return 'Close $criticalActionCount critical governance execution ${_plural(criticalActionCount, 'action')}.';
  }
  if (overdueActionCount > 0) {
    return 'Recover $overdueActionCount overdue governance execution ${_plural(overdueActionCount, 'action')}.';
  }
  if (highActionCount > 0) {
    return 'Close $highActionCount high-priority governance execution ${_plural(highActionCount, 'action')}.';
  }
  return 'Track $actionCount governance execution ${_plural(actionCount, 'action')}.';
}

String _plural(int count, String noun) {
  return count == 1 ? noun : '${noun}s';
}
