import 'package:flutter_test/flutter_test.dart';

import 'package:ky_fnb_core/ky_fnb_core.dart';

void main() {
  test('service statuses describe shared operating pressure', () {
    expect(FnbServiceStatus.calm.label, 'Calm');
    expect(
      FnbServiceStatus.blocked.priorityScore,
      greaterThan(FnbServiceStatus.critical.priorityScore),
    );
    expect(FnbServiceStatus.busy.needsAttention, isTrue);
    expect(FnbServiceStatus.calm.needsAttention, isFalse);
    expect(FnbServiceStatus.critical.isAtLeast(FnbServiceStatus.busy), isTrue);
    expect(
      FnbServiceStatus.blocked.mostUrgent(FnbServiceStatus.critical),
      FnbServiceStatus.blocked,
    );
  });

  test('service context describes shared guest and reservation details', () {
    final context = FnbServiceContext(
      guestName: 'Siti Rahma',
      partySize: 4,
      reservationTime: DateTime(2026, 6, 10, 18, 15),
      vip: true,
      occasion: 'Anniversary',
      notes: 'Window table',
    );

    expect(context.hasReservation, isTrue);
    expect(context.hasGuestContext, isTrue);
    expect(context.guestLabel, 'Siti Rahma');
    expect(context.partySizeLabel, '4 guests');
    expect(context.reservationTimeLabel, '18:15 reservation');
    expect(context.vipLabel, 'VIP');
    expect(context.occasionLabel, 'Anniversary');
    expect(context.notesLabel, 'Window table');
    expect(context.summaryLabels, [
      'VIP',
      'Siti Rahma',
      '4 guests',
      '18:15 reservation',
      'Anniversary',
    ]);
    expect(
      context.accessibilityLabel,
      'VIP, Siti Rahma, 4 guests, 18:15 reservation, Anniversary, Window table',
    );
  });

  test('service context prioritizes structured service alerts', () {
    const context = FnbServiceContext(
      alerts: [
        FnbServiceAlert(
          type: FnbServiceAlertType.preference,
          label: 'Low sugar',
        ),
        FnbServiceAlert(
          type: FnbServiceAlertType.allergy,
          label: 'Peanut allergy',
          description: 'Use clean utensils.',
          critical: true,
        ),
      ],
    );

    expect(context.hasGuestContext, isTrue);
    expect(context.hasAlerts, isTrue);
    expect(context.hasCriticalAlerts, isTrue);
    expect(context.primaryAlert?.titleLabel, 'Peanut allergy');
    expect(context.alertSummaryLabel, 'Allergy: Peanut allergy +1');
    expect(context.priorityAlerts.map((alert) => alert.titleLabel), [
      'Peanut allergy',
      'Low sugar',
    ]);
    expect(
      context.accessibilityLabel,
      'Critical Allergy: Peanut allergy, Use clean utensils., '
      'Preference: Low sugar',
    );
  });

  test('kitchen station model preserves shared load shape', () {
    const station = FnbKitchenStation(
      id: 'grill',
      name: 'Grill',
      lead: 'Ayu',
      ticketsInProgress: 8,
      averageFireMinutes: 14,
      queueLabel: '8 firing',
      status: FnbServiceStatus.busy,
    );

    final updated = station.copyWith(
      ticketsInProgress: 2,
      status: FnbServiceStatus.calm,
    );

    expect(updated.id, 'grill');
    expect(updated.ticketsInProgress, 2);
    expect(updated.averageFireMinutes, 14);
    expect(updated.status, FnbServiceStatus.calm);
    expect(updated.ticketLabel, '2 tickets');
    expect(updated.fireTimeLabel, '14m fire');
    expect(updated.averageFireTimeLabel, '14m average fire');
    expect(updated.queueLeadLabel, '8 firing - Lead Ayu');
    expect(
      updated.accessibilityLabel,
      'Grill, 8 firing, lead Ayu, 2 tickets, 14m average fire',
    );
  });

  test('kitchen station summary aggregates shared station pressure', () {
    const stations = [
      FnbKitchenStation(
        id: 'grill',
        name: 'Grill',
        lead: 'Ayu',
        ticketsInProgress: 8,
        averageFireMinutes: 21,
        queueLabel: 'Steaks and skewers',
        status: FnbServiceStatus.critical,
      ),
      FnbKitchenStation(
        id: 'wok',
        name: 'Wok',
        lead: 'Bima',
        ticketsInProgress: 5,
        averageFireMinutes: 15,
        queueLabel: 'Noodles and rice',
        status: FnbServiceStatus.busy,
      ),
      FnbKitchenStation(
        id: 'bar',
        name: 'Bar',
        lead: 'Citra',
        ticketsInProgress: 2,
        averageFireMinutes: 8,
        queueLabel: 'Coffee and mocktails',
        status: FnbServiceStatus.calm,
      ),
    ];

    final summary = FnbKitchenStationSummary.fromStations(stations);

    expect(summary.stationCount, 3);
    expect(summary.pressureCount, 2);
    expect(summary.delayedCount, 2);
    expect(summary.calmCount, 1);
    expect(summary.totalTickets, 15);
    expect(summary.averageFireMinutes, 15);
    expect(summary.pressureRate, closeTo(2 / 3, .01));
    expect(summary.pressureLabel, '2 stations warm');
  });

  test('kitchen station filters group shared station pressure', () {
    const calmStation = FnbKitchenStation(
      id: 'bar',
      name: 'Bar',
      lead: 'Citra',
      ticketsInProgress: 2,
      averageFireMinutes: 8,
      queueLabel: 'Coffee and mocktails',
      status: FnbServiceStatus.calm,
    );
    const delayedStation = FnbKitchenStation(
      id: 'grill',
      name: 'Grill',
      lead: 'Ayu',
      ticketsInProgress: 8,
      averageFireMinutes: 21,
      queueLabel: 'Steaks and skewers',
      status: FnbServiceStatus.critical,
    );

    expect(FnbKitchenStationFilter.all.includes(calmStation), isTrue);
    expect(FnbKitchenStationFilter.pressure.includes(delayedStation), isTrue);
    expect(FnbKitchenStationFilter.delayed.includes(delayedStation), isTrue);
    expect(FnbKitchenStationFilter.calm.includes(calmStation), isTrue);
    expect(FnbKitchenStationFilter.calm.includes(delayedStation), isFalse);
    expect(FnbKitchenStationFilter.pressure.label, 'Pressure');
  });

  test('kitchen station priority queue ranks shared station attention', () {
    const stations = [
      FnbKitchenStation(
        id: 'pass',
        name: 'Pass',
        lead: 'Dimas',
        ticketsInProgress: 2,
        averageFireMinutes: 7,
        queueLabel: 'Expo blocked',
        status: FnbServiceStatus.blocked,
      ),
      FnbKitchenStation(
        id: 'wok',
        name: 'Wok',
        lead: 'Bima',
        ticketsInProgress: 8,
        averageFireMinutes: 15,
        queueLabel: 'Noodles and rice',
        status: FnbServiceStatus.busy,
      ),
      FnbKitchenStation(
        id: 'bar',
        name: 'Bar',
        lead: 'Citra',
        ticketsInProgress: 3,
        averageFireMinutes: 6,
        queueLabel: 'Coffee and mocktails',
        status: FnbServiceStatus.calm,
      ),
      FnbKitchenStation(
        id: 'grill',
        name: 'Grill',
        lead: 'Ayu',
        ticketsInProgress: 12,
        averageFireMinutes: 21,
        queueLabel: 'Steaks and skewers',
        status: FnbServiceStatus.critical,
      ),
    ];

    final queue = FnbKitchenStationPriorityQueue.fromStations(stations);

    expect(queue.count, 3);
    expect(queue.stations.map((station) => station.id), [
      'pass',
      'grill',
      'wok',
    ]);
    expect(queue.topStation?.id, 'pass');
    expect(queue.isEmpty, isFalse);
  });

  test(
    'kitchen station pressure signal describes the top attention station',
    () {
      const stations = [
        FnbKitchenStation(
          id: 'wok',
          name: 'Wok',
          lead: 'Bima',
          ticketsInProgress: 8,
          averageFireMinutes: 15,
          queueLabel: 'Noodles and rice',
          status: FnbServiceStatus.busy,
        ),
        FnbKitchenStation(
          id: 'pass',
          name: 'Pass',
          lead: 'Dimas',
          ticketsInProgress: 2,
          averageFireMinutes: 7,
          queueLabel: 'Expo blocked',
          status: FnbServiceStatus.blocked,
        ),
      ];

      final signal = FnbKitchenStationPressureSignal.fromStations(stations);

      expect(signal.hasPressure, isTrue);
      expect(signal.station?.id, 'pass');
      expect(signal.status, FnbServiceStatus.blocked);
      expect(signal.titleLabel, 'Unblock Pass');
      expect(
        signal.messageLabel,
        'Expo blocked with 2 tickets, 7m average fire. Lead Dimas.',
      );
      expect(signal.actionLabel, 'Clear blocker with Dimas');
    },
  );

  test('kitchen station pressure signal reports a clear state', () {
    const stations = [
      FnbKitchenStation(
        id: 'bar',
        name: 'Bar',
        lead: 'Citra',
        ticketsInProgress: 0,
        averageFireMinutes: 6,
        queueLabel: 'Clear',
        status: FnbServiceStatus.calm,
      ),
    ];

    final signal = FnbKitchenStationPressureSignal.fromStations(stations);

    expect(signal, same(FnbKitchenStationPressureSignal.clear));
    expect(signal.hasPressure, isFalse);
    expect(signal.titleLabel, 'Kitchen flow steady');
    expect(signal.messageLabel, 'No stations need attention right now.');
    expect(signal.actionLabel, 'Keep monitoring');
  });
}
