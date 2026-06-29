import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/incoming_talent_activation_checkpoint_models.dart';
import '../models/incoming_talent_activation_follow_up_models.dart';
import 'talent_provider.dart';

final incomingTalentActivationFollowUpDraftProvider = StateNotifierProvider<
  IncomingTalentActivationFollowUpDraftNotifier,
  IncomingTalentActivationFollowUpDraft
>((ref) {
  return IncomingTalentActivationFollowUpDraftNotifier(
    ref.watch(talentAsOfDateProvider),
  );
});

class IncomingTalentActivationFollowUpDraftNotifier
    extends StateNotifier<IncomingTalentActivationFollowUpDraft> {
  IncomingTalentActivationFollowUpDraftNotifier(DateTime asOfDate)
    : super(IncomingTalentActivationFollowUpDraft.empty(asOfDate));

  void initializeFromCheckpoint(IncomingTalentActivationCheckpoint checkpoint) {
    state = IncomingTalentActivationFollowUpDraft.fromCheckpoint(
      checkpoint: checkpoint,
      asOfDate: state.asOfDate,
    );
  }

  void setOwnerName(String value) {
    state = state.copyWith(ownerName: value);
  }

  void setActionType(IncomingTalentActivationFollowUpType value) {
    state = state.copyWith(actionType: value);
  }

  void setDueDate(DateTime value) {
    state = state.copyWith(dueDate: value);
  }

  void setAction(String value) {
    state = state.copyWith(action: value);
  }

  void setSuccessCriteria(String value) {
    state = state.copyWith(successCriteria: value);
  }

  void clear() {
    state = IncomingTalentActivationFollowUpDraft.empty(state.asOfDate);
  }
}

final incomingTalentActivationFollowUpActionsProvider = StateNotifierProvider<
  IncomingTalentActivationFollowUpActionsNotifier,
  List<IncomingTalentActivationFollowUpAction>
>((ref) {
  return IncomingTalentActivationFollowUpActionsNotifier();
});

class IncomingTalentActivationFollowUpActionsNotifier
    extends StateNotifier<List<IncomingTalentActivationFollowUpAction>> {
  IncomingTalentActivationFollowUpActionsNotifier() : super(const []);

  IncomingTalentActivationFollowUpAction submitDraft(
    IncomingTalentActivationFollowUpDraft draft,
  ) {
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }
    if (state.any((action) => action.checkpointId == draft.checkpointId)) {
      throw StateError('Follow-up action already exists for this checkpoint');
    }

    final action = draft.toAction(id: _nextId(), createdAt: draft.asOfDate);
    state = [action, ...state];
    return action;
  }

  void start(String id) {
    _setStatus(id, IncomingTalentActivationFollowUpStatus.inProgress);
  }

  void complete(String id) {
    _setStatus(id, IncomingTalentActivationFollowUpStatus.completed);
  }

  void block(String id) {
    _setStatus(id, IncomingTalentActivationFollowUpStatus.blocked);
  }

  void _setStatus(String id, IncomingTalentActivationFollowUpStatus status) {
    state =
        state.map((action) {
          if (action.id != id) return action;
          return action.copyWith(status: status);
        }).toList();
  }

  String _nextId() {
    final sequence = state.length + 1;
    return 'talent-follow-up-${sequence.toString().padLeft(3, '0')}';
  }
}

final filteredIncomingTalentActivationFollowUpActionsProvider =
    Provider<List<IncomingTalentActivationFollowUpAction>>((ref) {
      final selectedDepartment = ref.watch(talentDepartmentProvider);
      final attentionOnly = ref.watch(talentNeedsAttentionProvider);

      return ref
          .watch(incomingTalentActivationFollowUpActionsProvider)
          .where(
            (action) =>
                (selectedDepartment == talentAllDepartments ||
                    action.department == selectedDepartment) &&
                (!attentionOnly || action.needsAttention),
          )
          .toList();
    });

final incomingTalentActivationFollowUpSummaryProvider =
    Provider<IncomingTalentActivationFollowUpSummary>((ref) {
      return IncomingTalentActivationFollowUpSummary.fromActions(
        actions: ref.watch(
          filteredIncomingTalentActivationFollowUpActionsProvider,
        ),
        asOfDate: ref.watch(talentAsOfDateProvider),
      );
    });
