import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_profile_timeline_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_risk_council_queue_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_profile_timeline_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_risk_council_queue_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_risk_council_source_filter_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test('talent risk council queue builds resolution review items', () {
    final asOfDate = DateTime(2026, 5, 30);
    final latestEventDate = asOfDate.subtract(const Duration(days: 1));

    final items = buildIncomingTalentRiskCouncilQueue(
      timelines: [
        _timeline(
          asOfDate,
          watchDevelopmentResolutionCount: 1,
          latestEventDate: latestEventDate,
        ),
      ],
      asOfDate: asOfDate,
    );
    final summary = IncomingTalentRiskCouncilQueueSummary.fromItems(items);

    expect(items, hasLength(1));
    expect(
      items.single.category,
      IncomingTalentRiskCouncilQueueCategory.resolutionReview,
    );
    expect(
      items.single.severity,
      IncomingTalentRiskCouncilQueueSeverity.critical,
    );
    expect(items.single.dueDate, latestEventDate);
    expect(
      items.single.recommendedAction,
      'Decide whether to escalate, reopen, or approve monitoring.',
    );
    expect(summary.totalItems, 1);
    expect(summary.criticalCount, 1);
    expect(summary.resolutionReviewCount, 1);
    expect(summary.nextAction, 'Prepare 1 critical talent risks for council.');
  });

  test('talent risk council queue includes promotion resolution reviews', () {
    final asOfDate = DateTime(2026, 5, 30);
    final latestEventDate = asOfDate.subtract(const Duration(days: 2));

    final items = buildIncomingTalentRiskCouncilQueue(
      timelines: [
        _timeline(
          asOfDate,
          watchPromotionResolutionCount: 1,
          latestEventDate: latestEventDate,
          latestEventType:
              IncomingTalentProfileTimelineEventType
                  .promotionFollowUpResolution,
          latestEventTone: IncomingTalentProfileTimelineEventTone.watch,
        ),
      ],
      asOfDate: asOfDate,
    );
    final summary = IncomingTalentRiskCouncilQueueSummary.fromItems(items);

    expect(items, hasLength(1));
    expect(
      items.single.id,
      'risk-council:candidate-001:promotion-resolution-review',
    );
    expect(
      items.single.category,
      IncomingTalentRiskCouncilQueueCategory.resolutionReview,
    );
    expect(items.single.severity, IncomingTalentRiskCouncilQueueSeverity.watch);
    expect(
      items.single.source,
      IncomingTalentRiskCouncilQueueSource.promotionResolutionReview,
    );
    expect(items.single.dueDate, latestEventDate);
    expect(items.single.title, 'Promotion resolution review risk');
    expect(
      items.single.recommendedAction,
      'Decide whether to reopen follow-up, escalate to people panel, or approve monitoring.',
    );
    expect(summary.totalItems, 1);
    expect(summary.watchCount, 1);
    expect(summary.resolutionReviewCount, 1);
    expect(summary.promotionResolutionReviewCount, 1);
    expect(summary.nextAction, 'Review 1 promotion resolution risks.');
  });

  test(
    'talent risk council queue escalates critical promotion resolutions',
    () {
      final asOfDate = DateTime(2026, 5, 30);

      final items = buildIncomingTalentRiskCouncilQueue(
        timelines: [
          _timeline(
            asOfDate,
            watchPromotionResolutionCount: 1,
            latestEventDate: asOfDate,
            latestEventType:
                IncomingTalentProfileTimelineEventType
                    .promotionFollowUpResolution,
            latestEventTone: IncomingTalentProfileTimelineEventTone.critical,
          ),
        ],
        asOfDate: asOfDate,
      );
      final summary = IncomingTalentRiskCouncilQueueSummary.fromItems(items);

      expect(
        items.single.severity,
        IncomingTalentRiskCouncilQueueSeverity.critical,
      );
      expect(summary.criticalCount, 1);
      expect(summary.promotionResolutionReviewCount, 1);
      expect(
        summary.nextAction,
        'Prepare 1 critical talent risks for council.',
      );
    },
  );

  test('talent risk council queue sorts critical high-signal items first', () {
    final asOfDate = DateTime(2026, 5, 30);

    final items = buildIncomingTalentRiskCouncilQueue(
      timelines: [
        _timeline(
          asOfDate,
          candidateId: 'watch-candidate',
          candidateName: 'Watch Candidate',
          openInterventionCount: 1,
        ),
        _timeline(
          asOfDate,
          candidateId: 'program-candidate',
          candidateName: 'Program Candidate',
          programCompletionExtensionCount: 1,
        ),
        _timeline(
          asOfDate,
          candidateId: 'critical-candidate',
          candidateName: 'Critical Candidate',
          openInterventionCount: 3,
        ),
      ],
      asOfDate: asOfDate,
    );

    expect(items.map((item) => item.candidateName), [
      'Critical Candidate',
      'Program Candidate',
      'Watch Candidate',
    ]);
    expect(items.first.signalCount, 3);
    expect(items.first.isCritical, isTrue);
    expect(items.last.severity, IncomingTalentRiskCouncilQueueSeverity.watch);
  });

  test('talent risk council queue provider summarizes filtered timelines', () {
    final asOfDate = DateTime(2026, 5, 30);
    final container = ProviderContainer(
      overrides: [
        talentAsOfDateProvider.overrideWithValue(asOfDate),
        filteredIncomingTalentProfileTimelinesProvider.overrideWithValue([
          _timeline(
            asOfDate,
            candidateId: 'engineering',
            candidateName: 'Fajar Nugroho',
            department: 'Engineering',
            openInterventionCount: 2,
            watchDevelopmentResolutionCount: 1,
          ),
          _timeline(
            asOfDate,
            candidateId: 'finance',
            candidateName: 'Mira Lestari',
            department: 'Finance',
            openCareerSupportCount: 1,
          ),
        ]),
      ],
    );
    addTearDown(container.dispose);

    final items = container.read(incomingTalentRiskCouncilQueueItemsProvider);
    final summary = container.read(
      incomingTalentRiskCouncilQueueSummaryProvider,
    );

    expect(items, hasLength(3));
    expect(summary.totalItems, 3);
    expect(summary.criticalCount, 2);
    expect(summary.watchCount, 1);
    expect(summary.candidateCount, 2);
    expect(summary.departmentCount, 2);
    expect(summary.openActionCount, 2);
    expect(summary.resolutionReviewCount, 1);
  });

  test('talent risk council source filter narrows queue items', () {
    final asOfDate = DateTime(2026, 5, 30);
    final container = ProviderContainer(
      overrides: [
        talentAsOfDateProvider.overrideWithValue(asOfDate),
        filteredIncomingTalentProfileTimelinesProvider.overrideWithValue([
          _timeline(
            asOfDate,
            openInterventionCount: 1,
            watchPromotionResolutionCount: 1,
            latestEventDate: asOfDate,
            latestEventType:
                IncomingTalentProfileTimelineEventType
                    .promotionFollowUpResolution,
          ),
        ]),
      ],
    );
    addTearDown(container.dispose);

    expect(
      container.read(incomingTalentRiskCouncilQueueItemsProvider),
      hasLength(2),
    );

    container
        .read(incomingTalentRiskCouncilSourceFilterProvider.notifier)
        .state = IncomingTalentRiskCouncilQueueSource.promotionResolutionReview;

    final items = container.read(incomingTalentRiskCouncilQueueItemsProvider);
    final summary = container.read(
      incomingTalentRiskCouncilQueueSummaryProvider,
    );

    expect(items, hasLength(1));
    expect(
      items.single.source,
      IncomingTalentRiskCouncilQueueSource.promotionResolutionReview,
    );
    expect(summary.totalItems, 1);
    expect(summary.promotionResolutionReviewCount, 1);
    expect(summary.nextAction, 'Review 1 promotion resolution risks.');
  });
}

IncomingTalentProfileTimeline _timeline(
  DateTime asOfDate, {
  String candidateId = 'candidate-001',
  String candidateName = 'Fajar Nugroho',
  String role = 'Senior Flutter Engineer',
  String department = 'Engineering',
  int openInterventionCount = 0,
  int watchDevelopmentOutcomeCount = 0,
  int openDevelopmentFollowUpCount = 0,
  int watchDevelopmentFollowUpCount = 0,
  int watchDevelopmentResolutionCount = 0,
  int openCareerSupportCount = 0,
  int watchCareerSupportOutcomeCount = 0,
  int programMilestoneRevisionCount = 0,
  int programCompletionExtensionCount = 0,
  int watchPromotionResolutionCount = 0,
  DateTime? latestEventDate,
  IncomingTalentProfileTimelineEventType latestEventType =
      IncomingTalentProfileTimelineEventType.outcome,
  IncomingTalentProfileTimelineEventTone latestEventTone =
      IncomingTalentProfileTimelineEventTone.watch,
}) {
  return IncomingTalentProfileTimeline(
    candidateId: candidateId,
    candidateName: candidateName,
    role: role,
    department: department,
    readinessScore: 72,
    confidenceScore: 3,
    openInterventionCount: openInterventionCount,
    watchDevelopmentOutcomeCount: watchDevelopmentOutcomeCount,
    openDevelopmentFollowUpCount: openDevelopmentFollowUpCount,
    watchDevelopmentFollowUpCount: watchDevelopmentFollowUpCount,
    watchDevelopmentResolutionCount: watchDevelopmentResolutionCount,
    openCareerSupportCount: openCareerSupportCount,
    watchCareerSupportOutcomeCount: watchCareerSupportOutcomeCount,
    programMilestoneRevisionCount: programMilestoneRevisionCount,
    programCompletionExtensionCount: programCompletionExtensionCount,
    watchPromotionResolutionCount: watchPromotionResolutionCount,
    latestCalibrationDecisionLabel: 'Not calibrated',
    nextAction: 'Review profile risk.',
    events:
        latestEventDate == null
            ? const []
            : [
              IncomingTalentProfileTimelineEvent(
                id: 'event-$candidateId',
                candidateId: candidateId,
                candidateName: candidateName,
                role: role,
                department: department,
                type: latestEventType,
                tone: latestEventTone,
                title: 'Risk signal',
                description: 'Council queue source signal.',
                eventDate: latestEventDate,
                statusLabel: 'Watch',
              ),
            ],
  );
}
