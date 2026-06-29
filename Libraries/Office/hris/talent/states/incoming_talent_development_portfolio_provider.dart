import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/incoming_talent_development_portfolio_models.dart';
import '../models/incoming_talent_development_roadmap_models.dart';
import 'incoming_talent_development_roadmap_provider.dart';
import 'talent_provider.dart';

final incomingTalentDevelopmentPortfolioDraftProvider = StateNotifierProvider<
  IncomingTalentDevelopmentPortfolioDraftNotifier,
  IncomingTalentDevelopmentPortfolioDraft
>((ref) {
  return IncomingTalentDevelopmentPortfolioDraftNotifier(
    ref.watch(talentAsOfDateProvider),
  );
});

class IncomingTalentDevelopmentPortfolioDraftNotifier
    extends StateNotifier<IncomingTalentDevelopmentPortfolioDraft> {
  IncomingTalentDevelopmentPortfolioDraftNotifier(DateTime asOfDate)
    : super(IncomingTalentDevelopmentPortfolioDraft.empty(asOfDate));

  void initializeFromRoadmap(IncomingTalentDevelopmentRoadmap roadmap) {
    state = IncomingTalentDevelopmentPortfolioDraft.fromRoadmap(
      roadmap: roadmap,
      asOfDate: state.asOfDate,
    );
  }

  void setPortfolioOwnerName(String value) {
    state = state.copyWith(portfolioOwnerName: value);
  }

  void setMentorName(String value) {
    state = state.copyWith(mentorName: value);
  }

  void setCompetencyFocus(String value) {
    state = state.copyWith(competencyFocus: value);
  }

  void setGrowthGoal(String value) {
    state = state.copyWith(growthGoal: value);
  }

  void setLearningPath(String value) {
    state = state.copyWith(learningPath: value);
  }

  void setEvidencePlan(String value) {
    state = state.copyWith(evidencePlan: value);
  }

  void setStage(IncomingTalentDevelopmentPortfolioStage value) {
    state = state.copyWith(stage: value);
  }

  void setPriority(IncomingTalentDevelopmentPortfolioPriority value) {
    state = state.copyWith(priority: value);
  }

  void setReviewCadence(IncomingTalentDevelopmentPortfolioCadence value) {
    state = state.copyWith(reviewCadence: value);
  }

  void setStartDate(DateTime value) {
    state = state.copyWith(startDate: value);
  }

  void setNextReviewDate(DateTime value) {
    state = state.copyWith(nextReviewDate: value);
  }

  void setTargetCompletionDate(DateTime value) {
    state = state.copyWith(targetCompletionDate: value);
  }

  void clear() {
    state = IncomingTalentDevelopmentPortfolioDraft.empty(state.asOfDate);
  }
}

final incomingTalentDevelopmentPortfoliosProvider = StateNotifierProvider<
  IncomingTalentDevelopmentPortfoliosNotifier,
  List<IncomingTalentDevelopmentPortfolio>
>((ref) {
  return IncomingTalentDevelopmentPortfoliosNotifier();
});

class IncomingTalentDevelopmentPortfoliosNotifier
    extends StateNotifier<List<IncomingTalentDevelopmentPortfolio>> {
  IncomingTalentDevelopmentPortfoliosNotifier() : super(const []);

  IncomingTalentDevelopmentPortfolio submitDraft(
    IncomingTalentDevelopmentPortfolioDraft draft,
  ) {
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }
    if (state.any((portfolio) => portfolio.roadmapId == draft.roadmapId)) {
      throw StateError('IDP portfolio already exists for this roadmap');
    }

    final portfolio = draft.toPortfolio(
      id: _nextId(),
      createdAt: draft.asOfDate,
    );
    state = [portfolio, ...state];
    return portfolio;
  }

  void updateStage({
    required String id,
    required IncomingTalentDevelopmentPortfolioStage stage,
  }) {
    state = [
      for (final portfolio in state)
        if (portfolio.id == id) _copyWithStage(portfolio, stage) else portfolio,
    ];
  }

  String _nextId() {
    final sequence = state.length + 1;
    return 'talent-idp-${sequence.toString().padLeft(3, '0')}';
  }

  IncomingTalentDevelopmentPortfolio _copyWithStage(
    IncomingTalentDevelopmentPortfolio portfolio,
    IncomingTalentDevelopmentPortfolioStage stage,
  ) {
    return IncomingTalentDevelopmentPortfolio(
      id: portfolio.id,
      roadmapId: portfolio.roadmapId,
      outcomeReviewId: portfolio.outcomeReviewId,
      candidateId: portfolio.candidateId,
      candidateName: portfolio.candidateName,
      role: portfolio.role,
      department: portfolio.department,
      portfolioOwnerName: portfolio.portfolioOwnerName,
      mentorName: portfolio.mentorName,
      competencyFocus: portfolio.competencyFocus,
      growthGoal: portfolio.growthGoal,
      learningPath: portfolio.learningPath,
      evidencePlan: portfolio.evidencePlan,
      stage: stage,
      priority: portfolio.priority,
      reviewCadence: portfolio.reviewCadence,
      startDate: portfolio.startDate,
      nextReviewDate: portfolio.nextReviewDate,
      targetCompletionDate: portfolio.targetCompletionDate,
      sourceRoadmapStatus: portfolio.sourceRoadmapStatus,
      sourceRetentionRisk: portfolio.sourceRetentionRisk,
      sourceReadinessScore: portfolio.sourceReadinessScore,
      createdAt: portfolio.createdAt,
    );
  }
}

final portfolioReadyDevelopmentRoadmapsProvider =
    Provider<List<IncomingTalentDevelopmentRoadmap>>((ref) {
      final portfolioRoadmapIds =
          ref
              .watch(incomingTalentDevelopmentPortfoliosProvider)
              .map((portfolio) => portfolio.roadmapId)
              .toSet();
      return ref
          .watch(filteredIncomingTalentDevelopmentRoadmapsProvider)
          .where((roadmap) => !portfolioRoadmapIds.contains(roadmap.id))
          .toList();
    });

final filteredIncomingTalentDevelopmentPortfoliosProvider =
    Provider<List<IncomingTalentDevelopmentPortfolio>>((ref) {
      final selectedDepartment = ref.watch(talentDepartmentProvider);
      final attentionOnly = ref.watch(talentNeedsAttentionProvider);

      return ref
          .watch(incomingTalentDevelopmentPortfoliosProvider)
          .where(
            (portfolio) =>
                (selectedDepartment == talentAllDepartments ||
                    portfolio.department == selectedDepartment) &&
                (!attentionOnly || portfolio.needsAttention),
          )
          .toList();
    });

final incomingTalentDevelopmentPortfolioSummaryProvider =
    Provider<IncomingTalentDevelopmentPortfolioSummary>((ref) {
      return IncomingTalentDevelopmentPortfolioSummary.fromPortfolios(
        portfolios: ref.watch(
          filteredIncomingTalentDevelopmentPortfoliosProvider,
        ),
        asOfDate: ref.watch(talentAsOfDateProvider),
      );
    });
