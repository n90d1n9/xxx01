import 'incoming_talent_risk_council_agenda_item.dart';
import 'incoming_talent_risk_council_commitment_log_item.dart';
import 'incoming_talent_risk_council_readiness_checklist_item.dart';

List<IncomingTalentRiskCouncilCommitmentLogItem>
buildIncomingTalentRiskCouncilCommitmentLog({
  required List<IncomingTalentRiskCouncilAgendaItem> agendaItems,
  required List<IncomingTalentRiskCouncilReadinessChecklistItem> readinessItems,
  required DateTime asOfDate,
}) {
  if (agendaItems.isEmpty) {
    return [
      _clearCommitmentItem(
        agendaItemId: 'risk-council-agenda:empty',
        readinessTaskIds: const [],
        asOfDate: asOfDate,
      ),
    ];
  }

  final readinessById = {for (final item in readinessItems) item.id: item};
  final items =
      agendaItems.map((agendaItem) {
          final linkedReadinessItems =
              agendaItem.readinessTaskIds
                  .map((id) => readinessById[id])
                  .whereType<IncomingTalentRiskCouncilReadinessChecklistItem>()
                  .toList();
          if (agendaItem.section ==
              IncomingTalentRiskCouncilAgendaSection.clear) {
            return _clearCommitmentItem(
              agendaItemId: agendaItem.id,
              readinessTaskIds: agendaItem.readinessTaskIds,
              asOfDate: asOfDate,
            );
          }
          return IncomingTalentRiskCouncilCommitmentLogItem(
            id: 'risk-council-commitment:${agendaItem.id}',
            agendaItemId: agendaItem.id,
            type: _typeFor(agendaItem.section),
            status: _statusFor(
              agendaItem: agendaItem,
              readinessItems: linkedReadinessItems,
            ),
            title: _titleFor(agendaItem.section),
            commitment: _commitmentFor(agendaItem.section),
            evidenceExpectation: _evidenceFor(agendaItem.section),
            ownerName: agendaItem.facilitatorName,
            dueDate: _dueDateFor(
              agendaItem: agendaItem,
              readinessItems: linkedReadinessItems,
              asOfDate: asOfDate,
            ),
            sourceCount: _sourceCountFor(
              agendaItem: agendaItem,
              readinessItems: linkedReadinessItems,
            ),
            readinessTaskIds: agendaItem.readinessTaskIds,
          );
        }).toList()
        ..sort(_compareCommitments);

  return items;
}

IncomingTalentRiskCouncilCommitmentLogItem _clearCommitmentItem({
  required String agendaItemId,
  required List<String> readinessTaskIds,
  required DateTime asOfDate,
}) {
  return IncomingTalentRiskCouncilCommitmentLogItem(
    id: 'risk-council-commitment:clear',
    agendaItemId: agendaItemId,
    type: IncomingTalentRiskCouncilCommitmentLogType.clear,
    status: IncomingTalentRiskCouncilCommitmentLogStatus.clear,
    title: 'No council commitments to publish',
    commitment:
        'Confirm the talent risk council pack is clear and schedule the next review.',
    evidenceExpectation: 'Next review date is confirmed.',
    ownerName: 'Talent Operations',
    dueDate: asOfDate,
    sourceCount: 0,
    readinessTaskIds: readinessTaskIds,
  );
}

IncomingTalentRiskCouncilCommitmentLogStatus _statusFor({
  required IncomingTalentRiskCouncilAgendaItem agendaItem,
  required List<IncomingTalentRiskCouncilReadinessChecklistItem> readinessItems,
}) {
  if (agendaItem.section ==
      IncomingTalentRiskCouncilAgendaSection.commitmentClose) {
    return agendaItem.sourceCount == 0
        ? IncomingTalentRiskCouncilCommitmentLogStatus.readyToPublish
        : IncomingTalentRiskCouncilCommitmentLogStatus.needsOwner;
  }
  if (_hasReadinessStatus(
    readinessItems,
    IncomingTalentRiskCouncilReadinessChecklistStatus.blocked,
  )) {
    return IncomingTalentRiskCouncilCommitmentLogStatus.blocked;
  }
  if (agendaItem.section ==
          IncomingTalentRiskCouncilAgendaSection.leadershipEscalation ||
      agendaItem.section ==
          IncomingTalentRiskCouncilAgendaSection.decisionDocket) {
    return IncomingTalentRiskCouncilCommitmentLogStatus.needsDecision;
  }
  if (_hasReadinessStatus(
        readinessItems,
        IncomingTalentRiskCouncilReadinessChecklistStatus.overdue,
      ) ||
      agendaItem.section ==
          IncomingTalentRiskCouncilAgendaSection.slaRecovery ||
      agendaItem.section ==
          IncomingTalentRiskCouncilAgendaSection.executionReview) {
    return IncomingTalentRiskCouncilCommitmentLogStatus.needsEvidence;
  }
  if (agendaItem.section ==
          IncomingTalentRiskCouncilAgendaSection.followUpPlanning ||
      agendaItem.section ==
          IncomingTalentRiskCouncilAgendaSection.ownerConfirmation) {
    return IncomingTalentRiskCouncilCommitmentLogStatus.needsOwner;
  }
  return IncomingTalentRiskCouncilCommitmentLogStatus.readyToPublish;
}

IncomingTalentRiskCouncilCommitmentLogType _typeFor(
  IncomingTalentRiskCouncilAgendaSection section,
) {
  return switch (section) {
    IncomingTalentRiskCouncilAgendaSection.clear =>
      IncomingTalentRiskCouncilCommitmentLogType.clear,
    IncomingTalentRiskCouncilAgendaSection.leadershipEscalation =>
      IncomingTalentRiskCouncilCommitmentLogType.leadershipDecision,
    IncomingTalentRiskCouncilAgendaSection.slaRecovery =>
      IncomingTalentRiskCouncilCommitmentLogType.recoveryAction,
    IncomingTalentRiskCouncilAgendaSection.decisionDocket =>
      IncomingTalentRiskCouncilCommitmentLogType.decisionRecord,
    IncomingTalentRiskCouncilAgendaSection.followUpPlanning =>
      IncomingTalentRiskCouncilCommitmentLogType.followUpPlan,
    IncomingTalentRiskCouncilAgendaSection.ownerConfirmation =>
      IncomingTalentRiskCouncilCommitmentLogType.ownerUpdate,
    IncomingTalentRiskCouncilAgendaSection.executionReview =>
      IncomingTalentRiskCouncilCommitmentLogType.executionEvidence,
    IncomingTalentRiskCouncilAgendaSection.commitmentClose =>
      IncomingTalentRiskCouncilCommitmentLogType.publishCloseout,
  };
}

String _titleFor(IncomingTalentRiskCouncilAgendaSection section) {
  return switch (section) {
    IncomingTalentRiskCouncilAgendaSection.clear => 'Council clear checkpoint',
    IncomingTalentRiskCouncilAgendaSection.leadershipEscalation =>
      'Log leadership unblock decision',
    IncomingTalentRiskCouncilAgendaSection.slaRecovery =>
      'Log SLA recovery commitment',
    IncomingTalentRiskCouncilAgendaSection.decisionDocket =>
      'Log council decision outcome',
    IncomingTalentRiskCouncilAgendaSection.followUpPlanning =>
      'Log follow-up ownership plan',
    IncomingTalentRiskCouncilAgendaSection.ownerConfirmation =>
      'Log due-soon owner update',
    IncomingTalentRiskCouncilAgendaSection.executionReview =>
      'Log execution evidence review',
    IncomingTalentRiskCouncilAgendaSection.commitmentClose =>
      'Publish commitment closeout',
  };
}

String _commitmentFor(IncomingTalentRiskCouncilAgendaSection section) {
  return switch (section) {
    IncomingTalentRiskCouncilAgendaSection.clear =>
      'Confirm the council pack is clear and keep the next review date visible.',
    IncomingTalentRiskCouncilAgendaSection.leadershipEscalation =>
      'Capture the unblock decision, executive owner, and recovery date.',
    IncomingTalentRiskCouncilAgendaSection.slaRecovery =>
      'Capture the recovery action, evidence refresh owner, and revised due date.',
    IncomingTalentRiskCouncilAgendaSection.decisionDocket =>
      'Capture the approved council decision, accountable owner, and follow-up date.',
    IncomingTalentRiskCouncilAgendaSection.followUpPlanning =>
      'Create a follow-up action plan with owner, cadence, and success signal.',
    IncomingTalentRiskCouncilAgendaSection.ownerConfirmation =>
      'Confirm the owner update, confidence level, and next action for due-soon work.',
    IncomingTalentRiskCouncilAgendaSection.executionReview =>
      'Record accepted evidence, remaining risk, or escalation required.',
    IncomingTalentRiskCouncilAgendaSection.commitmentClose =>
      'Publish the council commitment log and confirm every open owner.',
  };
}

String _evidenceFor(IncomingTalentRiskCouncilAgendaSection section) {
  return switch (section) {
    IncomingTalentRiskCouncilAgendaSection.clear =>
      'Next review date and clear council note.',
    IncomingTalentRiskCouncilAgendaSection.leadershipEscalation =>
      'Decision note, unblock owner, and recovery due date.',
    IncomingTalentRiskCouncilAgendaSection.slaRecovery =>
      'Updated SLA evidence and recovery timeline.',
    IncomingTalentRiskCouncilAgendaSection.decisionDocket =>
      'Council decision record and follow-up trigger.',
    IncomingTalentRiskCouncilAgendaSection.followUpPlanning =>
      'Follow-up plan with owner and check-in cadence.',
    IncomingTalentRiskCouncilAgendaSection.ownerConfirmation =>
      'Owner update with current status and next action.',
    IncomingTalentRiskCouncilAgendaSection.executionReview =>
      'Evidence note, risk disposition, and escalation decision if needed.',
    IncomingTalentRiskCouncilAgendaSection.commitmentClose =>
      'Published commitment log and accountable owner list.',
  };
}

DateTime _dueDateFor({
  required IncomingTalentRiskCouncilAgendaItem agendaItem,
  required List<IncomingTalentRiskCouncilReadinessChecklistItem> readinessItems,
  required DateTime asOfDate,
}) {
  final dueDates = readinessItems.map((item) => item.dueDate).toList()..sort();
  if (dueDates.isNotEmpty) return dueDates.first;

  final offset = switch (agendaItem.section) {
    IncomingTalentRiskCouncilAgendaSection.clear => 0,
    IncomingTalentRiskCouncilAgendaSection.leadershipEscalation => 0,
    IncomingTalentRiskCouncilAgendaSection.slaRecovery => 1,
    IncomingTalentRiskCouncilAgendaSection.decisionDocket => 0,
    IncomingTalentRiskCouncilAgendaSection.followUpPlanning => 2,
    IncomingTalentRiskCouncilAgendaSection.ownerConfirmation => 2,
    IncomingTalentRiskCouncilAgendaSection.executionReview => 3,
    IncomingTalentRiskCouncilAgendaSection.commitmentClose => 1,
  };
  return asOfDate.add(Duration(days: offset));
}

int _sourceCountFor({
  required IncomingTalentRiskCouncilAgendaItem agendaItem,
  required List<IncomingTalentRiskCouncilReadinessChecklistItem> readinessItems,
}) {
  final readinessSignalCount = readinessItems.fold<int>(0, (sum, item) {
    return sum + item.sourceCount;
  });
  if (agendaItem.sourceCount > readinessSignalCount) {
    return agendaItem.sourceCount;
  }
  return readinessSignalCount;
}

bool _hasReadinessStatus(
  List<IncomingTalentRiskCouncilReadinessChecklistItem> items,
  IncomingTalentRiskCouncilReadinessChecklistStatus status,
) {
  return items.any((item) => item.status == status);
}

int _compareCommitments(
  IncomingTalentRiskCouncilCommitmentLogItem left,
  IncomingTalentRiskCouncilCommitmentLogItem right,
) {
  final urgency = left.urgencyRank.compareTo(right.urgencyRank);
  if (urgency != 0) return urgency;

  final dueDate = left.dueDate.compareTo(right.dueDate);
  if (dueDate != 0) return dueDate;

  return left.title.compareTo(right.title);
}
