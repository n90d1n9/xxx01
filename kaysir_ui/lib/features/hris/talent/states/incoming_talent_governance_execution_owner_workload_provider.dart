import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/incoming_talent_governance_execution_models.dart';
import 'incoming_talent_governance_execution_action_provider.dart';

/// Owner workload view for talent governance execution actions.
final incomingTalentGovernanceExecutionOwnerWorkloadItemsProvider =
    Provider<List<IncomingTalentGovernanceExecutionOwnerWorkloadItem>>((ref) {
      return buildIncomingTalentGovernanceExecutionOwnerWorkloads(
        actions: ref.watch(incomingTalentGovernanceExecutionActionsProvider),
      );
    });

/// Summary for talent governance execution owner workload.
final incomingTalentGovernanceExecutionOwnerWorkloadSummaryProvider =
    Provider<IncomingTalentGovernanceExecutionOwnerWorkloadSummary>((ref) {
      return IncomingTalentGovernanceExecutionOwnerWorkloadSummary.fromItems(
        ref.watch(incomingTalentGovernanceExecutionOwnerWorkloadItemsProvider),
      );
    });
