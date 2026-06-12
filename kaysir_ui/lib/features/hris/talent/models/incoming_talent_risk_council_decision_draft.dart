import 'incoming_talent_risk_council_decision.dart';
import 'incoming_talent_risk_council_decision_policy.dart';
import 'incoming_talent_risk_council_queue_item.dart';

/// Editable draft used to record a council decision for one queued talent risk.
class IncomingTalentRiskCouncilDecisionDraft {
  final String queueItemId;
  final String candidateId;
  final String candidateName;
  final String role;
  final String department;
  final IncomingTalentRiskCouncilQueueCategory? category;
  final IncomingTalentRiskCouncilQueueSeverity? sourceSeverity;
  final IncomingTalentRiskCouncilQueueSource source;
  final String decisionMakerName;
  final String ownerName;
  final DateTime? decisionDate;
  final IncomingTalentRiskCouncilDecisionOutcome? outcome;
  final String commitmentSummary;
  final String minutesNote;
  final DateTime? followUpDate;
  final int signalCount;
  final DateTime asOfDate;

  const IncomingTalentRiskCouncilDecisionDraft({
    required this.queueItemId,
    required this.candidateId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.category,
    required this.sourceSeverity,
    required this.source,
    required this.decisionMakerName,
    required this.ownerName,
    required this.decisionDate,
    required this.outcome,
    required this.commitmentSummary,
    required this.minutesNote,
    required this.followUpDate,
    required this.signalCount,
    required this.asOfDate,
  });

  factory IncomingTalentRiskCouncilDecisionDraft.empty(DateTime asOfDate) {
    return IncomingTalentRiskCouncilDecisionDraft(
      queueItemId: '',
      candidateId: '',
      candidateName: '',
      role: '',
      department: '',
      category: null,
      sourceSeverity: null,
      source: IncomingTalentRiskCouncilQueueSource.general,
      decisionMakerName: '',
      ownerName: '',
      decisionDate: null,
      outcome: null,
      commitmentSummary: '',
      minutesNote: '',
      followUpDate: null,
      signalCount: 0,
      asOfDate: asOfDate,
    );
  }

  factory IncomingTalentRiskCouncilDecisionDraft.fromQueueItem({
    required IncomingTalentRiskCouncilQueueItem item,
    required DateTime asOfDate,
  }) {
    final outcome = defaultRiskCouncilDecisionOutcome(item);

    return IncomingTalentRiskCouncilDecisionDraft(
      queueItemId: item.id,
      candidateId: item.candidateId,
      candidateName: item.candidateName,
      role: item.role,
      department: item.department,
      category: item.category,
      sourceSeverity: item.severity,
      source: item.source,
      decisionMakerName: 'Talent Council',
      ownerName: defaultRiskCouncilDecisionOwnerName(item),
      decisionDate: asOfDate,
      outcome: outcome,
      commitmentSummary: defaultRiskCouncilCommitmentSummary(item, outcome),
      minutesNote: item.detail,
      followUpDate: defaultRiskCouncilDecisionFollowUpDate(
        outcome: outcome,
        asOfDate: asOfDate,
      ),
      signalCount: item.signalCount,
      asOfDate: asOfDate,
    );
  }

  IncomingTalentRiskCouncilDecisionDraft copyWith({
    String? queueItemId,
    String? candidateId,
    String? candidateName,
    String? role,
    String? department,
    IncomingTalentRiskCouncilQueueCategory? category,
    IncomingTalentRiskCouncilQueueSeverity? sourceSeverity,
    IncomingTalentRiskCouncilQueueSource? source,
    String? decisionMakerName,
    String? ownerName,
    DateTime? decisionDate,
    IncomingTalentRiskCouncilDecisionOutcome? outcome,
    String? commitmentSummary,
    String? minutesNote,
    DateTime? followUpDate,
    int? signalCount,
    DateTime? asOfDate,
  }) {
    return IncomingTalentRiskCouncilDecisionDraft(
      queueItemId: queueItemId ?? this.queueItemId,
      candidateId: candidateId ?? this.candidateId,
      candidateName: candidateName ?? this.candidateName,
      role: role ?? this.role,
      department: department ?? this.department,
      category: category ?? this.category,
      sourceSeverity: sourceSeverity ?? this.sourceSeverity,
      source: source ?? this.source,
      decisionMakerName: decisionMakerName ?? this.decisionMakerName,
      ownerName: ownerName ?? this.ownerName,
      decisionDate: decisionDate ?? this.decisionDate,
      outcome: outcome ?? this.outcome,
      commitmentSummary: commitmentSummary ?? this.commitmentSummary,
      minutesNote: minutesNote ?? this.minutesNote,
      followUpDate: followUpDate ?? this.followUpDate,
      signalCount: signalCount ?? this.signalCount,
      asOfDate: asOfDate ?? this.asOfDate,
    );
  }

  double get completionRatio {
    final completed =
        [
          queueItemId.trim().isNotEmpty,
          decisionMakerName.trim().isNotEmpty,
          ownerName.trim().isNotEmpty,
          category != null,
          sourceSeverity != null,
          decisionDate != null,
          outcome != null,
          commitmentSummary.trim().length >= 12,
          minutesNote.trim().length >= 12,
          followUpDate != null,
        ].where((item) => item).length;

    return completed / 10;
  }

  List<String> get validationErrors {
    return [
      if (validateRiskCouncilDecisionRequired(
            queueItemId,
            'a council queue item',
          )
          case final error?)
        error,
      if (validateRiskCouncilDecisionRequired(
            decisionMakerName,
            'a decision maker',
          )
          case final error?)
        error,
      if (validateRiskCouncilDecisionRequired(ownerName, 'an owner')
          case final error?)
        error,
      if (validateRiskCouncilDecisionOutcome(outcome) case final error?) error,
      if (validateRiskCouncilDecisionDate(decisionDate, asOfDate)
          case final error?)
        error,
      if (validateRiskCouncilDecisionFollowUpDate(decisionDate, followUpDate)
          case final error?)
        error,
      if (riskCouncilDecisionLongTextError(
            commitmentSummary,
            'commitment summary',
          )
          case final error?)
        error,
      if (riskCouncilDecisionLongTextError(minutesNote, 'minutes note')
          case final error?)
        error,
    ];
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  IncomingTalentRiskCouncilDecision toDecision({
    required String id,
    required DateTime createdAt,
  }) {
    return IncomingTalentRiskCouncilDecision(
      id: id,
      queueItemId: queueItemId,
      candidateId: candidateId,
      candidateName: candidateName.trim(),
      role: role.trim(),
      department: department.trim(),
      category: category!,
      sourceSeverity: sourceSeverity!,
      source: source,
      decisionMakerName: decisionMakerName.trim(),
      ownerName: ownerName.trim(),
      decisionDate: decisionDate!,
      outcome: outcome!,
      commitmentSummary: commitmentSummary.trim(),
      minutesNote: minutesNote.trim(),
      followUpDate: followUpDate!,
      createdAt: createdAt,
      signalCount: signalCount,
    );
  }
}
