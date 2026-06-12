import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_commerce_channel_behaviors.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel_behavior_impact.dart';

void main() {
  test('behavior impact compares added, removed, and retained modules', () {
    final registry = defaultPOSCommerceChannelBehaviorRegistry;
    final impact = POSCommerceChannelBehaviorImpact.compare(
      currentProfile: registry.profileForChannel('in_store'),
      targetProfile: registry.profileForChannel('delivery_app'),
    );

    expect(impact.hasChanges, isTrue);
    expect(impact.summaryLabel, 'Adds 4 behaviors and removes 3 behaviors');
    expect(
      impact.addedItems.map((item) => item.module.id),
      containsAll([
        'delivery_aggregator',
        'delivery_fulfillment',
        'inventory_reservation',
        'account_pricing',
      ]),
    );
    expect(
      impact.removedItems.map((item) => item.module.id),
      containsAll([
        'counter_checkout',
        'immediate_fulfillment',
        'offline_capture',
      ]),
    );
    expect(impact.retainedItems, isEmpty);
    expect(impact.searchTerms, contains('Adds Delivery aggregator'));
    expect(impact.searchTerms, contains('offline-ready'));
  });

  test('behavior impact stays empty for the same profile', () {
    final profile = defaultPOSCommerceChannelBehaviorRegistry.profileForChannel(
      'in_store',
    );
    final impact = POSCommerceChannelBehaviorImpact.compare(
      currentProfile: profile,
      targetProfile: profile,
    );

    expect(impact.isCurrentProfile, isTrue);
    expect(impact.hasChanges, isFalse);
    expect(impact.summaryLabel, 'No behavior change');
    expect(impact.addedItems, isEmpty);
    expect(impact.removedItems, isEmpty);
    expect(
      impact.retainedItems.map((item) => item.module.id),
      containsAll(['counter_checkout', 'immediate_fulfillment']),
    );
  });
}
