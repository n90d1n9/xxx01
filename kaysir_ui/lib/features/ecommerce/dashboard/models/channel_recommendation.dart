import 'channel_strategy.dart';

enum ChannelRecommendationType {
  registerChannels,
  addFulfillmentModes,
  addPaymentChannel,
  addCustomerIdentityChannel,
  addFulfillmentTrackingChannel,
  addChannelRequirementCoverage,
}

enum ChannelRecommendationTone { attention }

class ChannelRecommendation {
  final ChannelRecommendationType type;
  final String title;
  final String detail;
  final String actionLabel;
  final int priority;
  final ChannelRecommendationTone tone;
  final String? coverageRequirementId;

  const ChannelRecommendation({
    required this.type,
    required this.title,
    required this.detail,
    required this.actionLabel,
    required this.priority,
    this.tone = ChannelRecommendationTone.attention,
    this.coverageRequirementId,
  });
}

extension ChannelStrategyRecommendations on ChannelStrategy {
  List<ChannelRecommendation> get recommendations {
    return channelRecommendationsFor(this);
  }

  bool get hasRecommendations => recommendations.isNotEmpty;
}

List<ChannelRecommendation> channelRecommendationsFor(
  ChannelStrategy strategy, {
  int maxRecommendations = 5,
}) {
  if (maxRecommendations <= 0) return const [];

  final recommendations =
      strategy.coverageSignals
          .where((signal) => signal.needsAttention)
          .map(_recommendationFor)
          .toList()
        ..sort((a, b) {
          final priorityComparison = a.priority.compareTo(b.priority);
          if (priorityComparison != 0) return priorityComparison;
          return a.title.compareTo(b.title);
        });

  return List.unmodifiable(recommendations.take(maxRecommendations));
}

ChannelRecommendation _recommendationFor(ChannelCoverageSignal signal) {
  return switch (signal.type) {
    ChannelCoverageSignalType.channels => const ChannelRecommendation(
      type: ChannelRecommendationType.registerChannels,
      title: 'Register sales channels',
      detail:
          'Map this product profile to owned, marketplace, assisted, or product-specific selling channels.',
      actionLabel: 'Define channel',
      priority: 10,
    ),
    ChannelCoverageSignalType.fulfillment => const ChannelRecommendation(
      type: ChannelRecommendationType.addFulfillmentModes,
      title: 'Add fulfillment modes',
      detail:
          'Assign the channel handoff model, such as pickup, delivery, shipment, table service, or pre-order.',
      actionLabel: 'Map handoff',
      priority: 20,
    ),
    ChannelCoverageSignalType.payments => ChannelRecommendation(
      type: ChannelRecommendationType.addPaymentChannel,
      title: 'Add payment-capable channel',
      detail:
          'Checkout, payment link, or subscription products need at least one channel that can capture or reconcile payment.',
      actionLabel: 'Add payment',
      priority: 30,
      coverageRequirementId: signal.requirementId,
    ),
    ChannelCoverageSignalType.customers => ChannelRecommendation(
      type: ChannelRecommendationType.addCustomerIdentityChannel,
      title: 'Add customer identity coverage',
      detail:
          'Customer-aware checkout and renewal workflows need a channel that can identify the buyer.',
      actionLabel: 'Add identity',
      priority: 40,
      coverageRequirementId: signal.requirementId,
    ),
    ChannelCoverageSignalType.fulfillmentTracking => ChannelRecommendation(
      type: ChannelRecommendationType.addFulfillmentTrackingChannel,
      title: 'Add fulfillment tracking',
      detail:
          'Pickup, delivery, and shipping profiles need a channel that can expose order handoff status.',
      actionLabel: 'Add tracking',
      priority: 50,
      coverageRequirementId: signal.requirementId,
    ),
    ChannelCoverageSignalType.channelRequirement => ChannelRecommendation(
      type: ChannelRecommendationType.addChannelRequirementCoverage,
      title:
          signal.recommendationTitle ??
          'Add ${signal.label.toLowerCase()} coverage',
      detail: signal.recommendationDetail ?? signal.detail,
      actionLabel: signal.recommendationActionLabel ?? 'Review coverage',
      priority: signal.recommendationPriority ?? 60,
      coverageRequirementId: signal.requirementId,
    ),
  };
}
