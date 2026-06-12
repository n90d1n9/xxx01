import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/incoming_talent_governance_decision_ledger_models.dart';
import 'incoming_talent_governance_review_pack_provider.dart';
import 'incoming_talent_governance_review_readiness_provider.dart';
import 'talent_provider.dart';

/// Executive decision ledger for publishing talent governance outcomes.
final incomingTalentGovernanceDecisionLedgerItemsProvider =
    Provider<List<IncomingTalentGovernanceDecisionLedgerItem>>((ref) {
      return buildIncomingTalentGovernanceDecisionLedger(
        reviewPack: ref.watch(incomingTalentGovernanceReviewPackProvider),
        readinessItems: ref.watch(
          incomingTalentGovernanceReviewReadinessItemsProvider,
        ),
        asOfDate: ref.watch(talentAsOfDateProvider),
      );
    });

/// Publication summary for executive talent governance decisions.
final incomingTalentGovernanceDecisionLedgerSummaryProvider =
    Provider<IncomingTalentGovernanceDecisionLedgerSummary>((ref) {
      return IncomingTalentGovernanceDecisionLedgerSummary.fromItems(
        ref.watch(incomingTalentGovernanceDecisionLedgerItemsProvider),
      );
    });
