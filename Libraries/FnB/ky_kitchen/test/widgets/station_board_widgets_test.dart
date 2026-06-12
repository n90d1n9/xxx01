import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_kitchen/ky_kitchen.dart';

void main() {
  testWidgets('station board summary strip renders operating metrics', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KitchenStationBoardSummaryStrip(board: _testBoard()),
        ),
      ),
    );

    expect(find.text('Station board'), findsOneWidget);
    expect(find.text('2 stations warm'), findsOneWidget);
    expect(find.text('2 active'), findsOneWidget);
    expect(find.text('1 late'), findsOneWidget);
    expect(find.text('0 ready'), findsOneWidget);
    expect(find.text('3 items'), findsOneWidget);
    expect(find.text('10m avg fire'), findsOneWidget);
  });

  testWidgets('station pressure callout surfaces top station action', (
    tester,
  ) async {
    final selectedStations = <String>[];
    final board = _testBoard();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KitchenStationPressureCallout(
            signal: board.pressureSignal,
            onStationSelected: (station) => selectedStations.add(station.id),
          ),
        ),
      ),
    );

    expect(find.text('Unblock Pass'), findsOneWidget);
    expect(
      find.text('1 active with 1 ticket, 7m average fire. Lead Dimas.'),
      findsOneWidget,
    );
    expect(find.text('Clear blocker with Dimas'), findsOneWidget);

    await tester.tap(find.text('Clear blocker with Dimas'));
    await tester.pump();

    expect(selectedStations, ['pass']);
  });

  testWidgets('station pressure callout hides clear state by default', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: KitchenStationPressureCallout(
            signal: FnbKitchenStationPressureSignal.clear,
          ),
        ),
      ),
    );

    expect(find.text('Kitchen flow steady'), findsNothing);
  });

  testWidgets('station filter bar renders counts and reports selection', (
    tester,
  ) async {
    final changes = <FnbKitchenStationFilter>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KitchenStationFilterBar(
            board: _testBoard(),
            selectedFilter: FnbKitchenStationFilter.pressure,
            onChanged: changes.add,
          ),
        ),
      ),
    );

    expect(find.text('All 3'), findsOneWidget);
    expect(find.text('Pressure 2'), findsOneWidget);
    expect(find.text('Delayed 1'), findsOneWidget);
    expect(find.text('Calm 1'), findsOneWidget);

    await tester.tap(find.text('Calm 1'));
    await tester.pump();

    expect(changes, [FnbKitchenStationFilter.calm]);
  });

  testWidgets('station load card renders station pressure details', (
    tester,
  ) async {
    final board = _testBoard();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KitchenStationLoadCard(
            load: board.topLoad ?? board.loads.first,
            selected: true,
          ),
        ),
      ),
    );

    expect(find.text('Pass'), findsOneWidget);
    expect(find.text('1 active - Lead Dimas'), findsOneWidget);
    expect(find.text('Blocked'), findsOneWidget);
    expect(find.text('1 active'), findsOneWidget);
    expect(find.text('0 late'), findsOneWidget);
    expect(find.text('0 ready'), findsOneWidget);
    expect(find.text('1 items'), findsOneWidget);
    expect(find.text('7m fire'), findsOneWidget);
  });

  testWidgets('station load list filters cards and reports selection', (
    tester,
  ) async {
    final changes = <String>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KitchenStationLoadList(
            board: _testBoard(),
            filter: FnbKitchenStationFilter.pressure,
            selectedStationId: 'pass',
            onLoadSelected: (load) => changes.add(load.station.id),
          ),
        ),
      ),
    );

    expect(find.text('Grill'), findsOneWidget);
    expect(find.text('Pass'), findsOneWidget);
    expect(find.text('Bar'), findsNothing);

    await tester.tap(find.text('Grill'));
    await tester.pump();

    expect(changes, ['grill']);
  });

  testWidgets('station load list renders empty filter state', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KitchenStationLoadList(
            board: _calmBoard(),
            filter: FnbKitchenStationFilter.pressure,
          ),
        ),
      ),
    );

    expect(
      find.text('No pressure kitchen stations right now.'),
      findsOneWidget,
    );
  });
}

KitchenStationBoard _testBoard() {
  final now = DateTime(2026, 6, 9, 18, 30);
  const stations = [
    FnbKitchenStation(
      id: 'grill',
      name: 'Grill',
      lead: 'Ayu',
      ticketsInProgress: 0,
      averageFireMinutes: 18,
      queueLabel: 'Clear',
      status: FnbServiceStatus.calm,
    ),
    FnbKitchenStation(
      id: 'pass',
      name: 'Pass',
      lead: 'Dimas',
      ticketsInProgress: 0,
      averageFireMinutes: 7,
      queueLabel: 'Expo blocked',
      status: FnbServiceStatus.blocked,
    ),
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

  return KitchenStationBoard.fromQueue(
    stations: stations,
    queue: KitchenTicketQueue(
      now: now,
      tickets: [
        KitchenTicket(
          id: 'late-grill',
          orderId: 'order-1',
          stationId: 'grill',
          stationName: 'Grill',
          customerLabel: 'Table 12',
          dueAt: now.subtract(const Duration(minutes: 2)),
          stage: KitchenTicketStage.firing,
          items: const [
            KitchenTicketItem(
              menuItemId: 'rib',
              name: 'Short Rib Rendang',
              quantity: 2,
            ),
          ],
        ),
        KitchenTicket(
          id: 'pass-ticket',
          orderId: 'order-2',
          stationId: 'pass',
          stationName: 'Pass',
          customerLabel: 'Counter',
          dueAt: now.add(const Duration(minutes: 4)),
          stage: KitchenTicketStage.queued,
          items: const [
            KitchenTicketItem(
              menuItemId: 'spritz',
              name: 'Pandan Spritz',
              quantity: 1,
            ),
          ],
        ),
      ],
    ),
  );
}

KitchenStationBoard _calmBoard() {
  final now = DateTime(2026, 6, 9, 18, 30);
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

  return KitchenStationBoard.fromQueue(
    stations: stations,
    queue: KitchenTicketQueue(now: now, tickets: const []),
  );
}
