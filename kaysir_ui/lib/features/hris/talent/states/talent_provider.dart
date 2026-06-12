import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../recruitment/states/candidate_talent_handoff_checklist_provider.dart';
import '../../recruitment/states/candidate_talent_handoff_provider.dart';
import '../data/talent_seed_data.dart';
import '../models/incoming_talent_readiness.dart';
import '../models/incoming_talent_readiness_summary.dart';
import '../models/talent_models.dart';

const talentAllDepartments = 'All';

final talentDepartmentProvider = StateProvider<String>(
  (ref) => talentAllDepartments,
);
final talentNeedsAttentionProvider = StateProvider<bool>((ref) => false);
final talentAsOfDateProvider = Provider<DateTime>((ref) => DateTime.now());

final skillGapsProvider = Provider<List<SkillGap>>((ref) {
  return talentSkillGaps;
});

final learningPlansProvider = Provider<List<LearningPlan>>((ref) {
  return buildLearningPlans(ref.watch(talentAsOfDateProvider));
});

final certificationsProvider = Provider<List<CertificationRecord>>((ref) {
  return buildCertifications(ref.watch(talentAsOfDateProvider));
});

final mentorshipPairsProvider = Provider<List<MentorshipPair>>((ref) {
  return buildMentorshipPairs(ref.watch(talentAsOfDateProvider));
});

final talentDepartmentsProvider = Provider<List<String>>((ref) {
  final departments =
      <String>{
          ...ref.watch(skillGapsProvider).map((item) => item.department),
          ...ref.watch(learningPlansProvider).map((item) => item.department),
          ...ref.watch(certificationsProvider).map((item) => item.department),
          ...ref.watch(mentorshipPairsProvider).map((item) => item.department),
          ...ref
              .watch(incomingTalentReadinessProvider)
              .map((item) => item.department),
        }.where((department) => department != talentAllDepartments).toList()
        ..sort();

  return [talentAllDepartments, ...departments];
});

final filteredSkillGapsProvider = Provider<List<SkillGap>>((ref) {
  return ref
      .watch(skillGapsProvider)
      .where(
        (item) =>
            _matchesDepartment(ref, item.department) &&
            _matchesAttention(ref, item.status == SkillGapStatus.gap),
      )
      .toList();
});

final filteredLearningPlansProvider = Provider<List<LearningPlan>>((ref) {
  return ref
      .watch(learningPlansProvider)
      .where(
        (item) =>
            _matchesDepartment(ref, item.department) &&
            _matchesAttention(
              ref,
              item.status == LearningPlanStatus.overdue ||
                  item.pendingCount > 0,
            ),
      )
      .toList();
});

final filteredCertificationsProvider = Provider<List<CertificationRecord>>((
  ref,
) {
  return ref
      .watch(certificationsProvider)
      .where(
        (item) =>
            _matchesDepartment(ref, item.department) &&
            _matchesAttention(ref, item.status != CertificationStatus.active),
      )
      .toList();
});

final filteredMentorshipPairsProvider = Provider<List<MentorshipPair>>((ref) {
  return ref
      .watch(mentorshipPairsProvider)
      .where(
        (item) =>
            _matchesDepartment(ref, item.department) &&
            _matchesAttention(ref, item.health != MentorshipHealth.healthy),
      )
      .toList();
});

final incomingTalentReadinessProvider = Provider<List<IncomingTalentReadiness>>(
  (ref) {
    final checklistItems = ref.watch(
      candidateTalentHandoffChecklistItemsProvider,
    );
    final readiness =
        ref
            .watch(candidateTalentHandoffsProvider)
            .map(
              (handoff) => IncomingTalentReadiness.fromHandoff(
                handoff: handoff,
                checklistItems: checklistItems,
                asOfDate: ref.watch(talentAsOfDateProvider),
              ),
            )
            .toList()
          ..sort(_compareIncomingTalentReadiness);

    return readiness;
  },
);

final filteredIncomingTalentReadinessProvider =
    Provider<List<IncomingTalentReadiness>>((ref) {
      return ref
          .watch(incomingTalentReadinessProvider)
          .where(
            (item) =>
                _matchesDepartment(ref, item.department) &&
                _matchesAttention(ref, item.needsAttention),
          )
          .toList();
    });

final incomingTalentReadinessSummaryProvider =
    Provider<IncomingTalentReadinessSummary>((ref) {
      return IncomingTalentReadinessSummary.fromReadiness(
        ref.watch(filteredIncomingTalentReadinessProvider),
      );
    });

final talentRiskSummaryProvider = Provider<TalentRiskSummary>((ref) {
  return TalentRiskSummary.fromData(
    skillGaps: ref.watch(filteredSkillGapsProvider),
    learningPlans: ref.watch(filteredLearningPlansProvider),
    certifications: ref.watch(filteredCertificationsProvider),
    mentorshipPairs: ref.watch(filteredMentorshipPairsProvider),
    asOfDate: ref.watch(talentAsOfDateProvider),
  );
});

final talentSummaryProvider = Provider<TalentSummary>((ref) {
  final skillGaps = ref.watch(filteredSkillGapsProvider);
  final learningPlans = ref.watch(filteredLearningPlansProvider);
  final certifications = ref.watch(filteredCertificationsProvider);
  final mentorshipPairs = ref.watch(filteredMentorshipPairsProvider);

  final totalCompletion = learningPlans.fold<double>(
    0,
    (total, plan) => total + plan.completionRate,
  );

  return TalentSummary(
    skillGaps:
        skillGaps.where((item) => item.status == SkillGapStatus.gap).length,
    learningDue: learningPlans.fold<int>(
      0,
      (total, plan) => total + plan.pendingCount,
    ),
    certificationRisks:
        certifications
            .where((item) => item.status != CertificationStatus.active)
            .length,
    mentoringWatch:
        mentorshipPairs
            .where((item) => item.health != MentorshipHealth.healthy)
            .length,
    averageLearningCompletion:
        learningPlans.isEmpty ? 0 : totalCompletion / learningPlans.length,
  );
});

bool _matchesDepartment(Ref ref, String department) {
  final selectedDepartment = ref.watch(talentDepartmentProvider);
  return selectedDepartment == talentAllDepartments ||
      department == selectedDepartment;
}

bool _matchesAttention(Ref ref, bool needsAttention) {
  return !ref.watch(talentNeedsAttentionProvider) || needsAttention;
}

int _compareIncomingTalentReadiness(
  IncomingTalentReadiness a,
  IncomingTalentReadiness b,
) {
  final statusCompare = _readinessStatusRank(
    a.status,
  ).compareTo(_readinessStatusRank(b.status));
  if (statusCompare != 0) return statusCompare;
  return a.targetStartDate.compareTo(b.targetStartDate);
}

int _readinessStatusRank(IncomingTalentReadinessStatus status) {
  return switch (status) {
    IncomingTalentReadinessStatus.blocked => 0,
    IncomingTalentReadinessStatus.attention => 1,
    IncomingTalentReadinessStatus.ready => 2,
  };
}
