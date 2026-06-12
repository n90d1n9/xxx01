import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_risk_council_agenda_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_risk_council_brief_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_risk_council_readiness_checklist_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_risk_council_agenda_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_risk_council_brief_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_risk_council_readiness_checklist_provider.dart';

void main() {
  test('risk council agenda prioritizes leadership and decision sections', () {
    final container = _container(
      brief: _brief(
        status: IncomingTalentRiskCouncilBriefStatus.critical,
        pendingDecisionCount: 2,
        criticalDecisionCount: 1,
        decisionCount: 3,
        openFollowUpCount: 3,
        completedFollowUpCount: 1,
        blockedSlaCount: 1,
        escalatedSlaCount: 1,
        overdueSlaCount: 1,
        dueSoonSlaCount: 2,
        waitingFollowUpCount: 1,
        activeFollowUpCount: 3,
      ),
      readinessItems: [
        _readinessItem(
          id: 'blocked',
          category:
              IncomingTalentRiskCouncilReadinessChecklistCategory
                  .evidenceReview,
          status: IncomingTalentRiskCouncilReadinessChecklistStatus.blocked,
        ),
        _readinessItem(
          id: 'overdue',
          category:
              IncomingTalentRiskCouncilReadinessChecklistCategory
                  .evidenceReview,
          status: IncomingTalentRiskCouncilReadinessChecklistStatus.overdue,
        ),
        _readinessItem(
          id: 'escalation',
          category:
              IncomingTalentRiskCouncilReadinessChecklistCategory
                  .escalationPrep,
        ),
        _readinessItem(
          id: 'decision',
          category:
              IncomingTalentRiskCouncilReadinessChecklistCategory.decisionPrep,
        ),
        _readinessItem(
          id: 'follow-up',
          category:
              IncomingTalentRiskCouncilReadinessChecklistCategory
                  .followUpPlanning,
        ),
        _readinessItem(
          id: 'owner',
          category:
              IncomingTalentRiskCouncilReadinessChecklistCategory
                  .ownerConfirmation,
        ),
        _readinessItem(
          id: 'execution',
          category:
              IncomingTalentRiskCouncilReadinessChecklistCategory
                  .evidenceReview,
        ),
      ],
    );
    addTearDown(container.dispose);

    final items = container.read(incomingTalentRiskCouncilAgendaItemsProvider);
    final summary = container.read(
      incomingTalentRiskCouncilAgendaSummaryProvider,
    );

    expect(items, hasLength(7));
    expect(
      items.first.section,
      IncomingTalentRiskCouncilAgendaSection.leadershipEscalation,
    );
    expect(
      items.first.priority,
      IncomingTalentRiskCouncilAgendaPriority.critical,
    );
    expect(
      items.map((item) => item.section),
      contains(IncomingTalentRiskCouncilAgendaSection.decisionDocket),
    );
    expect(
      items.last.section,
      IncomingTalentRiskCouncilAgendaSection.commitmentClose,
    );
    expect(summary.totalCount, 7);
    expect(summary.criticalCount, 2);
    expect(summary.highCount, 1);
    expect(summary.normalCount, 4);
    expect(summary.readinessTaskCount, 7);
    expect(summary.totalTimeboxMinutes, greaterThan(50));
    expect(summary.nextAction, 'Start council with 2 critical agenda items.');
  });

  test('risk council agenda clears when there is no active work', () {
    final container = _container(
      brief: _brief(status: IncomingTalentRiskCouncilBriefStatus.clear),
      readinessItems: [
        _readinessItem(
          id: 'clear',
          category:
              IncomingTalentRiskCouncilReadinessChecklistCategory.councilPack,
          status: IncomingTalentRiskCouncilReadinessChecklistStatus.ready,
        ),
      ],
    );
    addTearDown(container.dispose);

    final items = container.read(incomingTalentRiskCouncilAgendaItemsProvider);
    final summary = container.read(
      incomingTalentRiskCouncilAgendaSummaryProvider,
    );

    expect(items, hasLength(1));
    expect(items.single.section, IncomingTalentRiskCouncilAgendaSection.clear);
    expect(
      items.single.priority,
      IncomingTalentRiskCouncilAgendaPriority.clear,
    );
    expect(items.single.timeboxMinutes, 10);
    expect(summary.clearCount, 1);
    expect(summary.criticalCount, 0);
    expect(summary.totalTimeboxMinutes, 10);
    expect(
      summary.nextAction,
      'Council agenda is clear; confirm the next review date.',
    );
  });
}

ProviderContainer _container({
  required IncomingTalentRiskCouncilBrief brief,
  required List<IncomingTalentRiskCouncilReadinessChecklistItem> readinessItems,
}) {
  return ProviderContainer(
    overrides: [
      incomingTalentRiskCouncilBriefProvider.overrideWithValue(brief),
      incomingTalentRiskCouncilReadinessChecklistItemsProvider
          .overrideWithValue(readinessItems),
    ],
  );
}

IncomingTalentRiskCouncilBrief _brief({
  required IncomingTalentRiskCouncilBriefStatus status,
  int pendingDecisionCount = 0,
  int criticalDecisionCount = 0,
  int decisionCount = 0,
  int openFollowUpCount = 0,
  int completedFollowUpCount = 0,
  int blockedSlaCount = 0,
  int escalatedSlaCount = 0,
  int overdueSlaCount = 0,
  int dueSoonSlaCount = 0,
  int waitingFollowUpCount = 0,
  int activeFollowUpCount = 0,
}) {
  return IncomingTalentRiskCouncilBrief(
    status: status,
    pendingDecisionCount: pendingDecisionCount,
    criticalDecisionCount: criticalDecisionCount,
    decisionCount: decisionCount,
    openFollowUpCount: openFollowUpCount,
    completedFollowUpCount: completedFollowUpCount,
    blockedSlaCount: blockedSlaCount,
    escalatedSlaCount: escalatedSlaCount,
    overdueSlaCount: overdueSlaCount,
    dueSoonSlaCount: dueSoonSlaCount,
    waitingFollowUpCount: waitingFollowUpCount,
    activeFollowUpCount: activeFollowUpCount,
    readinessRatio: 1,
    nextAction: 'Brief next action.',
    insights: const [],
  );
}

IncomingTalentRiskCouncilReadinessChecklistItem _readinessItem({
  required String id,
  required IncomingTalentRiskCouncilReadinessChecklistCategory category,
  IncomingTalentRiskCouncilReadinessChecklistStatus status =
      IncomingTalentRiskCouncilReadinessChecklistStatus.needsPrep,
}) {
  return IncomingTalentRiskCouncilReadinessChecklistItem(
    id: 'readiness:$id',
    category: category,
    status: status,
    title: 'Readiness task',
    detail: 'Prepare talent risk council evidence.',
    ownerName: 'Talent Operations',
    dueDate: DateTime(2026, 6, 6),
    sourceCount: 1,
  );
}
