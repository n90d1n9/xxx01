import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/incoming_talent_succession_models.dart';
import 'incoming_talent_succession_activation_resolution_review_provider.dart';
import 'talent_provider.dart';

final incomingTalentSuccessionActivationClosureDraftProvider =
    StateNotifierProvider<
      IncomingTalentSuccessionActivationClosureDraftNotifier,
      IncomingTalentSuccessionActivationClosureDraft
    >((ref) {
      return IncomingTalentSuccessionActivationClosureDraftNotifier(
        ref.watch(talentAsOfDateProvider),
      );
    });

class IncomingTalentSuccessionActivationClosureDraftNotifier
    extends StateNotifier<IncomingTalentSuccessionActivationClosureDraft> {
  IncomingTalentSuccessionActivationClosureDraftNotifier(DateTime asOfDate)
    : super(IncomingTalentSuccessionActivationClosureDraft.empty(asOfDate));

  void initializeFromReview(
    IncomingTalentSuccessionActivationResolutionReview review,
  ) {
    state = IncomingTalentSuccessionActivationClosureDraft.fromReview(
      review: review,
      asOfDate: state.asOfDate,
    );
  }

  void setOwnerName(String value) {
    state = state.copyWith(ownerName: value);
  }

  void setClosureType(IncomingTalentSuccessionActivationClosureType value) {
    state = state.copyWith(closureType: value);
  }

  void setStatus(IncomingTalentSuccessionActivationClosureStatus value) {
    state = state.copyWith(status: value);
  }

  void setEffectiveDate(DateTime value) {
    state = state.copyWith(effectiveDate: value);
  }

  void setHandoverOwner(String value) {
    state = state.copyWith(handoverOwner: value);
  }

  void setHrPartnerName(String value) {
    state = state.copyWith(hrPartnerName: value);
  }

  void setCommunicationPlan(String value) {
    state = state.copyWith(communicationPlan: value);
  }

  void setAccessReadiness(String value) {
    state = state.copyWith(accessReadiness: value);
  }

  void setCompensationNote(String value) {
    state = state.copyWith(compensationNote: value);
  }

  void setGovernanceNote(String value) {
    state = state.copyWith(governanceNote: value);
  }

  void clear() {
    state = IncomingTalentSuccessionActivationClosureDraft.empty(
      state.asOfDate,
    );
  }
}

final incomingTalentSuccessionActivationClosuresProvider =
    StateNotifierProvider<
      IncomingTalentSuccessionActivationClosuresNotifier,
      List<IncomingTalentSuccessionActivationClosure>
    >((ref) {
      return IncomingTalentSuccessionActivationClosuresNotifier();
    });

class IncomingTalentSuccessionActivationClosuresNotifier
    extends StateNotifier<List<IncomingTalentSuccessionActivationClosure>> {
  IncomingTalentSuccessionActivationClosuresNotifier() : super(const []);

  IncomingTalentSuccessionActivationClosure submitDraft(
    IncomingTalentSuccessionActivationClosureDraft draft,
  ) {
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }
    if (state.any(
      (closure) => closure.resolutionReviewId == draft.resolutionReviewId,
    )) {
      throw StateError('Closure already exists for this resolution review');
    }

    final closure = draft.toClosure(id: _nextId(), createdAt: draft.asOfDate);
    state = [closure, ...state];
    return closure;
  }

  void activate(String id) {
    _setStatus(id, IncomingTalentSuccessionActivationClosureStatus.active);
  }

  void complete(String id) {
    _setStatus(id, IncomingTalentSuccessionActivationClosureStatus.completed);
  }

  void defer(String id) {
    _setStatus(id, IncomingTalentSuccessionActivationClosureStatus.deferred);
  }

  void _setStatus(
    String id,
    IncomingTalentSuccessionActivationClosureStatus status,
  ) {
    state =
        state.map((closure) {
          if (closure.id != id) return closure;
          return closure.copyWith(status: status);
        }).toList();
  }

  String _nextId() {
    final sequence = state.length + 1;
    return 'talent-succession-activation-closure-${sequence.toString().padLeft(3, '0')}';
  }
}

final closureReadySuccessionActivationResolutionReviewsProvider =
    Provider<List<IncomingTalentSuccessionActivationResolutionReview>>((ref) {
      final closedReviewIds =
          ref
              .watch(incomingTalentSuccessionActivationClosuresProvider)
              .map((closure) => closure.resolutionReviewId)
              .toSet();

      return ref
          .watch(
            filteredIncomingTalentSuccessionActivationResolutionReviewsProvider,
          )
          .where(
            (review) =>
                review.outcome ==
                    IncomingTalentSuccessionActivationResolutionOutcome
                        .transitionCleared &&
                review.residualRisk ==
                    IncomingTalentSuccessionActivationResidualRisk.low &&
                !review.needsAttention &&
                !closedReviewIds.contains(review.id),
          )
          .toList();
    });

final filteredIncomingTalentSuccessionActivationClosuresProvider =
    Provider<List<IncomingTalentSuccessionActivationClosure>>((ref) {
      final selectedDepartment = ref.watch(talentDepartmentProvider);
      final attentionOnly = ref.watch(talentNeedsAttentionProvider);

      return ref
          .watch(incomingTalentSuccessionActivationClosuresProvider)
          .where(
            (closure) =>
                (selectedDepartment == talentAllDepartments ||
                    closure.department == selectedDepartment) &&
                (!attentionOnly || closure.needsAttention),
          )
          .toList();
    });

final incomingTalentSuccessionActivationClosureSummaryProvider =
    Provider<IncomingTalentSuccessionActivationClosureSummary>((ref) {
      return IncomingTalentSuccessionActivationClosureSummary.fromClosures(
        closures: ref.watch(
          filteredIncomingTalentSuccessionActivationClosuresProvider,
        ),
        asOfDate: ref.watch(talentAsOfDateProvider),
      );
    });
