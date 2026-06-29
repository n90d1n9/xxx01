import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../talent/models/talent_models.dart';
import '../../talent/states/talent_provider.dart';
import '../models/candidate_ramp_models.dart';
import '../models/recruitment_models.dart';
import 'recruitment_provider.dart';

final candidateRampPlansProvider = Provider<List<CandidateRampPlan>>((ref) {
  final asOfDate = ref.watch(recruitmentAsOfDateProvider);
  final skillGaps = ref.watch(skillGapsProvider);
  final learningPlans = ref.watch(learningPlansProvider);
  final mentorshipPairs = ref.watch(mentorshipPairsProvider);

  return ref
      .watch(candidateProfilesProvider)
      .where((candidate) => candidate.isActive)
      .map(
        (candidate) => CandidateRampPlan.fromSignals(
          candidate: candidate,
          skillGap: _bestSkillGap(candidate, skillGaps),
          learningPlan: _bestLearningPlan(candidate, learningPlans),
          mentorshipPair: _bestMentorshipPair(candidate, mentorshipPairs),
          asOfDate: asOfDate,
        ),
      )
      .toList();
});

final filteredRecruitmentCandidateRampPlansProvider =
    Provider<List<CandidateRampPlan>>((ref) {
      final department = ref.watch(recruitmentDepartmentProvider);
      final priorityOnly = ref.watch(recruitmentPriorityOnlyProvider);

      return ref
          .watch(candidateRampPlansProvider)
          .where(
            (plan) =>
                _matchesRecruitmentDepartment(plan, department) &&
                _matchesRecruitmentPriority(plan, priorityOnly),
          )
          .toList();
    });

final recruitmentCandidateRampSummaryProvider = Provider<CandidateRampSummary>((
  ref,
) {
  return CandidateRampSummary.fromPlans(
    ref.watch(filteredRecruitmentCandidateRampPlansProvider),
  );
});

final filteredTalentCandidateRampPlansProvider =
    Provider<List<CandidateRampPlan>>((ref) {
      final department = ref.watch(talentDepartmentProvider);
      final attentionOnly = ref.watch(talentNeedsAttentionProvider);

      return ref
          .watch(candidateRampPlansProvider)
          .where(
            (plan) =>
                _matchesTalentDepartment(plan, department) &&
                (!attentionOnly || plan.needsAttention),
          )
          .toList();
    });

final talentCandidateRampSummaryProvider = Provider<CandidateRampSummary>((
  ref,
) {
  return CandidateRampSummary.fromPlans(
    ref.watch(filteredTalentCandidateRampPlansProvider),
  );
});

SkillGap? _bestSkillGap(CandidateProfile candidate, List<SkillGap> skillGaps) {
  final matches =
      skillGaps
          .where((item) => item.department == candidate.department)
          .toList()
        ..sort((first, second) {
          final firstRoleMatch = _roleMatches(candidate.role, first.role);
          final secondRoleMatch = _roleMatches(candidate.role, second.role);
          if (firstRoleMatch != secondRoleMatch) {
            return firstRoleMatch ? -1 : 1;
          }

          final statusOrder = _skillStatusWeight(
            second.status,
          ).compareTo(_skillStatusWeight(first.status));
          if (statusOrder != 0) return statusOrder;

          return second.levelGap.compareTo(first.levelGap);
        });

  return matches.isEmpty ? null : matches.first;
}

LearningPlan? _bestLearningPlan(
  CandidateProfile candidate,
  List<LearningPlan> plans,
) {
  final matches =
      plans.where((item) => item.department == candidate.department).toList()
        ..sort((first, second) {
          final statusOrder = _learningStatusWeight(
            second.status,
          ).compareTo(_learningStatusWeight(first.status));
          if (statusOrder != 0) return statusOrder;
          return first.dueDate.compareTo(second.dueDate);
        });

  return matches.isEmpty ? null : matches.first;
}

MentorshipPair? _bestMentorshipPair(
  CandidateProfile candidate,
  List<MentorshipPair> pairs,
) {
  final matches =
      pairs.where((item) => item.department == candidate.department).toList()
        ..sort((first, second) {
          final healthOrder = _mentorshipHealthWeight(
            second.health,
          ).compareTo(_mentorshipHealthWeight(first.health));
          if (healthOrder != 0) return healthOrder;
          return first.nextSession.compareTo(second.nextSession);
        });

  return matches.isEmpty ? null : matches.first;
}

bool _matchesRecruitmentDepartment(CandidateRampPlan plan, String department) {
  return department == recruitmentAllDepartments ||
      plan.department == department;
}

bool _matchesRecruitmentPriority(CandidateRampPlan plan, bool priorityOnly) {
  return !priorityOnly ||
      plan.priority == RecruitmentPriority.high ||
      plan.readiness == CandidateRampReadiness.atRisk;
}

bool _matchesTalentDepartment(CandidateRampPlan plan, String department) {
  return department == talentAllDepartments || plan.department == department;
}

bool _roleMatches(String candidateRole, String skillRole) {
  final candidate = candidateRole.toLowerCase();
  final skill = skillRole.toLowerCase();
  return candidate.contains(skill) || skill.contains(candidate);
}

int _skillStatusWeight(SkillGapStatus status) {
  return switch (status) {
    SkillGapStatus.gap => 2,
    SkillGapStatus.growing => 1,
    SkillGapStatus.strength => 0,
  };
}

int _learningStatusWeight(LearningPlanStatus status) {
  return switch (status) {
    LearningPlanStatus.overdue => 3,
    LearningPlanStatus.inProgress => 2,
    LearningPlanStatus.planned => 1,
    LearningPlanStatus.completed => 0,
  };
}

int _mentorshipHealthWeight(MentorshipHealth health) {
  return switch (health) {
    MentorshipHealth.blocked => 2,
    MentorshipHealth.watch => 1,
    MentorshipHealth.healthy => 0,
  };
}
