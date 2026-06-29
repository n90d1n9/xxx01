import 'incoming_talent_risk_council_decision.dart';
import 'incoming_talent_risk_council_follow_up.dart';
import 'incoming_talent_risk_council_follow_up_policy.dart';
import 'incoming_talent_risk_council_queue_item.dart';

/// Editable draft for creating a follow-up from a council decision.
class IncomingTalentRiskCouncilFollowUpDraft {
  final String decisionId;
  final String queueItemId;
  final String candidateId;
  final String candidateName;
  final String role;
  final String department;
  final String decisionMakerName;
  final String followUpOwnerName;
  final IncomingTalentRiskCouncilDecisionOutcome? outcome;
  final IncomingTalentRiskCouncilQueueCategory? category;
  final IncomingTalentRiskCouncilQueueSeverity? sourceSeverity;
  final IncomingTalentRiskCouncilQueueSource source;
  final DateTime? decisionDate;
  final IncomingTalentRiskCouncilFollowUpType? followUpType;
  final DateTime? dueDate;
  final String actionPlan;
  final String successCriteria;
  final String blockerNote;
  final String escalationReason;
  final int signalCount;
  final DateTime asOfDate;

  const IncomingTalentRiskCouncilFollowUpDraft({
    required this.decisionId,
    required this.queueItemId,
    required this.candidateId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.decisionMakerName,
    required this.followUpOwnerName,
    required this.outcome,
    required this.category,
    required this.sourceSeverity,
    required this.source,
    required this.decisionDate,
    required this.followUpType,
    required this.dueDate,
    required this.actionPlan,
    required this.successCriteria,
    required this.blockerNote,
    required this.escalationReason,
    required this.signalCount,
    required this.asOfDate,
  });

  factory IncomingTalentRiskCouncilFollowUpDraft.empty(DateTime asOfDate) {
    return IncomingTalentRiskCouncilFollowUpDraft(
      decisionId: '',
      queueItemId: '',
      candidateId: '',
      candidateName: '',
      role: '',
      department: '',
      decisionMakerName: '',
      followUpOwnerName: '',
      outcome: null,
      category: null,
      sourceSeverity: null,
      source: IncomingTalentRiskCouncilQueueSource.general,
      decisionDate: null,
      followUpType: null,
      dueDate: null,
      actionPlan: '',
      successCriteria: '',
      blockerNote: '',
      escalationReason: '',
      signalCount: 0,
      asOfDate: asOfDate,
    );
  }

  factory IncomingTalentRiskCouncilFollowUpDraft.fromDecision({
    required IncomingTalentRiskCouncilDecision decision,
    required DateTime asOfDate,
  }) {
    final followUpType = defaultRiskCouncilFollowUpType(decision);

    return IncomingTalentRiskCouncilFollowUpDraft(
      decisionId: decision.id,
      queueItemId: decision.queueItemId,
      candidateId: decision.candidateId,
      candidateName: decision.candidateName,
      role: decision.role,
      department: decision.department,
      decisionMakerName: decision.decisionMakerName,
      followUpOwnerName: decision.ownerName,
      outcome: decision.outcome,
      category: decision.category,
      sourceSeverity: decision.sourceSeverity,
      source: decision.source,
      decisionDate: decision.decisionDate,
      followUpType: followUpType,
      dueDate: defaultRiskCouncilFollowUpDueDate(
        decision: decision,
        asOfDate: asOfDate,
      ),
      actionPlan: defaultRiskCouncilFollowUpActionPlan(decision, followUpType),
      successCriteria: defaultRiskCouncilFollowUpSuccessCriteria(decision),
      blockerNote: '',
      escalationReason:
          decision.outcome ==
                  IncomingTalentRiskCouncilDecisionOutcome.escalatePeopleBoard
              ? decision.commitmentSummary
              : '',
      signalCount: decision.signalCount,
      asOfDate: asOfDate,
    );
  }

  IncomingTalentRiskCouncilFollowUpDraft copyWith({
    String? decisionId,
    String? queueItemId,
    String? candidateId,
    String? candidateName,
    String? role,
    String? department,
    String? decisionMakerName,
    String? followUpOwnerName,
    IncomingTalentRiskCouncilDecisionOutcome? outcome,
    IncomingTalentRiskCouncilQueueCategory? category,
    IncomingTalentRiskCouncilQueueSeverity? sourceSeverity,
    IncomingTalentRiskCouncilQueueSource? source,
    DateTime? decisionDate,
    IncomingTalentRiskCouncilFollowUpType? followUpType,
    DateTime? dueDate,
    String? actionPlan,
    String? successCriteria,
    String? blockerNote,
    String? escalationReason,
    int? signalCount,
    DateTime? asOfDate,
  }) {
    return IncomingTalentRiskCouncilFollowUpDraft(
      decisionId: decisionId ?? this.decisionId,
      queueItemId: queueItemId ?? this.queueItemId,
      candidateId: candidateId ?? this.candidateId,
      candidateName: candidateName ?? this.candidateName,
      role: role ?? this.role,
      department: department ?? this.department,
      decisionMakerName: decisionMakerName ?? this.decisionMakerName,
      followUpOwnerName: followUpOwnerName ?? this.followUpOwnerName,
      outcome: outcome ?? this.outcome,
      category: category ?? this.category,
      sourceSeverity: sourceSeverity ?? this.sourceSeverity,
      source: source ?? this.source,
      decisionDate: decisionDate ?? this.decisionDate,
      followUpType: followUpType ?? this.followUpType,
      dueDate: dueDate ?? this.dueDate,
      actionPlan: actionPlan ?? this.actionPlan,
      successCriteria: successCriteria ?? this.successCriteria,
      blockerNote: blockerNote ?? this.blockerNote,
      escalationReason: escalationReason ?? this.escalationReason,
      signalCount: signalCount ?? this.signalCount,
      asOfDate: asOfDate ?? this.asOfDate,
    );
  }

  double get completionRatio {
    final completed =
        [
          decisionId.trim().isNotEmpty,
          followUpOwnerName.trim().isNotEmpty,
          followUpType != null,
          dueDate != null,
          actionPlan.trim().length >= 12,
          successCriteria.trim().length >= 12,
        ].where((item) => item).length;

    return completed / 6;
  }

  List<String> get validationErrors {
    return [
      if (validateRiskCouncilFollowUpRequired(decisionId, 'a council decision')
          case final error?)
        error,
      if (validateRiskCouncilFollowUpRequired(
            followUpOwnerName,
            'a follow-up owner',
          )
          case final error?)
        error,
      if (validateRiskCouncilFollowUpType(followUpType) case final error?)
        error,
      if (decisionDate == null)
        'Select decision date'
      else if (validateRiskCouncilFollowUpDueDate(
            dueDate: dueDate,
            decisionDate: decisionDate!,
            asOfDate: asOfDate,
          )
          case final error?)
        error,
      if (riskCouncilFollowUpLongTextError(actionPlan, 'action plan')
          case final error?)
        error,
      if (riskCouncilFollowUpLongTextError(successCriteria, 'success criteria')
          case final error?)
        error,
    ];
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  IncomingTalentRiskCouncilFollowUp toFollowUp({
    required String id,
    required DateTime createdAt,
  }) {
    return IncomingTalentRiskCouncilFollowUp(
      id: id,
      decisionId: decisionId,
      queueItemId: queueItemId,
      candidateId: candidateId,
      candidateName: candidateName.trim(),
      role: role.trim(),
      department: department.trim(),
      decisionMakerName: decisionMakerName.trim(),
      followUpOwnerName: followUpOwnerName.trim(),
      outcome: outcome!,
      category: category!,
      sourceSeverity: sourceSeverity!,
      source: source,
      followUpType: followUpType!,
      status: IncomingTalentRiskCouncilFollowUpStatus.planned,
      dueDate: dueDate!,
      actionPlan: actionPlan.trim(),
      successCriteria: successCriteria.trim(),
      blockerNote: blockerNote.trim(),
      escalationReason: escalationReason.trim(),
      createdAt: createdAt,
      signalCount: signalCount,
    );
  }
}
