import '../../talent/models/talent_models.dart';
import 'candidate_skill_fit_models.dart';
import 'recruitment_models.dart';

CandidateSkillFitProfile buildCandidateSkillFitProfile({
  required CandidateProfile candidate,
  required List<RoleSkillRequirement> roleRequirements,
  required List<CandidateSkillEvidence> evidence,
  required List<LearningPlan> learningPlans,
  required List<MentorshipPair> mentorshipPairs,
}) {
  final requirements = _requirementsForRole(candidate.role, roleRequirements);
  final signals =
      requirements.map((requirement) {
        final signalEvidence = _evidenceForSkill(
          candidate.id,
          requirement.skill,
          evidence,
        );
        return CandidateSkillFitSignal(
          skill: requirement.skill,
          currentLevel: signalEvidence?.currentLevel ?? 0,
          targetLevel: requirement.targetLevel,
          weight: requirement.weight,
          evidence: signalEvidence?.evidence ?? 'No evidence captured yet',
          learningPlanTitle: requirement.learningPlanTitle,
          mentorName: requirement.mentorName,
        );
      }).toList();
  final fitScore = _fitScore(candidate: candidate, signals: signals);
  final status = _statusFromSignals(fitScore, signals);
  final topGap = _topGap(signals);
  final suggestedLearningPlan =
      _learningPlanForGap(
        candidate: candidate,
        topGap: topGap,
        learningPlans: learningPlans,
      ) ??
      topGap?.learningPlanTitle ??
      'Role-specific onboarding checklist';
  final suggestedMentor =
      _mentorForCandidate(
        candidate: candidate,
        topGap: topGap,
        mentorshipPairs: mentorshipPairs,
      ) ??
      topGap?.mentorName ??
      candidate.owner;

  return CandidateSkillFitProfile(
    candidateId: candidate.id,
    candidateName: candidate.name,
    role: candidate.role,
    department: candidate.department,
    stage: candidate.stage,
    priority: candidate.priority,
    candidateScore: candidate.score,
    fitScore: fitScore,
    status: status,
    signals: signals,
    suggestedLearningPlan: suggestedLearningPlan,
    suggestedMentor: suggestedMentor,
    nextAction: _nextAction(
      candidate: candidate,
      status: status,
      topGap: topGap,
      suggestedMentor: suggestedMentor,
    ),
  );
}

List<RoleSkillRequirement> _requirementsForRole(
  String role,
  List<RoleSkillRequirement> requirements,
) {
  final matches =
      requirements
          .where((requirement) => requirement.matchesRole(role))
          .toList();

  if (matches.isNotEmpty) return matches;

  return [
    RoleSkillRequirement(
      role: role,
      skill: 'Role readiness',
      targetLevel: 3,
      weight: 1,
      learningPlanTitle: 'Role-specific onboarding checklist',
      mentorName: 'Hiring manager',
    ),
  ];
}

CandidateSkillEvidence? _evidenceForSkill(
  String candidateId,
  String skill,
  List<CandidateSkillEvidence> evidence,
) {
  final normalizedSkill = skill.toLowerCase();
  for (final item in evidence) {
    if (item.candidateId == candidateId &&
        item.skill.toLowerCase() == normalizedSkill) {
      return item;
    }
  }
  return null;
}

int _fitScore({
  required CandidateProfile candidate,
  required List<CandidateSkillFitSignal> signals,
}) {
  final requiredPoints = signals.fold<int>(
    0,
    (total, signal) => total + (signal.targetLevel * signal.weight),
  );
  if (requiredPoints <= 0) return candidate.score.clamp(0, 100);

  final candidatePoints = signals.fold<int>(
    0,
    (total, signal) =>
        total +
        (signal.currentLevel.clamp(0, signal.targetLevel) * signal.weight),
  );
  final skillScore = (candidatePoints / requiredPoints) * 100;
  return ((skillScore * 0.72) + (candidate.score * 0.28)).round();
}

CandidateSkillFitStatus _statusFromSignals(
  int fitScore,
  List<CandidateSkillFitSignal> signals,
) {
  final criticalGaps = signals.where(
    (signal) => signal.status == CandidateSkillSignalStatus.gap,
  );
  final coachingGaps = signals.where(
    (signal) => signal.status == CandidateSkillSignalStatus.coaching,
  );

  if (criticalGaps.isNotEmpty || fitScore < 78) {
    return CandidateSkillFitStatus.gapRisk;
  }
  if (coachingGaps.isNotEmpty || fitScore < 88) {
    return CandidateSkillFitStatus.coaching;
  }
  return CandidateSkillFitStatus.strongFit;
}

CandidateSkillFitSignal? _topGap(List<CandidateSkillFitSignal> signals) {
  final gaps =
      signals.where((signal) => signal.levelGap > 0).toList()
        ..sort((first, second) {
          final gapOrder = second.levelGap.compareTo(first.levelGap);
          if (gapOrder != 0) return gapOrder;
          return second.weight.compareTo(first.weight);
        });
  return gaps.isEmpty ? null : gaps.first;
}

String? _learningPlanForGap({
  required CandidateProfile candidate,
  required CandidateSkillFitSignal? topGap,
  required List<LearningPlan> learningPlans,
}) {
  if (topGap == null) return null;
  final matches =
      learningPlans
          .where((plan) => plan.department == candidate.department)
          .toList()
        ..sort((first, second) {
          final firstPlanMatch = _planMatchesGap(first, topGap);
          final secondPlanMatch = _planMatchesGap(second, topGap);
          if (firstPlanMatch != secondPlanMatch) {
            return firstPlanMatch ? -1 : 1;
          }
          return first.dueDate.compareTo(second.dueDate);
        });

  return matches.isEmpty ? null : matches.first.title;
}

bool _planMatchesGap(LearningPlan plan, CandidateSkillFitSignal topGap) {
  final title = plan.title.toLowerCase();
  final skill = topGap.skill.toLowerCase();
  final recommendation = topGap.learningPlanTitle.toLowerCase();
  return title.contains(skill) ||
      recommendation.contains(title) ||
      title.contains(recommendation);
}

String? _mentorForCandidate({
  required CandidateProfile candidate,
  required CandidateSkillFitSignal? topGap,
  required List<MentorshipPair> mentorshipPairs,
}) {
  final matches =
      mentorshipPairs
          .where((pair) => pair.department == candidate.department)
          .toList()
        ..sort((first, second) {
          final firstSkillMatch = _mentorMatchesGap(first, topGap);
          final secondSkillMatch = _mentorMatchesGap(second, topGap);
          if (firstSkillMatch != secondSkillMatch) {
            return firstSkillMatch ? -1 : 1;
          }
          return _mentorshipHealthWeight(
            first.health,
          ).compareTo(_mentorshipHealthWeight(second.health));
        });

  return matches.isEmpty ? null : matches.first.mentorName;
}

bool _mentorMatchesGap(MentorshipPair pair, CandidateSkillFitSignal? topGap) {
  if (topGap == null) return false;
  return pair.focusArea.toLowerCase().contains(topGap.skill.toLowerCase());
}

int _mentorshipHealthWeight(MentorshipHealth health) {
  return switch (health) {
    MentorshipHealth.healthy => 0,
    MentorshipHealth.watch => 1,
    MentorshipHealth.blocked => 2,
  };
}

String _nextAction({
  required CandidateProfile candidate,
  required CandidateSkillFitStatus status,
  required CandidateSkillFitSignal? topGap,
  required String suggestedMentor,
}) {
  final skill = topGap?.skill ?? 'role readiness';

  return switch (status) {
    CandidateSkillFitStatus.gapRisk =>
      'Resolve $skill gap before final approval for ${candidate.name}.',
    CandidateSkillFitStatus.coaching =>
      'Assign $suggestedMentor to coach $skill before handoff.',
    CandidateSkillFitStatus.strongFit =>
      'Keep standard scorecard evidence attached to the hiring packet.',
  };
}
