import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/incoming_talent_activation_checkpoint_models.dart';
import '../models/incoming_talent_activation_models.dart';
import 'talent_provider.dart';

final incomingTalentActivationCheckpointDraftProvider = StateNotifierProvider<
  IncomingTalentActivationCheckpointDraftNotifier,
  IncomingTalentActivationCheckpointDraft
>((ref) {
  return IncomingTalentActivationCheckpointDraftNotifier(
    ref.watch(talentAsOfDateProvider),
  );
});

class IncomingTalentActivationCheckpointDraftNotifier
    extends StateNotifier<IncomingTalentActivationCheckpointDraft> {
  IncomingTalentActivationCheckpointDraftNotifier(DateTime asOfDate)
    : super(IncomingTalentActivationCheckpointDraft.empty(asOfDate));

  void initializeFromPlan(IncomingTalentActivationPlan plan) {
    state = IncomingTalentActivationCheckpointDraft.fromPlan(
      plan: plan,
      asOfDate: state.asOfDate,
    );
  }

  void setReviewerName(String value) {
    state = state.copyWith(reviewerName: value);
  }

  void setReviewDate(DateTime value) {
    state = state.copyWith(reviewDate: value);
  }

  void setHealth(IncomingTalentActivationCheckpointHealth value) {
    state = state.copyWith(health: value);
  }

  void setConfidenceScore(int value) {
    state = state.copyWith(confidenceScore: value);
  }

  void setManagerFeedback(String value) {
    state = state.copyWith(managerFeedback: value);
  }

  void setBlockerNote(String value) {
    state = state.copyWith(blockerNote: value);
  }

  void setNextStep(String value) {
    state = state.copyWith(nextStep: value);
  }

  void clear() {
    state = IncomingTalentActivationCheckpointDraft.empty(state.asOfDate);
  }
}

final incomingTalentActivationCheckpointsProvider = StateNotifierProvider<
  IncomingTalentActivationCheckpointsNotifier,
  List<IncomingTalentActivationCheckpoint>
>((ref) {
  return IncomingTalentActivationCheckpointsNotifier();
});

class IncomingTalentActivationCheckpointsNotifier
    extends StateNotifier<List<IncomingTalentActivationCheckpoint>> {
  IncomingTalentActivationCheckpointsNotifier() : super(const []);

  IncomingTalentActivationCheckpoint submitDraft(
    IncomingTalentActivationCheckpointDraft draft,
  ) {
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }

    final checkpoint = draft.toCheckpoint(
      id: _nextId(),
      createdAt: draft.asOfDate,
    );
    state = [checkpoint, ...state];
    return checkpoint;
  }

  String _nextId() {
    final sequence = state.length + 1;
    return 'talent-checkpoint-${sequence.toString().padLeft(3, '0')}';
  }
}

final filteredIncomingTalentActivationCheckpointsProvider =
    Provider<List<IncomingTalentActivationCheckpoint>>((ref) {
      final selectedDepartment = ref.watch(talentDepartmentProvider);
      final attentionOnly = ref.watch(talentNeedsAttentionProvider);

      return ref
          .watch(incomingTalentActivationCheckpointsProvider)
          .where(
            (checkpoint) =>
                (selectedDepartment == talentAllDepartments ||
                    checkpoint.department == selectedDepartment) &&
                (!attentionOnly || checkpoint.needsAttention),
          )
          .toList();
    });

final incomingTalentActivationCheckpointSummaryProvider =
    Provider<IncomingTalentActivationCheckpointSummary>((ref) {
      return IncomingTalentActivationCheckpointSummary.fromCheckpoints(
        ref.watch(filteredIncomingTalentActivationCheckpointsProvider),
      );
    });
