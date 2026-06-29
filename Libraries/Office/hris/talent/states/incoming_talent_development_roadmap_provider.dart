import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/incoming_talent_activation_outcome_models.dart';
import '../models/incoming_talent_development_roadmap_models.dart';
import 'incoming_talent_activation_outcome_provider.dart';
import 'talent_provider.dart';

final incomingTalentDevelopmentRoadmapDraftProvider = StateNotifierProvider<
  IncomingTalentDevelopmentRoadmapDraftNotifier,
  IncomingTalentDevelopmentRoadmapDraft
>((ref) {
  return IncomingTalentDevelopmentRoadmapDraftNotifier(
    ref.watch(talentAsOfDateProvider),
  );
});

class IncomingTalentDevelopmentRoadmapDraftNotifier
    extends StateNotifier<IncomingTalentDevelopmentRoadmapDraft> {
  IncomingTalentDevelopmentRoadmapDraftNotifier(DateTime asOfDate)
    : super(IncomingTalentDevelopmentRoadmapDraft.empty(asOfDate));

  void initializeFromOutcome(IncomingTalentActivationOutcomeReview review) {
    state = IncomingTalentDevelopmentRoadmapDraft.fromOutcome(
      review: review,
      asOfDate: state.asOfDate,
    );
  }

  void setOwnerName(String value) {
    state = state.copyWith(ownerName: value);
  }

  void setMentorName(String value) {
    state = state.copyWith(mentorName: value);
  }

  void setFocusArea(String value) {
    state = state.copyWith(focusArea: value);
  }

  void setLearningObjective(String value) {
    state = state.copyWith(learningObjective: value);
  }

  void setFirstMilestone(String value) {
    state = state.copyWith(firstMilestone: value);
  }

  void setSuccessMetric(String value) {
    state = state.copyWith(successMetric: value);
  }

  void setCadence(IncomingTalentDevelopmentRoadmapCadence value) {
    state = state.copyWith(cadence: value);
  }

  void setStatus(IncomingTalentDevelopmentRoadmapStatus value) {
    state = state.copyWith(status: value);
  }

  void setStartDate(DateTime value) {
    state = state.copyWith(startDate: value);
  }

  void setTargetCompletionDate(DateTime value) {
    state = state.copyWith(targetCompletionDate: value);
  }

  void clear() {
    state = IncomingTalentDevelopmentRoadmapDraft.empty(state.asOfDate);
  }
}

final incomingTalentDevelopmentRoadmapsProvider = StateNotifierProvider<
  IncomingTalentDevelopmentRoadmapsNotifier,
  List<IncomingTalentDevelopmentRoadmap>
>((ref) {
  return IncomingTalentDevelopmentRoadmapsNotifier();
});

class IncomingTalentDevelopmentRoadmapsNotifier
    extends StateNotifier<List<IncomingTalentDevelopmentRoadmap>> {
  IncomingTalentDevelopmentRoadmapsNotifier() : super(const []);

  IncomingTalentDevelopmentRoadmap submitDraft(
    IncomingTalentDevelopmentRoadmapDraft draft,
  ) {
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }
    if (state.any(
      (roadmap) => roadmap.outcomeReviewId == draft.outcomeReviewId,
    )) {
      throw StateError('Roadmap already exists for this outcome review');
    }

    final roadmap = draft.toRoadmap(id: _nextId(), createdAt: draft.asOfDate);
    state = [roadmap, ...state];
    return roadmap;
  }

  void updateStatus({
    required String id,
    required IncomingTalentDevelopmentRoadmapStatus status,
  }) {
    state = [
      for (final roadmap in state)
        if (roadmap.id == id) _copyWithStatus(roadmap, status) else roadmap,
    ];
  }

  String _nextId() {
    final sequence = state.length + 1;
    return 'talent-roadmap-${sequence.toString().padLeft(3, '0')}';
  }

  IncomingTalentDevelopmentRoadmap _copyWithStatus(
    IncomingTalentDevelopmentRoadmap roadmap,
    IncomingTalentDevelopmentRoadmapStatus status,
  ) {
    return IncomingTalentDevelopmentRoadmap(
      id: roadmap.id,
      outcomeReviewId: roadmap.outcomeReviewId,
      activationPlanId: roadmap.activationPlanId,
      handoffId: roadmap.handoffId,
      candidateId: roadmap.candidateId,
      candidateName: roadmap.candidateName,
      role: roadmap.role,
      department: roadmap.department,
      ownerName: roadmap.ownerName,
      mentorName: roadmap.mentorName,
      focusArea: roadmap.focusArea,
      learningObjective: roadmap.learningObjective,
      firstMilestone: roadmap.firstMilestone,
      successMetric: roadmap.successMetric,
      cadence: roadmap.cadence,
      status: status,
      startDate: roadmap.startDate,
      targetCompletionDate: roadmap.targetCompletionDate,
      sourceDecision: roadmap.sourceDecision,
      retentionRisk: roadmap.retentionRisk,
      readinessScore: roadmap.readinessScore,
      createdAt: roadmap.createdAt,
    );
  }
}

final roadmapReadyActivationOutcomeReviewsProvider =
    Provider<List<IncomingTalentActivationOutcomeReview>>((ref) {
      final roadmappedOutcomeIds =
          ref
              .watch(incomingTalentDevelopmentRoadmapsProvider)
              .map((roadmap) => roadmap.outcomeReviewId)
              .toSet();
      return ref
          .watch(filteredIncomingTalentActivationOutcomeReviewsProvider)
          .where((review) => !roadmappedOutcomeIds.contains(review.id))
          .toList();
    });

final filteredIncomingTalentDevelopmentRoadmapsProvider =
    Provider<List<IncomingTalentDevelopmentRoadmap>>((ref) {
      final selectedDepartment = ref.watch(talentDepartmentProvider);
      final attentionOnly = ref.watch(talentNeedsAttentionProvider);

      return ref
          .watch(incomingTalentDevelopmentRoadmapsProvider)
          .where(
            (roadmap) =>
                (selectedDepartment == talentAllDepartments ||
                    roadmap.department == selectedDepartment) &&
                (!attentionOnly || roadmap.needsAttention),
          )
          .toList();
    });

final incomingTalentDevelopmentRoadmapSummaryProvider =
    Provider<IncomingTalentDevelopmentRoadmapSummary>((ref) {
      return IncomingTalentDevelopmentRoadmapSummary.fromRoadmaps(
        roadmaps: ref.watch(filteredIncomingTalentDevelopmentRoadmapsProvider),
        asOfDate: ref.watch(talentAsOfDateProvider),
      );
    });
