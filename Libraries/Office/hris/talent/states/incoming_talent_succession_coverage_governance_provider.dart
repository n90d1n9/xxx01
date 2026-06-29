import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/incoming_talent_succession_models.dart';
import 'incoming_talent_succession_coverage_action_outcome_provider.dart';
import 'incoming_talent_succession_coverage_action_provider.dart';
import 'incoming_talent_succession_coverage_review_provider.dart';
import 'talent_provider.dart';

final incomingTalentSuccessionCoverageGovernanceRecordsProvider = Provider<
  List<IncomingTalentSuccessionCoverageGovernanceRecord>
>((ref) {
  final actions = ref.watch(incomingTalentSuccessionCoverageActionsProvider);
  final outcomes = ref.watch(
    incomingTalentSuccessionCoverageActionOutcomesProvider,
  );

  final records =
      ref.watch(incomingTalentSuccessionCoverageReviewsProvider).map((review) {
          final action = _latestActionForReview(actions, review.id);
          return IncomingTalentSuccessionCoverageGovernanceRecord.fromChain(
            review: review,
            action: action,
            outcome:
                action == null ? null : _outcomeForAction(outcomes, action.id),
          );
        }).toList()
        ..sort(_compareRecords);

  return records;
});

final filteredIncomingTalentSuccessionCoverageGovernanceRecordsProvider =
    Provider<List<IncomingTalentSuccessionCoverageGovernanceRecord>>((ref) {
      final selectedDepartment = ref.watch(talentDepartmentProvider);
      final attentionOnly = ref.watch(talentNeedsAttentionProvider);

      return ref
          .watch(incomingTalentSuccessionCoverageGovernanceRecordsProvider)
          .where(
            (record) =>
                (selectedDepartment == talentAllDepartments ||
                    record.departmentScope == selectedDepartment) &&
                (!attentionOnly || record.needsAttention),
          )
          .toList();
    });

final incomingTalentSuccessionCoverageGovernanceSummaryProvider =
    Provider<IncomingTalentSuccessionCoverageGovernanceSummary>((ref) {
      return IncomingTalentSuccessionCoverageGovernanceSummary.fromRecords(
        records: ref.watch(
          filteredIncomingTalentSuccessionCoverageGovernanceRecordsProvider,
        ),
        asOfDate: ref.watch(talentAsOfDateProvider),
      );
    });

IncomingTalentSuccessionCoverageAction? _latestActionForReview(
  List<IncomingTalentSuccessionCoverageAction> actions,
  String reviewId,
) {
  final matches =
      actions.where((action) => action.coverageReviewId == reviewId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return matches.isEmpty ? null : matches.first;
}

IncomingTalentSuccessionCoverageActionOutcome? _outcomeForAction(
  List<IncomingTalentSuccessionCoverageActionOutcome> outcomes,
  String actionId,
) {
  final matches =
      outcomes.where((outcome) => outcome.actionId == actionId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return matches.isEmpty ? null : matches.first;
}

int _compareRecords(
  IncomingTalentSuccessionCoverageGovernanceRecord left,
  IncomingTalentSuccessionCoverageGovernanceRecord right,
) {
  final risk = right.riskLevel.index.compareTo(left.riskLevel.index);
  if (risk != 0) return risk;

  final dueDate = left.dueDate.compareTo(right.dueDate);
  if (dueDate != 0) return dueDate;

  return right.openedAt.compareTo(left.openedAt);
}
