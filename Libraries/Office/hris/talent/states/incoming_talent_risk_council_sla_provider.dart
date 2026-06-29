import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/incoming_talent_risk_council_sla_models.dart';
import 'incoming_talent_risk_council_decision_provider.dart';
import 'incoming_talent_risk_council_follow_up_provider.dart';
import 'talent_provider.dart';

final incomingTalentRiskCouncilSlaItemsProvider =
    Provider<List<IncomingTalentRiskCouncilSlaItem>>((ref) {
      final asOfDate = ref.watch(talentAsOfDateProvider);
      final selectedDepartment = ref.watch(talentDepartmentProvider);
      final attentionOnly = ref.watch(talentNeedsAttentionProvider);

      final items =
          [
                for (final item in ref.watch(
                  decisionReadyTalentRiskCouncilQueueItemsProvider,
                ))
                  IncomingTalentRiskCouncilSlaItem.fromQueueItem(
                    item: item,
                    asOfDate: asOfDate,
                  ),
                for (final decision in ref.watch(
                  followUpReadyTalentRiskCouncilDecisionsProvider,
                ))
                  IncomingTalentRiskCouncilSlaItem.fromDecision(
                    decision: decision,
                    asOfDate: asOfDate,
                  ),
                for (final followUp in ref
                    .watch(filteredIncomingTalentRiskCouncilFollowUpsProvider)
                    .where((followUp) => followUp.isOpen))
                  IncomingTalentRiskCouncilSlaItem.fromFollowUp(
                    followUp: followUp,
                    asOfDate: asOfDate,
                  ),
              ]
              .where(
                (item) =>
                    (selectedDepartment == talentAllDepartments ||
                        item.department == selectedDepartment) &&
                    (!attentionOnly || item.needsAttention),
              )
              .toList()
            ..sort(_compareSlaItems);

      return items;
    });

final incomingTalentRiskCouncilSlaSummaryProvider =
    Provider<IncomingTalentRiskCouncilSlaSummary>((ref) {
      return IncomingTalentRiskCouncilSlaSummary.fromItems(
        ref.watch(incomingTalentRiskCouncilSlaItemsProvider),
      );
    });

int _compareSlaItems(
  IncomingTalentRiskCouncilSlaItem left,
  IncomingTalentRiskCouncilSlaItem right,
) {
  final urgency = left.urgencyRank.compareTo(right.urgencyRank);
  if (urgency != 0) return urgency;

  final dueDate = left.dueDate.compareTo(right.dueDate);
  if (dueDate != 0) return dueDate;

  return left.candidateName.compareTo(right.candidateName);
}
