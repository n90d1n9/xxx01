import 'candidate_ramp_models.dart';
import 'candidate_skill_fit_models.dart';
import 'recruitment_models.dart';

enum CandidateDecisionRecommendation {
  approve('Approve'),
  conditional('Conditional'),
  hold('Hold');

  final String label;

  const CandidateDecisionRecommendation(this.label);
}

class CandidateDecisionPacket {
  final String candidateId;
  final String candidateName;
  final String role;
  final String department;
  final CandidateStage stage;
  final RecruitmentPriority priority;
  final int fitScore;
  final CandidateSkillFitStatus fitStatus;
  final String skillFocus;
  final CandidateRampReadiness? rampReadiness;
  final DateTime decisionDueDate;
  final CandidateDecisionRecommendation recommendation;
  final List<String> blockers;
  final List<String> handoffItems;
  final String suggestedMentor;
  final String suggestedLearningPlan;
  final String nextAction;

  const CandidateDecisionPacket({
    required this.candidateId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.stage,
    required this.priority,
    required this.fitScore,
    required this.fitStatus,
    required this.skillFocus,
    required this.rampReadiness,
    required this.decisionDueDate,
    required this.recommendation,
    required this.blockers,
    required this.handoffItems,
    required this.suggestedMentor,
    required this.suggestedLearningPlan,
    required this.nextAction,
  });

  bool get needsAttention {
    return recommendation != CandidateDecisionRecommendation.approve;
  }

  int daysUntilDue(DateTime asOfDate) {
    final start = DateTime(asOfDate.year, asOfDate.month, asOfDate.day);
    final due = DateTime(
      decisionDueDate.year,
      decisionDueDate.month,
      decisionDueDate.day,
    );
    return due.difference(start).inDays;
  }

  factory CandidateDecisionPacket.fromSignals({
    required CandidateSkillFitProfile fitProfile,
    required CandidateRampPlan? rampPlan,
    required OfferTracker? offer,
    required DateTime asOfDate,
  }) {
    final blockers = _blockers(
      fitProfile: fitProfile,
      rampPlan: rampPlan,
      offer: offer,
      asOfDate: asOfDate,
    );
    final handoffItems = _handoffItems(
      fitProfile: fitProfile,
      rampPlan: rampPlan,
    );
    final recommendation = _recommendation(
      fitProfile: fitProfile,
      rampPlan: rampPlan,
      blockers: blockers,
    );
    final decisionDueDate = _decisionDueDate(
      fitProfile: fitProfile,
      rampPlan: rampPlan,
      offer: offer,
      asOfDate: asOfDate,
    );

    return CandidateDecisionPacket(
      candidateId: fitProfile.candidateId,
      candidateName: fitProfile.candidateName,
      role: fitProfile.role,
      department: fitProfile.department,
      stage: fitProfile.stage,
      priority: fitProfile.priority,
      fitScore: fitProfile.fitScore,
      fitStatus: fitProfile.status,
      skillFocus: fitProfile.topSkillGap,
      rampReadiness: rampPlan?.readiness,
      decisionDueDate: decisionDueDate,
      recommendation: recommendation,
      blockers: blockers,
      handoffItems: handoffItems,
      suggestedMentor: rampPlan?.mentorName ?? fitProfile.suggestedMentor,
      suggestedLearningPlan:
          rampPlan?.learningPlanTitle ?? fitProfile.suggestedLearningPlan,
      nextAction: _nextAction(recommendation, blockers, handoffItems),
    );
  }
}

class CandidateDecisionSummary {
  final int totalPackets;
  final int approveCount;
  final int conditionalCount;
  final int holdCount;
  final int dueSoonCount;
  final String nextAction;

  const CandidateDecisionSummary({
    required this.totalPackets,
    required this.approveCount,
    required this.conditionalCount,
    required this.holdCount,
    required this.dueSoonCount,
    required this.nextAction,
  });

  factory CandidateDecisionSummary.fromPackets({
    required List<CandidateDecisionPacket> packets,
    required DateTime asOfDate,
  }) {
    final approveCount =
        packets
            .where(
              (packet) =>
                  packet.recommendation ==
                  CandidateDecisionRecommendation.approve,
            )
            .length;
    final conditionalCount =
        packets
            .where(
              (packet) =>
                  packet.recommendation ==
                  CandidateDecisionRecommendation.conditional,
            )
            .length;
    final holdCount =
        packets
            .where(
              (packet) =>
                  packet.recommendation == CandidateDecisionRecommendation.hold,
            )
            .length;
    final dueSoonCount =
        packets.where((packet) => packet.daysUntilDue(asOfDate) <= 7).length;

    return CandidateDecisionSummary(
      totalPackets: packets.length,
      approveCount: approveCount,
      conditionalCount: conditionalCount,
      holdCount: holdCount,
      dueSoonCount: dueSoonCount,
      nextAction: _summaryNextAction(
        holdCount: holdCount,
        conditionalCount: conditionalCount,
        dueSoonCount: dueSoonCount,
      ),
    );
  }
}

List<String> _blockers({
  required CandidateSkillFitProfile fitProfile,
  required CandidateRampPlan? rampPlan,
  required OfferTracker? offer,
  required DateTime asOfDate,
}) {
  return [
    if (fitProfile.status == CandidateSkillFitStatus.gapRisk)
      'Resolve skill gap: ${fitProfile.topSkillGap}',
    if (rampPlan == null) 'Create ramp plan before handoff',
    if (rampPlan?.readiness == CandidateRampReadiness.atRisk)
      'Ramp at risk: ${rampPlan!.action}',
    if (_offerExpiresSoon(offer, asOfDate))
      'Offer expires in ${offer!.expiresAt.difference(asOfDate).inDays} days',
  ];
}

List<String> _handoffItems({
  required CandidateSkillFitProfile fitProfile,
  required CandidateRampPlan? rampPlan,
}) {
  return [
    'Attach scorecard evidence for ${fitProfile.topSkillGap}',
    'Confirm mentor: ${rampPlan?.mentorName ?? fitProfile.suggestedMentor}',
    'Assign learning: ${rampPlan?.learningPlanTitle ?? fitProfile.suggestedLearningPlan}',
  ];
}

CandidateDecisionRecommendation _recommendation({
  required CandidateSkillFitProfile fitProfile,
  required CandidateRampPlan? rampPlan,
  required List<String> blockers,
}) {
  final rampReadiness = rampPlan?.readiness;
  final hasHardBlocker =
      fitProfile.status == CandidateSkillFitStatus.gapRisk ||
      rampReadiness == CandidateRampReadiness.atRisk ||
      rampPlan == null;
  if (hasHardBlocker) return CandidateDecisionRecommendation.hold;

  final needsCoaching =
      fitProfile.status == CandidateSkillFitStatus.coaching ||
      rampReadiness == CandidateRampReadiness.coaching ||
      blockers.isNotEmpty;
  if (needsCoaching) return CandidateDecisionRecommendation.conditional;

  return CandidateDecisionRecommendation.approve;
}

DateTime _decisionDueDate({
  required CandidateSkillFitProfile fitProfile,
  required CandidateRampPlan? rampPlan,
  required OfferTracker? offer,
  required DateTime asOfDate,
}) {
  if (offer != null && offer.isPending) return offer.expiresAt;
  if (fitProfile.stage == CandidateStage.offer) {
    return asOfDate.add(const Duration(days: 3));
  }
  return rampPlan?.rampStartDate ?? asOfDate.add(const Duration(days: 7));
}

bool _offerExpiresSoon(OfferTracker? offer, DateTime asOfDate) {
  if (offer == null || !offer.isPending) return false;
  return offer.expiresAt.difference(asOfDate).inDays <= 5;
}

String _nextAction(
  CandidateDecisionRecommendation recommendation,
  List<String> blockers,
  List<String> handoffItems,
) {
  return switch (recommendation) {
    CandidateDecisionRecommendation.hold => blockers.first,
    CandidateDecisionRecommendation.conditional => handoffItems.first,
    CandidateDecisionRecommendation.approve =>
      'Approve and send packet to onboarding.',
  };
}

String _summaryNextAction({
  required int holdCount,
  required int conditionalCount,
  required int dueSoonCount,
}) {
  if (holdCount > 0) {
    return 'Review $holdCount blocked hiring decisions.';
  }
  if (dueSoonCount > 0) {
    return 'Close $dueSoonCount decision packets this week.';
  }
  if (conditionalCount > 0) {
    return 'Confirm coaching owners for $conditionalCount packets.';
  }
  return 'Decision packets are ready for onboarding handoff.';
}
