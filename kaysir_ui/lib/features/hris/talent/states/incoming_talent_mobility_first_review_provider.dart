import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/incoming_talent_succession_models.dart';
import 'incoming_talent_mobility_launch_checklist_provider.dart';
import 'talent_provider.dart';

final incomingTalentMobilityFirstReviewDraftProvider = StateNotifierProvider<
  IncomingTalentMobilityFirstReviewDraftNotifier,
  IncomingTalentMobilityFirstReviewDraft
>((ref) {
  return IncomingTalentMobilityFirstReviewDraftNotifier(
    ref.watch(talentAsOfDateProvider),
  );
});

class IncomingTalentMobilityFirstReviewDraftNotifier
    extends StateNotifier<IncomingTalentMobilityFirstReviewDraft> {
  IncomingTalentMobilityFirstReviewDraftNotifier(DateTime asOfDate)
    : super(IncomingTalentMobilityFirstReviewDraft.empty(asOfDate));

  void initializeFromChecklist(
    IncomingTalentMobilityLaunchChecklist checklist,
  ) {
    state = IncomingTalentMobilityFirstReviewDraft.fromChecklist(
      checklist: checklist,
      asOfDate: state.asOfDate,
    );
  }

  void setReviewerName(String value) {
    state = state.copyWith(reviewerName: value);
  }

  void setReviewDate(DateTime value) {
    state = state.copyWith(
      reviewDate: value,
      followUpDate: value.add(const Duration(days: 30)),
    );
  }

  void setOutcome(IncomingTalentMobilityFirstReviewOutcome value) {
    state = state.copyWith(outcome: value);
  }

  void setHostConfidenceScore(int value) {
    state = state.copyWith(hostConfidenceScore: value);
  }

  void setDeliverySignal(String value) {
    state = state.copyWith(deliverySignal: value);
  }

  void setBlockerNote(String value) {
    state = state.copyWith(blockerNote: value);
  }

  void setRetentionRisk(IncomingTalentMobilityFirstReviewRetentionRisk value) {
    state = state.copyWith(retentionRisk: value);
  }

  void setNextAction(String value) {
    state = state.copyWith(nextAction: value);
  }

  void setFollowUpDate(DateTime value) {
    state = state.copyWith(followUpDate: value);
  }

  void clear() {
    state = IncomingTalentMobilityFirstReviewDraft.empty(state.asOfDate);
  }
}

final incomingTalentMobilityFirstReviewsProvider = StateNotifierProvider<
  IncomingTalentMobilityFirstReviewsNotifier,
  List<IncomingTalentMobilityFirstReview>
>((ref) {
  return IncomingTalentMobilityFirstReviewsNotifier();
});

class IncomingTalentMobilityFirstReviewsNotifier
    extends StateNotifier<List<IncomingTalentMobilityFirstReview>> {
  IncomingTalentMobilityFirstReviewsNotifier() : super(const []);

  IncomingTalentMobilityFirstReview submitDraft(
    IncomingTalentMobilityFirstReviewDraft draft,
  ) {
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }
    if (state.any((review) => review.checklistId == draft.checklistId)) {
      throw StateError('First review already exists for mobility launch');
    }

    final review = draft.toReview(id: _nextId(), createdAt: draft.asOfDate);
    state = [review, ...state];
    return review;
  }

  String _nextId() {
    final sequence = state.length + 1;
    return 'talent-mobility-first-review-${sequence.toString().padLeft(3, '0')}';
  }
}

final firstReviewReadyMobilityLaunchChecklistsProvider =
    Provider<List<IncomingTalentMobilityLaunchChecklist>>((ref) {
      final reviewedChecklistIds =
          ref
              .watch(incomingTalentMobilityFirstReviewsProvider)
              .map((review) => review.checklistId)
              .toSet();

      return ref
          .watch(filteredIncomingTalentMobilityLaunchChecklistsProvider)
          .where(
            (checklist) =>
                checklist.status ==
                    IncomingTalentMobilityLaunchStatus.launched &&
                !reviewedChecklistIds.contains(checklist.id),
          )
          .toList();
    });

final filteredIncomingTalentMobilityFirstReviewsProvider =
    Provider<List<IncomingTalentMobilityFirstReview>>((ref) {
      final selectedDepartment = ref.watch(talentDepartmentProvider);
      final attentionOnly = ref.watch(talentNeedsAttentionProvider);

      return ref
          .watch(incomingTalentMobilityFirstReviewsProvider)
          .where(
            (review) =>
                (selectedDepartment == talentAllDepartments ||
                    review.department == selectedDepartment ||
                    review.hostDepartment == selectedDepartment) &&
                (!attentionOnly || review.needsAttention),
          )
          .toList();
    });

final incomingTalentMobilityFirstReviewSummaryProvider =
    Provider<IncomingTalentMobilityFirstReviewSummary>((ref) {
      return IncomingTalentMobilityFirstReviewSummary.fromReviews(
        ref.watch(filteredIncomingTalentMobilityFirstReviewsProvider),
      );
    });
