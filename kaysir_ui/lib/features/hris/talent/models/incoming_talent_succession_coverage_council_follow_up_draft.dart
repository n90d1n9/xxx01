import 'incoming_talent_succession_coverage_council_agenda_item.dart';
import 'incoming_talent_succession_coverage_council_decision.dart';
import 'incoming_talent_succession_coverage_council_follow_up.dart';
import 'incoming_talent_succession_coverage_council_follow_up_policy.dart';
import 'incoming_talent_succession_coverage_governance_record.dart';

class IncomingTalentSuccessionCoverageCouncilFollowUpDraft {
  final String decisionId;
  final String agendaItemId;
  final String governanceRecordId;
  final String scopeLabel;
  final String departmentScope;
  final String councilOwnerName;
  final String followUpOwnerName;
  final String executiveSponsorName;
  final IncomingTalentSuccessionCoverageCouncilDecisionOutcome? outcome;
  final IncomingTalentSuccessionCoverageCouncilAgendaPriority? priority;
  final IncomingTalentSuccessionCoverageGovernanceRiskLevel? riskLevel;
  final DateTime? decisionDate;
  final IncomingTalentSuccessionCoverageCouncilFollowUpType? followUpType;
  final DateTime? dueDate;
  final String actionPlan;
  final String successCriteria;
  final String blockerNote;
  final String escalationReason;
  final DateTime asOfDate;

  const IncomingTalentSuccessionCoverageCouncilFollowUpDraft({
    required this.decisionId,
    required this.agendaItemId,
    required this.governanceRecordId,
    required this.scopeLabel,
    required this.departmentScope,
    required this.councilOwnerName,
    required this.followUpOwnerName,
    required this.executiveSponsorName,
    required this.outcome,
    required this.priority,
    required this.riskLevel,
    required this.decisionDate,
    required this.followUpType,
    required this.dueDate,
    required this.actionPlan,
    required this.successCriteria,
    required this.blockerNote,
    required this.escalationReason,
    required this.asOfDate,
  });

  factory IncomingTalentSuccessionCoverageCouncilFollowUpDraft.empty(
    DateTime asOfDate,
  ) {
    return IncomingTalentSuccessionCoverageCouncilFollowUpDraft(
      decisionId: '',
      agendaItemId: '',
      governanceRecordId: '',
      scopeLabel: '',
      departmentScope: '',
      councilOwnerName: '',
      followUpOwnerName: '',
      executiveSponsorName: '',
      outcome: null,
      priority: null,
      riskLevel: null,
      decisionDate: null,
      followUpType: null,
      dueDate: null,
      actionPlan: '',
      successCriteria: '',
      blockerNote: '',
      escalationReason: '',
      asOfDate: asOfDate,
    );
  }

  factory IncomingTalentSuccessionCoverageCouncilFollowUpDraft.fromDecision({
    required IncomingTalentSuccessionCoverageCouncilDecision decision,
    required DateTime asOfDate,
  }) {
    final followUpType = defaultCoverageCouncilFollowUpType(decision);

    return IncomingTalentSuccessionCoverageCouncilFollowUpDraft(
      decisionId: decision.id,
      agendaItemId: decision.agendaItemId,
      governanceRecordId: decision.governanceRecordId,
      scopeLabel: decision.scopeLabel,
      departmentScope: decision.departmentScope,
      councilOwnerName: decision.ownerName,
      followUpOwnerName: decision.executiveSponsorName,
      executiveSponsorName: decision.executiveSponsorName,
      outcome: decision.outcome,
      priority: decision.priority,
      riskLevel: decision.riskLevel,
      decisionDate: decision.decisionDate,
      followUpType: followUpType,
      dueDate: defaultCoverageCouncilFollowUpDueDate(
        decision: decision,
        asOfDate: asOfDate,
      ),
      actionPlan: defaultCoverageCouncilFollowUpActionPlan(
        decision,
        followUpType,
      ),
      successCriteria: defaultCoverageCouncilFollowUpSuccessCriteria(decision),
      blockerNote: '',
      escalationReason:
          decision.outcome ==
                  IncomingTalentSuccessionCoverageCouncilDecisionOutcome
                      .escalateToPeopleBoard
              ? decision.commitmentSummary
              : '',
      asOfDate: asOfDate,
    );
  }

  IncomingTalentSuccessionCoverageCouncilFollowUpDraft copyWith({
    String? decisionId,
    String? agendaItemId,
    String? governanceRecordId,
    String? scopeLabel,
    String? departmentScope,
    String? councilOwnerName,
    String? followUpOwnerName,
    String? executiveSponsorName,
    IncomingTalentSuccessionCoverageCouncilDecisionOutcome? outcome,
    IncomingTalentSuccessionCoverageCouncilAgendaPriority? priority,
    IncomingTalentSuccessionCoverageGovernanceRiskLevel? riskLevel,
    DateTime? decisionDate,
    IncomingTalentSuccessionCoverageCouncilFollowUpType? followUpType,
    DateTime? dueDate,
    String? actionPlan,
    String? successCriteria,
    String? blockerNote,
    String? escalationReason,
    DateTime? asOfDate,
  }) {
    return IncomingTalentSuccessionCoverageCouncilFollowUpDraft(
      decisionId: decisionId ?? this.decisionId,
      agendaItemId: agendaItemId ?? this.agendaItemId,
      governanceRecordId: governanceRecordId ?? this.governanceRecordId,
      scopeLabel: scopeLabel ?? this.scopeLabel,
      departmentScope: departmentScope ?? this.departmentScope,
      councilOwnerName: councilOwnerName ?? this.councilOwnerName,
      followUpOwnerName: followUpOwnerName ?? this.followUpOwnerName,
      executiveSponsorName: executiveSponsorName ?? this.executiveSponsorName,
      outcome: outcome ?? this.outcome,
      priority: priority ?? this.priority,
      riskLevel: riskLevel ?? this.riskLevel,
      decisionDate: decisionDate ?? this.decisionDate,
      followUpType: followUpType ?? this.followUpType,
      dueDate: dueDate ?? this.dueDate,
      actionPlan: actionPlan ?? this.actionPlan,
      successCriteria: successCriteria ?? this.successCriteria,
      blockerNote: blockerNote ?? this.blockerNote,
      escalationReason: escalationReason ?? this.escalationReason,
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
      if (validateCoverageCouncilFollowUpRequired(
            decisionId,
            'a council decision',
          )
          case final error?)
        error,
      if (validateCoverageCouncilFollowUpRequired(
            followUpOwnerName,
            'a follow-up owner',
          )
          case final error?)
        error,
      if (validateCoverageCouncilFollowUpType(followUpType) case final error?)
        error,
      if (decisionDate == null)
        'Select decision date'
      else if (validateCoverageCouncilFollowUpDueDate(
            dueDate: dueDate,
            decisionDate: decisionDate!,
            asOfDate: asOfDate,
          )
          case final error?)
        error,
      if (coverageCouncilFollowUpLongTextError(actionPlan, 'action plan')
          case final error?)
        error,
      if (coverageCouncilFollowUpLongTextError(
            successCriteria,
            'success criteria',
          )
          case final error?)
        error,
    ];
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  IncomingTalentSuccessionCoverageCouncilFollowUp toFollowUp({
    required String id,
    required DateTime createdAt,
  }) {
    return IncomingTalentSuccessionCoverageCouncilFollowUp(
      id: id,
      decisionId: decisionId,
      agendaItemId: agendaItemId,
      governanceRecordId: governanceRecordId,
      scopeLabel: scopeLabel.trim(),
      departmentScope: departmentScope.trim(),
      councilOwnerName: councilOwnerName.trim(),
      followUpOwnerName: followUpOwnerName.trim(),
      executiveSponsorName: executiveSponsorName.trim(),
      outcome: outcome!,
      priority: priority!,
      riskLevel: riskLevel!,
      followUpType: followUpType!,
      status: IncomingTalentSuccessionCoverageCouncilFollowUpStatus.planned,
      dueDate: dueDate!,
      actionPlan: actionPlan.trim(),
      successCriteria: successCriteria.trim(),
      blockerNote: blockerNote.trim(),
      escalationReason: escalationReason.trim(),
      createdAt: createdAt,
    );
  }
}
