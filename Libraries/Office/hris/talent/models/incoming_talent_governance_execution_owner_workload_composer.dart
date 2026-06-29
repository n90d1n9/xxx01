import 'incoming_talent_governance_execution_action.dart';
import 'incoming_talent_governance_execution_owner_workload_item.dart';

/// Builds owner workload items from governance execution actions.
List<IncomingTalentGovernanceExecutionOwnerWorkloadItem>
buildIncomingTalentGovernanceExecutionOwnerWorkloads({
  required List<IncomingTalentGovernanceExecutionAction> actions,
}) {
  final byOwner = <String, List<IncomingTalentGovernanceExecutionAction>>{};

  for (final action in actions) {
    final ownerName =
        action.ownerName.trim().isEmpty
            ? 'Unassigned owner'
            : action.ownerName.trim();
    byOwner.putIfAbsent(ownerName, () => []).add(action);
  }

  final workloads =
      byOwner.entries.map((entry) {
          return _workloadForOwner(ownerName: entry.key, actions: entry.value);
        }).toList()
        ..sort(_compareWorkloads);

  return workloads;
}

IncomingTalentGovernanceExecutionOwnerWorkloadItem _workloadForOwner({
  required String ownerName,
  required List<IncomingTalentGovernanceExecutionAction> actions,
}) {
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
  final signalCount = actions.fold<int>(
    0,
    (total, action) => total + action.signalCount,
  );
  final decisionCount = actions.fold<int>(
    0,
    (total, action) => total + action.decisionCount,
  );
  final readinessTaskCount = actions.fold<int>(
    0,
    (total, action) => total + action.readinessTaskCount,
  );
  final progressTotal = actions.fold<double>(
    0,
    (total, action) => total + action.normalizedProgressRatio,
  );
  final averageProgressRatio =
      actions.isEmpty ? 1.0 : progressTotal / actions.length;
  final earliestDueDate = _earliestDueDate(actions);
  final load = _loadFor(
    actionCount: actions.length,
    criticalActionCount: criticalActionCount,
    highActionCount: highActionCount,
    overdueActionCount: overdueActionCount,
    signalCount: signalCount,
  );

  return IncomingTalentGovernanceExecutionOwnerWorkloadItem(
    ownerName: ownerName,
    load: load,
    actionCount: actions.length,
    criticalActionCount: criticalActionCount,
    highActionCount: highActionCount,
    standardActionCount: standardActionCount,
    overdueActionCount: overdueActionCount,
    signalCount: signalCount,
    decisionCount: decisionCount,
    readinessTaskCount: readinessTaskCount,
    earliestDueDate: earliestDueDate,
    averageProgressRatio: averageProgressRatio,
    nextAction: _nextAction(
      ownerName: ownerName,
      criticalActionCount: criticalActionCount,
      highActionCount: highActionCount,
      overdueActionCount: overdueActionCount,
      actionCount: actions.length,
    ),
    actionIds: actions.map((action) => action.id).toList(),
  );
}

int _countByPriority(
  List<IncomingTalentGovernanceExecutionAction> actions,
  IncomingTalentGovernanceExecutionActionPriority priority,
) {
  return actions.where((action) => action.priority == priority).length;
}

DateTime _earliestDueDate(
  List<IncomingTalentGovernanceExecutionAction> actions,
) {
  final dueDates = actions.map((action) => action.dueDate).toList()..sort();
  return dueDates.first;
}

IncomingTalentGovernanceExecutionOwnerLoad _loadFor({
  required int actionCount,
  required int criticalActionCount,
  required int highActionCount,
  required int overdueActionCount,
  required int signalCount,
}) {
  if (overdueActionCount > 0 || criticalActionCount > 0) {
    return IncomingTalentGovernanceExecutionOwnerLoad.critical;
  }
  if (highActionCount > 0 || actionCount >= 3 || signalCount >= 6) {
    return IncomingTalentGovernanceExecutionOwnerLoad.stretched;
  }
  return IncomingTalentGovernanceExecutionOwnerLoad.balanced;
}

String _nextAction({
  required String ownerName,
  required int criticalActionCount,
  required int highActionCount,
  required int overdueActionCount,
  required int actionCount,
}) {
  if (overdueActionCount > 0) {
    return 'Rebalance $overdueActionCount overdue governance execution ${_plural(overdueActionCount, 'action')} from $ownerName.';
  }
  if (criticalActionCount > 0) {
    return 'Help $ownerName close $criticalActionCount critical governance execution ${_plural(criticalActionCount, 'action')}.';
  }
  if (highActionCount > 0) {
    return 'Support $ownerName on $highActionCount high-priority governance execution ${_plural(highActionCount, 'action')}.';
  }
  return 'Track $actionCount governance execution ${_plural(actionCount, 'action')} with $ownerName.';
}

int _compareWorkloads(
  IncomingTalentGovernanceExecutionOwnerWorkloadItem left,
  IncomingTalentGovernanceExecutionOwnerWorkloadItem right,
) {
  final urgency = left.urgencyRank.compareTo(right.urgencyRank);
  if (urgency != 0) return urgency;

  final overdue = right.overdueActionCount.compareTo(left.overdueActionCount);
  if (overdue != 0) return overdue;

  final critical = right.criticalActionCount.compareTo(
    left.criticalActionCount,
  );
  if (critical != 0) return critical;

  final actions = right.actionCount.compareTo(left.actionCount);
  if (actions != 0) return actions;

  final signals = right.signalCount.compareTo(left.signalCount);
  if (signals != 0) return signals;

  final dueDate = left.earliestDueDate.compareTo(right.earliestDueDate);
  if (dueDate != 0) return dueDate;

  return left.ownerName.compareTo(right.ownerName);
}

String _plural(int count, String noun) {
  return count == 1 ? noun : '${noun}s';
}
