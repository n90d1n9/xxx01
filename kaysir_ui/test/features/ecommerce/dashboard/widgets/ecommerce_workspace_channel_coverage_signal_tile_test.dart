import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/channel_strategy.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/channel_coverage_signal_tile.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/text_badge.dart';

import '../fixtures/widget_test_harness.dart';

void main() {
  const readySignal = ChannelCoverageSignal(
    type: ChannelCoverageSignalType.fulfillment,
    label: 'Fulfillment',
    value: '3 modes',
    detail: 'Pickup, delivery, and shipment',
    tone: ChannelCoverageTone.ready,
  );

  testWidgets('ChannelCoverageSignalTile renders required signal', (
    tester,
  ) async {
    await tester.pumpWorkspaceWidget(
      const ChannelCoverageSignalTile(
        width: 280,
        signal: readySignal,
        showRequirementBadge: true,
      ),
    );

    expect(find.text('Fulfillment'), findsOneWidget);
    expect(find.text('3 modes'), findsOneWidget);
    expect(find.text('Pickup, delivery, and shipment'), findsOneWidget);
    expect(find.text('Required'), findsOneWidget);
    expect(find.byIcon(Icons.local_shipping_outlined), findsOneWidget);
    expect(find.byType(TextBadge), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ChannelCoverageSignalTile can hide requirement badge', (
    tester,
  ) async {
    await tester.pumpWorkspaceWidget(
      const ChannelCoverageSignalTile(width: 280, signal: readySignal),
    );

    expect(find.text('Fulfillment'), findsOneWidget);
    expect(find.text('Required'), findsNothing);
    expect(find.byType(TextBadge), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ChannelCoverageSignalTile renders optional signal', (
    tester,
  ) async {
    await tester.pumpWorkspaceWidget(
      const ChannelCoverageSignalTile(
        width: 280,
        signal: ChannelCoverageSignal(
          type: ChannelCoverageSignalType.payments,
          label: 'Payments',
          value: 'Not required',
          detail: 'No payment coverage rule applies',
          tone: ChannelCoverageTone.attention,
          isRequired: false,
        ),
        showRequirementBadge: true,
      ),
    );

    expect(find.text('Payments'), findsOneWidget);
    expect(find.text('Optional'), findsOneWidget);
    expect(find.byIcon(Icons.payments_outlined), findsOneWidget);
    expect(find.byType(TextBadge), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
