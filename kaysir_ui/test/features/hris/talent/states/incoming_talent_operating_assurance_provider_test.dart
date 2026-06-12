import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_operating_inbox_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_operating_inbox_provider.dart';

void main() {
  test('talent assurance groups evidence gaps by workstream exposure', () {
    final container = ProviderContainer(
      overrides: [
        incomingTalentOperatingEvidenceGapsProvider.overrideWithValue([
          _gap(
            id: 'evidence-risk-overdue',
            workstreamLabel: 'Risk council',
            risk: IncomingTalentOperatingEvidenceGapRisk.critical,
            ownerName: 'People Operations Talent Partner',
            overdue: true,
            dueToday: false,
            linkedEscalationCount: 2,
            dueDate: DateTime(2026, 6, 10),
          ),
          _gap(
            id: 'evidence-risk-today',
            workstreamLabel: 'Risk council',
            risk: IncomingTalentOperatingEvidenceGapRisk.high,
            ownerName: 'Risk Council Chair',
            overdue: false,
            dueToday: true,
            linkedEscalationCount: 1,
            dueDate: DateTime(2026, 6, 11),
          ),
          _gap(
            id: 'evidence-development-watch',
            workstreamLabel: 'Development',
            risk: IncomingTalentOperatingEvidenceGapRisk.watch,
            ownerName: 'Learning Partner',
            overdue: false,
            dueToday: false,
            linkedEscalationCount: 0,
            dueDate: DateTime(2026, 6, 15),
          ),
        ]),
      ],
    );
    addTearDown(container.dispose);

    final workstreams = container.read(
      incomingTalentOperatingAssuranceWorkstreamsProvider,
    );
    final summary = container.read(
      incomingTalentOperatingAssuranceSummaryProvider,
    );

    expect(workstreams, hasLength(4));
    expect(workstreams.first.workstreamLabel, 'Risk council');
    expect(
      workstreams.first.level,
      IncomingTalentOperatingAssuranceLevel.exposed,
    );
    expect(workstreams.first.gapCount, 2);
    expect(workstreams.first.criticalGapCount, 1);
    expect(workstreams.first.overdueGapCount, 1);
    expect(workstreams.first.linkedEscalationCount, 3);
    expect(workstreams.first.ownerCount, 2);
    expect(
      workstreams.first.nextAction,
      'Recover 1 overdue risk council evidence gap.',
    );
    expect(workstreams[1].level, IncomingTalentOperatingAssuranceLevel.guarded);
    expect(summary.workstreamCount, 4);
    expect(summary.exposedWorkstreamCount, 1);
    expect(summary.guardedWorkstreamCount, 1);
    expect(summary.readyWorkstreamCount, 2);
    expect(summary.totalGapCount, 3);
    expect(summary.criticalGapCount, 1);
    expect(summary.overdueGapCount, 1);
    expect(summary.linkedEscalationCount, 3);
    expect(summary.nextAction, 'Stabilize 1 audit-exposed talent workstream.');
  });
}

IncomingTalentOperatingEvidenceGap _gap({
  required String id,
  required String workstreamLabel,
  required IncomingTalentOperatingEvidenceGapRisk risk,
  required String ownerName,
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
    daysUntilDue: dueToday ? 0 : 4,
    overdue: overdue,
    dueToday: dueToday,
    linkedEscalationCount: linkedEscalationCount,
    pressureRatio: 0.7,
    referenceIds: [id],
  );
}
