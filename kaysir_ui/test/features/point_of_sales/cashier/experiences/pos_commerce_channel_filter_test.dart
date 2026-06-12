import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_commerce_channel_behaviors.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_commerce_channels.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel_filter.dart';

void main() {
  test('commerce channel filter searches omni-channel metadata', () {
    final registry = defaultPOSCommerceChannelRegistry;
    final currentChannel = registry.channelForId('in_store');

    final result = const POSCommerceChannelFilter(
      query: 'courier',
    ).apply(registry: registry, currentChannel: currentChannel);

    expect(result.totalCount, 11);
    expect(result.matchCount, 1);
    expect(result.channels.single.id, 'delivery_app');
    expect(result.sections.single.title, 'Online channels');
  });

  test('commerce channel filter groups channel characteristics', () {
    final registry = defaultPOSCommerceChannelRegistry;
    final currentChannel = registry.channelForId('in_store');

    final inPersonResult = const POSCommerceChannelFilter(
      status: POSCommerceChannelFilterStatus.inPerson,
    ).apply(registry: registry, currentChannel: currentChannel);

    expect(inPersonResult.channels.map((channel) => channel.id), [
      'in_store',
      'kiosk',
      'mobile_pos',
      'table_service',
    ]);

    final deliveryResult = const POSCommerceChannelFilter(
      status: POSCommerceChannelFilterStatus.delivery,
    ).apply(registry: registry, currentChannel: currentChannel);

    expect(
      deliveryResult.channels.map((channel) => channel.id),
      containsAll(['web_store', 'marketplace', 'delivery_app', 'field_sales']),
    );
    expect(
      deliveryResult.channels.map((channel) => channel.id),
      isNot(contains('kiosk')),
    );
  });

  test('commerce channel filter counts respect search query', () {
    final registry = defaultPOSCommerceChannelRegistry;
    final currentChannel = registry.channelForId('web_store');

    final counts = POSCommerceChannelFilterCounts.fromRegistry(
      registry: registry,
      currentChannel: currentChannel,
      query: 'delivery',
    );

    expect(counts.countFor(POSCommerceChannelFilterStatus.all), 7);
    expect(counts.countFor(POSCommerceChannelFilterStatus.current), 1);
    expect(counts.countFor(POSCommerceChannelFilterStatus.online), 5);
    expect(counts.countFor(POSCommerceChannelFilterStatus.delivery), 7);
  });

  test('commerce channel filter can search resolved switch impact terms', () {
    final registry = defaultPOSCommerceChannelRegistry;
    final currentChannel = registry.channelForId('in_store');

    final result = const POSCommerceChannelFilter(query: 'address').apply(
      registry: registry,
      currentChannel: currentChannel,
      extraSearchTermsBuilder: (channel) sync* {
        if (channel.id == 'delivery_app') {
          yield 'Delivery address needed';
        }
      },
    );
    final counts = POSCommerceChannelFilterCounts.fromRegistry(
      registry: registry,
      currentChannel: currentChannel,
      query: 'address',
      extraSearchTermsBuilder: (channel) sync* {
        if (channel.id == 'delivery_app') {
          yield 'Delivery address needed';
        }
      },
    );

    expect(result.matchCount, 1);
    expect(result.channels.single.id, 'delivery_app');
    expect(counts.countFor(POSCommerceChannelFilterStatus.all), 1);
    expect(counts.countFor(POSCommerceChannelFilterStatus.delivery), 1);
  });

  test('commerce channel filter can search behavior profile terms', () {
    final registry = defaultPOSCommerceChannelRegistry;
    final behaviorRegistry = defaultPOSCommerceChannelBehaviorRegistry;
    final currentChannel = registry.channelForId('in_store');

    final result = const POSCommerceChannelFilter(query: 'handoff-now').apply(
      registry: registry,
      currentChannel: currentChannel,
      extraSearchTermsBuilder:
          (channel) =>
              behaviorRegistry.findByChannelId(channel.id)?.searchTerms ??
              const [],
    );

    expect(result.channels.map((channel) => channel.id), [
      'in_store',
      'kiosk',
      'mobile_pos',
    ]);
  });
}
