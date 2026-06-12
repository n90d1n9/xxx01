import 'package:flutter_test/flutter_test.dart';
import 'package:ky_fnb_core/ky_fnb_core.dart';

void main() {
  test('service alert lifecycle applies audit-friendly actions', () {
    final now = DateTime(2026, 6, 10, 18, 30);
    final acknowledged = const FnbServiceAlertLifecycle().applyAction(
      FnbServiceAlertLifecycleAction.acknowledge,
      at: now,
      actorId: 'expo-lead',
      actorLabel: 'Dimas',
      ownerId: 'expo-lead',
      ownerLabel: 'Expo lead',
      note: 'Confirming with server.',
    );

    expect(acknowledged.status, FnbServiceAlertLifecycleStatus.acknowledged);
    expect(acknowledged.statusLabel, 'Acknowledged');
    expect(acknowledged.ownerDisplayLabel, 'Expo lead');
    expect(acknowledged.isActionableAt(now), isTrue);
    expect(acknowledged.auditTrail.single.actionLabel, 'Acknowledge');
    expect(acknowledged.auditTrail.single.actorDisplayLabel, 'Dimas');
    expect(acknowledged.auditTrail.single.noteLabel, 'Confirming with server.');

    final snoozed = acknowledged.applyAction(
      FnbServiceAlertLifecycleAction.snooze,
      at: now,
      snoozeDuration: const Duration(minutes: 10),
    );

    expect(snoozed.status, FnbServiceAlertLifecycleStatus.snoozed);
    expect(snoozed.isSnoozedAt(now.add(const Duration(minutes: 5))), isTrue);
    expect(
      snoozed.isActionableAt(now.add(const Duration(minutes: 5))),
      isFalse,
    );
    expect(
      snoozed.isActionableAt(now.add(const Duration(minutes: 11))),
      isTrue,
    );
    expect(snoozed.snoozedUntilLabel(), 'Snoozed until 18:40');

    final resolved = snoozed.applyAction(
      FnbServiceAlertLifecycleAction.resolve,
      at: now.add(const Duration(minutes: 6)),
    );

    expect(resolved.isResolved, isTrue);
    expect(resolved.snoozedUntil, isNull);
    expect(resolved.availableActionsAt(now), [
      FnbServiceAlertLifecycleAction.reopen,
    ]);
    expect(resolved.auditTrail, hasLength(3));
  });

  test('service alert summary ranks alerts across operational sources', () {
    final now = DateTime(2026, 6, 10, 18, 30);
    final summary = FnbServiceAlertSummary.fromEntries([
      FnbServiceAlertEntry(
        sourceId: 'bar-ready',
        sourceLabel: 'Table 4',
        contextLabel: 'Bar',
        serviceStatus: FnbServiceStatus.busy,
        dueAt: now.add(const Duration(minutes: 2)),
        alert: const FnbServiceAlert(
          type: FnbServiceAlertType.preference,
          label: 'Low sugar',
        ),
      ),
      FnbServiceAlertEntry(
        sourceId: 'late-grill',
        sourceLabel: 'Table 12',
        contextLabel: 'Grill',
        serviceStatus: FnbServiceStatus.critical,
        dueAt: now.subtract(const Duration(minutes: 3)),
        alert: const FnbServiceAlert(
          type: FnbServiceAlertType.dietary,
          label: 'No shellfish',
        ),
      ),
      FnbServiceAlertEntry(
        sourceId: 'late-grill',
        sourceLabel: 'Table 12',
        contextLabel: 'Grill',
        serviceStatus: FnbServiceStatus.critical,
        dueAt: now.subtract(const Duration(minutes: 4)),
        alert: const FnbServiceAlert(
          type: FnbServiceAlertType.allergy,
          label: 'Peanut allergy',
          critical: true,
        ),
      ),
    ]);

    expect(summary.hasAlerts, isTrue);
    expect(summary.alertCount, 3);
    expect(summary.criticalAlertCount, 1);
    expect(summary.sourceCount, 2);
    expect(summary.serviceStatus, FnbServiceStatus.critical);
    expect(summary.alertCountLabel, '3 alerts');
    expect(summary.criticalAlertLabel, '1 critical');
    expect(summary.sourceCountLabel(singular: 'ticket'), '2 tickets');
    expect(summary.topEntry?.sourceId, 'late-grill');
    expect(summary.topEntry?.subtitleLabel, 'Grill - Table 12');
    expect(summary.entries.map((entry) => entry.titleLabel), [
      'Allergy: Peanut allergy',
      'Dietary: No shellfish',
      'Preference: Low sugar',
    ]);
  });

  test('service alert entries use pressure and due time as tie breakers', () {
    final now = DateTime(2026, 6, 10, 18, 30);
    final resolved = const FnbServiceAlertLifecycle().applyAction(
      FnbServiceAlertLifecycleAction.resolve,
      at: now.subtract(const Duration(minutes: 2)),
    );
    final entries = [
      FnbServiceAlertEntry(
        sourceId: 'later-critical',
        sourceLabel: 'Table 8',
        serviceStatus: FnbServiceStatus.critical,
        dueAt: now.add(const Duration(minutes: 4)),
        alert: const FnbServiceAlert(
          type: FnbServiceAlertType.service,
          label: 'Manager check',
        ),
      ),
      FnbServiceAlertEntry(
        sourceId: 'soon-critical',
        sourceLabel: 'Table 3',
        serviceStatus: FnbServiceStatus.critical,
        dueAt: now.add(const Duration(minutes: 1)),
        alert: const FnbServiceAlert(
          type: FnbServiceAlertType.service,
          label: 'Runner check',
        ),
      ),
      FnbServiceAlertEntry(
        sourceId: 'resolved-allergy',
        sourceLabel: 'Table 1',
        serviceStatus: FnbServiceStatus.critical,
        dueAt: now.subtract(const Duration(minutes: 8)),
        lifecycle: resolved,
        alert: const FnbServiceAlert(
          type: FnbServiceAlertType.allergy,
          label: 'Already checked',
          critical: true,
        ),
      ),
      FnbServiceAlertEntry(
        sourceId: 'busy',
        sourceLabel: 'Table 2',
        serviceStatus: FnbServiceStatus.busy,
        dueAt: now.subtract(const Duration(minutes: 3)),
        alert: const FnbServiceAlert(
          type: FnbServiceAlertType.service,
          label: 'Refire garnish',
        ),
      ),
    ]..sort(compareFnbServiceAlertEntries);

    expect(entries.map((entry) => entry.sourceId), [
      'soon-critical',
      'later-critical',
      'busy',
      'resolved-allergy',
    ]);
  });

  test('service alert summary exposes actionable lifecycle counts', () {
    final now = DateTime(2026, 6, 10, 18, 30);
    final snoozed = const FnbServiceAlertLifecycle().applyAction(
      FnbServiceAlertLifecycleAction.snooze,
      at: now,
      snoozeDuration: const Duration(minutes: 15),
    );
    final resolved = const FnbServiceAlertLifecycle().applyAction(
      FnbServiceAlertLifecycleAction.resolve,
      at: now,
    );
    final summary = FnbServiceAlertSummary.fromEntries([
      FnbServiceAlertEntry(
        sourceId: 'open',
        sourceLabel: 'Table 4',
        alert: const FnbServiceAlert(
          type: FnbServiceAlertType.preference,
          label: 'Low sugar',
        ),
      ),
      FnbServiceAlertEntry(
        sourceId: 'snoozed',
        sourceLabel: 'Table 8',
        lifecycle: snoozed,
        alert: const FnbServiceAlert(
          type: FnbServiceAlertType.service,
          label: 'Server follow-up',
        ),
      ),
      FnbServiceAlertEntry(
        sourceId: 'resolved',
        sourceLabel: 'Table 12',
        lifecycle: resolved,
        alert: const FnbServiceAlert(
          type: FnbServiceAlertType.allergy,
          label: 'Peanut allergy',
          critical: true,
        ),
      ),
    ]);

    expect(summary.alertCount, 3);
    expect(summary.actionableAlertCountAt(now), 1);
    expect(summary.snoozedAlertCountAt(now), 1);
    expect(summary.resolvedAlertCount, 1);
    expect(summary.actionableAlertCountLabelAt(now), '1 actionable');
    expect(summary.resolvedAlertCountLabel(), '1 resolved');
    expect(summary.actionableEntriesAt(now).map((entry) => entry.sourceId), [
      'open',
    ]);
  });

  test('service alert entry copyWith preserves unchanged fields', () {
    const entry = FnbServiceAlertEntry(
      sourceId: 'reservation-12',
      sourceLabel: 'Ayu Rahma',
      contextLabel: 'Patio',
      alert: FnbServiceAlert(
        type: FnbServiceAlertType.accessibility,
        label: 'Wheelchair access',
      ),
    );

    final updated = entry.copyWith(serviceStatus: FnbServiceStatus.busy);

    expect(updated.sourceId, 'reservation-12');
    expect(updated.subtitleLabel, 'Patio - Ayu Rahma');
    expect(updated.alert.titleLabel, 'Wheelchair access');
    expect(updated.serviceStatus, FnbServiceStatus.busy);
    expect(updated.lifecycle.status, FnbServiceAlertLifecycleStatus.open);
  });
}
