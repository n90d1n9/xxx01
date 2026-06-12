import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/incoming_talent_risk_council_source_pressure.dart';
import 'incoming_talent_risk_council_sla_provider.dart';

/// Ranked source pressure for active talent risk council SLA work.
final incomingTalentRiskCouncilSourcePressureProvider =
    Provider<List<IncomingTalentRiskCouncilSourcePressure>>((ref) {
      return IncomingTalentRiskCouncilSourcePressure.fromSlaItems(
        ref.watch(incomingTalentRiskCouncilSlaItemsProvider),
      );
    });
