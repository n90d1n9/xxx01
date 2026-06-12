import 'incoming_talent_risk_council_agenda_item.dart';
import 'incoming_talent_risk_council_brief.dart';
import 'incoming_talent_risk_council_readiness_checklist_item.dart';

List<IncomingTalentRiskCouncilAgendaItem> buildIncomingTalentRiskCouncilAgenda({
  required IncomingTalentRiskCouncilBrief brief,
  required List<IncomingTalentRiskCouncilReadinessChecklistItem> readinessItems,
}) {
  final attentionTaskIds =
      readinessItems.where((item) => item.needsAttention).map((item) {
        return item.id;
      }).toList();

  if (brief.status == IncomingTalentRiskCouncilBriefStatus.clear &&
      attentionTaskIds.isEmpty) {
    return [
      IncomingTalentRiskCouncilAgendaItem(
        id: 'risk-council-agenda:clear',
        section: IncomingTalentRiskCouncilAgendaSection.clear,
        priority: IncomingTalentRiskCouncilAgendaPriority.clear,
        title: 'Council calibration checkpoint',
        objective:
            'Confirm no new talent risk signals need a leadership decision.',
        targetOutcome: 'Clear council pack and confirm the next review date.',
        facilitatorName: 'Talent Operations',
        timeboxMinutes: 10,
        sourceCount: 0,
        readinessTaskIds: readinessItems.map((item) => item.id).toList(),
      ),
    ];
  }

  final items = <IncomingTalentRiskCouncilAgendaItem>[];
  final leadershipCount = brief.blockedSlaCount + brief.escalatedSlaCount;

  if (leadershipCount > 0) {
    items.add(
      IncomingTalentRiskCouncilAgendaItem(
        id: 'risk-council-agenda:leadership-escalation',
        section: IncomingTalentRiskCouncilAgendaSection.leadershipEscalation,
        priority: IncomingTalentRiskCouncilAgendaPriority.critical,
        title: 'Leadership unblock triage',
        objective:
            'Resolve blocked and escalated talent risk work before it stalls development movement.',
        targetOutcome: 'Named unblock owner, decision ask, and recovery date.',
        facilitatorName: 'HR Leadership',
        timeboxMinutes: _timebox(leadershipCount, base: 12, max: 20),
        sourceCount: leadershipCount,
        readinessTaskIds: _readinessTaskIds(
          readinessItems,
          statuses: const [
            IncomingTalentRiskCouncilReadinessChecklistStatus.blocked,
          ],
          categories: const [
            IncomingTalentRiskCouncilReadinessChecklistCategory.escalationPrep,
          ],
        ),
      ),
    );
  }

  if (brief.overdueSlaCount > 0) {
    items.add(
      IncomingTalentRiskCouncilAgendaItem(
        id: 'risk-council-agenda:sla-recovery',
        section: IncomingTalentRiskCouncilAgendaSection.slaRecovery,
        priority: IncomingTalentRiskCouncilAgendaPriority.high,
        title: 'Overdue SLA recovery',
        objective:
            'Review overdue talent risk evidence and agree recovery moves.',
        targetOutcome: 'Updated evidence owner and revised completion date.',
        facilitatorName: 'Talent Operations',
        timeboxMinutes: _timebox(brief.overdueSlaCount, base: 8, max: 16),
        sourceCount: brief.overdueSlaCount,
        readinessTaskIds: _readinessTaskIds(
          readinessItems,
          statuses: const [
            IncomingTalentRiskCouncilReadinessChecklistStatus.overdue,
          ],
        ),
      ),
    );
  }

  if (brief.pendingDecisionCount > 0) {
    items.add(
      IncomingTalentRiskCouncilAgendaItem(
        id: 'risk-council-agenda:decision-docket',
        section: IncomingTalentRiskCouncilAgendaSection.decisionDocket,
        priority:
            brief.criticalDecisionCount > 0
                ? IncomingTalentRiskCouncilAgendaPriority.critical
                : IncomingTalentRiskCouncilAgendaPriority.high,
        title: 'Talent risk decision docket',
        objective:
            'Convert pending council items into accountable development decisions.',
        targetOutcome: 'Approved decision, accountable owner, and due date.',
        facilitatorName: 'Talent Council Chair',
        timeboxMinutes: _timebox(brief.pendingDecisionCount, base: 10, max: 24),
        sourceCount: brief.pendingDecisionCount,
        readinessTaskIds: _readinessTaskIds(
          readinessItems,
          categories: const [
            IncomingTalentRiskCouncilReadinessChecklistCategory.decisionPrep,
          ],
        ),
      ),
    );
  }

  if (brief.waitingFollowUpCount > 0) {
    items.add(
      IncomingTalentRiskCouncilAgendaItem(
        id: 'risk-council-agenda:follow-up-planning',
        section: IncomingTalentRiskCouncilAgendaSection.followUpPlanning,
        priority: IncomingTalentRiskCouncilAgendaPriority.normal,
        title: 'Follow-up plan creation',
        objective:
            'Create accountable follow-up plans for decisions already recorded.',
        targetOutcome: 'Follow-up owner, action plan, and check-in cadence.',
        facilitatorName: 'Talent Partners',
        timeboxMinutes: _timebox(brief.waitingFollowUpCount, base: 6, max: 14),
        sourceCount: brief.waitingFollowUpCount,
        readinessTaskIds: _readinessTaskIds(
          readinessItems,
          categories: const [
            IncomingTalentRiskCouncilReadinessChecklistCategory
                .followUpPlanning,
          ],
        ),
      ),
    );
  }

  if (brief.dueSoonSlaCount > 0) {
    items.add(
      IncomingTalentRiskCouncilAgendaItem(
        id: 'risk-council-agenda:owner-confirmation',
        section: IncomingTalentRiskCouncilAgendaSection.ownerConfirmation,
        priority: IncomingTalentRiskCouncilAgendaPriority.normal,
        title: 'Due-soon owner confirmations',
        objective:
            'Confirm owner updates for talent risk work due in the next seven days.',
        targetOutcome: 'Owner confidence, current status, and next action.',
        facilitatorName: 'Talent Operations',
        timeboxMinutes: _timebox(brief.dueSoonSlaCount, base: 5, max: 12),
        sourceCount: brief.dueSoonSlaCount,
        readinessTaskIds: _readinessTaskIds(
          readinessItems,
          categories: const [
            IncomingTalentRiskCouncilReadinessChecklistCategory
                .ownerConfirmation,
          ],
        ),
      ),
    );
  }

  if (brief.openFollowUpCount > 0) {
    items.add(
      IncomingTalentRiskCouncilAgendaItem(
        id: 'risk-council-agenda:execution-review',
        section: IncomingTalentRiskCouncilAgendaSection.executionReview,
        priority: IncomingTalentRiskCouncilAgendaPriority.normal,
        title: 'Active follow-up execution review',
        objective:
            'Validate follow-up evidence and remove delivery friction for active talent risk actions.',
        targetOutcome: 'Evidence accepted, risk reduced, or escalation raised.',
        facilitatorName: 'Talent Partners',
        timeboxMinutes: _timebox(brief.openFollowUpCount, base: 7, max: 16),
        sourceCount: brief.openFollowUpCount,
        readinessTaskIds: _readinessTaskIds(
          readinessItems,
          statuses: const [
            IncomingTalentRiskCouncilReadinessChecklistStatus.needsPrep,
          ],
          categories: const [
            IncomingTalentRiskCouncilReadinessChecklistCategory.evidenceReview,
          ],
        ),
      ),
    );
  }

  items.add(
    IncomingTalentRiskCouncilAgendaItem(
      id: 'risk-council-agenda:commitment-close',
      section: IncomingTalentRiskCouncilAgendaSection.commitmentClose,
      priority: IncomingTalentRiskCouncilAgendaPriority.normal,
      title: 'Commitment close and owner lock',
      objective:
          'Close the council with confirmed owners, due dates, and follow-up expectations.',
      targetOutcome: 'Council commitment log is ready for follow-through.',
      facilitatorName: 'Talent Operations',
      timeboxMinutes: 5,
      sourceCount: attentionTaskIds.length,
      readinessTaskIds: attentionTaskIds,
    ),
  );

  return items;
}

List<String> _readinessTaskIds(
  List<IncomingTalentRiskCouncilReadinessChecklistItem> items, {
  List<IncomingTalentRiskCouncilReadinessChecklistStatus> statuses = const [],
  List<IncomingTalentRiskCouncilReadinessChecklistCategory> categories =
      const [],
}) {
  return items
      .where((item) {
        final matchesStatus =
            statuses.isEmpty || statuses.contains(item.status);
        final matchesCategory =
            categories.isEmpty || categories.contains(item.category);
        return item.needsAttention && matchesStatus && matchesCategory;
      })
      .map((item) {
        return item.id;
      })
      .toList();
}

int _timebox(int signalCount, {required int base, required int max}) {
  final minutes = base + (signalCount - 1).clamp(0, 99) * 3;
  if (minutes > max) return max;
  return minutes;
}
