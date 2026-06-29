import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/incoming_talent_career_framework_level_models.dart';
import '../models/incoming_talent_career_path_models.dart';
import 'incoming_talent_career_path_provider.dart';
import 'talent_provider.dart';

final incomingTalentCareerFrameworkLevelDraftProvider = StateNotifierProvider<
  IncomingTalentCareerFrameworkLevelDraftNotifier,
  IncomingTalentCareerFrameworkLevelDraft
>((ref) {
  return IncomingTalentCareerFrameworkLevelDraftNotifier(
    ref.watch(talentAsOfDateProvider),
  );
});

/// Owns the editable career-framework level draft.
class IncomingTalentCareerFrameworkLevelDraftNotifier
    extends StateNotifier<IncomingTalentCareerFrameworkLevelDraft> {
  IncomingTalentCareerFrameworkLevelDraftNotifier(DateTime asOfDate)
    : super(IncomingTalentCareerFrameworkLevelDraft.empty(asOfDate));

  void initializeFromCareerPath(IncomingTalentCareerPath careerPath) {
    state = IncomingTalentCareerFrameworkLevelDraft.fromCareerPath(
      careerPath: careerPath,
      asOfDate: state.asOfDate,
    );
  }

  void setDepartment(String value) {
    state = state.copyWith(department: value);
  }

  void setFamilyName(String value) {
    state = state.copyWith(familyName: value);
  }

  void setLevelCode(String value) {
    state = state.copyWith(levelCode: value);
  }

  void setRoleTitle(String value) {
    state = state.copyWith(roleTitle: value);
  }

  void setScope(IncomingTalentCareerFrameworkLevelScope value) {
    state = state.copyWith(scope: value);
  }

  void setStatus(IncomingTalentCareerFrameworkLevelStatus value) {
    state = state.copyWith(status: value);
  }

  void setOwnerName(String value) {
    state = state.copyWith(ownerName: value);
  }

  void setCompetencyName(String value) {
    state = state.copyWith(competencyName: value);
  }

  void setSuccessCriteria(String value) {
    state = state.copyWith(successCriteria: value);
  }

  void setEvidenceRequirement(String value) {
    state = state.copyWith(evidenceRequirement: value);
  }

  void setReviewCadence(IncomingTalentCareerFrameworkReviewCadence value) {
    state = state.copyWith(reviewCadence: value);
  }

  void clear() {
    state = IncomingTalentCareerFrameworkLevelDraft.empty(state.asOfDate);
  }
}

final incomingTalentCareerFrameworkLevelsProvider = StateNotifierProvider<
  IncomingTalentCareerFrameworkLevelsNotifier,
  List<IncomingTalentCareerFrameworkLevel>
>((ref) {
  return IncomingTalentCareerFrameworkLevelsNotifier();
});

/// Stores career framework levels and prevents duplicate ladder entries.
class IncomingTalentCareerFrameworkLevelsNotifier
    extends StateNotifier<List<IncomingTalentCareerFrameworkLevel>> {
  IncomingTalentCareerFrameworkLevelsNotifier() : super(const []);

  IncomingTalentCareerFrameworkLevel submitDraft(
    IncomingTalentCareerFrameworkLevelDraft draft,
  ) {
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }
    if (state.any((level) => _matchesDuplicate(level, draft))) {
      throw StateError('Career framework level already exists for this role');
    }

    final level = draft.toLevel(id: _nextId(), createdAt: draft.asOfDate);
    state = [level, ...state];
    return level;
  }

  void updateStatus({
    required String id,
    required IncomingTalentCareerFrameworkLevelStatus status,
  }) {
    state = [
      for (final level in state)
        if (level.id == id) _copyWithStatus(level, status) else level,
    ];
  }

  String _nextId() {
    final sequence = state.length + 1;
    return 'talent-career-framework-level-${sequence.toString().padLeft(3, '0')}';
  }

  bool _matchesDuplicate(
    IncomingTalentCareerFrameworkLevel level,
    IncomingTalentCareerFrameworkLevelDraft draft,
  ) {
    if (level.isArchived) return false;
    if (draft.sourceCareerPathId.isNotEmpty &&
        level.sourceCareerPathId == draft.sourceCareerPathId) {
      return true;
    }

    final draftKey = [
      draft.department,
      draft.familyName,
      draft.levelCode,
      draft.roleTitle,
    ].map(_normalize).join('|');
    return level.duplicateKey == draftKey;
  }

  IncomingTalentCareerFrameworkLevel _copyWithStatus(
    IncomingTalentCareerFrameworkLevel level,
    IncomingTalentCareerFrameworkLevelStatus status,
  ) {
    return IncomingTalentCareerFrameworkLevel(
      id: level.id,
      sourceCareerPathId: level.sourceCareerPathId,
      department: level.department,
      familyName: level.familyName,
      levelCode: level.levelCode,
      roleTitle: level.roleTitle,
      scope: level.scope,
      status: status,
      ownerName: level.ownerName,
      competencyName: level.competencyName,
      successCriteria: level.successCriteria,
      evidenceRequirement: level.evidenceRequirement,
      reviewCadence: level.reviewCadence,
      createdAt: level.createdAt,
    );
  }
}

final careerFrameworkReadyCareerPathsProvider =
    Provider<List<IncomingTalentCareerPath>>((ref) {
      final levels = ref.watch(incomingTalentCareerFrameworkLevelsProvider);

      return ref
          .watch(filteredIncomingTalentCareerPathsProvider)
          .where(
            (careerPath) =>
                !levels.any(
                  (level) =>
                      !level.isArchived &&
                      (level.matchesCareerPath(careerPath) ||
                          level.sourceCareerPathId == careerPath.id),
                ),
          )
          .toList();
    });

final filteredIncomingTalentCareerFrameworkLevelsProvider =
    Provider<List<IncomingTalentCareerFrameworkLevel>>((ref) {
      final selectedDepartment = ref.watch(talentDepartmentProvider);
      final attentionOnly = ref.watch(talentNeedsAttentionProvider);

      return ref
          .watch(incomingTalentCareerFrameworkLevelsProvider)
          .where(
            (level) =>
                (selectedDepartment == talentAllDepartments ||
                    level.department == selectedDepartment) &&
                (!attentionOnly || level.needsAttention),
          )
          .toList();
    });

final incomingTalentCareerFrameworkLevelSummaryProvider =
    Provider<IncomingTalentCareerFrameworkLevelSummary>((ref) {
      return IncomingTalentCareerFrameworkLevelSummary.fromLevels(
        levels: ref.watch(filteredIncomingTalentCareerFrameworkLevelsProvider),
        careerPaths: ref.watch(filteredIncomingTalentCareerPathsProvider),
      );
    });

String _normalize(String value) {
  return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}
