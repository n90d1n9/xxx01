import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../talent/states/talent_provider.dart';
import '../data/candidate_skill_fit_seed_data.dart';
import '../models/candidate_skill_evidence_models.dart';
import '../models/candidate_skill_fit_builder.dart';
import '../models/candidate_skill_fit_models.dart';
import '../models/recruitment_models.dart';
import 'recruitment_provider.dart';

final candidateRoleSkillRequirementsProvider =
    Provider<List<RoleSkillRequirement>>((ref) {
      return candidateRoleSkillRequirements;
    });

final candidateSkillEvidenceDraftProvider = StateNotifierProvider<
  CandidateSkillEvidenceDraftNotifier,
  CandidateSkillEvidenceDraft
>((ref) {
  return CandidateSkillEvidenceDraftNotifier();
});

final candidateSkillEvidenceProvider = StateNotifierProvider<
  CandidateSkillEvidenceNotifier,
  List<CandidateSkillEvidence>
>((ref) {
  return CandidateSkillEvidenceNotifier(candidateSkillEvidence);
});

final candidateSkillFitProfilesProvider =
    Provider<List<CandidateSkillFitProfile>>((ref) {
      final requirements = ref.watch(candidateRoleSkillRequirementsProvider);
      final evidence = ref.watch(candidateSkillEvidenceProvider);
      final learningPlans = ref.watch(learningPlansProvider);
      final mentorshipPairs = ref.watch(mentorshipPairsProvider);

      return ref
          .watch(candidateProfilesProvider)
          .where((candidate) => candidate.isActive)
          .map(
            (candidate) => buildCandidateSkillFitProfile(
              candidate: candidate,
              roleRequirements: requirements,
              evidence: evidence,
              learningPlans: learningPlans,
              mentorshipPairs: mentorshipPairs,
            ),
          )
          .toList();
    });

final filteredRecruitmentCandidateSkillFitProfilesProvider =
    Provider<List<CandidateSkillFitProfile>>((ref) {
      final department = ref.watch(recruitmentDepartmentProvider);
      final priorityOnly = ref.watch(recruitmentPriorityOnlyProvider);

      return ref
          .watch(candidateSkillFitProfilesProvider)
          .where(
            (profile) =>
                _matchesRecruitmentDepartment(profile, department) &&
                _matchesRecruitmentPriority(profile, priorityOnly),
          )
          .toList();
    });

final recruitmentCandidateSkillFitSummaryProvider =
    Provider<CandidateSkillFitSummary>((ref) {
      return CandidateSkillFitSummary.fromProfiles(
        ref.watch(filteredRecruitmentCandidateSkillFitProfilesProvider),
      );
    });

final filteredTalentCandidateSkillFitProfilesProvider =
    Provider<List<CandidateSkillFitProfile>>((ref) {
      final department = ref.watch(talentDepartmentProvider);
      final attentionOnly = ref.watch(talentNeedsAttentionProvider);

      return ref
          .watch(candidateSkillFitProfilesProvider)
          .where(
            (profile) =>
                _matchesTalentDepartment(profile, department) &&
                (!attentionOnly || profile.needsAttention),
          )
          .toList();
    });

final talentCandidateSkillFitSummaryProvider =
    Provider<CandidateSkillFitSummary>((ref) {
      return CandidateSkillFitSummary.fromProfiles(
        ref.watch(filteredTalentCandidateSkillFitProfilesProvider),
      );
    });

bool _matchesRecruitmentDepartment(
  CandidateSkillFitProfile profile,
  String department,
) {
  return department == recruitmentAllDepartments ||
      profile.department == department;
}

bool _matchesRecruitmentPriority(
  CandidateSkillFitProfile profile,
  bool priorityOnly,
) {
  return !priorityOnly ||
      profile.priority == RecruitmentPriority.high ||
      profile.needsAttention;
}

bool _matchesTalentDepartment(
  CandidateSkillFitProfile profile,
  String department,
) {
  return department == talentAllDepartments || profile.department == department;
}

class CandidateSkillEvidenceDraftNotifier
    extends StateNotifier<CandidateSkillEvidenceDraft> {
  CandidateSkillEvidenceDraftNotifier()
    : super(CandidateSkillEvidenceDraft.empty());

  void initializeFromSignal({
    required CandidateSkillFitProfile profile,
    required CandidateSkillFitSignal signal,
  }) {
    state = CandidateSkillEvidenceDraft.fromSignal(
      profile: profile,
      signal: signal,
    );
  }

  void setCandidate({
    required CandidateSkillFitProfile profile,
    CandidateSkillFitSignal? signal,
  }) {
    final selectedSignal =
        signal ?? profile.topGapSignal ?? profile.signals.first;
    state = CandidateSkillEvidenceDraft.fromSignal(
      profile: profile,
      signal: selectedSignal,
    );
  }

  void setSkill(CandidateSkillFitProfile profile, String skill) {
    final signal = profile.signals.firstWhere(
      (item) => item.skill == skill,
      orElse: () => profile.signals.first,
    );
    state = CandidateSkillEvidenceDraft.fromSignal(
      profile: profile,
      signal: signal,
    );
  }

  void setCurrentLevel(String value) {
    state = state.copyWith(currentLevelText: value);
  }

  void setEvidence(String value) {
    state = state.copyWith(evidence: value);
  }

  void clear() {
    state = CandidateSkillEvidenceDraft.empty();
  }
}

class CandidateSkillEvidenceNotifier
    extends StateNotifier<List<CandidateSkillEvidence>> {
  CandidateSkillEvidenceNotifier(List<CandidateSkillEvidence> evidence)
    : super([...evidence]);

  CandidateSkillEvidence upsertDraft(CandidateSkillEvidenceDraft draft) {
    final evidence = draft.toEvidence();
    state = [
      for (final item in state)
        if (!_matchesEvidence(item, evidence)) item,
      evidence,
    ];
    return evidence;
  }

  bool _matchesEvidence(
    CandidateSkillEvidence first,
    CandidateSkillEvidence second,
  ) {
    return first.candidateId == second.candidateId &&
        first.skill.toLowerCase() == second.skill.toLowerCase();
  }
}
