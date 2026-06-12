import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../states/pos_layout_provider.dart';
import 'pos_commerce_channel.dart';
import 'pos_commerce_channel_behavior.dart';
import 'pos_commerce_channel_behavior_impact.dart';
import 'pos_commerce_channel_filter.dart';
import 'pos_commerce_channel_provider.dart';
import 'pos_commerce_channel_registry.dart';
import 'pos_commerce_channel_switch_plan.dart';
import 'pos_commerce_channel_switch_history.dart';
import 'pos_commerce_channel_switch_result.dart';
import 'pos_order_fulfillment_provider.dart';

final posCommerceChannelSwitchResultProvider =
    StateProvider<POSCommerceChannelSwitchResult?>((ref) => null);

class POSCommerceChannelSwitchController {
  final Ref _ref;
  final POSCommerceChannelRegistry registry;
  final POSCommerceChannelBehaviorRegistry behaviorRegistry;
  final POSCommerceChannel currentChannel;
  final POSLayoutPreference currentLayoutPreference;

  const POSCommerceChannelSwitchController({
    required Ref ref,
    required this.registry,
    required this.behaviorRegistry,
    required this.currentChannel,
    required this.currentLayoutPreference,
  }) : _ref = ref;

  List<POSCommerceChannel> get channels => registry.channels;

  bool get isSingleOption => channels.length <= 1;

  POSCommerceChannel channelFor(String channelId) {
    return registry.channelForId(channelId);
  }

  POSCommerceChannelBehaviorProfile? behaviorProfileFor(
    POSCommerceChannel channel,
  ) {
    return behaviorRegistry.findByChannelId(channel.id);
  }

  POSCommerceChannelBehaviorImpact behaviorImpactFor(
    POSCommerceChannel channel,
  ) {
    return POSCommerceChannelBehaviorImpact.compare(
      currentProfile: behaviorProfileFor(currentChannel),
      targetProfile: behaviorProfileFor(channel),
    );
  }

  Iterable<String> behaviorSearchTermsFor(POSCommerceChannel channel) sync* {
    yield* (behaviorProfileFor(channel)?.searchTerms ?? const []);
    yield* behaviorImpactFor(channel).searchTerms;
  }

  POSCommerceChannelFilterResult filterChannels(
    POSCommerceChannelFilter filter, {
    POSCommerceChannelSearchTermsBuilder? extraSearchTermsBuilder,
  }) {
    return filter.apply(
      registry: registry,
      currentChannel: currentChannel,
      extraSearchTermsBuilder: extraSearchTermsBuilder,
    );
  }

  POSCommerceChannelFilterCounts channelCounts({
    String query = '',
    POSCommerceChannelSearchTermsBuilder? extraSearchTermsBuilder,
  }) {
    return POSCommerceChannelFilterCounts.fromRegistry(
      registry: registry,
      currentChannel: currentChannel,
      query: query,
      extraSearchTermsBuilder: extraSearchTermsBuilder,
    );
  }

  void apply(POSCommerceChannel channel, {bool applyPreferredLayout = true}) {
    if (registry.findById(channel.id) == null) {
      throw StateError(
        'POS commerce channel "${channel.id}" is not available.',
      );
    }

    _ref.read(selectedPOSCommerceChannelIdProvider.notifier).state = channel.id;

    if (applyPreferredLayout) {
      _ref.read(posLayoutPreferenceProvider.notifier).state =
          channel.preferredLayout;
    }

    _ref.read(posCommerceChannelSwitchResultProvider.notifier).state = null;
  }

  POSCommerceChannelSwitchResult applyPlan(POSCommerceChannelSwitchPlan plan) {
    if (registry.findById(plan.targetChannel.id) == null) {
      throw StateError(
        'POS commerce channel "${plan.targetChannel.id}" is not available.',
      );
    }

    _ref.read(selectedPOSCommerceChannelIdProvider.notifier).state =
        plan.targetChannel.id;
    _ref.read(posLayoutPreferenceProvider.notifier).state =
        plan.targetLayoutPreference;

    final result = POSCommerceChannelSwitchResult.fromPlan(
      plan: plan,
      resolvedFulfillmentContext: _ref.read(posOrderFulfillmentContextProvider),
    );
    _ref.read(posCommerceChannelSwitchResultProvider.notifier).state = result;
    _ref.read(posCommerceChannelSwitchHistoryProvider.notifier).record(result);

    return result;
  }
}

final posCommerceChannelSwitchControllerProvider =
    Provider<POSCommerceChannelSwitchController>((ref) {
      return POSCommerceChannelSwitchController(
        ref: ref,
        registry: ref.watch(posCommerceChannelRegistryProvider),
        behaviorRegistry: ref.watch(posCommerceChannelBehaviorRegistryProvider),
        currentChannel: ref.watch(posCommerceChannelProvider),
        currentLayoutPreference: ref.watch(posLayoutPreferenceProvider),
      );
    });
