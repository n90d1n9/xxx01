import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_operating_inbox_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_operating_inbox_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test('talent operating inbox owner digest ranks overloaded owners', () {
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
            id: 'career-critical',
            ownerName: 'Ari Talent Partner',
            source: IncomingTalentOperatingInboxSource.careerPathReview,
            priority: IncomingTalentOperatingInboxPriority.critical,
            dueDate: asOfDate.add(const Duration(days: 4)),
          ),
          _item(
            id: 'training-watch',
            ownerName: 'Bima HRBP',
            source: IncomingTalentOperatingInboxSource.trainingSession,
            priority: IncomingTalentOperatingInboxPriority.watch,
            dueDate: asOfDate.add(const Duration(days: 2)),
          ),
          _item(
            id: 'succession-routine',
            ownerName: 'Bima HRBP',
            source:
                IncomingTalentOperatingInboxSource.successionCoverageFollowUp,
            priority: IncomingTalentOperatingInboxPriority.routine,
            dueDate: asOfDate.add(const Duration(days: 5)),
          ),
          _item(
            id: 'promotion-routine',
            ownerName: 'Citra HRBP',
            source: IncomingTalentOperatingInboxSource.promotionStabilization,
            priority: IncomingTalentOperatingInboxPriority.routine,
            dueDate: asOfDate.add(const Duration(days: 14)),
          ),
        ]),
      ],
    );
    addTearDown(container.dispose);

    final digests = container.read(
      incomingTalentOperatingInboxOwnerDigestsProvider,
    );
    final summary = container.read(
      incomingTalentOperatingInboxOwnerDigestSummaryProvider,
    );

    expect(digests, hasLength(3));
    expect(digests.first.ownerName, 'Ari Talent Partner');
    expect(digests.first.load, IncomingTalentOperatingInboxOwnerLoad.critical);
    expect(digests.first.totalCount, 2);
    expect(digests.first.criticalCount, 2);
    expect(digests.first.overdueCount, 1);
    expect(digests.first.sourceCount, 2);
    expect(digests[1].ownerName, 'Bima HRBP');
    expect(digests[1].load, IncomingTalentOperatingInboxOwnerLoad.stretched);
    expect(summary.ownerCount, 3);
    expect(summary.criticalOwnerCount, 1);
    expect(summary.stretchedOwnerCount, 1);
    expect(summary.balancedOwnerCount, 1);
    expect(summary.totalItemCount, 5);
    expect(summary.criticalItemCount, 2);
    expect(summary.overdueItemCount, 1);
    expect(summary.dueSoonItemCount, 3);
    expect(summary.attentionOwnerCount, 2);
    expect(summary.nextAction, 'Support 1 critical talent owner workload.');
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
    title: 'Talent operating action',
    subjectName: 'Talent profile',
    department: 'People Operations',
    ownerName: ownerName,
    statusLabel: 'Open',
    nextAction: 'Complete the operating action.',
    dueDate: dueDate,
  );
}
