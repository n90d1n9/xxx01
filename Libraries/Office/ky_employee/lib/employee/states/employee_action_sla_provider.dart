import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/employee_action_sla_models.dart';
import '../models/employee_action_workflow_models.dart';
import '../models/employee_next_action_models.dart';
import 'employee_action_workflow_provider.dart';

final employeeActionSlaProfileProvider =
    Provider.family<EmployeeActionSlaProfile?, String>((ref, employeeId) {
      final workflow = ref.watch(employeeActionWorkflowProvider(employeeId));
      if (workflow == null) return null;

      final signals =
          workflow.tasks
              .map((task) => _signalForTask(task, workflow.asOfDate))
              .toList();

      return EmployeeActionSlaProfile(
        employeeId: workflow.employeeId,
        employeeName: workflow.employeeName,
        asOfDate: workflow.asOfDate,
        signals: signals,
        ownerLoads: _ownerLoads(signals),
      );
    });

EmployeeActionSlaSignal _signalForTask(
  EmployeeActionTask task,
  DateTime asOfDate,
) {
  final state = employeeActionSlaStateForTask(task: task, asOfDate: asOfDate);
  final escalation = employeeActionEscalationForTask(task: task, state: state);
  final today = DateTime(asOfDate.year, asOfDate.month, asOfDate.day);
  final dueDate = DateTime(
    task.dueDate.year,
    task.dueDate.month,
    task.dueDate.day,
  );

  return EmployeeActionSlaSignal(
    taskId: task.id,
    title: task.title,
    owner: task.owner,
    area: task.area,
    priority: task.priority,
    taskStatus: task.status,
    sourceLabel: task.sourceLabel,
    dueDate: dueDate,
    daysUntilDue: dueDate.difference(today).inDays,
    state: state,
    escalationLevel: escalation,
    recommendation: employeeActionSlaRecommendation(
      state: state,
      escalation: escalation,
    ),
  );
}

List<EmployeeActionOwnerLoad> _ownerLoads(
  List<EmployeeActionSlaSignal> signals,
) {
  final byOwner = <String, List<EmployeeActionSlaSignal>>{};
  for (final signal in signals) {
    if (signal.state == EmployeeActionSlaState.closed) continue;
    byOwner.putIfAbsent(signal.owner, () => []).add(signal);
  }

  final loads =
      byOwner.entries.map((entry) {
        final ownerSignals = entry.value;
        return EmployeeActionOwnerLoad(
          owner: entry.key,
          activeCount: ownerSignals.length,
          overdueCount:
              ownerSignals
                  .where(
                    (signal) => signal.state == EmployeeActionSlaState.overdue,
                  )
                  .length,
          dueSoonCount:
              ownerSignals
                  .where(
                    (signal) =>
                        signal.state == EmployeeActionSlaState.dueToday ||
                        signal.state == EmployeeActionSlaState.dueSoon,
                  )
                  .length,
          criticalCount:
              ownerSignals
                  .where(
                    (signal) =>
                        signal.priority == EmployeeNextActionPriority.critical,
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

int _riskRank(EmployeeActionOwnerLoad load) {
  if (load.overdueCount > 0) return 0;
  if (load.criticalCount > 1) return 1;
  if (load.dueSoonCount > 0) return 2;
  return 3;
}
