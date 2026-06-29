import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/incoming_talent_risk_council_readiness_checklist_models.dart';
import 'incoming_talent_risk_council_brief_provider.dart';
import 'incoming_talent_risk_council_sla_provider.dart';
import 'talent_provider.dart';

final incomingTalentRiskCouncilReadinessChecklistItemsProvider =
    Provider<List<IncomingTalentRiskCouncilReadinessChecklistItem>>((ref) {
      return buildIncomingTalentRiskCouncilReadinessChecklist(
        brief: ref.watch(incomingTalentRiskCouncilBriefProvider),
        slaItems: ref.watch(incomingTalentRiskCouncilSlaItemsProvider),
        asOfDate: ref.watch(talentAsOfDateProvider),
      );
    });

final incomingTalentRiskCouncilReadinessChecklistSummaryProvider =
    Provider<IncomingTalentRiskCouncilReadinessChecklistSummary>((ref) {
      return IncomingTalentRiskCouncilReadinessChecklistSummary.fromItems(
        ref.watch(incomingTalentRiskCouncilReadinessChecklistItemsProvider),
      );
    });
