import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_operating_inbox_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_operating_inbox_provider.dart';

void main() {
  test('talent assurance remediation groups evidence gaps by owner', () {
    final container = ProviderContainer(
      overrides: [
        incomingTalentOperatingEvidenceGapsProvider.overrideWithValue([
          _gap(
            id: 'evidence-risk-overdue',
            ownerName: 'People Operations Talent Partner',
            workstreamLabel: 'Risk council',
            risk: IncomingTalentOperatingEvidenceGapRisk.critical,
            overdue: true,
            dueToday: false,
            linkedEscalationCount: 2,
            dueDate: DateTime(2026, 6, 10),
          ),
          _gap(
            id: 'evidence-risk-linked',
            ownerName: 'People Operations Talent Partner',
            workstreamLabel: 'Risk council',
            risk: IncomingTalentOperatingEvidenceGapRisk.high,
            overdue: false,
            dueToday: false,
            linkedEscalationCount: 1,
            dueDate: DateTime(2026, 6, 12),
          ),
          _gap(
            id: 'evidence-development-today',
            ownerName: 'Learning Partner',
            workstreamLabel: 'Development',
            risk: IncomingTalentOperatingEvidenceGapRisk.high,
            overdue: false,
            dueToday: true,
            linkedEscalationCount: 0,
            dueDate: DateTime(2026, 6, 11),
          ),
          _gap(
            id: 'evidence-development-watch',
            ownerName: 'Career Partner',
            workstreamLabel: 'Development',
            risk: IncomingTalentOperatingEvidenceGapRisk.watch,
            overdue: false,
            dueToday: false,
            linkedEscalationCount: 0,
            dueDate: DateTime(2026, 6, 15),
          ),
        ]),
        incomingTalentOperatingAssuranceWorkstreamsProvider.overrideWithValue([
          _workstream(
            label: 'Risk council',
            level: IncomingTalentOperatingAssuranceLevel.exposed,
          ),
          _workstream(
            label: 'Development',
            level: IncomingTalentOperatingAssuranceLevel.guarded,
          ),
        ]),
      ],
    );
    addTearDown(container.dispose);

    final actions = container.read(
      incomingTalentOperatingAssuranceRemediationActionsProvider,
    );
    final summary = container.read(
      incomingTalentOperatingAssuranceRemediationSummaryProvider,
    );

    expect(actions, hasLength(3));
    expect(actions.first.ownerName, 'People Operations Talent Partner');
    expect(actions.first.workstreamLabel, 'Risk council');
    expect(
      actions.first.type,
      IncomingTalentOperatingAssuranceRemediationType.recoverOverdueEvidence,
    );
    expect(
      actions.first.priority,
      IncomingTalentOperatingAssuranceRemediationPriority.critical,
    );
    expect(actions.first.gapCount, 2);
    expect(actions.first.overdueGapCount, 1);
    expect(actions.first.linkedEscalationCount, 3);
    expect(
      actions.first.nextAction,
      'Ask People Operations Talent Partner to recover 1 overdue risk council evidence gap.',
    );
    expect(
      actions[1].type,
      IncomingTalentOperatingAssuranceRemediationType.closeDueToday,
    );
    expect(
      actions[2].priority,
      IncomingTalentOperatingAssuranceRemediationPriority.standard,
    );
    expect(summary.actionCount, 3);
    expect(summary.criticalActionCount, 1);
    expect(summary.highActionCount, 1);
    expect(summary.standardActionCount, 1);
    expect(summary.overdueActionCount, 1);
    expect(summary.dueTodayActionCount, 1);
    expect(summary.ownerCount, 3);
    expect(summary.workstreamCount, 2);
    expect(summary.totalGapCount, 4);
    expect(summary.linkedEscalationCount, 3);
    expect(
      summary.nextAction,
      'Complete 1 critical assurance remediation action.',
    );
  });
}

IncomingTalentOperatingEvidenceGap _gap({
  required String id,
  required String ownerName,
  required String workstreamLabel,
  required IncomingTalentOperatingEvidenceGapRisk risk,
  required bool overdue,
  required bool dueToday,
  required int linkedEscalationCount,
  required DateTime dueDate,
}) {
  return IncomingTalentOperatingEvidenceGap(
    id: id,
    type: IncomingTalentOperatingEvidenceGapType.riskCouncilEvidence,
    risk: risk,
    title: 'Evidence gap',
    subjectName: 'Talent profile',
    ownerName: ownerName,
    workstreamLabel: workstreamLabel,
    statusLabel: 'Open',
    evidenceRequest: 'Attach operating evidence.',
    nextAction: 'Attach operating evidence.',
    dueDate: dueDate,
    daysUntilDue:
        overdue
            ? -1
            : dueToday
            ? 0
            : 4,
    overdue: overdue,
    dueToday: dueToday,
    linkedEscalationCount: linkedEscalationCount,
    pressureRatio: 0.7,
    referenceIds: [id],
  );
}

IncomingTalentOperatingAssuranceWorkstream _workstream({
  required String label,
  required IncomingTalentOperatingAssuranceLevel level,
}) {
  return IncomingTalentOperatingAssuranceWorkstream(
    workstreamLabel: label,
    level: level,
    gapCount: 2,
    criticalGapCount:
        level == IncomingTalentOperatingAssuranceLevel.exposed ? 1 : 0,
    highGapCount: 1,
    watchGapCount: 0,
    overdueGapCount:
        level == IncomingTalentOperatingAssuranceLevel.exposed ? 1 : 0,
    dueTodayGapCount:
        level == IncomingTalentOperatingAssuranceLevel.guarded ? 1 : 0,
    linkedEscalationCount:
        level == IncomingTalentOperatingAssuranceLevel.exposed ? 3 : 0,
    ownerCount: 2,
    nextDueDate: DateTime(2026, 6, 10),
    nextAction: 'Close assurance gaps.',
    gapIds: const ['evidence-gap'],
  );
}
