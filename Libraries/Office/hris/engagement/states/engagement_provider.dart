import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/engagement_seed_data.dart';
import '../models/engagement_models.dart';

const engagementAllDepartments = 'All';

final engagementDepartmentProvider = StateProvider<String>(
  (ref) => engagementAllDepartments,
);
final engagementAttentionOnlyProvider = StateProvider<bool>((ref) => false);
final engagementAsOfDateProvider = Provider<DateTime>((ref) => DateTime.now());

final engagementSurveysProvider = Provider<List<EngagementSurvey>>((ref) {
  return buildEngagementSurveys(ref.watch(engagementAsOfDateProvider));
});

final pulseTopicsProvider = Provider<List<PulseTopic>>((ref) {
  return engagementPulseTopics;
});

final recognitionMomentsProvider = Provider<List<RecognitionMoment>>((ref) {
  return buildRecognitionMoments(ref.watch(engagementAsOfDateProvider));
});

final wellbeingRisksProvider = Provider<List<WellbeingRisk>>((ref) {
  return buildWellbeingRisks(ref.watch(engagementAsOfDateProvider));
});

final engagementActionPlansProvider = Provider<List<EngagementActionPlan>>((
  ref,
) {
  return buildEngagementActionPlans(ref.watch(engagementAsOfDateProvider));
});

final engagementDepartmentsProvider = Provider<List<String>>((ref) {
  final departments =
      <String>{
          ...ref
              .watch(engagementSurveysProvider)
              .map((item) => item.department),
          ...ref.watch(pulseTopicsProvider).map((item) => item.department),
          ...ref
              .watch(recognitionMomentsProvider)
              .map((item) => item.department),
          ...ref.watch(wellbeingRisksProvider).map((item) => item.department),
          ...ref
              .watch(engagementActionPlansProvider)
              .map((item) => item.department),
        }.where((department) => department != engagementAllDepartments).toList()
        ..sort();

  return [engagementAllDepartments, ...departments];
});

final filteredEngagementSurveysProvider = Provider<List<EngagementSurvey>>((
  ref,
) {
  return ref
      .watch(engagementSurveysProvider)
      .where(
        (item) =>
            _matchesDepartment(ref, item.department, includeGlobal: true) &&
            _matchesAttention(ref, item.status == SurveyStatus.actionRequired),
      )
      .toList();
});

final filteredPulseTopicsProvider = Provider<List<PulseTopic>>((ref) {
  return ref
      .watch(pulseTopicsProvider)
      .where(
        (item) =>
            _matchesDepartment(ref, item.department) &&
            _matchesAttention(
              ref,
              item.priority == EngagementPriority.high || item.score < 70,
            ),
      )
      .toList();
});

final filteredRecognitionMomentsProvider = Provider<List<RecognitionMoment>>((
  ref,
) {
  return ref
      .watch(recognitionMomentsProvider)
      .where(
        (item) =>
            _matchesDepartment(ref, item.department) &&
            !ref.watch(engagementAttentionOnlyProvider),
      )
      .toList();
});

final filteredWellbeingRisksProvider = Provider<List<WellbeingRisk>>((ref) {
  return ref
      .watch(wellbeingRisksProvider)
      .where(
        (item) =>
            _matchesDepartment(ref, item.department) &&
            _matchesAttention(ref, item.level == WellbeingRiskLevel.high),
      )
      .toList();
});

final filteredEngagementActionPlansProvider =
    Provider<List<EngagementActionPlan>>((ref) {
      return ref
          .watch(engagementActionPlansProvider)
          .where(
            (item) =>
                _matchesDepartment(ref, item.department) &&
                _matchesAttention(ref, item.status == ActionPlanStatus.blocked),
          )
          .toList();
    });

final engagementRiskSummaryProvider = Provider<EngagementRiskSummary>((ref) {
  return EngagementRiskSummary.fromData(
    surveys: ref.watch(filteredEngagementSurveysProvider),
    pulses: ref.watch(filteredPulseTopicsProvider),
    risks: ref.watch(filteredWellbeingRisksProvider),
    actions: ref.watch(filteredEngagementActionPlansProvider),
    asOfDate: ref.watch(engagementAsOfDateProvider),
  );
});

final engagementSummaryProvider = Provider<EngagementSummary>((ref) {
  final surveys = ref.watch(filteredEngagementSurveysProvider);
  final pulses = ref.watch(filteredPulseTopicsProvider);
  final recognition = ref.watch(filteredRecognitionMomentsProvider);
  final risks = ref.watch(filteredWellbeingRisksProvider);
  final actions = ref.watch(filteredEngagementActionPlansProvider);

  final pulseTotal = pulses.fold<int>(0, (total, item) => total + item.score);

  return EngagementSummary(
    liveSurveys:
        surveys.where((item) => item.status == SurveyStatus.live).length,
    actionItems:
        actions.where((item) => item.status != ActionPlanStatus.done).length,
    highRisks:
        risks.where((item) => item.level == WellbeingRiskLevel.high).length,
    recognitionCount: recognition.length,
    averagePulseScore: pulses.isEmpty ? 0 : pulseTotal / pulses.length,
  );
});

bool _matchesDepartment(
  Ref ref,
  String department, {
  bool includeGlobal = false,
}) {
  final selectedDepartment = ref.watch(engagementDepartmentProvider);
  return selectedDepartment == engagementAllDepartments ||
      department == selectedDepartment ||
      (includeGlobal && department == engagementAllDepartments);
}

bool _matchesAttention(Ref ref, bool needsAttention) {
  return !ref.watch(engagementAttentionOnlyProvider) || needsAttention;
}
