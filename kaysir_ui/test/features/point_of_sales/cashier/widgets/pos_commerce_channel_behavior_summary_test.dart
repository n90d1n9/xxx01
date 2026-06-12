import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_commerce_channel_behaviors.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_commerce_channel_behavior_summary.dart';

void main() {
  testWidgets('commerce channel behavior summary renders compact modules', (
    tester,
  ) async {
    final profile = defaultPOSCommerceChannelBehaviorRegistry.profileForChannel(
      'delivery_app',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: POSCommerceChannelBehaviorSummary(
            profile: profile,
            maxModules: 2,
          ),
        ),
      ),
    );

    expect(find.text('Delivery aggregator'), findsOneWidget);
    expect(find.text('Delivery fulfillment'), findsOneWidget);
    expect(find.text('+2 behaviors'), findsOneWidget);
    expect(find.text('Inventory reservation'), findsNothing);
  });

  testWidgets('commerce channel behavior summary hides empty profiles', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: POSCommerceChannelBehaviorSummary(profile: null)),
      ),
    );

    expect(find.byType(POSCommerceChannelBehaviorSummary), findsOneWidget);
    expect(find.byType(Text), findsNothing);
  });
}
