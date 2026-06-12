import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/incoming_talent_governance_review_readiness_models.dart';
import 'incoming_talent_governance_review_pack_provider.dart';
import 'talent_provider.dart';

/// Preparation checklist for the executive talent governance review.
final incomingTalentGovernanceReviewReadinessItemsProvider =
    Provider<List<IncomingTalentGovernanceReviewReadinessItem>>((ref) {
      return buildIncomingTalentGovernanceReviewReadiness(
        reviewPack: ref.watch(incomingTalentGovernanceReviewPackProvider),
        asOfDate: ref.watch(talentAsOfDateProvider),
      );
    });

/// Preparation summary for the executive talent governance review.
final incomingTalentGovernanceReviewReadinessSummaryProvider =
    Provider<IncomingTalentGovernanceReviewReadinessSummary>((ref) {
      return IncomingTalentGovernanceReviewReadinessSummary.fromItems(
        ref.watch(incomingTalentGovernanceReviewReadinessItemsProvider),
      );
    });
