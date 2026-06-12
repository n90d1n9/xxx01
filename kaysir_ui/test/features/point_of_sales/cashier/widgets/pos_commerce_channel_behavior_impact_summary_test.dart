import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_commerce_channel_behaviors.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel_behavior_impact.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_commerce_channel_behavior_impact_summary.dart';

void main() {
  testWidgets('behavior impact summary renders compact behavior changes', (
    tester,
  ) async {
    final registry = defaultPOSCommerceChannelBehaviorRegistry;
    final impact = POSCommerceChannelBehaviorImpact.compare(
      currentProfile: registry.profileForChannel('in_store'),
      targetProfile: registry.profileForChannel('delivery_app'),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: POSCommerceChannelBehaviorImpactSummary(impact: impact),
        ),
      ),
    );

    expect(find.text('Adds Delivery aggregator'), findsOneWidget);
    expect(find.text('Adds Delivery fulfillment'), findsOneWidget);
    expect(find.text('+2 additions'), findsOneWidget);
    expect(find.text('Removes 3 behaviors'), findsOneWidget);
  });

  testWidgets('behavior impact summary hides unchanged profiles', (
    tester,
  ) async {
    final profile = defaultPOSCommerceChannelBehaviorRegistry.profileForChannel(
      'in_store',
    );
    final impact = POSCommerceChannelBehaviorImpact.compare(
      currentProfile: profile,
      targetProfile: profile,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: POSCommerceChannelBehaviorImpactSummary(impact: impact),
        ),
      ),
    );

    expect(find.byType(Text), findsNothing);
  });
}
