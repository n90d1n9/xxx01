import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/incoming_talent_risk_council_queue_models.dart';
import '../models/incoming_talent_risk_council_source_drill_down.dart';
import '../models/incoming_talent_risk_council_source_pressure.dart';
import 'incoming_talent_risk_council_decision_provider.dart';
import 'incoming_talent_risk_council_follow_up_provider.dart';
import 'incoming_talent_risk_council_sla_provider.dart';
import 'incoming_talent_risk_council_source_filter_provider.dart';
import 'incoming_talent_risk_council_source_pressure_provider.dart';

/// Active source drill-down for council queue, decisions, follow-ups, and SLA.
final incomingTalentRiskCouncilSourceDrillDownProvider = Provider<
  IncomingTalentRiskCouncilSourceDrillDown
>((ref) {
  final selectedSource = ref.watch(
    incomingTalentRiskCouncilSourceFilterProvider,
  );
  final pressures = ref.watch(incomingTalentRiskCouncilSourcePressureProvider);
  final source = selectedSource ?? _topPressureSource(pressures);

  if (source == null) {
    return const IncomingTalentRiskCouncilSourceDrillDown(
      source: null,
      isAutoFocused: true,
      pressure: null,
      queueItems: [],
      decisions: [],
      followUps: [],
      slaItems: [],
    );
  }

  return IncomingTalentRiskCouncilSourceDrillDown(
    source: source,
    isAutoFocused: selectedSource == null,
    pressure: _pressureForSource(pressures, source),
    queueItems:
        ref
            .watch(decisionReadyTalentRiskCouncilQueueItemsProvider)
            .where((item) => item.source == source)
            .toList(),
    decisions:
        ref
            .watch(followUpReadyTalentRiskCouncilDecisionsProvider)
            .where((decision) => decision.source == source)
            .toList(),
    followUps:
        ref
            .watch(filteredIncomingTalentRiskCouncilFollowUpsProvider)
            .where((followUp) => followUp.isOpen && followUp.source == source)
            .toList(),
    slaItems:
        ref
            .watch(incomingTalentRiskCouncilSlaItemsProvider)
            .where((item) => item.councilSource == source)
            .toList(),
  );
});

IncomingTalentRiskCouncilQueueSource? _topPressureSource(
  List<IncomingTalentRiskCouncilSourcePressure> pressures,
) {
  if (pressures.isEmpty) return null;
  return pressures.first.source;
}

IncomingTalentRiskCouncilSourcePressure? _pressureForSource(
  List<IncomingTalentRiskCouncilSourcePressure> pressures,
  IncomingTalentRiskCouncilQueueSource source,
) {
  for (final pressure in pressures) {
    if (pressure.source == source) return pressure;
  }
  return null;
}
