import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_activation_outcome_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_calibration_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_career_path_review_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_career_path_support_action_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_career_path_support_outcome_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_development_check_in_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_development_intervention_outcome_follow_up_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_development_intervention_outcome_follow_up_resolution_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_development_intervention_outcome_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_development_program_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_development_roadmap_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_profile_timeline_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_promotion_decision_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_promotion_implementation_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_promotion_readiness_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_promotion_stabilization_follow_up_action_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_promotion_stabilization_follow_up_resolution_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_promotion_stabilization_review_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_calibration_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_career_path_support_action_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_career_path_support_outcome_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_development_program_completion_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_development_program_milestone_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_development_intervention_outcome_follow_up_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_development_intervention_outcome_follow_up_resolution_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_development_intervention_outcome_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_development_intervention_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_profile_timeline_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_promotion_stabilization_follow_up_action_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_promotion_stabilization_follow_up_resolution_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_promotion_stabilization_review_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

import 'incoming_talent_calibration_test_support.dart';

void main() {
  test('incoming talent profile timeline aggregates full talent history', () {
    final asOfDate = DateTime(2026, 5, 30);
    final container = calibrationTestContainer(asOfDate);
    addTearDown(container.dispose);

    final packet = seedRiskCalibrationPacket(container, asOfDate);
    final review = _submitCalibrationReview(container, packet);

    final timelines = container.read(incomingTalentProfileTimelinesProvider);
    final summary = container.read(
      incomingTalentProfileTimelineSummaryProvider,
    );
    final timeline = timelines.single;
    final eventTypes = timeline.events.map((event) => event.type).toSet();

    expect(
      review.decision,
      IncomingTalentCalibrationDecision.retentionEscalation,
    );
    expect(timeline.candidateName, packet.candidateName);
    expect(timeline.openInterventionCount, 1);
    expect(timeline.latestCalibrationDecisionLabel, 'Retention escalation');
    expect(timeline.nextAction, 'Close 1 open intervention.');
    expect(timeline.needsAttention, isTrue);
    expect(
      eventTypes,
      containsAll({
        IncomingTalentProfileTimelineEventType.outcome,
        IncomingTalentProfileTimelineEventType.roadmap,
        IncomingTalentProfileTimelineEventType.checkIn,
        IncomingTalentProfileTimelineEventType.intervention,
        IncomingTalentProfileTimelineEventType.calibration,
      }),
    );
    for (var index = 1; index < timeline.events.length; index++) {
      expect(
        timeline.events[index].eventDate.isAfter(
          timeline.events[index - 1].eventDate,
        ),
        isFalse,
      );
    }
    expect(summary.totalProfiles, 1);
    expect(summary.attentionProfiles, 1);
    expect(summary.openInterventions, 1);
    expect(summary.nextAction, 'Resolve 1 open talent actions.');
  });

  test(
    'incoming talent profile timeline summarizes calibrated healthy profile',
    () {
      final asOfDate = DateTime(2026, 5, 30);
      final container = calibrationTestContainer(asOfDate);
      addTearDown(container.dispose);

      final outcome = submitCalibrationOutcome(
        container,
        calibrationOutcome(
          asOfDate,
          decision: IncomingTalentActivationOutcomeDecision.stabilized,
          risk: IncomingTalentActivationRetentionRisk.low,
          readinessScore: 92,
        ),
      );
      submitCalibrationRoadmap(
        container,
        calibrationRoadmap(
          asOfDate,
          outcome,
          status: IncomingTalentDevelopmentRoadmapStatus.active,
        ),
      );
      final packet = container
          .read(incomingTalentCalibrationPacketsProvider)
          .singleWhere((packet) => packet.outcomeReviewId == outcome.id);
      _submitCalibrationReview(container, packet);

      final timeline =
          container.read(incomingTalentProfileTimelinesProvider).single;
      final summary = container.read(
        incomingTalentProfileTimelineSummaryProvider,
      );

      expect(timeline.needsAttention, isFalse);
      expect(timeline.latestCalibrationDecisionLabel, 'Accelerate growth');
      expect(timeline.nextAction, 'Maintain development cadence.');
      expect(summary.highReadinessProfiles, 1);
      expect(summary.calibratedProfiles, 1);
      expect(summary.nextAction, 'Profile timelines are current.');
    },
  );

  test('incoming talent profile timeline includes career support history', () {
    final asOfDate = DateTime(2026, 5, 30);
    final container = calibrationTestContainer(asOfDate);
    addTearDown(container.dispose);

    final outcome = submitCalibrationOutcome(
      container,
      calibrationOutcome(
        asOfDate,
        decision: IncomingTalentActivationOutcomeDecision.stabilized,
        risk: IncomingTalentActivationRetentionRisk.low,
        readinessScore: 90,
      ),
    );
    _submitCareerSupportAction(container, asOfDate, outcome);
    _submitCareerSupportOutcome(container, asOfDate, outcome);

    final timeline =
        container.read(incomingTalentProfileTimelinesProvider).single;
    final summary = container.read(
      incomingTalentProfileTimelineSummaryProvider,
    );
    final eventTypes = timeline.events.map((event) => event.type).toSet();

    expect(
      eventTypes,
      containsAll({
        IncomingTalentProfileTimelineEventType.careerSupportAction,
        IncomingTalentProfileTimelineEventType.careerSupportOutcome,
      }),
    );
    expect(timeline.openCareerSupportCount, 1);
    expect(timeline.nextAction, 'Close 1 career support action.');
    expect(summary.nextAction, 'Resolve 1 open talent actions.');
  });

  test(
    'incoming talent profile timeline includes development intervention outcomes',
    () {
      final asOfDate = DateTime(2026, 5, 30);
      final container = calibrationTestContainer(asOfDate);
      addTearDown(container.dispose);

      final outcome = submitCalibrationOutcome(
        container,
        calibrationOutcome(
          asOfDate,
          decision: IncomingTalentActivationOutcomeDecision.stabilized,
          risk: IncomingTalentActivationRetentionRisk.medium,
          readinessScore: 78,
        ),
      );
      final roadmap = submitCalibrationRoadmap(
        container,
        calibrationRoadmap(
          asOfDate,
          outcome,
          status: IncomingTalentDevelopmentRoadmapStatus.atRisk,
        ),
      );
      final checkIn = submitCalibrationCheckIn(
        container,
        calibrationCheckIn(
          asOfDate,
          roadmap,
          trend: IncomingTalentDevelopmentCheckInTrend.blocked,
          confidenceScore: 2,
        ),
      );
      final interventionOutcome = _submitDevelopmentInterventionOutcome(
        container,
        checkIn,
      );

      final timeline =
          container.read(incomingTalentProfileTimelinesProvider).single;
      final summary = container.read(
        incomingTalentProfileTimelineSummaryProvider,
      );
      final outcomeEvent = timeline.events.firstWhere(
        (event) =>
            event.type ==
            IncomingTalentProfileTimelineEventType.interventionOutcome,
      );

      expect(
        interventionOutcome.decision,
        IncomingTalentDevelopmentInterventionOutcomeDecision.monitor,
      );
      expect(timeline.openInterventionCount, 0);
      expect(timeline.watchDevelopmentOutcomeCount, 1);
      expect(timeline.needsAttention, isTrue);
      expect(
        timeline.nextAction,
        'Follow up 1 development intervention outcome.',
      );
      expect(summary.watchDevelopmentOutcomes, 1);
      expect(
        summary.nextAction,
        'Follow up 1 development intervention outcome.',
      );
      expect(outcomeEvent.statusLabel, '3/5 confidence');
      expect(outcomeEvent.tone, IncomingTalentProfileTimelineEventTone.watch);
    },
  );

  test(
    'incoming talent profile timeline includes intervention outcome follow-ups',
    () {
      final asOfDate = DateTime(2026, 5, 30);
      final container = calibrationTestContainer(asOfDate);
      addTearDown(container.dispose);

      final outcome = submitCalibrationOutcome(
        container,
        calibrationOutcome(
          asOfDate,
          decision: IncomingTalentActivationOutcomeDecision.stabilized,
          risk: IncomingTalentActivationRetentionRisk.medium,
          readinessScore: 78,
        ),
      );
      final roadmap = submitCalibrationRoadmap(
        container,
        calibrationRoadmap(
          asOfDate,
          outcome,
          status: IncomingTalentDevelopmentRoadmapStatus.atRisk,
        ),
      );
      final checkIn = submitCalibrationCheckIn(
        container,
        calibrationCheckIn(
          asOfDate,
          roadmap,
          trend: IncomingTalentDevelopmentCheckInTrend.blocked,
          confidenceScore: 2,
        ),
      );
      final interventionOutcome = _submitDevelopmentInterventionOutcome(
        container,
        checkIn,
      );
      final followUp = _submitDevelopmentInterventionOutcomeFollowUp(
        container,
        interventionOutcome,
      );

      final timeline =
          container.read(incomingTalentProfileTimelinesProvider).single;
      final summary = container.read(
        incomingTalentProfileTimelineSummaryProvider,
      );
      final followUpEvent = timeline.events.firstWhere(
        (event) =>
            event.type ==
            IncomingTalentProfileTimelineEventType.interventionOutcomeFollowUp,
      );

      expect(
        followUp.status,
        IncomingTalentDevelopmentInterventionOutcomeFollowUpStatus.open,
      );
      expect(timeline.openDevelopmentFollowUpCount, 1);
      expect(timeline.watchDevelopmentFollowUpCount, 1);
      expect(timeline.nextAction, 'Resolve 1 intervention outcome follow-up.');
      expect(summary.openDevelopmentFollowUps, 1);
      expect(summary.watchDevelopmentFollowUps, 1);
      expect(followUpEvent.statusLabel, 'Monitor');
      expect(followUpEvent.tone, IncomingTalentProfileTimelineEventTone.watch);
    },
  );

  test(
    'incoming talent profile timeline includes intervention follow-up resolution reviews',
    () {
      final asOfDate = DateTime(2026, 5, 30);
      final container = calibrationTestContainer(asOfDate);
      addTearDown(container.dispose);

      final outcome = submitCalibrationOutcome(
        container,
        calibrationOutcome(
          asOfDate,
          decision: IncomingTalentActivationOutcomeDecision.stabilized,
          risk: IncomingTalentActivationRetentionRisk.medium,
          readinessScore: 78,
        ),
      );
      final roadmap = submitCalibrationRoadmap(
        container,
        calibrationRoadmap(
          asOfDate,
          outcome,
          status: IncomingTalentDevelopmentRoadmapStatus.atRisk,
        ),
      );
      final checkIn = submitCalibrationCheckIn(
        container,
        calibrationCheckIn(
          asOfDate,
          roadmap,
          trend: IncomingTalentDevelopmentCheckInTrend.blocked,
          confidenceScore: 2,
        ),
      );
      final interventionOutcome = _submitDevelopmentInterventionOutcome(
        container,
        checkIn,
      );
      final followUp = _submitDevelopmentInterventionOutcomeFollowUp(
        container,
        interventionOutcome,
      );
      container
          .read(
            incomingTalentDevelopmentInterventionOutcomeFollowUpsProvider
                .notifier,
          )
          .escalate(
            followUp.id,
            resolutionNote:
                'Residual release risk escalated to HR manager council.',
          );
      final escalatedFollowUp = container
          .read(incomingTalentDevelopmentInterventionOutcomeFollowUpsProvider)
          .firstWhere((item) => item.id == followUp.id);
      final resolution =
          _submitDevelopmentInterventionOutcomeFollowUpResolution(
            container,
            escalatedFollowUp,
          );

      final timeline =
          container.read(incomingTalentProfileTimelinesProvider).single;
      final summary = container.read(
        incomingTalentProfileTimelineSummaryProvider,
      );
      final resolutionEvent = timeline.events.firstWhere(
        (event) =>
            event.type ==
            IncomingTalentProfileTimelineEventType
                .interventionOutcomeFollowUpResolution,
      );

      expect(
        resolution.decision,
        IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDecision
            .escalate,
      );
      expect(timeline.openDevelopmentFollowUpCount, 0);
      expect(timeline.watchDevelopmentFollowUpCount, 0);
      expect(timeline.watchDevelopmentResolutionCount, 1);
      expect(
        timeline.nextAction,
        'Resolve 1 intervention follow-up resolution review.',
      );
      expect(summary.watchDevelopmentResolutions, 1);
      expect(summary.nextAction, 'Resolve 1 follow-up resolution review.');
      expect(resolutionEvent.statusLabel, '2/5 confidence');
      expect(
        resolutionEvent.tone,
        IncomingTalentProfileTimelineEventTone.critical,
      );
    },
  );

  test(
    'incoming talent profile timeline includes program milestone reviews',
    () {
      final asOfDate = DateTime(2026, 5, 30);
      final container = calibrationTestContainer(asOfDate);
      addTearDown(container.dispose);

      final outcome = submitCalibrationOutcome(
        container,
        calibrationOutcome(
          asOfDate,
          decision: IncomingTalentActivationOutcomeDecision.stabilized,
          risk: IncomingTalentActivationRetentionRisk.low,
          readinessScore: 88,
        ),
      );
      _submitProgramMilestone(container, asOfDate, outcome);

      final timeline =
          container.read(incomingTalentProfileTimelinesProvider).single;
      final summary = container.read(
        incomingTalentProfileTimelineSummaryProvider,
      );
      final eventTypes = timeline.events.map((event) => event.type).toSet();

      expect(
        eventTypes,
        contains(IncomingTalentProfileTimelineEventType.programMilestone),
      );
      expect(timeline.programMilestoneRevisionCount, 1);
      expect(timeline.needsAttention, isTrue);
      expect(timeline.nextAction, 'Resolve 1 program milestone revision.');
      expect(summary.programMilestoneRevisions, 1);
      expect(summary.nextAction, 'Resolve 1 program milestone revision.');
    },
  );

  test('incoming talent profile timeline includes program completions', () {
    final asOfDate = DateTime(2026, 5, 30);
    final container = calibrationTestContainer(asOfDate);
    addTearDown(container.dispose);

    final outcome = submitCalibrationOutcome(
      container,
      calibrationOutcome(
        asOfDate,
        decision: IncomingTalentActivationOutcomeDecision.stabilized,
        risk: IncomingTalentActivationRetentionRisk.low,
        readinessScore: 86,
      ),
    );
    _submitProgramCompletion(container, asOfDate, outcome);

    final timeline =
        container.read(incomingTalentProfileTimelinesProvider).single;
    final summary = container.read(
      incomingTalentProfileTimelineSummaryProvider,
    );
    final eventTypes = timeline.events.map((event) => event.type).toSet();

    expect(
      eventTypes,
      contains(IncomingTalentProfileTimelineEventType.programCompletion),
    );
    expect(timeline.programCompletionExtensionCount, 1);
    expect(timeline.needsAttention, isTrue);
    expect(timeline.nextAction, 'Resolve 1 program extension decision.');
    expect(summary.programCompletionExtensions, 1);
    expect(summary.nextAction, 'Resolve 1 program extension decision.');
  });

  test(
    'incoming talent profile timeline includes promotion stabilization reviews',
    () {
      final asOfDate = DateTime(2026, 5, 30);
      final container = calibrationTestContainer(asOfDate);
      addTearDown(container.dispose);

      final outcome = submitCalibrationOutcome(
        container,
        calibrationOutcome(
          asOfDate,
          decision: IncomingTalentActivationOutcomeDecision.stabilized,
          risk: IncomingTalentActivationRetentionRisk.low,
          readinessScore: 88,
        ),
      );
      final review = _submitPromotionStabilizationReview(
        container,
        asOfDate,
        outcome,
      );

      final timeline =
          container.read(incomingTalentProfileTimelinesProvider).single;
      final summary = container.read(
        incomingTalentProfileTimelineSummaryProvider,
      );
      final stabilizationEvent = timeline.events.firstWhere(
        (event) =>
            event.type ==
            IncomingTalentProfileTimelineEventType.promotionStabilization,
      );

      expect(
        review.outcome,
        IncomingTalentPromotionStabilizationOutcome.needsManagerSupport,
      );
      expect(timeline.watchPromotionStabilizationCount, 1);
      expect(timeline.needsAttention, isTrue);
      expect(timeline.nextAction, 'Resolve 1 promotion stabilization review.');
      expect(summary.watchPromotionStabilizations, 1);
      expect(summary.nextAction, 'Resolve 1 promotion stabilization review.');
      expect(stabilizationEvent.statusLabel, '2/5 confidence');
      expect(
        stabilizationEvent.tone,
        IncomingTalentProfileTimelineEventTone.watch,
      );
    },
  );

  test(
    'incoming talent profile timeline includes promotion follow-up actions',
    () {
      final asOfDate = DateTime(2026, 5, 30);
      final container = calibrationTestContainer(asOfDate);
      addTearDown(container.dispose);

      final outcome = submitCalibrationOutcome(
        container,
        calibrationOutcome(
          asOfDate,
          decision: IncomingTalentActivationOutcomeDecision.stabilized,
          risk: IncomingTalentActivationRetentionRisk.low,
          readinessScore: 88,
        ),
      );
      final review = _submitPromotionStabilizationReview(
        container,
        asOfDate,
        outcome,
      );
      final action = _submitPromotionFollowUpAction(
        container,
        asOfDate,
        review,
      );

      final timeline =
          container.read(incomingTalentProfileTimelinesProvider).single;
      final summary = container.read(
        incomingTalentProfileTimelineSummaryProvider,
      );
      final followUpEvent = timeline.events.firstWhere(
        (event) =>
            event.type ==
            IncomingTalentProfileTimelineEventType.promotionFollowUp,
      );

      expect(
        action.priority,
        IncomingTalentPromotionStabilizationFollowUpPriority.critical,
      );
      expect(timeline.openPromotionFollowUpCount, 1);
      expect(timeline.watchPromotionFollowUpCount, 1);
      expect(timeline.openTalentActionCount, 1);
      expect(timeline.needsAttention, isTrue);
      expect(timeline.nextAction, 'Resolve 1 promotion follow-up action.');
      expect(summary.openPromotionFollowUps, 1);
      expect(summary.watchPromotionFollowUps, 1);
      expect(summary.openTalentActions, 1);
      expect(summary.nextAction, 'Resolve 1 promotion follow-up action.');
      expect(followUpEvent.statusLabel, 'Open');
      expect(
        followUpEvent.tone,
        IncomingTalentProfileTimelineEventTone.critical,
      );
    },
  );

  test(
    'incoming talent profile timeline includes promotion resolution reviews',
    () {
      final asOfDate = DateTime(2026, 5, 30);
      final container = calibrationTestContainer(asOfDate);
      addTearDown(container.dispose);

      final outcome = submitCalibrationOutcome(
        container,
        calibrationOutcome(
          asOfDate,
          decision: IncomingTalentActivationOutcomeDecision.stabilized,
          risk: IncomingTalentActivationRetentionRisk.low,
          readinessScore: 88,
        ),
      );
      final review = _submitPromotionStabilizationReview(
        container,
        asOfDate,
        outcome,
      );
      final action = _submitPromotionFollowUpAction(
        container,
        asOfDate,
        review,
      );
      container
          .read(
            incomingTalentPromotionStabilizationFollowUpActionsProvider
                .notifier,
          )
          .updateStatus(
            id: action.id,
            status: IncomingTalentPromotionStabilizationFollowUpStatus.resolved,
            resolutionNote:
                'Manager coaching completed with one checkpoint remaining.',
          );
      final resolvedAction = container
          .read(incomingTalentPromotionStabilizationFollowUpActionsProvider)
          .firstWhere((item) => item.id == action.id);
      final resolution = _submitPromotionFollowUpResolution(
        container,
        resolvedAction,
      );

      final timeline =
          container.read(incomingTalentProfileTimelinesProvider).single;
      final summary = container.read(
        incomingTalentProfileTimelineSummaryProvider,
      );
      final resolutionEvent = timeline.events.firstWhere(
        (event) =>
            event.type ==
            IncomingTalentProfileTimelineEventType.promotionFollowUpResolution,
      );

      expect(
        resolution.outcome,
        IncomingTalentPromotionStabilizationFollowUpResolutionOutcome.monitor,
      );
      expect(timeline.openPromotionFollowUpCount, 0);
      expect(timeline.watchPromotionFollowUpCount, 0);
      expect(timeline.watchPromotionResolutionCount, 1);
      expect(timeline.openTalentActionCount, 0);
      expect(timeline.needsAttention, isTrue);
      expect(timeline.nextAction, 'Resolve 1 promotion resolution review.');
      expect(summary.openPromotionFollowUps, 0);
      expect(summary.watchPromotionFollowUps, 0);
      expect(summary.watchPromotionResolutions, 1);
      expect(summary.openTalentActions, 0);
      expect(summary.nextAction, 'Resolve 1 promotion resolution review.');
      expect(resolutionEvent.statusLabel, '3/5 confidence');
      expect(
        resolutionEvent.tone,
        IncomingTalentProfileTimelineEventTone.watch,
      );
    },
  );

  test('incoming talent profile timelines follow talent filters', () {
    final asOfDate = DateTime(2026, 5, 30);
    final container = calibrationTestContainer(asOfDate);
    addTearDown(container.dispose);

    final engineeringOutcome = submitCalibrationOutcome(
      container,
      calibrationOutcome(
        asOfDate,
        id: 'outcome-engineering',
        activationPlanId: 'activation-engineering',
        candidateName: 'Fajar Nugroho',
        department: 'Engineering',
        role: 'Senior Flutter Engineer',
        decision: IncomingTalentActivationOutcomeDecision.stabilized,
        risk: IncomingTalentActivationRetentionRisk.low,
        readinessScore: 92,
      ),
    );
    submitCalibrationRoadmap(
      container,
      calibrationRoadmap(
        asOfDate,
        engineeringOutcome,
        status: IncomingTalentDevelopmentRoadmapStatus.active,
      ),
    );
    seedRiskCalibrationPacket(
      container,
      asOfDate,
      outcome: calibrationOutcome(
        asOfDate,
        id: 'outcome-finance',
        activationPlanId: 'activation-finance',
        candidateName: 'Mira Lestari',
        department: 'Finance',
        role: 'Finance Operations Analyst',
        decision: IncomingTalentActivationOutcomeDecision.escalateRisk,
        risk: IncomingTalentActivationRetentionRisk.high,
        readinessScore: 48,
      ),
    );

    container.read(talentDepartmentProvider.notifier).state = 'Finance';
    container.read(talentNeedsAttentionProvider.notifier).state = true;

    final filtered = container.read(
      filteredIncomingTalentProfileTimelinesProvider,
    );
    final summary = container.read(
      incomingTalentProfileTimelineSummaryProvider,
    );

    expect(filtered.map((timeline) => timeline.candidateName), [
      'Mira Lestari',
    ]);
    expect(filtered.single.needsAttention, isTrue);
    expect(summary.totalProfiles, 1);
    expect(summary.openInterventions, 1);
  });
}

IncomingTalentPromotionStabilizationFollowUpAction
_submitPromotionFollowUpAction(
  ProviderContainer container,
  DateTime asOfDate,
  IncomingTalentPromotionStabilizationReview review,
) {
  final draft =
      IncomingTalentPromotionStabilizationFollowUpActionDraft.fromReview(
        review: review,
        asOfDate: asOfDate,
      );

  return container
      .read(
        incomingTalentPromotionStabilizationFollowUpActionsProvider.notifier,
      )
      .submitDraft(draft);
}

IncomingTalentPromotionStabilizationFollowUpResolution
_submitPromotionFollowUpResolution(
  ProviderContainer container,
  IncomingTalentPromotionStabilizationFollowUpAction action,
) {
  container
      .read(
        incomingTalentPromotionStabilizationFollowUpResolutionDraftProvider
            .notifier,
      )
      .initializeFromAction(action);
  return container
      .read(
        incomingTalentPromotionStabilizationFollowUpResolutionsProvider
            .notifier,
      )
      .submitDraft(
        container.read(
          incomingTalentPromotionStabilizationFollowUpResolutionDraftProvider,
        ),
      );
}

IncomingTalentDevelopmentInterventionOutcome
_submitDevelopmentInterventionOutcome(
  ProviderContainer container,
  IncomingTalentDevelopmentCheckIn checkIn,
) {
  final intervention = submitCalibrationIntervention(container, checkIn);
  container
      .read(incomingTalentDevelopmentInterventionsProvider.notifier)
      .resolve(
        intervention.id,
        resolutionNote:
            'Manager coaching completed but readiness risk remains active.',
      );
  final resolvedIntervention = container
      .read(incomingTalentDevelopmentInterventionsProvider)
      .firstWhere((item) => item.id == intervention.id);
  final draftNotifier = container.read(
    incomingTalentDevelopmentInterventionOutcomeDraftProvider.notifier,
  );
  draftNotifier.initializeFromIntervention(resolvedIntervention);
  draftNotifier.setDecision(
    IncomingTalentDevelopmentInterventionOutcomeDecision.monitor,
  );
  draftNotifier.setConfidenceAfter(3);
  draftNotifier.setRemainingReleaseRiskCount(1);
  draftNotifier.setNextAction('Run one additional manager readiness review.');

  return container
      .read(incomingTalentDevelopmentInterventionOutcomesProvider.notifier)
      .submitDraft(
        container.read(
          incomingTalentDevelopmentInterventionOutcomeDraftProvider,
        ),
      );
}

IncomingTalentDevelopmentInterventionOutcomeFollowUp
_submitDevelopmentInterventionOutcomeFollowUp(
  ProviderContainer container,
  IncomingTalentDevelopmentInterventionOutcome outcome,
) {
  container
      .read(
        incomingTalentDevelopmentInterventionOutcomeFollowUpDraftProvider
            .notifier,
      )
      .initializeFromOutcome(outcome);
  return container
      .read(
        incomingTalentDevelopmentInterventionOutcomeFollowUpsProvider.notifier,
      )
      .submitDraft(
        container.read(
          incomingTalentDevelopmentInterventionOutcomeFollowUpDraftProvider,
        ),
      );
}

IncomingTalentDevelopmentInterventionOutcomeFollowUpResolution
_submitDevelopmentInterventionOutcomeFollowUpResolution(
  ProviderContainer container,
  IncomingTalentDevelopmentInterventionOutcomeFollowUp followUp,
) {
  container
      .read(
        incomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDraftProvider
            .notifier,
      )
      .initializeFromFollowUp(followUp);
  return container
      .read(
        incomingTalentDevelopmentInterventionOutcomeFollowUpResolutionsProvider
            .notifier,
      )
      .submitDraft(
        container.read(
          incomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDraftProvider,
        ),
      );
}

IncomingTalentDevelopmentProgramCompletion _submitProgramCompletion(
  ProviderContainer container,
  DateTime asOfDate,
  IncomingTalentActivationOutcomeReview outcome,
) {
  return container
      .read(incomingTalentDevelopmentProgramCompletionsProvider.notifier)
      .submitDraft(
        IncomingTalentDevelopmentProgramCompletionDraft(
          milestoneId: 'milestone-${outcome.id}',
          enrollmentId: 'enrollment-${outcome.id}',
          programId: 'program-${outcome.id}',
          programTitle: '${outcome.role} readiness cohort',
          candidateId: outcome.candidateId,
          candidateName: outcome.candidateName,
          role: outcome.role,
          department: outcome.department,
          reviewerName: outcome.reviewerName,
          decision:
              IncomingTalentDevelopmentProgramCompletionDecision.extendProgram,
          credentialLevel:
              IncomingTalentDevelopmentProgramCredentialLevel.foundational,
          score: 62,
          completedAt: asOfDate.subtract(const Duration(days: 1)),
          renewalDate: asOfDate.add(const Duration(days: 90)),
          credentialNote: 'Credential needs extended readiness evidence.',
          managerRecommendation:
              'Extend program before using credential for growth decisions.',
          asOfDate: asOfDate,
        ),
      );
}

IncomingTalentDevelopmentProgramMilestone _submitProgramMilestone(
  ProviderContainer container,
  DateTime asOfDate,
  IncomingTalentActivationOutcomeReview outcome,
) {
  return container
      .read(incomingTalentDevelopmentProgramMilestonesProvider.notifier)
      .submitDraft(
        IncomingTalentDevelopmentProgramMilestoneDraft(
          enrollmentId: 'enrollment-${outcome.id}',
          programId: 'program-${outcome.id}',
          programTitle: '${outcome.role} readiness cohort',
          candidateId: outcome.candidateId,
          candidateName: outcome.candidateName,
          role: outcome.role,
          department: outcome.department,
          reviewerName: outcome.reviewerName,
          title: 'Complete ${outcome.role} milestone evidence review.',
          evidenceSummary: 'Submitted manager-reviewed milestone evidence.',
          reviewNotes: 'Needs revision before evidence can be accepted.',
          type: IncomingTalentDevelopmentProgramMilestoneType.skillEvidence,
          status: IncomingTalentDevelopmentProgramMilestoneStatus.needsRevision,
          score: 58,
          dueDate: asOfDate.add(const Duration(days: 10)),
          submittedAt: asOfDate.add(const Duration(days: 5)),
          reviewedAt: asOfDate.add(const Duration(days: 6)),
          sourceEnrollmentStatus:
              IncomingTalentDevelopmentProgramEnrollmentStatus.watch,
          asOfDate: asOfDate,
        ),
      );
}

IncomingTalentPromotionStabilizationReview _submitPromotionStabilizationReview(
  ProviderContainer container,
  DateTime asOfDate,
  IncomingTalentActivationOutcomeReview outcome,
) {
  return container
      .read(incomingTalentPromotionStabilizationReviewsProvider.notifier)
      .submitDraft(
        IncomingTalentPromotionStabilizationReviewDraft(
          implementationId: 'promotion-implementation-${outcome.id}',
          decisionId: 'promotion-decision-${outcome.id}',
          readinessId: 'promotion-readiness-${outcome.id}',
          candidateId: outcome.candidateId,
          candidateName: outcome.candidateName,
          department: outcome.department,
          currentRole: outcome.role,
          newRole: 'Lead ${outcome.role}',
          frameworkLevelCode: 'L5',
          ownerName: outcome.reviewerName,
          reviewerName: outcome.reviewerName,
          outcome:
              IncomingTalentPromotionStabilizationOutcome.needsManagerSupport,
          status: IncomingTalentPromotionStabilizationStatus.followUpRequired,
          reviewDate: asOfDate.add(const Duration(days: 4)),
          followUpDate: asOfDate.add(const Duration(days: 14)),
          confidenceScore: 2,
          managerFeedback:
              'Manager needs clearer operating expectations after promotion.',
          employeeFeedback:
              'Employee needs clearer promotion goals and support cadence.',
          evidenceSummary:
              'Promotion letter, HRIS update, and manager feedback reviewed.',
          supportPlan:
              'Schedule manager support checkpoint and clarify success measures.',
          sourceAction: IncomingTalentPromotionImplementationAction.titleUpdate,
          sourceImplementationStatus:
              IncomingTalentPromotionImplementationStatus.completed,
          sourceOutcome: IncomingTalentPromotionDecisionOutcome.promoteNow,
          sourceReadinessRating:
              IncomingTalentPromotionReadinessRating.readyNow,
          asOfDate: asOfDate,
        ),
      );
}

IncomingTalentCareerPathSupportAction _submitCareerSupportAction(
  ProviderContainer container,
  DateTime asOfDate,
  IncomingTalentActivationOutcomeReview outcome,
) {
  return container
      .read(incomingTalentCareerPathSupportActionsProvider.notifier)
      .submitDraft(
        IncomingTalentCareerPathSupportActionDraft(
          reviewId: 'career-review-${outcome.id}',
          careerPathId: 'career-path-${outcome.id}',
          portfolioId: 'portfolio-${outcome.id}',
          roadmapId: 'roadmap-${outcome.id}',
          candidateId: outcome.candidateId,
          candidateName: outcome.candidateName,
          department: outcome.department,
          targetRole: outcome.role,
          competencyName: '${outcome.role} competency',
          ownerName: outcome.reviewerName,
          actionType: IncomingTalentCareerPathSupportActionType.coaching,
          priority: IncomingTalentCareerPathSupportActionPriority.high,
          status: IncomingTalentCareerPathSupportActionStatus.open,
          dueDate: asOfDate.add(const Duration(days: 7)),
          actionPlan: 'Complete focused manager coaching support.',
          successCriteria: 'Raise competency level with signed evidence.',
          escalationNote: 'Escalate if support progress stalls.',
          sourceDecision: IncomingTalentCareerPathReviewDecision.needsSupport,
          reviewedLevel: 2,
          targetLevel: 4,
          sourceLevelGap: 2,
          asOfDate: asOfDate,
        ),
      );
}

IncomingTalentCareerPathSupportOutcome _submitCareerSupportOutcome(
  ProviderContainer container,
  DateTime asOfDate,
  IncomingTalentActivationOutcomeReview outcome,
) {
  return container
      .read(incomingTalentCareerPathSupportOutcomesProvider.notifier)
      .submitDraft(
        IncomingTalentCareerPathSupportOutcomeDraft(
          actionId: 'resolved-support-${outcome.id}',
          reviewId: 'resolved-review-${outcome.id}',
          careerPathId: 'resolved-career-${outcome.id}',
          portfolioId: 'resolved-portfolio-${outcome.id}',
          roadmapId: 'resolved-roadmap-${outcome.id}',
          candidateId: outcome.candidateId,
          candidateName: outcome.candidateName,
          department: outcome.department,
          targetRole: outcome.role,
          competencyName: '${outcome.role} delivery',
          actionType: IncomingTalentCareerPathSupportActionType.coaching,
          actionPriority: IncomingTalentCareerPathSupportActionPriority.high,
          actionStatus: IncomingTalentCareerPathSupportActionStatus.resolved,
          actionOwnerName: outcome.reviewerName,
          actionPlan: 'Completed manager coaching support.',
          successCriteria: 'Evidence confirms support progress.',
          sourceDecision: IncomingTalentCareerPathReviewDecision.needsSupport,
          reviewedLevelBefore: 2,
          targetLevel: 4,
          sourceLevelGap: 2,
          reviewerName: outcome.reviewerName,
          outcomeDate: asOfDate.add(const Duration(days: 9)),
          decision: IncomingTalentCareerPathSupportOutcomeDecision.monitor,
          residualRisk: IncomingTalentCareerPathSupportOutcomeResidualRisk.high,
          verifiedLevel: 3,
          evidenceSummary: 'Reviewed support evidence with manager.',
          managerNote: 'Manager confirmed progress but residual risk remains.',
          nextReviewAction: 'Keep weekly support review active.',
          nextReviewDate: asOfDate.add(const Duration(days: 23)),
          asOfDate: asOfDate,
        ),
      );
}

IncomingTalentCalibrationReview _submitCalibrationReview(
  ProviderContainer container,
  IncomingTalentCalibrationPacket packet,
) {
  container
      .read(incomingTalentCalibrationReviewDraftProvider.notifier)
      .initializeFromPacket(packet);
  return container
      .read(incomingTalentCalibrationReviewsProvider.notifier)
      .submitDraft(
        container.read(incomingTalentCalibrationReviewDraftProvider),
      );
}
