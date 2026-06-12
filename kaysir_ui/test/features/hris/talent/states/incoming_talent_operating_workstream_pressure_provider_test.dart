import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_operating_inbox_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_operating_inbox_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test('talent workstream pressure ranks cross-HRIS operating pressure', () {
    final asOfDate = DateTime(2026, 6, 11);
    final container = ProviderContainer(
      overrides: [
        talentAsOfDateProvider.overrideWithValue(asOfDate),
        incomingTalentOperatingInboxItemsProvider.overrideWithValue([
          _item(
            id: 'risk-overdue',
            ownerName: 'Ari Talent Partner',
            source: IncomingTalentOperatingInboxSource.riskCouncilFollowUp,
            priority: IncomingTalentOperatingInboxPriority.critical,
            dueDate: asOfDate.subtract(const Duration(days: 1)),
          ),
          _item(
            id: 'risk-critical',
            ownerName: 'Ari Talent Partner',
            source: IncomingTalentOperatingInboxSource.riskCouncilDecision,
            priority: IncomingTalentOperatingInboxPriority.critical,
            dueDate: asOfDate.add(const Duration(days: 3)),
          ),
          _item(
            id: 'training-watch',
            ownerName: 'Bima HRBP',
            source: IncomingTalentOperatingInboxSource.trainingSession,
            priority: IncomingTalentOperatingInboxPriority.watch,
            dueDate: asOfDate.add(const Duration(days: 2)),
          ),
          _item(
            id: 'career-watch',
            ownerName: 'Bima HRBP',
            source: IncomingTalentOperatingInboxSource.careerPathReview,
            priority: IncomingTalentOperatingInboxPriority.watch,
            dueDate: asOfDate.add(const Duration(days: 4)),
          ),
          _item(
            id: 'promotion-routine',
            ownerName: 'Citra HRBP',
            source: IncomingTalentOperatingInboxSource.promotionStabilization,
            priority: IncomingTalentOperatingInboxPriority.routine,
            dueDate: asOfDate.add(const Duration(days: 10)),
          ),
        ]),
        incomingTalentOperatingInboxOwnerDigestsProvider.overrideWithValue([
          _ownerDigest(
            ownerName: 'Ari Talent Partner',
            load: IncomingTalentOperatingInboxOwnerLoad.critical,
            totalCount: 2,
            criticalCount: 2,
            overdueCount: 1,
            dueSoonCount: 1,
            riskCouncilCount: 2,
          ),
          _ownerDigest(
            ownerName: 'Bima HRBP',
            load: IncomingTalentOperatingInboxOwnerLoad.stretched,
            totalCount: 2,
            watchCount: 2,
            dueSoonCount: 2,
            developmentCount: 2,
          ),
          _ownerDigest(
            ownerName: 'Citra HRBP',
            load: IncomingTalentOperatingInboxOwnerLoad.balanced,
            totalCount: 1,
            routineCount: 1,
            promotionCount: 1,
          ),
        ]),
      ],
    );
    addTearDown(container.dispose);

    final pressures = container.read(
      incomingTalentOperatingWorkstreamPressuresProvider,
    );
    final summary = container.read(
      incomingTalentOperatingWorkstreamPressureSummaryProvider,
    );

    expect(pressures, hasLength(4));
    expect(
      pressures.first.workstream,
      IncomingTalentOperatingWorkstream.riskCouncil,
    );
    expect(
      pressures.first.level,
      IncomingTalentOperatingWorkstreamPressureLevel.critical,
    );
    expect(pressures.first.totalCount, 2);
    expect(pressures.first.criticalCount, 2);
    expect(pressures.first.overdueCount, 1);
    expect(pressures.first.overloadedOwnerCount, 1);
    expect(pressures.first.nextAction, 'Recover 1 overdue risk council item.');
    expect(
      pressures[1].workstream,
      IncomingTalentOperatingWorkstream.development,
    );
    expect(
      pressures[1].level,
      IncomingTalentOperatingWorkstreamPressureLevel.elevated,
    );
    expect(pressures[1].overloadedOwnerCount, 1);
    expect(summary.workstreamCount, 4);
    expect(summary.activeWorkstreamCount, 3);
    expect(summary.criticalWorkstreamCount, 1);
    expect(summary.elevatedWorkstreamCount, 1);
    expect(summary.totalItemCount, 5);
    expect(summary.criticalItemCount, 2);
    expect(summary.overdueItemCount, 1);
    expect(summary.overloadedOwnerCount, 2);
    expect(summary.nextAction, 'Stabilize 1 critical talent workstream.');
  });
}

IncomingTalentOperatingInboxItem _item({
  required String id,
  required String ownerName,
  required IncomingTalentOperatingInboxSource source,
  required IncomingTalentOperatingInboxPriority priority,
  required DateTime dueDate,
}) {
  return IncomingTalentOperatingInboxItem(
    id: id,
    source: source,
    priority: priority,
    title: 'Talent operating item',
    subjectName: 'Talent profile',
    department: 'People Operations',
    ownerName: ownerName,
    statusLabel: 'Open',
    nextAction: 'Complete the workstream action.',
    dueDate: dueDate,
  );
}

IncomingTalentOperatingInboxOwnerDigest _ownerDigest({
  required String ownerName,
  required IncomingTalentOperatingInboxOwnerLoad load,
  required int totalCount,
  int criticalCount = 0,
  int watchCount = 0,
  int routineCount = 0,
  int overdueCount = 0,
  int dueSoonCount = 0,
  int riskCouncilCount = 0,
  int developmentCount = 0,
  int successionCount = 0,
  int promotionCount = 0,
}) {
  return IncomingTalentOperatingInboxOwnerDigest(
    ownerName: ownerName,
    load: load,
    totalCount: totalCount,
    criticalCount: criticalCount,
    watchCount: watchCount,
    routineCount: routineCount,
    overdueCount: overdueCount,
    dueSoonCount: dueSoonCount,
    riskCouncilCount: riskCouncilCount,
    developmentCount: developmentCount,
    successionCount: successionCount,
    promotionCount: promotionCount,
    earliestDueDate: DateTime(2026, 6, 12),
    nextAction: 'Track owner workload.',
    itemIds: const [],
  );
}
