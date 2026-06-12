import 'incoming_talent_succession_coverage_council_agenda_item.dart';
import 'incoming_talent_succession_coverage_council_decision.dart';
import 'incoming_talent_succession_coverage_council_decision_policy.dart';
import 'incoming_talent_succession_coverage_governance_record.dart';

class IncomingTalentSuccessionCoverageCouncilDecisionDraft {
  final String agendaItemId;
  final String governanceRecordId;
  final String scopeLabel;
  final String departmentScope;
  final String ownerName;
  final String decisionMakerName;
  final String executiveSponsorName;
  final IncomingTalentSuccessionCoverageCouncilAgendaLane? lane;
  final IncomingTalentSuccessionCoverageCouncilAgendaPriority? priority;
  final IncomingTalentSuccessionCoverageGovernanceRiskLevel? riskLevel;
  final int coverageScore;
  final DateTime? decisionDate;
  final IncomingTalentSuccessionCoverageCouncilDecisionOutcome? outcome;
  final String commitmentSummary;
  final String minutesNote;
  final DateTime? followUpDate;
  final DateTime asOfDate;

  const IncomingTalentSuccessionCoverageCouncilDecisionDraft({
    required this.agendaItemId,
    required this.governanceRecordId,
    required this.scopeLabel,
    required this.departmentScope,
    required this.ownerName,
    required this.decisionMakerName,
    required this.executiveSponsorName,
    required this.lane,
    required this.priority,
    required this.riskLevel,
    required this.coverageScore,
    required this.decisionDate,
    required this.outcome,
    required this.commitmentSummary,
    required this.minutesNote,
    required this.followUpDate,
    required this.asOfDate,
  });

  factory IncomingTalentSuccessionCoverageCouncilDecisionDraft.empty(
    DateTime asOfDate,
  ) {
    return IncomingTalentSuccessionCoverageCouncilDecisionDraft(
      agendaItemId: '',
      governanceRecordId: '',
      scopeLabel: '',
      departmentScope: '',
      ownerName: '',
      decisionMakerName: '',
      executiveSponsorName: '',
      lane: null,
      priority: null,
      riskLevel: null,
      coverageScore: 0,
      decisionDate: null,
      outcome: null,
      commitmentSummary: '',
      minutesNote: '',
      followUpDate: null,
      asOfDate: asOfDate,
    );
  }

  factory IncomingTalentSuccessionCoverageCouncilDecisionDraft.fromAgendaItem({
    required IncomingTalentSuccessionCoverageCouncilAgendaItem item,
    required DateTime asOfDate,
  }) {
    final outcome = defaultCoverageCouncilDecisionOutcome(item);

    return IncomingTalentSuccessionCoverageCouncilDecisionDraft(
      agendaItemId: item.id,
      governanceRecordId: item.governanceRecordId,
      scopeLabel: item.scopeLabel,
      departmentScope: item.departmentScope,
      ownerName: item.ownerName,
      decisionMakerName: 'Talent Council',
      executiveSponsorName: item.ownerName,
      lane: item.lane,
      priority: item.priority,
      riskLevel: item.riskLevel,
      coverageScore: item.coverageScore,
      decisionDate: asOfDate,
      outcome: outcome,
      commitmentSummary: defaultCoverageCouncilCommitmentSummary(item, outcome),
      minutesNote: item.discussionPrompt,
      followUpDate: defaultCoverageCouncilDecisionFollowUpDate(
        outcome: outcome,
        asOfDate: asOfDate,
      ),
      asOfDate: asOfDate,
    );
  }

  IncomingTalentSuccessionCoverageCouncilDecisionDraft copyWith({
    String? agendaItemId,
    String? governanceRecordId,
    String? scopeLabel,
    String? departmentScope,
    String? ownerName,
    String? decisionMakerName,
    String? executiveSponsorName,
    IncomingTalentSuccessionCoverageCouncilAgendaLane? lane,
    IncomingTalentSuccessionCoverageCouncilAgendaPriority? priority,
    IncomingTalentSuccessionCoverageGovernanceRiskLevel? riskLevel,
    int? coverageScore,
    DateTime? decisionDate,
    IncomingTalentSuccessionCoverageCouncilDecisionOutcome? outcome,
    String? commitmentSummary,
    String? minutesNote,
    DateTime? followUpDate,
    DateTime? asOfDate,
  }) {
    return IncomingTalentSuccessionCoverageCouncilDecisionDraft(
      agendaItemId: agendaItemId ?? this.agendaItemId,
      governanceRecordId: governanceRecordId ?? this.governanceRecordId,
      scopeLabel: scopeLabel ?? this.scopeLabel,
      departmentScope: departmentScope ?? this.departmentScope,
      ownerName: ownerName ?? this.ownerName,
      decisionMakerName: decisionMakerName ?? this.decisionMakerName,
      executiveSponsorName: executiveSponsorName ?? this.executiveSponsorName,
      lane: lane ?? this.lane,
      priority: priority ?? this.priority,
      riskLevel: riskLevel ?? this.riskLevel,
      coverageScore: coverageScore ?? this.coverageScore,
      decisionDate: decisionDate ?? this.decisionDate,
      outcome: outcome ?? this.outcome,
      commitmentSummary: commitmentSummary ?? this.commitmentSummary,
      minutesNote: minutesNote ?? this.minutesNote,
      followUpDate: followUpDate ?? this.followUpDate,
      asOfDate: asOfDate ?? this.asOfDate,
    );
  }

  double get completionRatio {
    final completed =
        [
          agendaItemId.trim().isNotEmpty,
          decisionMakerName.trim().isNotEmpty,
          executiveSponsorName.trim().isNotEmpty,
          lane != null,
          priority != null,
          riskLevel != null,
          decisionDate != null,
          outcome != null,
          commitmentSummary.trim().length >= 12,
          minutesNote.trim().length >= 12,
          followUpDate != null,
        ].where((item) => item).length;

    return completed / 11;
  }

  List<String> get validationErrors {
    return [
      if (validateCoverageCouncilDecisionRequired(
            agendaItemId,
            'a council agenda item',
          )
          case final error?)
        error,
      if (validateCoverageCouncilDecisionRequired(
            decisionMakerName,
            'a decision maker',
          )
          case final error?)
        error,
      if (validateCoverageCouncilDecisionRequired(
            executiveSponsorName,
            'an executive sponsor',
          )
          case final error?)
        error,
      if (validateCoverageCouncilDecisionOutcome(outcome) case final error?)
        error,
      if (validateCoverageCouncilDecisionDate(decisionDate, asOfDate)
          case final error?)
        error,
      if (validateCoverageCouncilDecisionFollowUpDate(
            decisionDate,
            followUpDate,
          )
          case final error?)
        error,
      if (coverageCouncilDecisionLongTextError(
            commitmentSummary,
            'commitment summary',
          )
          case final error?)
        error,
      if (coverageCouncilDecisionLongTextError(minutesNote, 'minutes note')
          case final error?)
        error,
    ];
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  IncomingTalentSuccessionCoverageCouncilDecision toDecision({
    required String id,
    required DateTime createdAt,
  }) {
    return IncomingTalentSuccessionCoverageCouncilDecision(
      id: id,
      agendaItemId: agendaItemId,
      governanceRecordId: governanceRecordId,
      scopeLabel: scopeLabel.trim(),
      departmentScope: departmentScope.trim(),
      ownerName: ownerName.trim(),
      decisionMakerName: decisionMakerName.trim(),
      executiveSponsorName: executiveSponsorName.trim(),
      lane: lane!,
      priority: priority!,
      riskLevel: riskLevel!,
      coverageScore: coverageScore,
      decisionDate: decisionDate!,
      outcome: outcome!,
      commitmentSummary: commitmentSummary.trim(),
      minutesNote: minutesNote.trim(),
      followUpDate: followUpDate!,
      createdAt: createdAt,
    );
  }
}
