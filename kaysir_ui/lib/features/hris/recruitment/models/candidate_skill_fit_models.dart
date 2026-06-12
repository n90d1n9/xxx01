import 'recruitment_models.dart';

enum CandidateSkillSignalStatus {
  strength('Strength'),
  coaching('Coaching'),
  gap('Gap');

  final String label;

  const CandidateSkillSignalStatus(this.label);
}

enum CandidateSkillFitStatus {
  strongFit('Strong fit'),
  coaching('Coach before hire'),
  gapRisk('Gap risk');

  final String label;

  const CandidateSkillFitStatus(this.label);
}

class RoleSkillRequirement {
  final String role;
  final String skill;
  final int targetLevel;
  final int weight;
  final String learningPlanTitle;
  final String mentorName;

  const RoleSkillRequirement({
    required this.role,
    required this.skill,
    required this.targetLevel,
    required this.weight,
    required this.learningPlanTitle,
    required this.mentorName,
  });

  bool matchesRole(String candidateRole) {
    final normalizedRole = role.toLowerCase();
    final normalizedCandidate = candidateRole.toLowerCase();
    return normalizedRole == normalizedCandidate ||
        normalizedRole.contains(normalizedCandidate) ||
        normalizedCandidate.contains(normalizedRole);
  }
}

class CandidateSkillEvidence {
  final String candidateId;
  final String skill;
  final int currentLevel;
  final String evidence;

  const CandidateSkillEvidence({
    required this.candidateId,
    required this.skill,
    required this.currentLevel,
    required this.evidence,
  });
}

class CandidateSkillFitSignal {
  final String skill;
  final int currentLevel;
  final int targetLevel;
  final int weight;
  final String evidence;
  final String learningPlanTitle;
  final String mentorName;

  const CandidateSkillFitSignal({
    required this.skill,
    required this.currentLevel,
    required this.targetLevel,
    required this.weight,
    required this.evidence,
    required this.learningPlanTitle,
    required this.mentorName,
  });

  int get levelGap {
    final value = targetLevel - currentLevel;
    return value < 0 ? 0 : value;
  }

  double get progress {
    if (targetLevel <= 0) return 1;
    return (currentLevel / targetLevel).clamp(0, 1);
  }

  CandidateSkillSignalStatus get status {
    if (levelGap >= 2) return CandidateSkillSignalStatus.gap;
    if (levelGap == 1) return CandidateSkillSignalStatus.coaching;
    return CandidateSkillSignalStatus.strength;
  }
}

class CandidateSkillFitProfile {
  final String candidateId;
  final String candidateName;
  final String role;
  final String department;
  final CandidateStage stage;
  final RecruitmentPriority priority;
  final int candidateScore;
  final int fitScore;
  final CandidateSkillFitStatus status;
  final List<CandidateSkillFitSignal> signals;
  final String suggestedLearningPlan;
  final String suggestedMentor;
  final String nextAction;

  const CandidateSkillFitProfile({
    required this.candidateId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.stage,
    required this.priority,
    required this.candidateScore,
    required this.fitScore,
    required this.status,
    required this.signals,
    required this.suggestedLearningPlan,
    required this.suggestedMentor,
    required this.nextAction,
  });

  bool get needsAttention => status != CandidateSkillFitStatus.strongFit;

  int get criticalGapCount {
    return signals
        .where((signal) => signal.status == CandidateSkillSignalStatus.gap)
        .length;
  }

  int get coachingGapCount {
    return signals
        .where((signal) => signal.status == CandidateSkillSignalStatus.coaching)
        .length;
  }

  CandidateSkillFitSignal? get topGapSignal {
    final gaps =
        signals.where((signal) => signal.levelGap > 0).toList()
          ..sort((first, second) {
            final gapOrder = second.levelGap.compareTo(first.levelGap);
            if (gapOrder != 0) return gapOrder;
            return second.weight.compareTo(first.weight);
          });
    return gaps.isEmpty ? null : gaps.first;
  }

  String get topSkillGap {
    return topGapSignal?.skill ?? 'No skill gaps';
  }
}

class CandidateSkillFitSummary {
  final int totalProfiles;
  final int strongFitCount;
  final int coachingCount;
  final int gapRiskCount;
  final double averageFitScore;
  final String topGapSkill;
  final String nextAction;

  const CandidateSkillFitSummary({
    required this.totalProfiles,
    required this.strongFitCount,
    required this.coachingCount,
    required this.gapRiskCount,
    required this.averageFitScore,
    required this.topGapSkill,
    required this.nextAction,
  });

  factory CandidateSkillFitSummary.fromProfiles(
    List<CandidateSkillFitProfile> profiles,
  ) {
    final strongFitCount =
        profiles
            .where(
              (profile) => profile.status == CandidateSkillFitStatus.strongFit,
            )
            .length;
    final coachingCount =
        profiles
            .where(
              (profile) => profile.status == CandidateSkillFitStatus.coaching,
            )
            .length;
    final gapRiskCount =
        profiles
            .where(
              (profile) => profile.status == CandidateSkillFitStatus.gapRisk,
            )
            .length;
    final totalFitScore = profiles.fold<int>(
      0,
      (total, profile) => total + profile.fitScore,
    );
    final topGapProfile = _topGapProfile(profiles);

    return CandidateSkillFitSummary(
      totalProfiles: profiles.length,
      strongFitCount: strongFitCount,
      coachingCount: coachingCount,
      gapRiskCount: gapRiskCount,
      averageFitScore: profiles.isEmpty ? 0 : totalFitScore / profiles.length,
      topGapSkill: topGapProfile?.topSkillGap ?? 'No skill gaps',
      nextAction: _summaryNextAction(
        gapRiskCount: gapRiskCount,
        coachingCount: coachingCount,
        topGapSkill: topGapProfile?.topSkillGap,
      ),
    );
  }
}

CandidateSkillFitProfile? _topGapProfile(
  List<CandidateSkillFitProfile> profiles,
) {
  final candidates =
      profiles.where((profile) => profile.topGapSignal != null).toList()
        ..sort((first, second) {
          final statusOrder = _fitStatusWeight(
            second.status,
          ).compareTo(_fitStatusWeight(first.status));
          if (statusOrder != 0) return statusOrder;

          final criticalOrder = second.criticalGapCount.compareTo(
            first.criticalGapCount,
          );
          if (criticalOrder != 0) return criticalOrder;

          return first.fitScore.compareTo(second.fitScore);
        });

  return candidates.isEmpty ? null : candidates.first;
}

int _fitStatusWeight(CandidateSkillFitStatus status) {
  return switch (status) {
    CandidateSkillFitStatus.gapRisk => 2,
    CandidateSkillFitStatus.coaching => 1,
    CandidateSkillFitStatus.strongFit => 0,
  };
}

String _summaryNextAction({
  required int gapRiskCount,
  required int coachingCount,
  required String? topGapSkill,
}) {
  if (gapRiskCount > 0) {
    return 'Resolve $gapRiskCount critical fit gaps before offer approval.';
  }
  if (coachingCount > 0) {
    return 'Pre-assign coaches for $coachingCount candidates.';
  }
  return 'Candidate skill fit is ready for standard handoff.';
}
