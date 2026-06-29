import 'incoming_talent_risk_council_brief.dart';
import 'incoming_talent_risk_council_readiness_checklist_item.dart';
import 'incoming_talent_risk_council_sla_item.dart';

List<IncomingTalentRiskCouncilReadinessChecklistItem>
buildIncomingTalentRiskCouncilReadinessChecklist({
  required IncomingTalentRiskCouncilBrief brief,
  required List<IncomingTalentRiskCouncilSlaItem> slaItems,
  required DateTime asOfDate,
}) {
  final items = <IncomingTalentRiskCouncilReadinessChecklistItem>[
    if (brief.blockedSlaCount > 0)
      IncomingTalentRiskCouncilReadinessChecklistItem(
        id: 'risk-council-readiness:blocked-sla',
        category:
            IncomingTalentRiskCouncilReadinessChecklistCategory.evidenceReview,
        status: IncomingTalentRiskCouncilReadinessChecklistStatus.blocked,
        title: 'Unblock council-critical SLA work',
        detail:
            '${brief.blockedSlaCount} blocked talent risk SLA ${_plural(brief.blockedSlaCount, 'item')} need an owner unblock plan before council.',
        ownerName: 'Talent Operations',
        dueDate:
            _earliestDueDate(
              slaItems,
              IncomingTalentRiskCouncilSlaStatus.blocked,
            ) ??
            asOfDate,
        sourceCount: brief.blockedSlaCount,
      ),
    if (brief.overdueSlaCount > 0)
      IncomingTalentRiskCouncilReadinessChecklistItem(
        id: 'risk-council-readiness:overdue-sla',
        category:
            IncomingTalentRiskCouncilReadinessChecklistCategory.evidenceReview,
        status: IncomingTalentRiskCouncilReadinessChecklistStatus.overdue,
        title: 'Recover overdue council evidence',
        detail:
            '${brief.overdueSlaCount} overdue talent risk SLA ${_plural(brief.overdueSlaCount, 'item')} need updated evidence or recovery notes.',
        ownerName: 'Talent Operations',
        dueDate:
            _earliestDueDate(
              slaItems,
              IncomingTalentRiskCouncilSlaStatus.overdue,
            ) ??
            asOfDate,
        sourceCount: brief.overdueSlaCount,
      ),
    if (brief.escalatedSlaCount > 0)
      IncomingTalentRiskCouncilReadinessChecklistItem(
        id: 'risk-council-readiness:escalations',
        category:
            IncomingTalentRiskCouncilReadinessChecklistCategory.escalationPrep,
        status: IncomingTalentRiskCouncilReadinessChecklistStatus.needsPrep,
        title: 'Prepare people-leadership escalation pack',
        detail:
            '${brief.escalatedSlaCount} escalated talent risk SLA ${_plural(brief.escalatedSlaCount, 'item')} need a decision ask, context, and owner recommendation.',
        ownerName: 'HR Leadership',
        dueDate:
            _earliestDueDate(
              slaItems,
              IncomingTalentRiskCouncilSlaStatus.escalated,
            ) ??
            asOfDate,
        sourceCount: brief.escalatedSlaCount,
      ),
    if (brief.pendingDecisionCount > 0)
      IncomingTalentRiskCouncilReadinessChecklistItem(
        id: 'risk-council-readiness:decision-docket',
        category:
            IncomingTalentRiskCouncilReadinessChecklistCategory.decisionPrep,
        status: IncomingTalentRiskCouncilReadinessChecklistStatus.needsPrep,
        title: 'Prepare decision docket',
        detail:
            '${brief.pendingDecisionCount} pending council ${_plural(brief.pendingDecisionCount, 'decision')} need options, owner recommendation, and due date.',
        ownerName: 'Talent Council',
        dueDate:
            _earliestDueDate(
              slaItems,
              IncomingTalentRiskCouncilSlaStatus.dueSoon,
              source: IncomingTalentRiskCouncilSlaSource.councilDecision,
            ) ??
            asOfDate,
        sourceCount: brief.pendingDecisionCount,
      ),
    if (brief.waitingFollowUpCount > 0)
      IncomingTalentRiskCouncilReadinessChecklistItem(
        id: 'risk-council-readiness:follow-up-creation',
        category:
            IncomingTalentRiskCouncilReadinessChecklistCategory
                .followUpPlanning,
        status: IncomingTalentRiskCouncilReadinessChecklistStatus.needsPrep,
        title: 'Create follow-up plans for recorded decisions',
        detail:
            '${brief.waitingFollowUpCount} recorded ${_plural(brief.waitingFollowUpCount, 'decision')} need accountable follow-up plans.',
        ownerName: 'Talent Partners',
        dueDate:
            _earliestDueDate(
              slaItems,
              IncomingTalentRiskCouncilSlaStatus.dueSoon,
              source: IncomingTalentRiskCouncilSlaSource.councilFollowUp,
            ) ??
            asOfDate,
        sourceCount: brief.waitingFollowUpCount,
      ),
    if (brief.dueSoonSlaCount > 0)
      IncomingTalentRiskCouncilReadinessChecklistItem(
        id: 'risk-council-readiness:due-soon',
        category:
            IncomingTalentRiskCouncilReadinessChecklistCategory
                .ownerConfirmation,
        status: IncomingTalentRiskCouncilReadinessChecklistStatus.needsPrep,
        title: 'Confirm due-soon owner updates',
        detail:
            '${brief.dueSoonSlaCount} talent risk SLA ${_plural(brief.dueSoonSlaCount, 'item')} are due within seven days and need owner updates.',
        ownerName: 'Talent Partners',
        dueDate:
            _earliestDueDate(
              slaItems,
              IncomingTalentRiskCouncilSlaStatus.dueSoon,
            ) ??
            asOfDate,
        sourceCount: brief.dueSoonSlaCount,
      ),
    if (brief.openFollowUpCount > 0)
      IncomingTalentRiskCouncilReadinessChecklistItem(
        id: 'risk-council-readiness:open-follow-ups',
        category:
            IncomingTalentRiskCouncilReadinessChecklistCategory.evidenceReview,
        status: IncomingTalentRiskCouncilReadinessChecklistStatus.needsPrep,
        title: 'Validate active follow-up evidence',
        detail:
            '${brief.openFollowUpCount} active talent risk ${_plural(brief.openFollowUpCount, 'follow-up')} need current evidence before council.',
        ownerName: 'Talent Operations',
        dueDate:
            _earliestDueDate(
              slaItems,
              IncomingTalentRiskCouncilSlaStatus.waiting,
              source: IncomingTalentRiskCouncilSlaSource.followUpExecution,
            ) ??
            asOfDate,
        sourceCount: brief.openFollowUpCount,
      ),
  ];

  if (items.isEmpty) {
    return [
      IncomingTalentRiskCouncilReadinessChecklistItem(
        id: 'risk-council-readiness:clear',
        category:
            IncomingTalentRiskCouncilReadinessChecklistCategory.councilPack,
        status: IncomingTalentRiskCouncilReadinessChecklistStatus.ready,
        title: 'Council pack is ready',
        detail:
            'No active talent risk council preparation tasks need leadership attention.',
        ownerName: 'Talent Operations',
        dueDate: asOfDate,
        sourceCount: 0,
      ),
    ];
  }

  items.sort(_compareReadinessItems);
  return items;
}

int _compareReadinessItems(
  IncomingTalentRiskCouncilReadinessChecklistItem left,
  IncomingTalentRiskCouncilReadinessChecklistItem right,
) {
  final urgency = left.urgencyRank.compareTo(right.urgencyRank);
  if (urgency != 0) return urgency;

  final dueDate = left.dueDate.compareTo(right.dueDate);
  if (dueDate != 0) return dueDate;

  return left.title.compareTo(right.title);
}

DateTime? _earliestDueDate(
  List<IncomingTalentRiskCouncilSlaItem> items,
  IncomingTalentRiskCouncilSlaStatus status, {
  IncomingTalentRiskCouncilSlaSource? source,
}) {
  final matches =
      items
          .where(
            (item) =>
                item.status == status &&
                (source == null || item.source == source),
          )
          .map((item) => item.dueDate)
          .toList()
        ..sort();
  if (matches.isEmpty) return null;
  return matches.first;
}

String _plural(int count, String noun) {
  return count == 1 ? noun : '${noun}s';
}
