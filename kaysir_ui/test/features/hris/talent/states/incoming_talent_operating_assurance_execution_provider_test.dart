import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_operating_inbox_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_operating_inbox_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test('talent assurance execution tracks remediation progress health', () {
    final container = ProviderContainer(
      overrides: [
        talentAsOfDateProvider.overrideWithValue(DateTime(2026, 6, 11)),
        incomingTalentOperatingAssuranceRemediationActionsProvider
            .overrideWithValue([
              _action(
                id: 'assurance-remediation-risk-blocked',
                priority:
                    IncomingTalentOperatingAssuranceRemediationPriority
                        .critical,
                ownerName: 'People Operations Talent Partner',
                workstreamLabel: 'Risk council',
                overdueGapCount: 0,
                dueTodayGapCount: 0,
                linkedEscalationCount: 2,
                nextDueDate: DateTime(2026, 6, 12),
              ),
              _action(
                id: 'assurance-remediation-training-recovery',
                priority:
                    IncomingTalentOperatingAssuranceRemediationPriority.high,
                ownerName: 'Learning Partner',
                workstreamLabel: 'Development',
                overdueGapCount: 1,
                dueTodayGapCount: 0,
                linkedEscalationCount: 0,
                nextDueDate: DateTime(2026, 6, 10),
              ),
              _action(
                id: 'assurance-remediation-career-today',
                priority:
                    IncomingTalentOperatingAssuranceRemediationPriority.high,
                ownerName: 'Career Partner',
                workstreamLabel: 'Career path',
                overdueGapCount: 0,
                dueTodayGapCount: 1,
                linkedEscalationCount: 0,
                nextDueDate: DateTime(2026, 6, 11),
              ),
              _action(
                id: 'assurance-remediation-succession-progress',
                priority:
                    IncomingTalentOperatingAssuranceRemediationPriority
                        .standard,
                ownerName: 'Succession Partner',
                workstreamLabel: 'Succession',
                overdueGapCount: 0,
                dueTodayGapCount: 0,
                linkedEscalationCount: 0,
                nextDueDate: DateTime(2026, 6, 17),
              ),
            ]),
      ],
    );
    addTearDown(container.dispose);

    final tracks = container.read(
      incomingTalentOperatingAssuranceExecutionTracksProvider,
    );
    final summary = container.read(
      incomingTalentOperatingAssuranceExecutionSummaryProvider,
    );

    expect(tracks, hasLength(4));
    expect(tracks.map((track) => track.status), [
      IncomingTalentOperatingAssuranceExecutionStatus.blocked,
      IncomingTalentOperatingAssuranceExecutionStatus.recovery,
      IncomingTalentOperatingAssuranceExecutionStatus.dueToday,
      IncomingTalentOperatingAssuranceExecutionStatus.inProgress,
    ]);
    expect(tracks.first.ownerName, 'People Operations Talent Partner');
    expect(
      tracks.first.blocker,
      '2 linked escalations must be cleared before assurance closure.',
    );
    expect(
      tracks.first.nextStep,
      'Unblock linked risk council escalations with People Operations Talent Partner.',
    );
    expect(tracks.first.completionEvidence, hasLength(3));
    expect(
      tracks[1].dueHealth,
      IncomingTalentOperatingAssuranceExecutionDueHealth.overdue,
    );
    expect(
      tracks[2].dueHealth,
      IncomingTalentOperatingAssuranceExecutionDueHealth.dueToday,
    );
    expect(summary.trackCount, 4);
    expect(summary.blockedCount, 1);
    expect(summary.recoveryCount, 1);
    expect(summary.dueTodayCount, 1);
    expect(summary.inProgressCount, 1);
    expect(summary.overdueCount, 1);
    expect(summary.ownerCount, 4);
    expect(summary.completionEvidenceCount, 12);
    expect(summary.linkedEscalationCount, 2);
    expect(
      summary.nextAction,
      'Unblock 1 assurance remediation execution track.',
    );
  });
}

IncomingTalentOperatingAssuranceRemediationAction _action({
  required String id,
  required IncomingTalentOperatingAssuranceRemediationPriority priority,
  required String ownerName,
  required String workstreamLabel,
  required int overdueGapCount,
  required int dueTodayGapCount,
  required int linkedEscalationCount,
  required DateTime nextDueDate,
}) {
  return IncomingTalentOperatingAssuranceRemediationAction(
    id: id,
    type: IncomingTalentOperatingAssuranceRemediationType.prepareAuditPack,
    priority: priority,
    assuranceLevel: IncomingTalentOperatingAssuranceLevel.guarded,
    ownerName: ownerName,
    workstreamLabel: workstreamLabel,
    title: '$ownerName - $workstreamLabel evidence',
    detail: '1 assurance gap in $workstreamLabel',
    nextAction: 'Attach assurance evidence.',
    gapCount: 1,
    criticalGapCount:
        priority == IncomingTalentOperatingAssuranceRemediationPriority.critical
            ? 1
            : 0,
    highGapCount:
        priority == IncomingTalentOperatingAssuranceRemediationPriority.high
            ? 1
            : 0,
    overdueGapCount: overdueGapCount,
    dueTodayGapCount: dueTodayGapCount,
    linkedEscalationCount: linkedEscalationCount,
    nextDueDate: nextDueDate,
    pressureRatio:
        priority == IncomingTalentOperatingAssuranceRemediationPriority.standard
            ? 0.24
            : 0.72,
    evidenceRequests: ['Attach ${workstreamLabel.toLowerCase()} evidence.'],
    gapIds: [id],
  );
}
