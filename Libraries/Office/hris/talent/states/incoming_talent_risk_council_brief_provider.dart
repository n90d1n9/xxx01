import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/incoming_talent_risk_council_brief_models.dart';
import 'incoming_talent_risk_council_decision_provider.dart';
import 'incoming_talent_risk_council_follow_up_provider.dart';
import 'incoming_talent_risk_council_sla_provider.dart';

final incomingTalentRiskCouncilBriefProvider = Provider<
  IncomingTalentRiskCouncilBrief
>((ref) {
  return IncomingTalentRiskCouncilBrief.fromSignals(
    queueItems: ref.watch(decisionReadyTalentRiskCouncilQueueItemsProvider),
    decisions: ref.watch(filteredIncomingTalentRiskCouncilDecisionsProvider),
    followUps: ref.watch(filteredIncomingTalentRiskCouncilFollowUpsProvider),
    slaItems: ref.watch(incomingTalentRiskCouncilSlaItemsProvider),
    slaSummary: ref.watch(incomingTalentRiskCouncilSlaSummaryProvider),
  );
});
