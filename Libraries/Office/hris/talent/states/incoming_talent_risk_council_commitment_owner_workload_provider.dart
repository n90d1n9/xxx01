import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/incoming_talent_risk_council_commitment_owner_workload_models.dart';
import 'incoming_talent_risk_council_commitment_action_provider.dart';
import 'talent_provider.dart';

final incomingTalentRiskCouncilCommitmentOwnerWorkloadItemsProvider =
    Provider<List<IncomingTalentRiskCouncilCommitmentOwnerWorkloadItem>>((ref) {
      return buildIncomingTalentRiskCouncilCommitmentOwnerWorkloads(
        actions: ref.watch(
          filteredIncomingTalentRiskCouncilCommitmentActionsProvider,
        ),
        asOfDate: ref.watch(talentAsOfDateProvider),
      );
    });

final incomingTalentRiskCouncilCommitmentOwnerWorkloadSummaryProvider =
    Provider<IncomingTalentRiskCouncilCommitmentOwnerWorkloadSummary>((ref) {
      return IncomingTalentRiskCouncilCommitmentOwnerWorkloadSummary.fromItems(
        ref.watch(
          incomingTalentRiskCouncilCommitmentOwnerWorkloadItemsProvider,
        ),
      );
    });

/// Rebalance recommendations for overloaded council commitment owners.
final incomingTalentRiskCouncilCommitmentOwnerRebalancePlanProvider = Provider<
  IncomingTalentRiskCouncilCommitmentOwnerRebalancePlan
>((ref) {
  return IncomingTalentRiskCouncilCommitmentOwnerRebalancePlan.fromWorkloads(
    ref.watch(incomingTalentRiskCouncilCommitmentOwnerWorkloadItemsProvider),
  );
});
