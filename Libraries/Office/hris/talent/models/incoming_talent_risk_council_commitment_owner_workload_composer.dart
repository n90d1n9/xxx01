import 'incoming_talent_risk_council_commitment_action.dart';
import 'incoming_talent_risk_council_commitment_owner_workload_item.dart';

List<IncomingTalentRiskCouncilCommitmentOwnerWorkloadItem>
buildIncomingTalentRiskCouncilCommitmentOwnerWorkloads({
  required List<IncomingTalentRiskCouncilCommitmentAction> actions,
  required DateTime asOfDate,
}) {
  final byOwner = <String, List<IncomingTalentRiskCouncilCommitmentAction>>{};
  for (final action in actions) {
    final ownerName =
        action.ownerName.trim().isEmpty
            ? 'Unassigned owner'
            : action.ownerName.trim();
    byOwner.putIfAbsent(ownerName, () => []).add(action);
  }

  final workloads =
      byOwner.entries.map((entry) {
          return _workloadForOwner(
            ownerName: entry.key,
            actions: entry.value,
            asOfDate: asOfDate,
          );
        }).toList()
        ..sort(_compareWorkloads);

  return workloads;
}

IncomingTalentRiskCouncilCommitmentOwnerWorkloadItem _workloadForOwner({
  required String ownerName,
  required List<IncomingTalentRiskCouncilCommitmentAction> actions,
  required DateTime asOfDate,
}) {
  final openCount = actions.where((action) => action.isOpen).length;
  final completedCount =
      actions
          .where(
            (action) =>
                action.status ==
                IncomingTalentRiskCouncilCommitmentActionStatus.completed,
          )
          .length;
  final blockedCount = _countByStatus(
    actions,
    IncomingTalentRiskCouncilCommitmentActionStatus.blocked,
  );
  final escalatedCount = _countByStatus(
    actions,
    IncomingTalentRiskCouncilCommitmentActionStatus.escalated,
  );
  final waitingEvidenceCount = _countByStatus(
    actions,
    IncomingTalentRiskCouncilCommitmentActionStatus.waitingEvidence,
  );
  final dueSoonCount =
      actions.where((action) => action.isDueSoon(asOfDate)).length;
  final overdueCount =
      actions.where((action) => action.isOverdue(asOfDate)).length;
  final attentionCount =
      actions.where((action) => action.needsAttention(asOfDate)).length;
  final sourceCount = actions.fold<int>(0, (sum, action) {
    return sum + action.sourceCount;
  });
  final earliestDueDate = _earliestDueDate(actions, asOfDate);
  final load = _loadFor(
    openCount: openCount,
    blockedCount: blockedCount,
    escalatedCount: escalatedCount,
    waitingEvidenceCount: waitingEvidenceCount,
    dueSoonCount: dueSoonCount,
    overdueCount: overdueCount,
  );

  return IncomingTalentRiskCouncilCommitmentOwnerWorkloadItem(
    ownerName: ownerName,
    load: load,
    totalCount: actions.length,
    openCount: openCount,
    completedCount: completedCount,
    blockedCount: blockedCount,
    escalatedCount: escalatedCount,
    waitingEvidenceCount: waitingEvidenceCount,
    dueSoonCount: dueSoonCount,
    overdueCount: overdueCount,
    attentionCount: attentionCount,
    sourceCount: sourceCount,
    earliestDueDate: earliestDueDate,
    nextAction: _nextAction(
      openCount: openCount,
      blockedCount: blockedCount,
      escalatedCount: escalatedCount,
      waitingEvidenceCount: waitingEvidenceCount,
      dueSoonCount: dueSoonCount,
      overdueCount: overdueCount,
    ),
    actionIds: actions.map((action) => action.id).toList(),
  );
}

int _countByStatus(
  List<IncomingTalentRiskCouncilCommitmentAction> actions,
  IncomingTalentRiskCouncilCommitmentActionStatus status,
) {
  return actions.where((action) => action.status == status).length;
}

DateTime _earliestDueDate(
  List<IncomingTalentRiskCouncilCommitmentAction> actions,
  DateTime asOfDate,
) {
  final dueDates =
      actions
          .where((action) => action.isOpen)
          .map((action) => action.dueDate)
          .toList()
        ..sort();
  if (dueDates.isNotEmpty) return dueDates.first;

  final allDueDates = actions.map((action) => action.dueDate).toList()..sort();
  if (allDueDates.isNotEmpty) return allDueDates.first;

  return asOfDate;
}

IncomingTalentRiskCouncilCommitmentOwnerLoad _loadFor({
  required int openCount,
  required int blockedCount,
  required int escalatedCount,
  required int waitingEvidenceCount,
  required int dueSoonCount,
  required int overdueCount,
}) {
  if (blockedCount > 0 || escalatedCount > 0 || overdueCount > 0) {
    return IncomingTalentRiskCouncilCommitmentOwnerLoad.critical;
  }
  if (waitingEvidenceCount > 0 || dueSoonCount > 1 || openCount >= 3) {
    return IncomingTalentRiskCouncilCommitmentOwnerLoad.stretched;
  }
  if (openCount > 0) {
    return IncomingTalentRiskCouncilCommitmentOwnerLoad.balanced;
  }
  return IncomingTalentRiskCouncilCommitmentOwnerLoad.clear;
}

String _nextAction({
  required int openCount,
  required int blockedCount,
  required int escalatedCount,
  required int waitingEvidenceCount,
  required int dueSoonCount,
  required int overdueCount,
}) {
  if (blockedCount > 0) {
    return 'Unblock $blockedCount owner commitment ${_plural(blockedCount, 'action')}.';
  }
  if (escalatedCount > 0) {
    return 'Support $escalatedCount escalated owner commitment ${_plural(escalatedCount, 'action')}.';
  }
  if (overdueCount > 0) {
    return 'Recover $overdueCount overdue owner commitment ${_plural(overdueCount, 'action')}.';
  }
  if (waitingEvidenceCount > 0) {
    return 'Attach evidence for $waitingEvidenceCount owner commitment ${_plural(waitingEvidenceCount, 'action')}.';
  }
  if (dueSoonCount > 0) {
    return 'Close $dueSoonCount owner commitment ${_plural(dueSoonCount, 'action')} due soon.';
  }
  if (openCount > 0) {
    return 'Track $openCount open owner commitment ${_plural(openCount, 'action')}.';
  }
  return 'Owner commitments are complete.';
}

int _compareWorkloads(
  IncomingTalentRiskCouncilCommitmentOwnerWorkloadItem left,
  IncomingTalentRiskCouncilCommitmentOwnerWorkloadItem right,
) {
  final urgency = left.urgencyRank.compareTo(right.urgencyRank);
  if (urgency != 0) return urgency;

  final attention = right.attentionCount.compareTo(left.attentionCount);
  if (attention != 0) return attention;

  final open = right.openCount.compareTo(left.openCount);
  if (open != 0) return open;

  final dueDate = left.earliestDueDate.compareTo(right.earliestDueDate);
  if (dueDate != 0) return dueDate;

  return left.ownerName.compareTo(right.ownerName);
}

String _plural(int count, String noun) {
  return count == 1 ? noun : '${noun}s';
}
