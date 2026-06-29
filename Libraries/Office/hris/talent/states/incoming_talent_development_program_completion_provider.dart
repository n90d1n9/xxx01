import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/incoming_talent_development_program_models.dart';
import 'incoming_talent_development_program_milestone_provider.dart';
import 'talent_provider.dart';

final incomingTalentDevelopmentProgramCompletionDraftProvider =
    StateNotifierProvider<
      IncomingTalentDevelopmentProgramCompletionDraftNotifier,
      IncomingTalentDevelopmentProgramCompletionDraft
    >((ref) {
      return IncomingTalentDevelopmentProgramCompletionDraftNotifier(
        ref.watch(talentAsOfDateProvider),
      );
    });

class IncomingTalentDevelopmentProgramCompletionDraftNotifier
    extends StateNotifier<IncomingTalentDevelopmentProgramCompletionDraft> {
  IncomingTalentDevelopmentProgramCompletionDraftNotifier(DateTime asOfDate)
    : super(IncomingTalentDevelopmentProgramCompletionDraft.empty(asOfDate));

  void initializeFromMilestone(
    IncomingTalentDevelopmentProgramMilestone milestone,
  ) {
    state = IncomingTalentDevelopmentProgramCompletionDraft.fromMilestone(
      milestone: milestone,
      asOfDate: state.asOfDate,
    );
  }

  void setReviewerName(String value) {
    state = state.copyWith(reviewerName: value);
  }

  void setDecision(IncomingTalentDevelopmentProgramCompletionDecision value) {
    state = state.copyWith(decision: value);
  }

  void setCredentialLevel(
    IncomingTalentDevelopmentProgramCredentialLevel value,
  ) {
    state = state.copyWith(credentialLevel: value);
  }

  void setScore(int value) {
    state = state.copyWith(score: value);
  }

  void setCompletedAt(DateTime value) {
    state = state.copyWith(completedAt: value);
  }

  void setRenewalDate(DateTime value) {
    state = state.copyWith(renewalDate: value);
  }

  void setCredentialNote(String value) {
    state = state.copyWith(credentialNote: value);
  }

  void setManagerRecommendation(String value) {
    state = state.copyWith(managerRecommendation: value);
  }

  void clear() {
    state = IncomingTalentDevelopmentProgramCompletionDraft.empty(
      state.asOfDate,
    );
  }
}

final incomingTalentDevelopmentProgramCompletionsProvider =
    StateNotifierProvider<
      IncomingTalentDevelopmentProgramCompletionsNotifier,
      List<IncomingTalentDevelopmentProgramCompletion>
    >((ref) {
      return IncomingTalentDevelopmentProgramCompletionsNotifier();
    });

class IncomingTalentDevelopmentProgramCompletionsNotifier
    extends StateNotifier<List<IncomingTalentDevelopmentProgramCompletion>> {
  IncomingTalentDevelopmentProgramCompletionsNotifier() : super(const []);

  IncomingTalentDevelopmentProgramCompletion submitDraft(
    IncomingTalentDevelopmentProgramCompletionDraft draft,
  ) {
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }
    if (state.any(
      (completion) => completion.milestoneId == draft.milestoneId,
    )) {
      throw StateError('Completion already exists for accepted milestone');
    }

    final completion = draft.toCompletion(
      id: _nextId(),
      createdAt: draft.asOfDate,
    );
    state = [completion, ...state];
    return completion;
  }

  String _nextId() {
    final sequence = state.length + 1;
    return 'talent-program-completion-${sequence.toString().padLeft(3, '0')}';
  }
}

final completionReadyProgramMilestonesProvider =
    Provider<List<IncomingTalentDevelopmentProgramMilestone>>((ref) {
      final completedMilestoneIds =
          ref
              .watch(incomingTalentDevelopmentProgramCompletionsProvider)
              .map((completion) => completion.milestoneId)
              .toSet();

      return ref
          .watch(filteredIncomingTalentDevelopmentProgramMilestonesProvider)
          .where(
            (milestone) =>
                milestone.status ==
                    IncomingTalentDevelopmentProgramMilestoneStatus.accepted &&
                !completedMilestoneIds.contains(milestone.id),
          )
          .toList();
    });

final filteredIncomingTalentDevelopmentProgramCompletionsProvider =
    Provider<List<IncomingTalentDevelopmentProgramCompletion>>((ref) {
      final selectedDepartment = ref.watch(talentDepartmentProvider);
      final attentionOnly = ref.watch(talentNeedsAttentionProvider);

      return ref
          .watch(incomingTalentDevelopmentProgramCompletionsProvider)
          .where(
            (completion) =>
                (selectedDepartment == talentAllDepartments ||
                    completion.department == selectedDepartment) &&
                (!attentionOnly || completion.needsAttention),
          )
          .toList();
    });

final incomingTalentDevelopmentProgramCompletionSummaryProvider =
    Provider<IncomingTalentDevelopmentProgramCompletionSummary>((ref) {
      return IncomingTalentDevelopmentProgramCompletionSummary.fromCompletions(
        completions: ref.watch(
          filteredIncomingTalentDevelopmentProgramCompletionsProvider,
        ),
        asOfDate: ref.watch(talentAsOfDateProvider),
      );
    });
