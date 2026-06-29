import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/incoming_talent_governance_execution_models.dart';
import 'incoming_talent_governance_decision_ledger_provider.dart';
import 'talent_provider.dart';

/// Execution tracker for published executive talent governance decisions.
final incomingTalentGovernanceExecutionTracksProvider =
    Provider<List<IncomingTalentGovernanceExecutionTrack>>((ref) {
      return buildIncomingTalentGovernanceExecutionTracks(
        ledgerItems: ref.watch(
          incomingTalentGovernanceDecisionLedgerItemsProvider,
        ),
        asOfDate: ref.watch(talentAsOfDateProvider),
      );
    });

/// Execution health summary for executive talent governance decisions.
final incomingTalentGovernanceExecutionSummaryProvider =
    Provider<IncomingTalentGovernanceExecutionSummary>((ref) {
      return IncomingTalentGovernanceExecutionSummary.fromTracks(
        ref.watch(incomingTalentGovernanceExecutionTracksProvider),
      );
    });
