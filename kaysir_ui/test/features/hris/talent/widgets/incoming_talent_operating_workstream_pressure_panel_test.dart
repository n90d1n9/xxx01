import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_operating_inbox_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_operating_inbox_provider.dart';
import 'package:kaysir/features/hris/talent/widgets/incoming_talent_operating_workstream_pressure_panel.dart';

void main() {
  testWidgets('talent workstream pressure panel exposes ranked pressure', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          incomingTalentOperatingWorkstreamPressuresProvider.overrideWithValue([
            _criticalPressure,
            _elevatedPressure,
          ]),
          incomingTalentOperatingWorkstreamPressureSummaryProvider
              .overrideWithValue(
                IncomingTalentOperatingWorkstreamPressureSummary.fromItems([
                  _criticalPressure,
                  _elevatedPressure,
                ]),
              ),
        ],
        child: _shell(const IncomingTalentOperatingWorkstreamPressurePanel()),
      ),
    );

    expect(find.text('Talent workstream pressure'), findsOneWidget);
    expect(find.text('Risk council'), findsOneWidget);
    expect(find.text('Development'), findsOneWidget);
    expect(find.text('Critical'), findsWidgets);
    expect(find.text('1 overloaded owners'), findsWidgets);
    expect(find.text('Recover 1 overdue risk council item.'), findsOneWidget);
  });
}

Widget _shell(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: child,
      ),
    ),
  );
}

final _criticalPressure = IncomingTalentOperatingWorkstreamPressure(
  workstream: IncomingTalentOperatingWorkstream.riskCouncil,
  level: IncomingTalentOperatingWorkstreamPressureLevel.critical,
  totalCount: 4,
  criticalCount: 2,
  watchCount: 1,
  routineCount: 1,
  overdueCount: 1,
  dueSoonCount: 1,
  ownerCount: 2,
  overloadedOwnerCount: 1,
  earliestDueDate: DateTime(2026, 6, 10),
  nextAction: 'Recover 1 overdue risk council item.',
  itemIds: const ['risk-overdue', 'risk-follow-up'],
);

final _elevatedPressure = IncomingTalentOperatingWorkstreamPressure(
  workstream: IncomingTalentOperatingWorkstream.development,
  level: IncomingTalentOperatingWorkstreamPressureLevel.elevated,
  totalCount: 2,
  criticalCount: 0,
  watchCount: 2,
  routineCount: 0,
  overdueCount: 0,
  dueSoonCount: 2,
  ownerCount: 1,
  overloadedOwnerCount: 1,
  earliestDueDate: DateTime(2026, 6, 13),
  nextAction: 'Rebalance 1 overloaded development owner.',
  itemIds: const ['training-watch', 'career-watch'],
);
