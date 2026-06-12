import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_risk_council_agenda_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_risk_council_commitment_log_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_risk_council_readiness_checklist_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_risk_council_agenda_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_risk_council_commitment_log_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_risk_council_readiness_checklist_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test(
    'risk council commitment log creates publish commitments from agenda',
    () {
      final asOfDate = DateTime(2026, 6, 6);
      final container = _container(
        asOfDate: asOfDate,
        agendaItems: [
          _agendaItem(
            id: 'leadership',
            section:
                IncomingTalentRiskCouncilAgendaSection.leadershipEscalation,
            priority: IncomingTalentRiskCouncilAgendaPriority.critical,
            sourceCount: 2,
            readinessTaskIds: const [
              'readiness:blocked',
              'readiness:escalation',
            ],
          ),
          _agendaItem(
            id: 'decision',
            section: IncomingTalentRiskCouncilAgendaSection.decisionDocket,
            priority: IncomingTalentRiskCouncilAgendaPriority.critical,
            sourceCount: 2,
            readinessTaskIds: const ['readiness:decision'],
          ),
          _agendaItem(
            id: 'execution',
            section: IncomingTalentRiskCouncilAgendaSection.executionReview,
            priority: IncomingTalentRiskCouncilAgendaPriority.normal,
            sourceCount: 3,
            readinessTaskIds: const ['readiness:execution'],
          ),
          _agendaItem(
            id: 'close',
            section: IncomingTalentRiskCouncilAgendaSection.commitmentClose,
            priority: IncomingTalentRiskCouncilAgendaPriority.normal,
            sourceCount: 4,
            readinessTaskIds: const [
              'readiness:blocked',
              'readiness:decision',
              'readiness:execution',
            ],
          ),
        ],
        readinessItems: [
          _readinessItem(
            asOfDate,
            id: 'blocked',
            category:
                IncomingTalentRiskCouncilReadinessChecklistCategory
                    .evidenceReview,
            status: IncomingTalentRiskCouncilReadinessChecklistStatus.blocked,
            dueOffset: 2,
          ),
          _readinessItem(
            asOfDate,
            id: 'escalation',
            category:
                IncomingTalentRiskCouncilReadinessChecklistCategory
                    .escalationPrep,
            dueOffset: 1,
          ),
          _readinessItem(
            asOfDate,
            id: 'decision',
            category:
                IncomingTalentRiskCouncilReadinessChecklistCategory
                    .decisionPrep,
            dueOffset: 0,
          ),
          _readinessItem(
            asOfDate,
            id: 'execution',
            category:
                IncomingTalentRiskCouncilReadinessChecklistCategory
                    .evidenceReview,
            status: IncomingTalentRiskCouncilReadinessChecklistStatus.overdue,
            dueOffset: -1,
          ),
        ],
      );
      addTearDown(container.dispose);

      final items = container.read(
        incomingTalentRiskCouncilCommitmentLogItemsProvider,
      );
      final summary = container.read(
        incomingTalentRiskCouncilCommitmentLogSummaryProvider,
      );

      expect(items, hasLength(4));
      expect(items.first.title, 'Log leadership unblock decision');
      expect(
        items.first.status,
        IncomingTalentRiskCouncilCommitmentLogStatus.blocked,
      );
      expect(
        items.map((item) => item.status),
        contains(IncomingTalentRiskCouncilCommitmentLogStatus.needsDecision),
      );
      expect(
        items.map((item) => item.status),
        contains(IncomingTalentRiskCouncilCommitmentLogStatus.needsEvidence),
      );
      expect(
        items.last.status,
        IncomingTalentRiskCouncilCommitmentLogStatus.needsOwner,
      );
      expect(summary.totalCount, 4);
      expect(summary.blockedCount, 1);
      expect(summary.needsDecisionCount, 1);
      expect(summary.needsEvidenceCount, 1);
      expect(summary.needsOwnerCount, 1);
      expect(summary.attentionCount, 4);
      expect(summary.publishableRatio, 0);
      expect(
        summary.nextAction,
        'Resolve 1 blocked council commitment before publishing.',
      );
    },
  );

  test('risk council commitment log clears when agenda is clear', () {
    final asOfDate = DateTime(2026, 6, 6);
    final container = _container(
      asOfDate: asOfDate,
      agendaItems: [
        _agendaItem(
          id: 'clear',
          section: IncomingTalentRiskCouncilAgendaSection.clear,
          priority: IncomingTalentRiskCouncilAgendaPriority.clear,
          sourceCount: 0,
          readinessTaskIds: const ['readiness:clear'],
        ),
      ],
      readinessItems: [
        _readinessItem(
          asOfDate,
          id: 'clear',
          category:
              IncomingTalentRiskCouncilReadinessChecklistCategory.councilPack,
          status: IncomingTalentRiskCouncilReadinessChecklistStatus.ready,
          dueOffset: 0,
        ),
      ],
    );
    addTearDown(container.dispose);

    final items = container.read(
      incomingTalentRiskCouncilCommitmentLogItemsProvider,
    );
    final summary = container.read(
      incomingTalentRiskCouncilCommitmentLogSummaryProvider,
    );

    expect(items, hasLength(1));
    expect(
      items.single.status,
      IncomingTalentRiskCouncilCommitmentLogStatus.clear,
    );
    expect(items.single.ownerName, 'Talent Operations');
    expect(summary.clearCount, 1);
    expect(summary.attentionCount, 0);
    expect(summary.publishableRatio, 1);
    expect(summary.nextAction, 'Commitment log is ready to publish.');
  });
}

ProviderContainer _container({
  required DateTime asOfDate,
  required List<IncomingTalentRiskCouncilAgendaItem> agendaItems,
  required List<IncomingTalentRiskCouncilReadinessChecklistItem> readinessItems,
}) {
  return ProviderContainer(
    overrides: [
      talentAsOfDateProvider.overrideWithValue(asOfDate),
      incomingTalentRiskCouncilAgendaItemsProvider.overrideWithValue(
        agendaItems,
      ),
      incomingTalentRiskCouncilReadinessChecklistItemsProvider
          .overrideWithValue(readinessItems),
    ],
  );
}

IncomingTalentRiskCouncilAgendaItem _agendaItem({
  required String id,
  required IncomingTalentRiskCouncilAgendaSection section,
  required IncomingTalentRiskCouncilAgendaPriority priority,
  required int sourceCount,
  required List<String> readinessTaskIds,
}) {
  return IncomingTalentRiskCouncilAgendaItem(
    id: 'agenda:$id',
    section: section,
    priority: priority,
    title: 'Agenda section',
    objective: 'Review talent risk council work.',
    targetOutcome: 'Council commitment is ready.',
    facilitatorName: 'Talent Operations',
    timeboxMinutes: 10,
    sourceCount: sourceCount,
    readinessTaskIds: readinessTaskIds,
  );
}

IncomingTalentRiskCouncilReadinessChecklistItem _readinessItem(
  DateTime asOfDate, {
  required String id,
  required IncomingTalentRiskCouncilReadinessChecklistCategory category,
  IncomingTalentRiskCouncilReadinessChecklistStatus status =
      IncomingTalentRiskCouncilReadinessChecklistStatus.needsPrep,
  required int dueOffset,
}) {
  return IncomingTalentRiskCouncilReadinessChecklistItem(
    id: 'readiness:$id',
    category: category,
    status: status,
    title: 'Readiness task',
    detail: 'Prepare talent risk council evidence.',
    ownerName: 'Talent Operations',
    dueDate: asOfDate.add(Duration(days: dueOffset)),
    sourceCount: 1,
  );
}
