import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/incoming_talent_career_path_models.dart';
import '../models/incoming_talent_development_portfolio_models.dart';
import 'incoming_talent_development_portfolio_provider.dart';
import 'talent_provider.dart';

final incomingTalentCareerPathDraftProvider = StateNotifierProvider<
  IncomingTalentCareerPathDraftNotifier,
  IncomingTalentCareerPathDraft
>((ref) {
  return IncomingTalentCareerPathDraftNotifier(
    ref.watch(talentAsOfDateProvider),
  );
});

class IncomingTalentCareerPathDraftNotifier
    extends StateNotifier<IncomingTalentCareerPathDraft> {
  IncomingTalentCareerPathDraftNotifier(DateTime asOfDate)
    : super(IncomingTalentCareerPathDraft.empty(asOfDate));

  void initializeFromPortfolio(IncomingTalentDevelopmentPortfolio portfolio) {
    state = IncomingTalentCareerPathDraft.fromPortfolio(
      portfolio: portfolio,
      asOfDate: state.asOfDate,
    );
  }

  void setCurrentRole(String value) {
    state = state.copyWith(currentRole: value);
  }

  void setTargetRole(String value) {
    state = state.copyWith(targetRole: value);
  }

  void setOwnerName(String value) {
    state = state.copyWith(ownerName: value);
  }

  void setMentorName(String value) {
    state = state.copyWith(mentorName: value);
  }

  void setCompetencyName(String value) {
    state = state.copyWith(competencyName: value);
  }

  void setCurrentLevel(int value) {
    state = state.copyWith(currentLevel: value);
  }

  void setTargetLevel(int value) {
    state = state.copyWith(targetLevel: value);
  }

  void setStatus(IncomingTalentCareerPathStatus value) {
    state = state.copyWith(status: value);
  }

  void setPriority(IncomingTalentCareerPathPriority value) {
    state = state.copyWith(priority: value);
  }

  void setDevelopmentAction(String value) {
    state = state.copyWith(developmentAction: value);
  }

  void setEvidenceRequirement(String value) {
    state = state.copyWith(evidenceRequirement: value);
  }

  void setReviewDate(DateTime value) {
    state = state.copyWith(reviewDate: value);
  }

  void clear() {
    state = IncomingTalentCareerPathDraft.empty(state.asOfDate);
  }
}

final incomingTalentCareerPathsProvider = StateNotifierProvider<
  IncomingTalentCareerPathsNotifier,
  List<IncomingTalentCareerPath>
>((ref) {
  return IncomingTalentCareerPathsNotifier();
});

class IncomingTalentCareerPathsNotifier
    extends StateNotifier<List<IncomingTalentCareerPath>> {
  IncomingTalentCareerPathsNotifier() : super(const []);

  IncomingTalentCareerPath submitDraft(IncomingTalentCareerPathDraft draft) {
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }
    if (state.any(
      (careerPath) => careerPath.portfolioId == draft.portfolioId,
    )) {
      throw StateError('Career path already exists for this IDP portfolio');
    }

    final careerPath = draft.toCareerPath(
      id: _nextId(),
      createdAt: draft.asOfDate,
    );
    state = [careerPath, ...state];
    return careerPath;
  }

  void updateStatus({
    required String id,
    required IncomingTalentCareerPathStatus status,
  }) {
    state = [
      for (final careerPath in state)
        if (careerPath.id == id)
          _copyWithStatus(careerPath, status)
        else
          careerPath,
    ];
  }

  String _nextId() {
    final sequence = state.length + 1;
    return 'talent-career-path-${sequence.toString().padLeft(3, '0')}';
  }

  IncomingTalentCareerPath _copyWithStatus(
    IncomingTalentCareerPath careerPath,
    IncomingTalentCareerPathStatus status,
  ) {
    return IncomingTalentCareerPath(
      id: careerPath.id,
      portfolioId: careerPath.portfolioId,
      roadmapId: careerPath.roadmapId,
      candidateId: careerPath.candidateId,
      candidateName: careerPath.candidateName,
      department: careerPath.department,
      currentRole: careerPath.currentRole,
      targetRole: careerPath.targetRole,
      ownerName: careerPath.ownerName,
      mentorName: careerPath.mentorName,
      competencyName: careerPath.competencyName,
      currentLevel: careerPath.currentLevel,
      targetLevel: careerPath.targetLevel,
      status: status,
      priority: careerPath.priority,
      developmentAction: careerPath.developmentAction,
      evidenceRequirement: careerPath.evidenceRequirement,
      reviewDate: careerPath.reviewDate,
      sourcePortfolioPriority: careerPath.sourcePortfolioPriority,
      sourcePortfolioStage: careerPath.sourcePortfolioStage,
      createdAt: careerPath.createdAt,
    );
  }
}

final careerPathReadyDevelopmentPortfoliosProvider =
    Provider<List<IncomingTalentDevelopmentPortfolio>>((ref) {
      final careerPathPortfolioIds =
          ref
              .watch(incomingTalentCareerPathsProvider)
              .map((careerPath) => careerPath.portfolioId)
              .toSet();
      return ref
          .watch(filteredIncomingTalentDevelopmentPortfoliosProvider)
          .where((portfolio) => !careerPathPortfolioIds.contains(portfolio.id))
          .toList();
    });

final filteredIncomingTalentCareerPathsProvider =
    Provider<List<IncomingTalentCareerPath>>((ref) {
      final selectedDepartment = ref.watch(talentDepartmentProvider);
      final attentionOnly = ref.watch(talentNeedsAttentionProvider);

      return ref
          .watch(incomingTalentCareerPathsProvider)
          .where(
            (careerPath) =>
                (selectedDepartment == talentAllDepartments ||
                    careerPath.department == selectedDepartment) &&
                (!attentionOnly || careerPath.needsAttention),
          )
          .toList();
    });

final incomingTalentCareerPathSummaryProvider =
    Provider<IncomingTalentCareerPathSummary>((ref) {
      return IncomingTalentCareerPathSummary.fromCareerPaths(
        careerPaths: ref.watch(filteredIncomingTalentCareerPathsProvider),
        asOfDate: ref.watch(talentAsOfDateProvider),
      );
    });
