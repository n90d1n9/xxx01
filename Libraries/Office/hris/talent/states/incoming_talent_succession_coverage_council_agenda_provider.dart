import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/incoming_talent_succession_models.dart';
import 'incoming_talent_succession_coverage_governance_provider.dart';
import 'talent_provider.dart';

final incomingTalentSuccessionCoverageCouncilAgendaItemsProvider = Provider<
  List<IncomingTalentSuccessionCoverageCouncilAgendaItem>
>((ref) {
  final asOfDate = ref.watch(talentAsOfDateProvider);
  final items =
      ref
          .watch(
            filteredIncomingTalentSuccessionCoverageGovernanceRecordsProvider,
          )
          .where(shouldIncludeCoverageCouncilAgendaRecord)
          .map(
            (record) =>
                IncomingTalentSuccessionCoverageCouncilAgendaItem.fromRecord(
                  record: record,
                  asOfDate: asOfDate,
                ),
          )
          .toList()
        ..sort(_compareAgendaItems(asOfDate));

  return items;
});

final incomingTalentSuccessionCoverageCouncilAgendaSummaryProvider =
    Provider<IncomingTalentSuccessionCoverageCouncilAgendaSummary>((ref) {
      return IncomingTalentSuccessionCoverageCouncilAgendaSummary.fromItems(
        items: ref.watch(
          incomingTalentSuccessionCoverageCouncilAgendaItemsProvider,
        ),
        asOfDate: ref.watch(talentAsOfDateProvider),
      );
    });

Comparator<IncomingTalentSuccessionCoverageCouncilAgendaItem>
_compareAgendaItems(DateTime asOfDate) {
  return (left, right) {
    final priority = left.priority.index.compareTo(right.priority.index);
    if (priority != 0) return priority;

    final overdue = _boolRank(
      right.isOverdue(asOfDate),
    ).compareTo(_boolRank(left.isOverdue(asOfDate)));
    if (overdue != 0) return overdue;

    final executive = _boolRank(
      right.needsExecutiveDecision,
    ).compareTo(_boolRank(left.needsExecutiveDecision));
    if (executive != 0) return executive;

    return left.dueDate.compareTo(right.dueDate);
  };
}

int _boolRank(bool value) => value ? 1 : 0;
