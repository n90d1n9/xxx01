import '../../talent/models/talent_models.dart';
import 'recruitment_models.dart';

enum CandidateRampReadiness {
  ready('Ready'),
  coaching('Coaching'),
  atRisk('At risk');

  final String label;

  const CandidateRampReadiness(this.label);
}

class CandidateRampPlan {
  final String id;
  final String candidateName;
  final String role;
  final String department;
  final CandidateStage stage;
  final RecruitmentPriority priority;
  final int candidateScore;
  final String skillFocus;
  final int skillGapLevel;
  final String learningPlanTitle;
  final String mentorName;
  final DateTime rampStartDate;
  final DateTime readinessDate;
  final bool offerSensitive;
  final CandidateRampReadiness readiness;
  final String action;

  const CandidateRampPlan({
    required this.id,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.stage,
    required this.priority,
    required this.candidateScore,
    required this.skillFocus,
    required this.skillGapLevel,
    required this.learningPlanTitle,
    required this.mentorName,
    required this.rampStartDate,
    required this.readinessDate,
    required this.offerSensitive,
    required this.readiness,
    required this.action,
  });

  int daysUntilReady(DateTime asOfDate) {
    final start = DateTime(asOfDate.year, asOfDate.month, asOfDate.day);
    final ready = DateTime(
      readinessDate.year,
      readinessDate.month,
      readinessDate.day,
    );
    return ready.difference(start).inDays;
  }

  bool get needsAttention => readiness != CandidateRampReadiness.ready;

  factory CandidateRampPlan.fromSignals({
    required CandidateProfile candidate,
    required SkillGap? skillGap,
    required LearningPlan? learningPlan,
    required MentorshipPair? mentorshipPair,
    required DateTime asOfDate,
  }) {
    final riskScore = _riskScore(
      candidate: candidate,
      skillGap: skillGap,
      learningPlan: learningPlan,
      mentorshipPair: mentorshipPair,
    );
    final readiness = _readinessFromRisk(riskScore);

    return CandidateRampPlan(
      id: 'ramp-${candidate.id}',
      candidateName: candidate.name,
      role: candidate.role,
      department: candidate.department,
      stage: candidate.stage,
      priority: candidate.priority,
      candidateScore: candidate.score,
      skillFocus: skillGap?.skill ?? _fallbackSkillFocus(candidate.role),
      skillGapLevel: skillGap?.levelGap ?? 0,
      learningPlanTitle:
          learningPlan?.title ?? 'Role-specific onboarding checklist',
      mentorName: mentorshipPair?.mentorName ?? candidate.owner,
      rampStartDate: _rampStartDate(candidate, asOfDate),
      readinessDate: _readinessDate(readiness, asOfDate),
      offerSensitive: candidate.stage == CandidateStage.offer,
      readiness: readiness,
      action: _nextAction(readiness, candidate, skillGap, mentorshipPair),
    );
  }
}

class CandidateRampSummary {
  final int totalPlans;
  final int readyCount;
  final int coachingCount;
  final int atRiskCount;
  final int offerStageCount;
  final double averageCandidateScore;
  final String nextAction;

  const CandidateRampSummary({
    required this.totalPlans,
    required this.readyCount,
    required this.coachingCount,
    required this.atRiskCount,
    required this.offerStageCount,
    required this.averageCandidateScore,
    required this.nextAction,
  });

  factory CandidateRampSummary.fromPlans(List<CandidateRampPlan> plans) {
    final readyCount =
        plans
            .where((item) => item.readiness == CandidateRampReadiness.ready)
            .length;
    final coachingCount =
        plans
            .where((item) => item.readiness == CandidateRampReadiness.coaching)
            .length;
    final atRiskCount =
        plans
            .where((item) => item.readiness == CandidateRampReadiness.atRisk)
            .length;
    final offerStageCount = plans.where((item) => item.offerSensitive).length;
    final totalScore = plans.fold<int>(
      0,
      (total, item) => total + item.candidateScore,
    );

    return CandidateRampSummary(
      totalPlans: plans.length,
      readyCount: readyCount,
      coachingCount: coachingCount,
      atRiskCount: atRiskCount,
      offerStageCount: offerStageCount,
      averageCandidateScore: plans.isEmpty ? 0 : totalScore / plans.length,
      nextAction: _summaryNextAction(
        atRiskCount: atRiskCount,
        coachingCount: coachingCount,
        offerStageCount: offerStageCount,
      ),
    );
  }
}

int _riskScore({
  required CandidateProfile candidate,
  required SkillGap? skillGap,
  required LearningPlan? learningPlan,
  required MentorshipPair? mentorshipPair,
}) {
  var score = 0;
  if (candidate.priority == RecruitmentPriority.high) score += 1;
  if (candidate.stage == CandidateStage.offer) score += 1;
  if (candidate.score < 80) score += 1;

  if (skillGap != null) {
    score += switch (skillGap.status) {
      SkillGapStatus.gap => 2,
      SkillGapStatus.growing => 1,
      SkillGapStatus.strength => 0,
    };
  }

  if (learningPlan != null) {
    score += switch (learningPlan.status) {
      LearningPlanStatus.overdue => 2,
      LearningPlanStatus.planned => 1,
      LearningPlanStatus.inProgress => learningPlan.pendingCount > 0 ? 1 : 0,
      LearningPlanStatus.completed => 0,
    };
  }

  if (mentorshipPair != null) {
    score += switch (mentorshipPair.health) {
      MentorshipHealth.blocked => 2,
      MentorshipHealth.watch => 1,
      MentorshipHealth.healthy => 0,
    };
  }

  return score;
}

CandidateRampReadiness _readinessFromRisk(int riskScore) {
  if (riskScore >= 5) return CandidateRampReadiness.atRisk;
  if (riskScore >= 2) return CandidateRampReadiness.coaching;
  return CandidateRampReadiness.ready;
}

String _fallbackSkillFocus(String role) {
  final normalized = role.toLowerCase();
  if (normalized.contains('engineer')) return 'Architecture onboarding';
  if (normalized.contains('payroll')) return 'Payroll process fluency';
  if (normalized.contains('operations')) return 'Operations leadership';
  if (normalized.contains('partner')) return 'Employee relations practice';
  return 'Role readiness';
}

DateTime _rampStartDate(CandidateProfile candidate, DateTime asOfDate) {
  return switch (candidate.stage) {
    CandidateStage.offer => asOfDate.add(const Duration(days: 7)),
    CandidateStage.hired => asOfDate,
    CandidateStage.interview => asOfDate.add(const Duration(days: 14)),
    CandidateStage.screening => asOfDate.add(const Duration(days: 21)),
    CandidateStage.applied => asOfDate.add(const Duration(days: 28)),
    CandidateStage.rejected => asOfDate,
  };
}

DateTime _readinessDate(CandidateRampReadiness readiness, DateTime asOfDate) {
  return switch (readiness) {
    CandidateRampReadiness.ready => asOfDate.add(const Duration(days: 30)),
    CandidateRampReadiness.coaching => asOfDate.add(const Duration(days: 45)),
    CandidateRampReadiness.atRisk => asOfDate.add(const Duration(days: 60)),
  };
}

String _nextAction(
  CandidateRampReadiness readiness,
  CandidateProfile candidate,
  SkillGap? skillGap,
  MentorshipPair? mentorshipPair,
) {
  if (readiness == CandidateRampReadiness.atRisk) {
    if (mentorshipPair?.health == MentorshipHealth.blocked) {
      return 'Unblock mentor capacity before offer handoff.';
    }
    return 'Create a manager-owned ramp plan before moving ${candidate.name}.';
  }

  if (readiness == CandidateRampReadiness.coaching) {
    if ((skillGap?.levelGap ?? 0) > 0) {
      return 'Assign focused coaching for ${skillGap!.skill}.';
    }
    return 'Confirm onboarding owner and first-week learning goals.';
  }

  return 'Prepare standard onboarding and success checkpoints.';
}

String _summaryNextAction({
  required int atRiskCount,
  required int coachingCount,
  required int offerStageCount,
}) {
  if (atRiskCount > 0) {
    return 'Pair at-risk candidates with mentors before offer handoff.';
  }
  if (offerStageCount > 0) {
    return 'Attach ramp plans to active offers.';
  }
  if (coachingCount > 0) {
    return 'Confirm coaching owners for ramp plans.';
  }
  return 'Ramp plans are ready for standard onboarding.';
}
