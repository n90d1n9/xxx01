import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/incoming_talent_career_path_models.dart';
import '../models/incoming_talent_promotion_readiness_models.dart';
import 'incoming_talent_career_framework_level_provider.dart';
import 'incoming_talent_career_path_provider.dart';
import 'talent_provider.dart';

final incomingTalentPromotionReadinessDraftProvider = StateNotifierProvider<
  IncomingTalentPromotionReadinessDraftNotifier,
  IncomingTalentPromotionReadinessDraft
>((ref) {
  return IncomingTalentPromotionReadinessDraftNotifier(
    ref.watch(talentAsOfDateProvider),
  );
});

/// Owns the editable promotion-readiness assessment draft.
class IncomingTalentPromotionReadinessDraftNotifier
    extends StateNotifier<IncomingTalentPromotionReadinessDraft> {
  IncomingTalentPromotionReadinessDraftNotifier(DateTime asOfDate)
    : super(IncomingTalentPromotionReadinessDraft.empty(asOfDate));

  void initializeFromSource(IncomingTalentPromotionReadinessSource source) {
    state = IncomingTalentPromotionReadinessDraft.fromSource(
      source: source,
      asOfDate: state.asOfDate,
    );
  }

  void setAssessorName(String value) {
    state = state.copyWith(assessorName: value);
  }

  void setRating(IncomingTalentPromotionReadinessRating value) {
    state = state.copyWith(rating: value);
  }

  void setStatus(IncomingTalentPromotionReadinessStatus value) {
    state = state.copyWith(status: value);
  }

  void setEvidenceSummary(String value) {
    state = state.copyWith(evidenceSummary: value);
  }

  void setGapSummary(String value) {
    state = state.copyWith(gapSummary: value);
  }

  void setPanelRecommendation(String value) {
    state = state.copyWith(panelRecommendation: value);
  }

  void setReviewDate(DateTime value) {
    state = state.copyWith(
      reviewDate: value,
      nextReviewDate: value.add(const Duration(days: 45)),
    );
  }

  void setNextReviewDate(DateTime value) {
    state = state.copyWith(nextReviewDate: value);
  }

  void clear() {
    state = IncomingTalentPromotionReadinessDraft.empty(state.asOfDate);
  }
}

final incomingTalentPromotionReadinessProvider = StateNotifierProvider<
  IncomingTalentPromotionReadinessNotifier,
  List<IncomingTalentPromotionReadiness>
>((ref) {
  return IncomingTalentPromotionReadinessNotifier();
});

/// Stores promotion-readiness packets and prevents duplicate panel reviews.
class IncomingTalentPromotionReadinessNotifier
    extends StateNotifier<List<IncomingTalentPromotionReadiness>> {
  IncomingTalentPromotionReadinessNotifier() : super(const []);

  IncomingTalentPromotionReadiness submitDraft(
    IncomingTalentPromotionReadinessDraft draft,
  ) {
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }
    if (state.any(
      (packet) =>
          packet.careerPathId == draft.careerPathId &&
          packet.frameworkLevelId == draft.frameworkLevelId &&
          _isSameDay(packet.reviewDate, draft.reviewDate!),
    )) {
      throw StateError('Promotion readiness already exists for this review');
    }

    final packet = draft.toReadiness(id: _nextId(), createdAt: draft.asOfDate);
    state = [packet, ...state];
    return packet;
  }

  void updateStatus({
    required String id,
    required IncomingTalentPromotionReadinessStatus status,
  }) {
    state = [
      for (final packet in state)
        if (packet.id == id) _copyWithStatus(packet, status) else packet,
    ];
  }

  String _nextId() {
    final sequence = state.length + 1;
    return 'talent-promotion-readiness-${sequence.toString().padLeft(3, '0')}';
  }

  IncomingTalentPromotionReadiness _copyWithStatus(
    IncomingTalentPromotionReadiness packet,
    IncomingTalentPromotionReadinessStatus status,
  ) {
    return IncomingTalentPromotionReadiness(
      id: packet.id,
      careerPathId: packet.careerPathId,
      frameworkLevelId: packet.frameworkLevelId,
      candidateId: packet.candidateId,
      candidateName: packet.candidateName,
      department: packet.department,
      currentRole: packet.currentRole,
      targetRole: packet.targetRole,
      frameworkFamilyName: packet.frameworkFamilyName,
      frameworkLevelCode: packet.frameworkLevelCode,
      frameworkScope: packet.frameworkScope,
      frameworkReviewCadence: packet.frameworkReviewCadence,
      assessorName: packet.assessorName,
      rating: packet.rating,
      status: status,
      competencyName: packet.competencyName,
      evidenceSummary: packet.evidenceSummary,
      gapSummary: packet.gapSummary,
      panelRecommendation: packet.panelRecommendation,
      reviewDate: packet.reviewDate,
      nextReviewDate: packet.nextReviewDate,
      sourceCareerPathStatus: packet.sourceCareerPathStatus,
      sourceCareerPathPriority: packet.sourceCareerPathPriority,
      createdAt: packet.createdAt,
    );
  }
}

final promotionReadinessSourceProvider =
    Provider<List<IncomingTalentPromotionReadinessSource>>((ref) {
      final packets = ref.watch(incomingTalentPromotionReadinessProvider);
      final completedSourceKeys =
          packets
              .map(
                (packet) => '${packet.careerPathId}|${packet.frameworkLevelId}',
              )
              .toSet();
      final levels = ref.watch(incomingTalentCareerFrameworkLevelsProvider);

      return [
        for (final careerPath in ref.watch(
          filteredIncomingTalentCareerPathsProvider,
        ))
          if (careerPath.status != IncomingTalentCareerPathStatus.achieved)
            for (final level in levels)
              if (level.matchesCareerPath(careerPath) &&
                  !completedSourceKeys.contains('${careerPath.id}|${level.id}'))
                IncomingTalentPromotionReadinessSource(
                  careerPath: careerPath,
                  frameworkLevel: level,
                ),
      ];
    });

final filteredIncomingTalentPromotionReadinessProvider =
    Provider<List<IncomingTalentPromotionReadiness>>((ref) {
      final selectedDepartment = ref.watch(talentDepartmentProvider);
      final attentionOnly = ref.watch(talentNeedsAttentionProvider);

      return ref
          .watch(incomingTalentPromotionReadinessProvider)
          .where(
            (packet) =>
                (selectedDepartment == talentAllDepartments ||
                    packet.department == selectedDepartment) &&
                (!attentionOnly || packet.needsAttention),
          )
          .toList();
    });

final incomingTalentPromotionReadinessSummaryProvider =
    Provider<IncomingTalentPromotionReadinessSummary>((ref) {
      return IncomingTalentPromotionReadinessSummary.fromReadinessPackets(
        ref.watch(filteredIncomingTalentPromotionReadinessProvider),
      );
    });

bool _isSameDay(DateTime first, DateTime second) {
  return first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}
