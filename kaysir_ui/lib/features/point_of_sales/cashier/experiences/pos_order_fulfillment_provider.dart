import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../order/models/order.dart';
import '../../order/states/current_order_provider.dart';
import 'pos_commerce_channel.dart';
import 'pos_commerce_channel_provider.dart';
import 'pos_order_fulfillment.dart';
import 'pos_order_fulfillment_behavior_policy.dart';

final posOrderFulfillmentDraftsProvider =
    StateProvider<Map<String, POSOrderFulfillmentContext>>((ref) => const {});

final posOrderFulfillmentContextProvider = Provider<POSOrderFulfillmentContext>(
  (ref) {
    final order = ref.watch(currentOrderProvider);
    final channel = ref.watch(posCommerceChannelProvider);
    final drafts = ref.watch(posOrderFulfillmentDraftsProvider);

    return resolvePOSOrderFulfillmentContextFor(
      order: order,
      channel: channel,
      drafts: drafts,
    );
  },
);

final posOrderFulfillmentReadinessProvider =
    Provider<POSOrderFulfillmentReadiness?>((ref) {
      final order = ref.watch(currentOrderProvider);
      if (order == null) return null;
      final channel = ref.watch(posCommerceChannelProvider);
      final context = ref.watch(posOrderFulfillmentContextProvider);
      final behaviorProfile = ref.watch(
        posCommerceChannelBehaviorProfileProvider,
      );

      return resolvePOSOrderFulfillmentReadiness(
        order: order,
        channel: channel,
        context: context,
        extraIssues: POSOrderFulfillmentBehaviorPolicy.issuesFor(
          order: order,
          channel: channel,
          context: context,
          behaviorProfile: behaviorProfile,
        ),
      );
    });

final posOrderFulfillmentBehaviorHintsProvider =
    Provider<List<POSOrderFulfillmentBehaviorHint>>((ref) {
      return POSOrderFulfillmentBehaviorPolicy.hintsFor(
        channel: ref.watch(posCommerceChannelProvider),
        context: ref.watch(posOrderFulfillmentContextProvider),
        behaviorProfile: ref.watch(posCommerceChannelBehaviorProfileProvider),
      );
    });

final posOrderFulfillmentControllerProvider =
    Provider<POSOrderFulfillmentController>(
      (ref) => POSOrderFulfillmentController(ref),
    );

class POSOrderFulfillmentController {
  final Ref _ref;

  POSOrderFulfillmentController(this._ref);

  void setMode(POSFulfillmentMode mode) {
    _update(_current.copyWith(mode: mode));
  }

  void setContactName(String value) {
    _update(_current.copyWith(contactName: value));
  }

  void setDestination(String value) {
    _update(_current.copyWith(destination: value));
  }

  void setTableName(String value) {
    _update(_current.copyWith(tableName: value));
  }

  void setScheduleLabel(String value) {
    _update(_current.copyWith(scheduleLabel: value));
  }

  void saveDraftFor({
    required Order order,
    required POSCommerceChannel channel,
    required POSOrderFulfillmentContext context,
  }) {
    final draftKey = posOrderFulfillmentDraftKey(order.id, channel.id);
    final drafts = _ref.read(posOrderFulfillmentDraftsProvider);

    _ref.read(posOrderFulfillmentDraftsProvider.notifier).state = {
      ...drafts,
      draftKey: context,
    };
  }

  POSOrderFulfillmentContext get _current {
    return _ref.read(posOrderFulfillmentContextProvider);
  }

  void _update(POSOrderFulfillmentContext context) {
    final order = _ref.read(currentOrderProvider);
    if (order == null) return;

    saveDraftFor(
      order: order,
      channel: _ref.read(posCommerceChannelProvider),
      context: context,
    );
  }
}

POSOrderFulfillmentContext resolvePOSOrderFulfillmentContextFor({
  required Order? order,
  required POSCommerceChannel channel,
  required Map<String, POSOrderFulfillmentContext> drafts,
}) {
  final draftKey =
      order == null ? null : posOrderFulfillmentDraftKey(order.id, channel.id);
  final draft = draftKey == null ? null : drafts[draftKey];

  if (draft != null && channel.supportsFulfillment(draft.mode)) {
    return draft;
  }

  return POSOrderFulfillmentContext.forChannel(channel);
}

String posOrderFulfillmentDraftKey(String orderId, String channelId) {
  return '${orderId.trim()}::${channelId.trim()}';
}
