import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/employee_workflow_inbox_models.dart';
import '../models/employee_workflow_inbox_sla_models.dart';
import 'employee_workflow_inbox_provider.dart';

/// Builds a cross-source SLA health profile for one employee workflow inbox.
final employeeWorkflowInboxSlaProvider = Provider.family<
  EmployeeWorkflowInboxSlaProfile?,
  String
>((ref, employeeId) {
  final inbox = ref.watch(employeeWorkflowInboxProvider(employeeId));
  if (inbox == null) return null;

  final signals =
      inbox.items.map((item) => _signalForItem(item, inbox.asOfDate)).toList();

  return EmployeeWorkflowInboxSlaProfile(
    employeeId: inbox.employeeId,
    employeeName: inbox.employeeName,
    asOfDate: inbox.asOfDate,
    signals: signals,
    ownerLoads: _ownerLoads(signals),
  );
});

EmployeeWorkflowInboxSlaSignal _signalForItem(
  EmployeeWorkflowInboxItem item,
  DateTime asOfDate,
) {
  final state = employeeWorkflowInboxSlaStateForItem(
    item: item,
    asOfDate: asOfDate,
  );
  final escalation = employeeWorkflowInboxEscalationForItem(
    item: item,
    state: state,
  );
  final today = DateTime(asOfDate.year, asOfDate.month, asOfDate.day);
  final dueDate = DateTime(
    item.dueDate.year,
    item.dueDate.month,
    item.dueDate.day,
  );

  return EmployeeWorkflowInboxSlaSignal(
    itemId: item.id,
    sourceRecordId: item.sourceRecordId,
    title: item.title,
    owner: item.owner,
    source: item.source,
    action: item.primaryAction,
    area: item.area,
    priority: item.priority,
    dueDate: dueDate,
    daysUntilDue: dueDate.difference(today).inDays,
    isReady: item.isReady,
    state: state,
    escalationLevel: escalation,
    recommendation: employeeWorkflowInboxSlaRecommendation(
      isReady: item.isReady,
      state: state,
      escalation: escalation,
    ),
  );
}

List<EmployeeWorkflowInboxSlaOwnerLoad> _ownerLoads(
  List<EmployeeWorkflowInboxSlaSignal> signals,
) {
  final byOwner = <String, List<EmployeeWorkflowInboxSlaSignal>>{};
  for (final signal in signals) {
    byOwner.putIfAbsent(signal.owner, () => []).add(signal);
  }

  final loads =
      byOwner.entries.map((entry) {
        final ownerSignals = entry.value;
        return EmployeeWorkflowInboxSlaOwnerLoad(
          owner: entry.key,
          activeCount: ownerSignals.length,
          readyCount: ownerSignals.where((signal) => signal.isReady).length,
          overdueCount:
              ownerSignals
                  .where(
                    (signal) =>
                        signal.state == EmployeeWorkflowInboxSlaState.overdue,
                  )
                  .length,
          dueSoonCount:
              ownerSignals
                  .where(
                    (signal) =>
                        signal.state ==
                            EmployeeWorkflowInboxSlaState.dueToday ||
                        signal.state == EmployeeWorkflowInboxSlaState.dueSoon,
                  )
                  .length,
          leadershipCount:
              ownerSignals
                  .where(
                    (signal) =>
                        signal.escalationLevel ==
                        EmployeeWorkflowInboxEscalationLevel.leadership,
                  )
                  .length,
        );
      }).toList();

  loads.sort((a, b) {
    final riskCompare = _riskRank(a).compareTo(_riskRank(b));
    if (riskCompare != 0) return riskCompare;
    final activeCompare = b.activeCount.compareTo(a.activeCount);
    if (activeCompare != 0) return activeCompare;
    return a.owner.compareTo(b.owner);
  });
  return loads;
}

int _riskRank(EmployeeWorkflowInboxSlaOwnerLoad load) {
  if (load.leadershipCount > 0) return 0;
  if (load.overdueCount > 0) return 1;
  if (load.readyCount > 0) return 2;
  if (load.dueSoonCount > 0) return 3;
  return 4;
}
