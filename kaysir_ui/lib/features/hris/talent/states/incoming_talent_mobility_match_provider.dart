import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/incoming_talent_succession_models.dart';
import 'incoming_talent_succession_activation_provider.dart';
import 'incoming_talent_succession_panel_decision_provider.dart';
import 'talent_provider.dart';

final incomingTalentMobilityMatchDraftProvider = StateNotifierProvider<
  IncomingTalentMobilityMatchDraftNotifier,
  IncomingTalentMobilityMatchDraft
>((ref) {
  return IncomingTalentMobilityMatchDraftNotifier(
    ref.watch(talentAsOfDateProvider),
  );
});

class IncomingTalentMobilityMatchDraftNotifier
    extends StateNotifier<IncomingTalentMobilityMatchDraft> {
  IncomingTalentMobilityMatchDraftNotifier(DateTime asOfDate)
    : super(IncomingTalentMobilityMatchDraft.empty(asOfDate));

  void initializeFromDecision(IncomingTalentSuccessionPanelDecision decision) {
    state = IncomingTalentMobilityMatchDraft.fromDecision(
      decision: decision,
      asOfDate: state.asOfDate,
    );
  }

  void setOpportunityTitle(String value) {
    state = state.copyWith(opportunityTitle: value);
  }

  void setHostDepartment(String value) {
    state = state.copyWith(hostDepartment: value);
  }

  void setSponsorName(String value) {
    state = state.copyWith(sponsorName: value);
  }

  void setMobilityOwnerName(String value) {
    state = state.copyWith(mobilityOwnerName: value);
  }

  void setMoveType(IncomingTalentMobilityMoveType value) {
    state = state.copyWith(moveType: value);
  }

  void setStatus(IncomingTalentMobilityMatchStatus value) {
    state = state.copyWith(status: value);
  }

  void setFitScore(int value) {
    state = state.copyWith(fitScore: value);
  }

  void setStartDate(DateTime value) {
    state = state.copyWith(
      startDate: value,
      reviewDate: value.add(const Duration(days: 45)),
    );
  }

  void setReviewDate(DateTime value) {
    state = state.copyWith(reviewDate: value);
  }

  void setBusinessRationale(String value) {
    state = state.copyWith(businessRationale: value);
  }

  void setSuccessMeasure(String value) {
    state = state.copyWith(successMeasure: value);
  }

  void setSupportPlan(String value) {
    state = state.copyWith(supportPlan: value);
  }

  void clear() {
    state = IncomingTalentMobilityMatchDraft.empty(state.asOfDate);
  }
}

final incomingTalentMobilityMatchesProvider = StateNotifierProvider<
  IncomingTalentMobilityMatchesNotifier,
  List<IncomingTalentMobilityMatch>
>((ref) {
  return IncomingTalentMobilityMatchesNotifier();
});

class IncomingTalentMobilityMatchesNotifier
    extends StateNotifier<List<IncomingTalentMobilityMatch>> {
  IncomingTalentMobilityMatchesNotifier() : super(const []);

  IncomingTalentMobilityMatch submitDraft(
    IncomingTalentMobilityMatchDraft draft,
  ) {
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }
    if (state.any((match) => match.decisionId == draft.decisionId)) {
      throw StateError('Mobility match already exists for panel decision');
    }

    final match = draft.toMatch(id: _nextId(), createdAt: draft.asOfDate);
    state = [match, ...state];
    return match;
  }

  void sponsorReview(String id) {
    _setStatus(id, IncomingTalentMobilityMatchStatus.sponsorReview);
  }

  void accept(String id) {
    _setStatus(id, IncomingTalentMobilityMatchStatus.accepted);
  }

  void block(String id) {
    _setStatus(id, IncomingTalentMobilityMatchStatus.blocked);
  }

  void activate(String id) {
    _setStatus(id, IncomingTalentMobilityMatchStatus.activated);
  }

  void _setStatus(String id, IncomingTalentMobilityMatchStatus status) {
    state =
        state.map((match) {
          if (match.id != id) return match;
          return match.copyWith(status: status);
        }).toList();
  }

  String _nextId() {
    final sequence = state.length + 1;
    return 'talent-mobility-match-${sequence.toString().padLeft(3, '0')}';
  }
}

final mobilityReadySuccessionPanelDecisionsProvider =
    Provider<List<IncomingTalentSuccessionPanelDecision>>((ref) {
      final matchedDecisionIds =
          ref
              .watch(incomingTalentMobilityMatchesProvider)
              .map((match) => match.decisionId)
              .toSet();
      final activatedDecisionIds =
          ref
              .watch(incomingTalentSuccessionActivationPlansProvider)
              .map((plan) => plan.decisionId)
              .toSet();

      return ref
          .watch(filteredIncomingTalentSuccessionPanelDecisionsProvider)
          .where(
            (decision) =>
                decision.isApproved &&
                !matchedDecisionIds.contains(decision.id) &&
                !activatedDecisionIds.contains(decision.id),
          )
          .toList();
    });

final filteredIncomingTalentMobilityMatchesProvider =
    Provider<List<IncomingTalentMobilityMatch>>((ref) {
      final selectedDepartment = ref.watch(talentDepartmentProvider);
      final attentionOnly = ref.watch(talentNeedsAttentionProvider);

      return ref
          .watch(incomingTalentMobilityMatchesProvider)
          .where(
            (match) =>
                (selectedDepartment == talentAllDepartments ||
                    match.department == selectedDepartment ||
                    match.hostDepartment == selectedDepartment) &&
                (!attentionOnly || match.needsAttention),
          )
          .toList();
    });

final incomingTalentMobilityMatchSummaryProvider =
    Provider<IncomingTalentMobilityMatchSummary>((ref) {
      return IncomingTalentMobilityMatchSummary.fromMatches(
        matches: ref.watch(filteredIncomingTalentMobilityMatchesProvider),
        asOfDate: ref.watch(talentAsOfDateProvider),
      );
    });
