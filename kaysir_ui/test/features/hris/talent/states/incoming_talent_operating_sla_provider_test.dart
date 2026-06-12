import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_operating_inbox_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_operating_inbox_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test('talent operating SLA monitor normalizes inbox and assurance work', () {
    final container = ProviderContainer(
      overrides: [
        talentAsOfDateProvider.overrideWithValue(DateTime(2026, 6, 11)),
        incomingTalentOperatingInboxItemsProvider.overrideWithValue([
          _inboxItem(
            id: 'risk-overdue',
            source: IncomingTalentOperatingInboxSource.riskCouncilDecision,
            priority: IncomingTalentOperatingInboxPriority.critical,
            title: 'Resolve candidate handoff',
            subjectName: 'Alya Candidate',
            ownerName: 'People Operations Talent Partner',
            dueDate: DateTime(2026, 6, 10),
          ),
          _inboxItem(
            id: 'training-today',
            source: IncomingTalentOperatingInboxSource.trainingSession,
            priority: IncomingTalentOperatingInboxPriority.watch,
            title: 'Confirm training evidence',
            subjectName: 'Ari Talent',
            ownerName: 'Learning Partner',
            dueDate: DateTime(2026, 6, 11),
          ),
          _inboxItem(
            id: 'career-watch',
            source: IncomingTalentOperatingInboxSource.careerPathReview,
            priority: IncomingTalentOperatingInboxPriority.watch,
            title: 'Review career path block',
            subjectName: 'Raka Talent',
            ownerName: 'Career Partner',
            dueDate: DateTime(2026, 6, 15),
          ),
          _inboxItem(
            id: 'succession-track',
            source:
                IncomingTalentOperatingInboxSource.successionCoverageFollowUp,
            priority: IncomingTalentOperatingInboxPriority.routine,
            title: 'Track succession follow-up',
            subjectName: 'Maya Talent',
            ownerName: 'Succession Partner',
            dueDate: DateTime(2026, 6, 25),
          ),
        ]),
        incomingTalentOperatingAssuranceExecutionTracksProvider
            .overrideWithValue([
              _executionTrack(
                status: IncomingTalentOperatingAssuranceExecutionStatus.blocked,
                dueHealth:
                    IncomingTalentOperatingAssuranceExecutionDueHealth.upcoming,
                dueDate: DateTime(2026, 6, 12),
              ),
            ]),
      ],
    );
    addTearDown(container.dispose);

    final items = container.read(incomingTalentOperatingSlaItemsProvider);
    final summary = container.read(incomingTalentOperatingSlaSummaryProvider);

    expect(items, hasLength(5));
    expect(items.first.id, 'operating-sla-inbox-risk-overdue');
    expect(items.first.source, IncomingTalentOperatingSlaSource.recruitment);
    expect(items.first.status, IncomingTalentOperatingSlaStatus.overdue);
    expect(items.first.daysUntilDue, -1);
    expect(items[1].status, IncomingTalentOperatingSlaStatus.dueToday);
    expect(items[2].status, IncomingTalentOperatingSlaStatus.atRisk);
    expect(items[2].source, IncomingTalentOperatingSlaSource.assurance);
    expect(items[2].evidenceCount, 3);
    expect(items.last.status, IncomingTalentOperatingSlaStatus.onTrack);
    expect(summary.itemCount, 5);
    expect(summary.overdueCount, 1);
    expect(summary.dueTodayCount, 1);
    expect(summary.atRiskCount, 2);
    expect(summary.onTrackCount, 1);
    expect(summary.ownerCount, 5);
    expect(summary.sourceCount, 5);
    expect(summary.evidenceCount, 3);
    expect(summary.nextAction, 'Recover 1 overdue talent operating SLA item.');
  });
}

IncomingTalentOperatingInboxItem _inboxItem({
  required String id,
  required IncomingTalentOperatingInboxSource source,
  required IncomingTalentOperatingInboxPriority priority,
  required String title,
  required String subjectName,
  required String ownerName,
  required DateTime dueDate,
}) {
  return IncomingTalentOperatingInboxItem(
    id: id,
    source: source,
    priority: priority,
    title: title,
    subjectName: subjectName,
    department: 'People Operations',
    ownerName: ownerName,
    statusLabel: 'Open',
    nextAction: 'Close the active talent operating item.',
    dueDate: dueDate,
  );
}

IncomingTalentOperatingAssuranceExecutionTrack _executionTrack({
  required IncomingTalentOperatingAssuranceExecutionStatus status,
  required IncomingTalentOperatingAssuranceExecutionDueHealth dueHealth,
  required DateTime dueDate,
}) {
  return IncomingTalentOperatingAssuranceExecutionTrack(
    id: 'assurance-execution-risk',
    remediationActionId: 'assurance-remediation-risk',
    status: status,
    dueHealth: dueHealth,
    priority: IncomingTalentOperatingAssuranceRemediationPriority.critical,
    ownerName: 'Assurance Partner',
    workstreamLabel: 'Risk council',
    title: 'Assurance Partner execution - Risk council',
    detail: '2 open gaps with 3 completion proofs required',
    blocker: 'Linked escalation needs closure.',
    nextStep: 'Unblock linked risk council escalations.',
    dueDate: dueDate,
    executionRatio: 0.32,
    openGapCount: 2,
    overdueGapCount: 0,
    dueTodayGapCount: 0,
    linkedEscalationCount: 1,
    completionEvidence: const [
      'Attach decision notes.',
      'Owner confirmation for 2 gaps.',
      'HRIS closure note for risk council assurance.',
    ],
    gapIds: const ['gap-risk-1', 'gap-risk-2'],
  );
}
