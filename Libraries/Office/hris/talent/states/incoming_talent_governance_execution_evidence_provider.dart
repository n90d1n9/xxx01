import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/incoming_talent_governance_execution_models.dart';
import 'incoming_talent_governance_execution_action_provider.dart';
import 'incoming_talent_governance_execution_closure_provider.dart';

/// Evidence register for governance execution actions and closures.
final incomingTalentGovernanceExecutionEvidenceItemsProvider =
    Provider<List<IncomingTalentGovernanceExecutionEvidenceItem>>((ref) {
      return buildIncomingTalentGovernanceExecutionEvidenceItems(
        actions: ref.watch(incomingTalentGovernanceExecutionActionsProvider),
        closures: ref.watch(incomingTalentGovernanceExecutionClosuresProvider),
      );
    });

/// Summary for governance execution evidence audit readiness.
final incomingTalentGovernanceExecutionEvidenceSummaryProvider =
    Provider<IncomingTalentGovernanceExecutionEvidenceSummary>((ref) {
      return IncomingTalentGovernanceExecutionEvidenceSummary.fromItems(
        ref.watch(incomingTalentGovernanceExecutionEvidenceItemsProvider),
      );
    });
