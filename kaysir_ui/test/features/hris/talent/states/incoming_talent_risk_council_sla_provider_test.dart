import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_risk_council_decision_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_risk_council_follow_up_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_risk_council_queue_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_risk_council_sla_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_risk_council_source_pressure.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_risk_council_decision_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_risk_council_follow_up_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_risk_council_sla_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_risk_council_source_pressure_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test('risk council SLA dashboard ranks active work and summarizes', () {
    final asOfDate = DateTime(2026, 6, 6);
    final container = _container(
      asOfDate,
      queueItems: [
        _queueItem(
          asOfDate,
          id: 'queue-overdue',
          candidateName: 'Queue Candidate',
          department: 'Finance',
          dueOffset: -1,
          severity: IncomingTalentRiskCouncilQueueSeverity.critical,
        ),
      ],
      decisions: [
        _decision(
          asOfDate,
          id: 'decision-escalated',
          candidateName: 'Decision Candidate',
          department: 'People',
          outcome: IncomingTalentRiskCouncilDecisionOutcome.escalatePeopleBoard,
          followUpOffset: 7,
        ),
      ],
      followUps: [
        _followUp(
          asOfDate,
          id: 'blocked-follow-up',
          candidateName: 'Blocked Candidate',
          department: 'Operations',
          status: IncomingTalentRiskCouncilFollowUpStatus.blocked,
          dueOffset: 10,
        ),
        _followUp(
          asOfDate,
          id: 'planned-follow-up',
          candidateName: 'Planned Candidate',
          department: 'Product',
          status: IncomingTalentRiskCouncilFollowUpStatus.planned,
          dueOffset: 5,
        ),
      ],
    );
    addTearDown(container.dispose);

    final items = container.read(incomingTalentRiskCouncilSlaItemsProvider);
    final summary = container.read(incomingTalentRiskCouncilSlaSummaryProvider);

    expect(items.map((item) => item.status).take(3), [
      IncomingTalentRiskCouncilSlaStatus.blocked,
      IncomingTalentRiskCouncilSlaStatus.escalated,
      IncomingTalentRiskCouncilSlaStatus.overdue,
    ]);
    expect(summary.totalCount, 4);
    expect(summary.blockedCount, 1);
    expect(summary.escalatedCount, 1);
    expect(summary.overdueCount, 1);
    expect(summary.dueSoonCount, 1);
    expect(summary.waitingDecisionCount, 1);
    expect(summary.waitingFollowUpCount, 1);
    expect(summary.activeFollowUpCount, 2);
    expect(summary.nextAction, 'Unblock 1 talent risk SLA item.');
  });

  test(
    'risk council SLA dashboard follows department and attention filters',
    () {
      final asOfDate = DateTime(2026, 6, 6);
      final container = _container(
        asOfDate,
        queueItems: [
          _queueItem(
            asOfDate,
            id: 'engineering',
            candidateName: 'Fajar Nugroho',
            department: 'Engineering',
            dueOffset: 1,
            severity: IncomingTalentRiskCouncilQueueSeverity.critical,
          ),
        ],
        decisions: [
          _decision(
            asOfDate,
            id: 'finance-decision',
            candidateName: 'Mira Lestari',
            department: 'Finance',
            outcome:
                IncomingTalentRiskCouncilDecisionOutcome.escalatePeopleBoard,
            followUpOffset: 7,
          ),
        ],
        followUps: [
          _followUp(
            asOfDate,
            id: 'finance-follow-up',
            candidateName: 'Mira Lestari',
            department: 'Finance',
            status: IncomingTalentRiskCouncilFollowUpStatus.planned,
            dueOffset: 20,
            sourceSeverity: IncomingTalentRiskCouncilQueueSeverity.watch,
            outcome: IncomingTalentRiskCouncilDecisionOutcome.closeRisk,
          ),
        ],
      );
      addTearDown(container.dispose);

      container.read(talentDepartmentProvider.notifier).state = 'Finance';
      container.read(talentNeedsAttentionProvider.notifier).state = true;

      final items = container.read(incomingTalentRiskCouncilSlaItemsProvider);
      final summary = container.read(
        incomingTalentRiskCouncilSlaSummaryProvider,
      );

      expect(items.map((item) => item.source), [
        IncomingTalentRiskCouncilSlaSource.councilFollowUp,
      ]);
      expect(summary.totalCount, 1);
      expect(summary.escalatedCount, 1);
      expect(summary.waitingFollowUpCount, 1);
      expect(summary.nextAction, 'Track 1 escalated talent risk SLA item.');
    },
  );

  test('risk council source pressure groups SLA items by original source', () {
    final asOfDate = DateTime(2026, 6, 6);
    final container = _container(
      asOfDate,
      queueItems: [
        _queueItem(
          asOfDate,
          id: 'development-overdue',
          candidateName: 'Queue Candidate',
          department: 'Finance',
          dueOffset: -1,
          severity: IncomingTalentRiskCouncilQueueSeverity.critical,
          source: IncomingTalentRiskCouncilQueueSource.developmentFollowUp,
        ),
      ],
      decisions: [
        _decision(
          asOfDate,
          id: 'promotion-escalated',
          candidateName: 'Decision Candidate',
          department: 'People',
          outcome: IncomingTalentRiskCouncilDecisionOutcome.escalatePeopleBoard,
          followUpOffset: 7,
          source:
              IncomingTalentRiskCouncilQueueSource.promotionResolutionReview,
        ),
      ],
      followUps: [
        _followUp(
          asOfDate,
          id: 'promotion-follow-up',
          candidateName: 'Follow-up Candidate',
          department: 'People',
          status: IncomingTalentRiskCouncilFollowUpStatus.planned,
          dueOffset: 5,
          sourceSeverity: IncomingTalentRiskCouncilQueueSeverity.watch,
          outcome: IncomingTalentRiskCouncilDecisionOutcome.closeRisk,
          source:
              IncomingTalentRiskCouncilQueueSource.promotionResolutionReview,
        ),
      ],
    );
    addTearDown(container.dispose);

    final pressures = container.read(
      incomingTalentRiskCouncilSourcePressureProvider,
    );
    final promotionPressure = pressures.first;
    final developmentPressure = pressures.last;

    expect(pressures, hasLength(2));
    expect(
      promotionPressure.source,
      IncomingTalentRiskCouncilQueueSource.promotionResolutionReview,
    );
    expect(
      promotionPressure.level,
      IncomingTalentRiskCouncilSourcePressureLevel.critical,
    );
    expect(promotionPressure.totalCount, 2);
    expect(promotionPressure.escalatedCount, 1);
    expect(promotionPressure.dueSoonCount, 1);
    expect(promotionPressure.waitingFollowUpCount, 1);
    expect(promotionPressure.activeFollowUpCount, 1);
    expect(
      promotionPressure.nextAction,
      'Track 1 escalated promotion resolution review SLA item.',
    );
    expect(
      developmentPressure.source,
      IncomingTalentRiskCouncilQueueSource.developmentFollowUp,
    );
    expect(developmentPressure.overdueCount, 1);
    expect(
      developmentPressure.nextAction,
      'Recover 1 overdue development follow-up SLA item.',
    );
  });
}

ProviderContainer _container(
  DateTime asOfDate, {
  List<IncomingTalentRiskCouncilQueueItem> queueItems = const [],
  List<IncomingTalentRiskCouncilDecision> decisions = const [],
  List<IncomingTalentRiskCouncilFollowUp> followUps = const [],
}) {
  return ProviderContainer(
    overrides: [
      talentAsOfDateProvider.overrideWithValue(asOfDate),
      decisionReadyTalentRiskCouncilQueueItemsProvider.overrideWithValue(
        queueItems,
      ),
      followUpReadyTalentRiskCouncilDecisionsProvider.overrideWithValue(
        decisions,
      ),
      filteredIncomingTalentRiskCouncilFollowUpsProvider.overrideWithValue(
        followUps,
      ),
    ],
  );
}

IncomingTalentRiskCouncilQueueItem _queueItem(
  DateTime asOfDate, {
  required String id,
  required String candidateName,
  required String department,
  required int dueOffset,
  required IncomingTalentRiskCouncilQueueSeverity severity,
  IncomingTalentRiskCouncilQueueSource source =
      IncomingTalentRiskCouncilQueueSource.general,
}) {
  return IncomingTalentRiskCouncilQueueItem(
    id: 'risk-queue:$id',
    candidateId: 'candidate-$id',
    candidateName: candidateName,
    role: 'Senior Analyst',
    department: department,
    category: IncomingTalentRiskCouncilQueueCategory.followUp,
    severity: severity,
    title: '$candidateName needs council decision',
    detail:
        'Council has enough risk evidence to determine the next accountable action.',
    recommendedAction:
        'Confirm council decision, owner, follow-up date, and minutes note.',
    dueDate: asOfDate.add(Duration(days: dueOffset)),
    signalCount:
        severity == IncomingTalentRiskCouncilQueueSeverity.critical ? 3 : 1,
    source: source,
  );
}

IncomingTalentRiskCouncilDecision _decision(
  DateTime asOfDate, {
  required String id,
  required String candidateName,
  required String department,
  required IncomingTalentRiskCouncilDecisionOutcome outcome,
  required int followUpOffset,
  IncomingTalentRiskCouncilQueueSource source =
      IncomingTalentRiskCouncilQueueSource.general,
}) {
  return IncomingTalentRiskCouncilDecision(
    id: 'decision:$id',
    queueItemId: 'risk-queue:$id',
    candidateId: 'candidate-$id',
    candidateName: candidateName,
    role: 'Senior Analyst',
    department: department,
    category: IncomingTalentRiskCouncilQueueCategory.followUp,
    sourceSeverity: IncomingTalentRiskCouncilQueueSeverity.critical,
    source: source,
    decisionMakerName: 'Talent Council',
    ownerName: '$department Talent Partner',
    decisionDate: asOfDate,
    outcome: outcome,
    commitmentSummary:
        '$candidateName council commitment is ready for follow-up.',
    minutesNote: '$candidateName council minutes are ready.',
    followUpDate: asOfDate.add(Duration(days: followUpOffset)),
    createdAt: asOfDate,
    signalCount: 3,
  );
}

IncomingTalentRiskCouncilFollowUp _followUp(
  DateTime asOfDate, {
  required String id,
  required String candidateName,
  required String department,
  required IncomingTalentRiskCouncilFollowUpStatus status,
  required int dueOffset,
  IncomingTalentRiskCouncilQueueSeverity sourceSeverity =
      IncomingTalentRiskCouncilQueueSeverity.critical,
  IncomingTalentRiskCouncilDecisionOutcome outcome =
      IncomingTalentRiskCouncilDecisionOutcome.assignOwner,
  IncomingTalentRiskCouncilQueueSource source =
      IncomingTalentRiskCouncilQueueSource.general,
}) {
  return IncomingTalentRiskCouncilFollowUp(
    id: 'follow-up:$id',
    decisionId: 'decision:$id',
    queueItemId: 'risk-queue:$id',
    candidateId: 'candidate-$id',
    candidateName: candidateName,
    role: 'Senior Analyst',
    department: department,
    decisionMakerName: 'Talent Council',
    followUpOwnerName: '$department Talent Partner',
    outcome: outcome,
    category: IncomingTalentRiskCouncilQueueCategory.followUp,
    sourceSeverity: sourceSeverity,
    source: source,
    followUpType: IncomingTalentRiskCouncilFollowUpType.actionCheckpoint,
    status: status,
    dueDate: asOfDate.add(Duration(days: dueOffset)),
    actionPlan: '$candidateName follow-up action plan is active.',
    successCriteria: '$candidateName success criteria is measurable.',
    blockerNote: '',
    escalationReason: '',
    createdAt: asOfDate,
    signalCount:
        sourceSeverity == IncomingTalentRiskCouncilQueueSeverity.critical
            ? 3
            : 1,
  );
}
