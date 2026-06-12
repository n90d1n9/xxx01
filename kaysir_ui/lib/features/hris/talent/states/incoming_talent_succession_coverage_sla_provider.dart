import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/incoming_talent_succession_models.dart';
import 'incoming_talent_succession_coverage_action_outcome_provider.dart';
import 'incoming_talent_succession_coverage_action_provider.dart';
import 'incoming_talent_succession_coverage_council_decision_provider.dart';
import 'incoming_talent_succession_coverage_council_follow_up_provider.dart';
import 'talent_provider.dart';

final incomingTalentSuccessionCoverageSlaItemsProvider = Provider<
  List<IncomingTalentSuccessionCoverageSlaItem>
>((ref) {
  final asOfDate = ref.watch(talentAsOfDateProvider);
  final selectedDepartment = ref.watch(talentDepartmentProvider);
  final attentionOnly = ref.watch(talentNeedsAttentionProvider);

  final items =
      [
            for (final review in ref.watch(
              actionReadySuccessionCoverageReviewsProvider,
            ))
              IncomingTalentSuccessionCoverageSlaItem.fromReviewActionGap(
                review: review,
                asOfDate: asOfDate,
              ),
            for (final action in ref
                .watch(filteredIncomingTalentSuccessionCoverageActionsProvider)
                .where((action) => action.isOpen))
              IncomingTalentSuccessionCoverageSlaItem.fromCoverageAction(
                action: action,
                asOfDate: asOfDate,
              ),
            for (final action in ref.watch(
              outcomeReadySuccessionCoverageActionsProvider,
            ))
              IncomingTalentSuccessionCoverageSlaItem.fromOutcomeAction(
                action: action,
                asOfDate: asOfDate,
              ),
            for (final item in ref.watch(
              decisionReadyCoverageCouncilAgendaItemsProvider,
            ))
              IncomingTalentSuccessionCoverageSlaItem.fromCouncilAgendaItem(
                item: item,
                asOfDate: asOfDate,
              ),
            for (final decision in ref.watch(
              followUpReadyCoverageCouncilDecisionsProvider,
            ))
              IncomingTalentSuccessionCoverageSlaItem.fromCouncilDecision(
                decision: decision,
                asOfDate: asOfDate,
              ),
            for (final followUp in ref
                .watch(
                  filteredIncomingTalentSuccessionCoverageCouncilFollowUpsProvider,
                )
                .where((followUp) => followUp.isOpen))
              IncomingTalentSuccessionCoverageSlaItem.fromCouncilFollowUp(
                followUp: followUp,
                asOfDate: asOfDate,
              ),
          ]
          .where(
            (item) =>
                (selectedDepartment == talentAllDepartments ||
                    item.departmentScope == selectedDepartment) &&
                (!attentionOnly || item.needsAttention),
          )
          .toList()
        ..sort(_compareSlaItems);

  return items;
});

final incomingTalentSuccessionCoverageSlaSummaryProvider =
    Provider<IncomingTalentSuccessionCoverageSlaSummary>((ref) {
      return IncomingTalentSuccessionCoverageSlaSummary.fromItems(
        ref.watch(incomingTalentSuccessionCoverageSlaItemsProvider),
      );
    });

int _compareSlaItems(
  IncomingTalentSuccessionCoverageSlaItem left,
  IncomingTalentSuccessionCoverageSlaItem right,
) {
  final urgency = left.urgencyRank.compareTo(right.urgencyRank);
  if (urgency != 0) return urgency;

  final dueDate = left.dueDate.compareTo(right.dueDate);
  if (dueDate != 0) return dueDate;

  return left.scopeLabel.compareTo(right.scopeLabel);
}
