import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_operating_inbox_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_operating_inbox_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test('talent evidence gaps rank proof needs linked to escalations', () {
    final asOfDate = DateTime(2026, 6, 11);
    final container = ProviderContainer(
      overrides: [
        talentAsOfDateProvider.overrideWithValue(asOfDate),
        incomingTalentOperatingInboxItemsProvider.overrideWithValue([
          _item(
            id: 'risk-overdue',
            source: IncomingTalentOperatingInboxSource.riskCouncilFollowUp,
            priority: IncomingTalentOperatingInboxPriority.critical,
            ownerName: 'People Operations Talent Partner',
            statusLabel: 'Blocked',
            dueDate: asOfDate.subtract(const Duration(days: 1)),
          ),
          _item(
            id: 'training-today',
            source: IncomingTalentOperatingInboxSource.trainingSession,
            priority: IncomingTalentOperatingInboxPriority.watch,
            ownerName: 'Learning Partner',
            statusLabel: 'Pending proof',
            dueDate: asOfDate,
          ),
          _item(
            id: 'career-week',
            source: IncomingTalentOperatingInboxSource.careerPathReview,
            priority: IncomingTalentOperatingInboxPriority.routine,
            ownerName: 'Career Partner',
            statusLabel: 'Open',
            dueDate: asOfDate.add(const Duration(days: 4)),
          ),
          _item(
            id: 'career-later',
            source: IncomingTalentOperatingInboxSource.careerPathReview,
            priority: IncomingTalentOperatingInboxPriority.routine,
            ownerName: 'Career Partner',
            statusLabel: 'Complete',
            dueDate: asOfDate.add(const Duration(days: 20)),
          ),
        ]),
        incomingTalentOperatingEscalationsProvider.overrideWithValue([
          _escalation(
            title: 'Overdue talent cadence',
            referenceIds: const ['risk-overdue', 'training-today'],
          ),
          _escalation(
            title: 'Risk council pressure',
            referenceIds: const ['risk-overdue'],
          ),
        ]),
      ],
    );
    addTearDown(container.dispose);

    final gaps = container.read(incomingTalentOperatingEvidenceGapsProvider);
    final summary = container.read(
      incomingTalentOperatingEvidenceGapSummaryProvider,
    );

    expect(gaps.map((gap) => gap.id), [
      'evidence-risk-overdue',
      'evidence-training-today',
      'evidence-career-week',
    ]);
    expect(gaps.first.risk, IncomingTalentOperatingEvidenceGapRisk.critical);
    expect(gaps.first.linkedEscalationCount, 2);
    expect(
      gaps.first.nextAction,
      'Recover overdue risk council evidence for Talent profile.',
    );
    expect(gaps[1].risk, IncomingTalentOperatingEvidenceGapRisk.high);
    expect(gaps[1].dueToday, isTrue);
    expect(gaps[2].risk, IncomingTalentOperatingEvidenceGapRisk.watch);
    expect(summary.totalCount, 3);
    expect(summary.criticalCount, 1);
    expect(summary.highCount, 1);
    expect(summary.watchCount, 1);
    expect(summary.overdueCount, 1);
    expect(summary.dueTodayCount, 1);
    expect(summary.linkedEscalationCount, 2);
    expect(summary.ownerCount, 3);
    expect(summary.workstreamCount, 2);
    expect(summary.nextAction, 'Close 1 critical talent evidence gap.');
  });
}

IncomingTalentOperatingInboxItem _item({
  required String id,
  required IncomingTalentOperatingInboxSource source,
  required IncomingTalentOperatingInboxPriority priority,
  required String ownerName,
  required String statusLabel,
  required DateTime dueDate,
}) {
  return IncomingTalentOperatingInboxItem(
    id: id,
    source: source,
    priority: priority,
    title: 'Evidence task',
    subjectName: 'Talent profile',
    department: 'People Operations',
    ownerName: ownerName,
    statusLabel: statusLabel,
    nextAction: 'Attach operating evidence.',
    dueDate: dueDate,
  );
}

IncomingTalentOperatingEscalationItem _escalation({
  required String title,
  required List<String> referenceIds,
}) {
  return IncomingTalentOperatingEscalationItem(
    source: IncomingTalentOperatingEscalationSource.cadence,
    severity: IncomingTalentOperatingEscalationSeverity.critical,
    title: title,
    detail: 'Escalated operating signal',
    nextAction: 'Clear escalation with proof.',
    signalCount: referenceIds.length,
    dueDate: DateTime(2026, 6, 10),
    overdue: true,
    dueToday: false,
    ownerName: null,
    workstreamLabel: null,
    pressureRatio: 0.8,
    referenceIds: referenceIds,
  );
}
