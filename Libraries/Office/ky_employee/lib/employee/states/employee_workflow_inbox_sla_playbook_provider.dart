import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/employee_workflow_inbox_models.dart';
import '../models/employee_workflow_inbox_sla_models.dart';
import '../models/employee_workflow_inbox_sla_playbook_models.dart';
import 'employee_workflow_inbox_sla_provider.dart';

/// Builds prioritized recovery steps for one employee workflow inbox SLA profile.
final employeeWorkflowInboxSlaPlaybookProvider =
    Provider.family<EmployeeWorkflowInboxSlaPlaybook?, String>((
      ref,
      employeeId,
    ) {
      final sla = ref.watch(employeeWorkflowInboxSlaProvider(employeeId));
      if (sla == null) return null;

      return EmployeeWorkflowInboxSlaPlaybook(
        employeeId: sla.employeeId,
        employeeName: sla.employeeName,
        asOfDate: sla.asOfDate,
        steps: _stepsForProfile(sla),
      );
    });

List<EmployeeWorkflowInboxSlaPlaybookStep> _stepsForProfile(
  EmployeeWorkflowInboxSlaProfile sla,
) {
  final steps = <EmployeeWorkflowInboxSlaPlaybookStep>[];
  final leadershipSignals =
      sla.signals
          .where(
            (signal) =>
                signal.escalationLevel ==
                EmployeeWorkflowInboxEscalationLevel.leadership,
          )
          .toList();
  final managerSignals =
      sla.signals
          .where(
            (signal) =>
                signal.escalationLevel ==
                EmployeeWorkflowInboxEscalationLevel.manager,
          )
          .toList();
  final readySignals = sla.signals.where((signal) => signal.isReady).toList();
  final overdueSignals =
      sla.signals
          .where(
            (signal) => signal.state == EmployeeWorkflowInboxSlaState.overdue,
          )
          .toList();
  final dueSoonSignals =
      sla.signals
          .where(
            (signal) =>
                signal.state == EmployeeWorkflowInboxSlaState.dueToday ||
                signal.state == EmployeeWorkflowInboxSlaState.dueSoon,
          )
          .toList();

  if (leadershipSignals.isNotEmpty) {
    steps.add(
      _step(
        id: 'leadership',
        type: EmployeeWorkflowInboxSlaPlaybookStepType.leadershipEscalation,
        urgency: EmployeeWorkflowInboxSlaPlaybookUrgency.critical,
        title: 'Escalate leadership-risk inbox SLAs',
        detail:
            'Unblock high-impact overdue workflow items with HR leadership.',
        owner: 'HR Leadership',
        signals: leadershipSignals,
        fallbackDate: sla.asOfDate,
      ),
    );
  }

  if (managerSignals.isNotEmpty) {
    steps.add(
      _step(
        id: 'manager',
        type: EmployeeWorkflowInboxSlaPlaybookStepType.managerEscalation,
        urgency: EmployeeWorkflowInboxSlaPlaybookUrgency.high,
        title: 'Escalate owner-manager SLA risks',
        detail:
            'Ask owner managers to recover blocked inbox commitments today.',
        owner: 'Owner Managers',
        signals: managerSignals,
        fallbackDate: sla.asOfDate,
      ),
    );
  }

  if (readySignals.isNotEmpty) {
    steps.add(
      _step(
        id: 'ready',
        type: EmployeeWorkflowInboxSlaPlaybookStepType.readyClearance,
        urgency: EmployeeWorkflowInboxSlaPlaybookUrgency.high,
        title: 'Clear ready inbox actions',
        detail: 'Run ready workflow actions before the SLA queue drifts.',
        owner: _ownerLabel(readySignals),
        signals: readySignals,
        fallbackDate: sla.asOfDate,
      ),
    );
  }

  if (overdueSignals.isNotEmpty) {
    steps.add(
      _step(
        id: 'overdue',
        type: EmployeeWorkflowInboxSlaPlaybookStepType.overdueRecovery,
        urgency: EmployeeWorkflowInboxSlaPlaybookUrgency.high,
        title: 'Recover overdue inbox items',
        detail: 'Re-baseline or close overdue workflow commitments today.',
        owner: _ownerLabel(overdueSignals),
        signals: overdueSignals,
        fallbackDate: sla.asOfDate,
      ),
    );
  }

  final riskyLoads =
      sla.ownerLoads.where((load) => load.needsBalancing).toList();
  if (riskyLoads.isNotEmpty) {
    steps.add(
      EmployeeWorkflowInboxSlaPlaybookStep(
        id: 'owner-rebalance',
        type: EmployeeWorkflowInboxSlaPlaybookStepType.ownerRebalance,
        urgency: EmployeeWorkflowInboxSlaPlaybookUrgency.medium,
        title: 'Rebalance overloaded workflow owners',
        detail:
            'Move backup ownership or clear queued work for ${_ownerLoadLabel(riskyLoads)}.',
        owner: 'People Operations',
        signalIds: _signalIdsForOwners(sla.signals, riskyLoads),
        sources: _sourcesForSignals(
          sla.signals.where(
            (signal) => riskyLoads.any((load) => load.owner == signal.owner),
          ),
        ),
        dueDate: sla.asOfDate,
      ),
    );
  }

  if (dueSoonSignals.isNotEmpty) {
    steps.add(
      _step(
        id: 'due-soon',
        type: EmployeeWorkflowInboxSlaPlaybookStepType.dueSoonWatch,
        urgency: EmployeeWorkflowInboxSlaPlaybookUrgency.medium,
        title: 'Confirm due-soon workflow progress',
        detail:
            'Check owner progress before upcoming workflow due dates breach.',
        owner: _ownerLabel(dueSoonSignals),
        signals: dueSoonSignals,
        fallbackDate: sla.asOfDate,
      ),
    );
  }

  return steps;
}

EmployeeWorkflowInboxSlaPlaybookStep _step({
  required String id,
  required EmployeeWorkflowInboxSlaPlaybookStepType type,
  required EmployeeWorkflowInboxSlaPlaybookUrgency urgency,
  required String title,
  required String detail,
  required String owner,
  required List<EmployeeWorkflowInboxSlaSignal> signals,
  required DateTime fallbackDate,
}) {
  return EmployeeWorkflowInboxSlaPlaybookStep(
    id: id,
    type: type,
    urgency: urgency,
    title: title,
    detail: detail,
    owner: owner,
    signalIds: signals.map((signal) => signal.itemId).toList(),
    sources: _sourcesForSignals(signals),
    dueDate: _earliestDueDate(signals, fallbackDate),
  );
}

String _ownerLabel(List<EmployeeWorkflowInboxSlaSignal> signals) {
  final owners = signals.map((signal) => signal.owner).toSet().toList()..sort();
  if (owners.isEmpty) return 'People Operations';
  if (owners.length == 1) return owners.first;
  return '${owners.length} owners';
}

String _ownerLoadLabel(List<EmployeeWorkflowInboxSlaOwnerLoad> loads) {
  final owners = loads.map((load) => load.owner).toList()..sort();
  if (owners.length == 1) return owners.first;
  return '${owners.length} owners';
}

List<String> _signalIdsForOwners(
  List<EmployeeWorkflowInboxSlaSignal> signals,
  List<EmployeeWorkflowInboxSlaOwnerLoad> loads,
) {
  final owners = loads.map((load) => load.owner).toSet();
  return [
    for (final signal in signals)
      if (owners.contains(signal.owner)) signal.itemId,
  ];
}

List<EmployeeWorkflowInboxSource> _sourcesForSignals(
  Iterable<EmployeeWorkflowInboxSlaSignal> signals,
) {
  final sources =
      signals.map((signal) => signal.source).toSet().toList()
        ..sort((a, b) => a.index.compareTo(b.index));
  return sources;
}

DateTime _earliestDueDate(
  List<EmployeeWorkflowInboxSlaSignal> signals,
  DateTime fallbackDate,
) {
  if (signals.isEmpty) return fallbackDate;
  final sorted = [...signals]..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  return sorted.first.dueDate;
}
