import 'package:flutter_riverpod/legacy.dart';

import '../models/incoming_talent_risk_council_queue_models.dart';

/// Selected source focus for talent risk council queue, decisions, and follow-ups.
final incomingTalentRiskCouncilSourceFilterProvider =
    StateProvider<IncomingTalentRiskCouncilQueueSource?>((ref) => null);

/// Human-readable label for the selected council source focus.
String incomingTalentRiskCouncilSourceFilterLabel(
  IncomingTalentRiskCouncilQueueSource? source,
) {
  return source?.label ?? 'All council sources';
}

/// Returns true when a council record should be visible for the source focus.
bool matchesIncomingTalentRiskCouncilSourceFilter({
  required IncomingTalentRiskCouncilQueueSource? selectedSource,
  required IncomingTalentRiskCouncilQueueSource source,
}) {
  return selectedSource == null || source == selectedSource;
}
