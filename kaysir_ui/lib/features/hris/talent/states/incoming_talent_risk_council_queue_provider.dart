import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/incoming_talent_risk_council_queue_models.dart';
import 'incoming_talent_profile_timeline_provider.dart';
import 'incoming_talent_risk_council_source_filter_provider.dart';
import 'talent_provider.dart';

final allIncomingTalentRiskCouncilQueueItemsProvider =
    Provider<List<IncomingTalentRiskCouncilQueueItem>>((ref) {
      return buildIncomingTalentRiskCouncilQueue(
        timelines: ref.watch(filteredIncomingTalentProfileTimelinesProvider),
        asOfDate: ref.watch(talentAsOfDateProvider),
      );
    });

final incomingTalentRiskCouncilQueueItemsProvider =
    Provider<List<IncomingTalentRiskCouncilQueueItem>>((ref) {
      final selectedSource = ref.watch(
        incomingTalentRiskCouncilSourceFilterProvider,
      );

      return ref
          .watch(allIncomingTalentRiskCouncilQueueItemsProvider)
          .where(
            (item) => matchesIncomingTalentRiskCouncilSourceFilter(
              selectedSource: selectedSource,
              source: item.source,
            ),
          )
          .toList();
    });

final incomingTalentRiskCouncilQueueSummaryProvider =
    Provider<IncomingTalentRiskCouncilQueueSummary>((ref) {
      return IncomingTalentRiskCouncilQueueSummary.fromItems(
        ref.watch(incomingTalentRiskCouncilQueueItemsProvider),
      );
    });
