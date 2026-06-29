import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/recruitment_seed_data.dart';
import '../models/recruitment_models.dart';

const recruitmentAllDepartments = 'All';

final recruitmentDepartmentProvider = StateProvider<String>(
  (ref) => recruitmentAllDepartments,
);
final recruitmentPriorityOnlyProvider = StateProvider<bool>((ref) => false);
final recruitmentAsOfDateProvider = Provider<DateTime>((ref) => DateTime.now());

final jobRequisitionsProvider = Provider<List<JobRequisition>>((ref) {
  return buildRecruitmentRequisitions(ref.watch(recruitmentAsOfDateProvider));
});

final candidateProfilesProvider = Provider<List<CandidateProfile>>((ref) {
  return buildRecruitmentCandidates(ref.watch(recruitmentAsOfDateProvider));
});

final interviewSlotsProvider = Provider<List<InterviewSlot>>((ref) {
  return buildRecruitmentInterviews(ref.watch(recruitmentAsOfDateProvider));
});

final offerTrackersProvider = Provider<List<OfferTracker>>((ref) {
  return buildRecruitmentOffers(ref.watch(recruitmentAsOfDateProvider));
});

final sourceMetricsProvider = Provider<List<SourceMetric>>((ref) {
  return recruitmentSourceMetrics;
});

final recruitmentDepartmentsProvider = Provider<List<String>>((ref) {
  final departments =
      <String>{
          ...ref.watch(jobRequisitionsProvider).map((item) => item.department),
          ...ref
              .watch(candidateProfilesProvider)
              .map((item) => item.department),
          ...ref.watch(interviewSlotsProvider).map((item) => item.department),
          ...ref.watch(offerTrackersProvider).map((item) => item.department),
        }.toList()
        ..sort();

  return [recruitmentAllDepartments, ...departments];
});

final filteredJobRequisitionsProvider = Provider<List<JobRequisition>>((ref) {
  return ref
      .watch(jobRequisitionsProvider)
      .where(
        (item) =>
            _matchesDepartment(ref, item.department) &&
            _matchesPriority(ref, item.priority == RecruitmentPriority.high),
      )
      .toList();
});

final filteredCandidateProfilesProvider = Provider<List<CandidateProfile>>((
  ref,
) {
  return ref
      .watch(candidateProfilesProvider)
      .where(
        (item) =>
            _matchesDepartment(ref, item.department) &&
            _matchesPriority(ref, item.priority == RecruitmentPriority.high),
      )
      .toList();
});

final filteredInterviewSlotsProvider = Provider<List<InterviewSlot>>((ref) {
  return ref
      .watch(interviewSlotsProvider)
      .where(
        (item) =>
            _matchesDepartment(ref, item.department) &&
            _matchesPriority(ref, item.status == InterviewStatus.needsFeedback),
      )
      .toList();
});

final filteredOfferTrackersProvider = Provider<List<OfferTracker>>((ref) {
  return ref
      .watch(offerTrackersProvider)
      .where(
        (item) =>
            _matchesDepartment(ref, item.department) &&
            _matchesPriority(ref, item.isPending),
      )
      .toList();
});

final filteredSourceMetricsProvider = Provider<List<SourceMetric>>((ref) {
  return ref
      .watch(sourceMetricsProvider)
      .where(
        (item) => _matchesPriority(ref, item.health != SourceHealth.strong),
      )
      .toList();
});

final recruitmentPipelineRiskProvider =
    Provider<RecruitmentPipelineRiskSummary>((ref) {
      return RecruitmentPipelineRiskSummary.fromData(
        requisitions: ref.watch(filteredJobRequisitionsProvider),
        candidates: ref.watch(filteredCandidateProfilesProvider),
        interviews: ref.watch(filteredInterviewSlotsProvider),
        offers: ref.watch(filteredOfferTrackersProvider),
        sources: ref.watch(filteredSourceMetricsProvider),
        asOfDate: ref.watch(recruitmentAsOfDateProvider),
      );
    });

final recruitmentSummaryProvider = Provider<RecruitmentSummary>((ref) {
  final requisitions = ref.watch(filteredJobRequisitionsProvider);
  final candidates = ref.watch(filteredCandidateProfilesProvider);
  final interviews = ref.watch(filteredInterviewSlotsProvider);
  final offers = ref.watch(filteredOfferTrackersProvider);
  final sources = ref.watch(filteredSourceMetricsProvider);
  final asOfDate = ref.watch(recruitmentAsOfDateProvider);

  final totalCandidates = sources.fold<int>(
    0,
    (total, source) => total + source.candidates,
  );
  final totalHires = sources.fold<int>(
    0,
    (total, source) => total + source.hires,
  );

  return RecruitmentSummary(
    openRequisitions: requisitions.where((item) => item.isOpen).length,
    activeCandidates: candidates.where((item) => item.isActive).length,
    interviewsToday:
        interviews
            .where((item) => _isSameDay(item.scheduledAt, asOfDate))
            .length,
    pendingOffers: offers.where((item) => item.isPending).length,
    sourceHireRate: totalCandidates == 0 ? 0 : totalHires / totalCandidates,
  );
});

bool _matchesDepartment(Ref ref, String department) {
  final selectedDepartment = ref.watch(recruitmentDepartmentProvider);
  return selectedDepartment == recruitmentAllDepartments ||
      department == selectedDepartment;
}

bool _matchesPriority(Ref ref, bool isPriority) {
  return !ref.watch(recruitmentPriorityOnlyProvider) || isPriority;
}

bool _isSameDay(DateTime first, DateTime second) {
  return first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}
