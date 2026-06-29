import 'incoming_talent_risk_council_commitment_action.dart';
import 'incoming_talent_risk_council_commitment_action_policy.dart';
import 'incoming_talent_risk_council_commitment_log_item.dart';

class IncomingTalentRiskCouncilCommitmentActionDraft {
  final String commitmentId;
  final String agendaItemId;
  final IncomingTalentRiskCouncilCommitmentLogType? type;
  final IncomingTalentRiskCouncilCommitmentLogStatus? sourceStatus;
  final IncomingTalentRiskCouncilCommitmentActionStatus? status;
  final String ownerName;
  final DateTime? dueDate;
  final String actionPlan;
  final String evidenceExpectation;
  final String evidenceNote;
  final String followUpCadence;
  final String blockerNote;
  final int sourceCount;
  final DateTime asOfDate;

  const IncomingTalentRiskCouncilCommitmentActionDraft({
    required this.commitmentId,
    required this.agendaItemId,
    required this.type,
    required this.sourceStatus,
    required this.status,
    required this.ownerName,
    required this.dueDate,
    required this.actionPlan,
    required this.evidenceExpectation,
    required this.evidenceNote,
    required this.followUpCadence,
    required this.blockerNote,
    required this.sourceCount,
    required this.asOfDate,
  });

  factory IncomingTalentRiskCouncilCommitmentActionDraft.empty(
    DateTime asOfDate,
  ) {
    return IncomingTalentRiskCouncilCommitmentActionDraft(
      commitmentId: '',
      agendaItemId: '',
      type: null,
      sourceStatus: null,
      status: null,
      ownerName: '',
      dueDate: null,
      actionPlan: '',
      evidenceExpectation: '',
      evidenceNote: '',
      followUpCadence: '',
      blockerNote: '',
      sourceCount: 0,
      asOfDate: asOfDate,
    );
  }

  factory IncomingTalentRiskCouncilCommitmentActionDraft.fromCommitment({
    required IncomingTalentRiskCouncilCommitmentLogItem commitment,
    required DateTime asOfDate,
  }) {
    return IncomingTalentRiskCouncilCommitmentActionDraft(
      commitmentId: commitment.id,
      agendaItemId: commitment.agendaItemId,
      type: commitment.type,
      sourceStatus: commitment.status,
      status: defaultRiskCouncilCommitmentActionStatus(commitment),
      ownerName: commitment.ownerName,
      dueDate: defaultRiskCouncilCommitmentActionDueDate(
        commitment: commitment,
        asOfDate: asOfDate,
      ),
      actionPlan: commitment.commitment,
      evidenceExpectation: commitment.evidenceExpectation,
      evidenceNote:
          commitment.status ==
                  IncomingTalentRiskCouncilCommitmentLogStatus.readyToPublish
              ? commitment.evidenceExpectation
              : '',
      followUpCadence: defaultRiskCouncilCommitmentActionCadence(
        commitment.type,
      ),
      blockerNote:
          commitment.status ==
                  IncomingTalentRiskCouncilCommitmentLogStatus.blocked
              ? commitment.commitment
              : '',
      sourceCount: commitment.sourceCount,
      asOfDate: asOfDate,
    );
  }

  IncomingTalentRiskCouncilCommitmentActionDraft copyWith({
    String? commitmentId,
    String? agendaItemId,
    IncomingTalentRiskCouncilCommitmentLogType? type,
    IncomingTalentRiskCouncilCommitmentLogStatus? sourceStatus,
    IncomingTalentRiskCouncilCommitmentActionStatus? status,
    String? ownerName,
    DateTime? dueDate,
    String? actionPlan,
    String? evidenceExpectation,
    String? evidenceNote,
    String? followUpCadence,
    String? blockerNote,
    int? sourceCount,
    DateTime? asOfDate,
  }) {
    return IncomingTalentRiskCouncilCommitmentActionDraft(
      commitmentId: commitmentId ?? this.commitmentId,
      agendaItemId: agendaItemId ?? this.agendaItemId,
      type: type ?? this.type,
      sourceStatus: sourceStatus ?? this.sourceStatus,
      status: status ?? this.status,
      ownerName: ownerName ?? this.ownerName,
      dueDate: dueDate ?? this.dueDate,
      actionPlan: actionPlan ?? this.actionPlan,
      evidenceExpectation: evidenceExpectation ?? this.evidenceExpectation,
      evidenceNote: evidenceNote ?? this.evidenceNote,
      followUpCadence: followUpCadence ?? this.followUpCadence,
      blockerNote: blockerNote ?? this.blockerNote,
      sourceCount: sourceCount ?? this.sourceCount,
      asOfDate: asOfDate ?? this.asOfDate,
    );
  }

  double get completionRatio {
    final completed =
        [
          commitmentId.trim().isNotEmpty,
          ownerName.trim().isNotEmpty,
          dueDate != null,
          actionPlan.trim().length >= 12,
          evidenceExpectation.trim().length >= 12,
          followUpCadence.trim().length >= 8,
        ].where((item) => item).length;

    return completed / 6;
  }

  List<String> get validationErrors {
    return [
      if (validateRiskCouncilCommitmentActionRequired(
            commitmentId,
            'a council commitment',
          )
          case final error?)
        error,
      if (validateRiskCouncilCommitmentActionRequired(
            ownerName,
            'an action owner',
          )
          case final error?)
        error,
      if (validateRiskCouncilCommitmentActionDueDate(
            dueDate: dueDate,
            asOfDate: asOfDate,
          )
          case final error?)
        error,
      if (riskCouncilCommitmentActionLongTextError(actionPlan, 'action plan')
          case final error?)
        error,
      if (riskCouncilCommitmentActionLongTextError(
            evidenceExpectation,
            'evidence expectation',
          )
          case final error?)
        error,
      if (riskCouncilCommitmentActionLongTextError(
            followUpCadence,
            'follow-up cadence',
          )
          case final error?)
        error,
    ];
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  IncomingTalentRiskCouncilCommitmentAction toAction({
    required String id,
    required DateTime createdAt,
  }) {
    return IncomingTalentRiskCouncilCommitmentAction(
      id: id,
      commitmentId: commitmentId,
      agendaItemId: agendaItemId,
      type: type!,
      sourceStatus: sourceStatus!,
      status: status!,
      ownerName: ownerName.trim(),
      dueDate: dueDate!,
      actionPlan: actionPlan.trim(),
      evidenceExpectation: evidenceExpectation.trim(),
      evidenceNote: evidenceNote.trim(),
      followUpCadence: followUpCadence.trim(),
      blockerNote: blockerNote.trim(),
      createdAt: createdAt,
      sourceCount: sourceCount,
    );
  }
}
