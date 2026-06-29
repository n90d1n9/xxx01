import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../talent/states/talent_provider.dart';
import '../models/candidate_decision_models.dart';
import '../models/candidate_ramp_models.dart';
import '../models/candidate_skill_fit_models.dart';
import '../models/recruitment_models.dart';
import 'candidate_ramp_provider.dart';
import 'candidate_skill_fit_provider.dart';
import 'recruitment_provider.dart';

final candidateDecisionPacketsProvider =
    Provider<List<CandidateDecisionPacket>>((ref) {
      final asOfDate = ref.watch(recruitmentAsOfDateProvider);
      final rampPlans = {
        for (final plan in ref.watch(candidateRampPlansProvider))
          plan.candidateName: plan,
      };
      final offers = {
        for (final offer in ref.watch(offerTrackersProvider))
          '${offer.candidateName}|${offer.role}': offer,
      };

      return ref
          .watch(candidateSkillFitProfilesProvider)
          .map(
            (profile) => CandidateDecisionPacket.fromSignals(
              fitProfile: profile,
              rampPlan: _rampPlanForProfile(profile, rampPlans),
              offer: _offerForProfile(profile, offers),
              asOfDate: asOfDate,
            ),
          )
          .toList();
    });

final filteredRecruitmentCandidateDecisionPacketsProvider =
    Provider<List<CandidateDecisionPacket>>((ref) {
      final department = ref.watch(recruitmentDepartmentProvider);
      final priorityOnly = ref.watch(recruitmentPriorityOnlyProvider);

      return ref
          .watch(candidateDecisionPacketsProvider)
          .where(
            (packet) =>
                _matchesRecruitmentDepartment(packet, department) &&
                _matchesRecruitmentPriority(packet, priorityOnly),
          )
          .toList();
    });

final recruitmentCandidateDecisionSummaryProvider =
    Provider<CandidateDecisionSummary>((ref) {
      return CandidateDecisionSummary.fromPackets(
        packets: ref.watch(filteredRecruitmentCandidateDecisionPacketsProvider),
        asOfDate: ref.watch(recruitmentAsOfDateProvider),
      );
    });

final filteredTalentCandidateDecisionPacketsProvider =
    Provider<List<CandidateDecisionPacket>>((ref) {
      final department = ref.watch(talentDepartmentProvider);
      final attentionOnly = ref.watch(talentNeedsAttentionProvider);

      return ref
          .watch(candidateDecisionPacketsProvider)
          .where(
            (packet) =>
                _matchesTalentDepartment(packet, department) &&
                (!attentionOnly || packet.needsAttention),
          )
          .toList();
    });

final talentCandidateDecisionSummaryProvider =
    Provider<CandidateDecisionSummary>((ref) {
      return CandidateDecisionSummary.fromPackets(
        packets: ref.watch(filteredTalentCandidateDecisionPacketsProvider),
        asOfDate: ref.watch(recruitmentAsOfDateProvider),
      );
    });

CandidateRampPlan? _rampPlanForProfile(
  CandidateSkillFitProfile profile,
  Map<String, CandidateRampPlan> rampPlans,
) {
  return rampPlans[profile.candidateName];
}

OfferTracker? _offerForProfile(
  CandidateSkillFitProfile profile,
  Map<String, OfferTracker> offers,
) {
  return offers['${profile.candidateName}|${profile.role}'];
}

bool _matchesRecruitmentDepartment(
  CandidateDecisionPacket packet,
  String department,
) {
  return department == recruitmentAllDepartments ||
      packet.department == department;
}

bool _matchesRecruitmentPriority(
  CandidateDecisionPacket packet,
  bool priorityOnly,
) {
  return !priorityOnly ||
      packet.priority == RecruitmentPriority.high ||
      packet.needsAttention;
}

bool _matchesTalentDepartment(
  CandidateDecisionPacket packet,
  String department,
) {
  return department == talentAllDepartments || packet.department == department;
}
