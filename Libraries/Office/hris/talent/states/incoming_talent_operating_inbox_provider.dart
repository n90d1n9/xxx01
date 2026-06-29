import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/incoming_talent_operating_inbox_models.dart';
import 'incoming_talent_career_path_review_provider.dart';
import 'incoming_talent_promotion_stabilization_follow_up_action_provider.dart';
import 'incoming_talent_risk_council_decision_provider.dart';
import 'incoming_talent_risk_council_follow_up_provider.dart';
import 'incoming_talent_succession_coverage_council_follow_up_provider.dart';
import 'incoming_talent_training_session_provider.dart';
import 'talent_provider.dart';

/// Unified operating inbox for active talent-management work.
final incomingTalentOperatingInboxItemsProvider = Provider<
  List<IncomingTalentOperatingInboxItem>
>((ref) {
  final asOfDate = ref.watch(talentAsOfDateProvider);

  return buildIncomingTalentOperatingInboxItems(
    riskQueueItems: ref.watch(decisionReadyTalentRiskCouncilQueueItemsProvider),
    riskDecisions: ref.watch(followUpReadyTalentRiskCouncilDecisionsProvider),
    riskFollowUps: ref.watch(
      filteredIncomingTalentRiskCouncilFollowUpsProvider,
    ),
    trainingSessions: ref.watch(filteredIncomingTalentTrainingSessionsProvider),
    careerPathReviews: ref.watch(
      filteredIncomingTalentCareerPathReviewsProvider,
    ),
    successionFollowUps: ref.watch(
      filteredIncomingTalentSuccessionCoverageCouncilFollowUpsProvider,
    ),
    promotionActions: ref.watch(
      filteredIncomingTalentPromotionStabilizationFollowUpActionsProvider,
    ),
    asOfDate: asOfDate,
  );
});

/// Summary counts and recommended next action for the talent operating inbox.
final incomingTalentOperatingInboxSummaryProvider =
    Provider<IncomingTalentOperatingInboxSummary>((ref) {
      return IncomingTalentOperatingInboxSummary.fromItems(
        items: ref.watch(incomingTalentOperatingInboxItemsProvider),
        asOfDate: ref.watch(talentAsOfDateProvider),
      );
    });

/// Owner-level workload concentration for the talent operating inbox.
final incomingTalentOperatingInboxOwnerDigestsProvider =
    Provider<List<IncomingTalentOperatingInboxOwnerDigest>>((ref) {
      return buildIncomingTalentOperatingInboxOwnerDigests(
        items: ref.watch(incomingTalentOperatingInboxItemsProvider),
        asOfDate: ref.watch(talentAsOfDateProvider),
      );
    });

/// Summary and recommended next action for talent inbox owner workloads.
final incomingTalentOperatingInboxOwnerDigestSummaryProvider =
    Provider<IncomingTalentOperatingInboxOwnerDigestSummary>((ref) {
      return IncomingTalentOperatingInboxOwnerDigestSummary.fromDigests(
        ref.watch(incomingTalentOperatingInboxOwnerDigestsProvider),
      );
    });

/// Rebalance plan for overloaded talent operating inbox owners.
final incomingTalentOperatingInboxOwnerRebalancePlanProvider =
    Provider<IncomingTalentOperatingInboxOwnerRebalancePlan>((ref) {
      return IncomingTalentOperatingInboxOwnerRebalancePlan.fromDigests(
        ref.watch(incomingTalentOperatingInboxOwnerDigestsProvider),
      );
    });

/// Workstream-level pressure across active talent operating inbox work.
final incomingTalentOperatingWorkstreamPressuresProvider =
    Provider<List<IncomingTalentOperatingWorkstreamPressure>>((ref) {
      return buildIncomingTalentOperatingWorkstreamPressures(
        items: ref.watch(incomingTalentOperatingInboxItemsProvider),
        ownerDigests: ref.watch(
          incomingTalentOperatingInboxOwnerDigestsProvider,
        ),
        asOfDate: ref.watch(talentAsOfDateProvider),
      );
    });

/// Summary of cross-workstream pressure for talent operations.
final incomingTalentOperatingWorkstreamPressureSummaryProvider =
    Provider<IncomingTalentOperatingWorkstreamPressureSummary>((ref) {
      return IncomingTalentOperatingWorkstreamPressureSummary.fromItems(
        ref.watch(incomingTalentOperatingWorkstreamPressuresProvider),
      );
    });

/// Due-date cadence buckets for active talent operating inbox work.
final incomingTalentOperatingCadenceBucketsProvider =
    Provider<List<IncomingTalentOperatingCadenceBucket>>((ref) {
      return buildIncomingTalentOperatingCadenceBuckets(
        items: ref.watch(incomingTalentOperatingInboxItemsProvider),
        asOfDate: ref.watch(talentAsOfDateProvider),
      );
    });

/// Summary of the active talent operating cadence forecast.
final incomingTalentOperatingCadenceForecastSummaryProvider =
    Provider<IncomingTalentOperatingCadenceForecastSummary>((ref) {
      return IncomingTalentOperatingCadenceForecastSummary.fromBuckets(
        ref.watch(incomingTalentOperatingCadenceBucketsProvider),
      );
    });

/// Ranked escalation board for active cross-HRIS talent operating work.
final incomingTalentOperatingEscalationsProvider =
    Provider<List<IncomingTalentOperatingEscalationItem>>((ref) {
      return buildIncomingTalentOperatingEscalations(
        inboxItems: ref.watch(incomingTalentOperatingInboxItemsProvider),
        cadenceBuckets: ref.watch(
          incomingTalentOperatingCadenceBucketsProvider,
        ),
        rebalancePlan: ref.watch(
          incomingTalentOperatingInboxOwnerRebalancePlanProvider,
        ),
        workstreamPressures: ref.watch(
          incomingTalentOperatingWorkstreamPressuresProvider,
        ),
        asOfDate: ref.watch(talentAsOfDateProvider),
      );
    });

/// Summary and recommended action for the talent operating escalation board.
final incomingTalentOperatingEscalationSummaryProvider =
    Provider<IncomingTalentOperatingEscalationSummary>((ref) {
      return IncomingTalentOperatingEscalationSummary.fromItems(
        ref.watch(incomingTalentOperatingEscalationsProvider),
      );
    });

/// Auditable evidence gaps across active talent operating work.
final incomingTalentOperatingEvidenceGapsProvider =
    Provider<List<IncomingTalentOperatingEvidenceGap>>((ref) {
      return buildIncomingTalentOperatingEvidenceGaps(
        items: ref.watch(incomingTalentOperatingInboxItemsProvider),
        escalations: ref.watch(incomingTalentOperatingEscalationsProvider),
        asOfDate: ref.watch(talentAsOfDateProvider),
      );
    });

/// Summary and recommended action for talent operating evidence gaps.
final incomingTalentOperatingEvidenceGapSummaryProvider =
    Provider<IncomingTalentOperatingEvidenceGapSummary>((ref) {
      return IncomingTalentOperatingEvidenceGapSummary.fromItems(
        ref.watch(incomingTalentOperatingEvidenceGapsProvider),
      );
    });

/// Workstream-level audit assurance for active talent operating work.
final incomingTalentOperatingAssuranceWorkstreamsProvider =
    Provider<List<IncomingTalentOperatingAssuranceWorkstream>>((ref) {
      return buildIncomingTalentOperatingAssuranceWorkstreams(
        gaps: ref.watch(incomingTalentOperatingEvidenceGapsProvider),
      );
    });

/// Summary of audit assurance across talent operating workstreams.
final incomingTalentOperatingAssuranceSummaryProvider =
    Provider<IncomingTalentOperatingAssuranceSummary>((ref) {
      return IncomingTalentOperatingAssuranceSummary.fromWorkstreams(
        ref.watch(incomingTalentOperatingAssuranceWorkstreamsProvider),
      );
    });

/// Owner-assigned remediation actions for talent assurance exposure.
final incomingTalentOperatingAssuranceRemediationActionsProvider =
    Provider<List<IncomingTalentOperatingAssuranceRemediationAction>>((ref) {
      return buildIncomingTalentOperatingAssuranceRemediationActions(
        gaps: ref.watch(incomingTalentOperatingEvidenceGapsProvider),
        workstreams: ref.watch(
          incomingTalentOperatingAssuranceWorkstreamsProvider,
        ),
      );
    });

/// Summary of active talent assurance remediation work.
final incomingTalentOperatingAssuranceRemediationSummaryProvider =
    Provider<IncomingTalentOperatingAssuranceRemediationSummary>((ref) {
      return IncomingTalentOperatingAssuranceRemediationSummary.fromActions(
        ref.watch(incomingTalentOperatingAssuranceRemediationActionsProvider),
      );
    });

/// Execution tracks for owner-led talent assurance remediation work.
final incomingTalentOperatingAssuranceExecutionTracksProvider =
    Provider<List<IncomingTalentOperatingAssuranceExecutionTrack>>((ref) {
      return buildIncomingTalentOperatingAssuranceExecutionTracks(
        actions: ref.watch(
          incomingTalentOperatingAssuranceRemediationActionsProvider,
        ),
        asOfDate: ref.watch(talentAsOfDateProvider),
      );
    });

/// Summary of active talent assurance remediation execution health.
final incomingTalentOperatingAssuranceExecutionSummaryProvider =
    Provider<IncomingTalentOperatingAssuranceExecutionSummary>((ref) {
      return IncomingTalentOperatingAssuranceExecutionSummary.fromTracks(
        ref.watch(incomingTalentOperatingAssuranceExecutionTracksProvider),
      );
    });

/// Cross-HRIS SLA monitor items for active talent operating work.
final incomingTalentOperatingSlaItemsProvider =
    Provider<List<IncomingTalentOperatingSlaItem>>((ref) {
      return buildIncomingTalentOperatingSlaItems(
        inboxItems: ref.watch(incomingTalentOperatingInboxItemsProvider),
        executionTracks: ref.watch(
          incomingTalentOperatingAssuranceExecutionTracksProvider,
        ),
        asOfDate: ref.watch(talentAsOfDateProvider),
      );
    });

/// Summary of cross-HRIS talent operating SLA health.
final incomingTalentOperatingSlaSummaryProvider =
    Provider<IncomingTalentOperatingSlaSummary>((ref) {
      return IncomingTalentOperatingSlaSummary.fromItems(
        ref.watch(incomingTalentOperatingSlaItemsProvider),
      );
    });
