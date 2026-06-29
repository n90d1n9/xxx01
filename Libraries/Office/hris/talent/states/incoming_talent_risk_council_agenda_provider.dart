import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/incoming_talent_risk_council_agenda_models.dart';
import 'incoming_talent_risk_council_brief_provider.dart';
import 'incoming_talent_risk_council_readiness_checklist_provider.dart';

final incomingTalentRiskCouncilAgendaItemsProvider =
    Provider<List<IncomingTalentRiskCouncilAgendaItem>>((ref) {
      return buildIncomingTalentRiskCouncilAgenda(
        brief: ref.watch(incomingTalentRiskCouncilBriefProvider),
        readinessItems: ref.watch(
          incomingTalentRiskCouncilReadinessChecklistItemsProvider,
        ),
      );
    });

final incomingTalentRiskCouncilAgendaSummaryProvider =
    Provider<IncomingTalentRiskCouncilAgendaSummary>((ref) {
      return IncomingTalentRiskCouncilAgendaSummary.fromItems(
        ref.watch(incomingTalentRiskCouncilAgendaItemsProvider),
      );
    });
