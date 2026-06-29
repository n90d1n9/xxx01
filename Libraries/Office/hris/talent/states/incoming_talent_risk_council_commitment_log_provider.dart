import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/incoming_talent_risk_council_commitment_log_models.dart';
import 'incoming_talent_risk_council_agenda_provider.dart';
import 'incoming_talent_risk_council_readiness_checklist_provider.dart';
import 'talent_provider.dart';

final incomingTalentRiskCouncilCommitmentLogItemsProvider =
    Provider<List<IncomingTalentRiskCouncilCommitmentLogItem>>((ref) {
      return buildIncomingTalentRiskCouncilCommitmentLog(
        agendaItems: ref.watch(incomingTalentRiskCouncilAgendaItemsProvider),
        readinessItems: ref.watch(
          incomingTalentRiskCouncilReadinessChecklistItemsProvider,
        ),
        asOfDate: ref.watch(talentAsOfDateProvider),
      );
    });

final incomingTalentRiskCouncilCommitmentLogSummaryProvider =
    Provider<IncomingTalentRiskCouncilCommitmentLogSummary>((ref) {
      return IncomingTalentRiskCouncilCommitmentLogSummary.fromItems(
        ref.watch(incomingTalentRiskCouncilCommitmentLogItemsProvider),
      );
    });
