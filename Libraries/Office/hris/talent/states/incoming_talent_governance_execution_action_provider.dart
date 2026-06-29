import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/incoming_talent_governance_execution_models.dart';
import 'incoming_talent_governance_execution_provider.dart';

/// Owner-ready action board for governance execution follow-through.
final incomingTalentGovernanceExecutionActionsProvider =
    Provider<List<IncomingTalentGovernanceExecutionAction>>((ref) {
      return buildIncomingTalentGovernanceExecutionActions(
        tracks: ref.watch(incomingTalentGovernanceExecutionTracksProvider),
      );
    });

/// Summary for the governance execution action board.
final incomingTalentGovernanceExecutionActionSummaryProvider =
    Provider<IncomingTalentGovernanceExecutionActionSummary>((ref) {
      return IncomingTalentGovernanceExecutionActionSummary.fromActions(
        ref.watch(incomingTalentGovernanceExecutionActionsProvider),
      );
    });
