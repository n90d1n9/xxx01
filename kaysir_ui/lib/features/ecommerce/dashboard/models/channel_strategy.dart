import '../../../point_of_sales/cashier/experiences/pos_commerce_channel.dart';
import 'channel_requirement.dart';
import 'product_profile.dart';

enum ChannelCoverageSignalType {
  channels,
  fulfillment,
  payments,
  customers,
  fulfillmentTracking,
  channelRequirement,
}

enum ChannelCoverageTone { ready, attention }

class ChannelCoverageSignal {
  final ChannelCoverageSignalType type;
  final String label;
  final String value;
  final String detail;
  final ChannelCoverageTone tone;
  final bool isRequired;
  final String? requirementId;
  final String? recommendationTitle;
  final String? recommendationDetail;
  final String? recommendationActionLabel;
  final int? recommendationPriority;

  const ChannelCoverageSignal({
    required this.type,
    required this.label,
    required this.value,
    required this.detail,
    required this.tone,
    this.isRequired = true,
    this.requirementId,
    this.recommendationTitle,
    this.recommendationDetail,
    this.recommendationActionLabel,
    this.recommendationPriority,
  });

  bool get needsAttention => tone == ChannelCoverageTone.attention;
}

class ChannelStrategy {
  final List<POSCommerceChannel> channels;
  final List<ProductCapability> capabilities;
  final List<POSFulfillmentMode> fulfillmentModes;
  final int paymentChannelCount;
  final int customerIdentityChannelCount;
  final int fulfillmentTrackingChannelCount;
  final List<ChannelCoverageRequirement> coverageRequirements;

  const ChannelStrategy({
    required this.channels,
    required this.capabilities,
    required this.fulfillmentModes,
    required this.paymentChannelCount,
    required this.customerIdentityChannelCount,
    required this.fulfillmentTrackingChannelCount,
    required this.coverageRequirements,
  });

  factory ChannelStrategy.fromProfile(
    ProductProfile profile, {
    Iterable<ChannelCoverageRequirement>? coverageRequirements,
  }) {
    final channels = profile.salesChannels;
    final fulfillmentModes =
        channels.expand((channel) => channel.fulfillmentModes).toSet().toList()
          ..sort((a, b) => a.index.compareTo(b.index));
    final resolvedCoverageRequirements =
        List<ChannelCoverageRequirement>.unmodifiable(
          coverageRequirements ?? defaultChannelCoverageRequirements,
        );

    return ChannelStrategy(
      channels: List.unmodifiable(channels),
      capabilities: List.unmodifiable(profile.capabilities),
      fulfillmentModes: List.unmodifiable(fulfillmentModes),
      paymentChannelCount: _countChannelsWithCapability(
        channels,
        POSCommerceChannelCapability.payments,
      ),
      customerIdentityChannelCount: _countChannelsWithCapability(
        channels,
        POSCommerceChannelCapability.customerIdentity,
      ),
      fulfillmentTrackingChannelCount: _countChannelsWithCapability(
        channels,
        POSCommerceChannelCapability.fulfillmentTracking,
      ),
      coverageRequirements: resolvedCoverageRequirements,
    );
  }

  bool get hasChannels => channels.isNotEmpty;

  int get channelCount => channels.length;

  int get fulfillmentModeCount => fulfillmentModes.length;

  bool get requiresPaymentCoverage {
    return _coverageRequirement(
      ChannelCoverageRequirementType.payments,
    ).isRequiredFor(capabilities);
  }

  bool get requiresCustomerCoverage {
    return _coverageRequirement(
      ChannelCoverageRequirementType.customers,
    ).isRequiredFor(capabilities);
  }

  bool get requiresFulfillmentTrackingCoverage {
    return _coverageRequirement(
      ChannelCoverageRequirementType.fulfillmentTracking,
    ).isRequiredFor(capabilities);
  }

  String get channelCountLabel => _count(channelCount, 'channel');

  String get fulfillmentModeCountLabel =>
      fulfillmentModes.isEmpty
          ? 'No modes'
          : _count(fulfillmentModes.length, 'mode');

  String get paymentCoverageLabel => _coverageLabel(paymentChannelCount);

  String get customerCoverageLabel =>
      _coverageLabel(customerIdentityChannelCount);

  String get fulfillmentTrackingCoverageLabel =>
      _coverageLabel(fulfillmentTrackingChannelCount);

  String get fulfillmentSummary {
    if (fulfillmentModes.isEmpty) return 'No fulfillment modes';
    return fulfillmentModes.map((mode) => mode.label).join(', ');
  }

  List<ChannelCoverageSignal> get coverageSignals {
    return List.unmodifiable([
      ChannelCoverageSignal(
        type: ChannelCoverageSignalType.channels,
        label: 'Channels',
        value: channelCountLabel,
        detail:
            hasChannels ? 'Sales channels registered' : 'Add sales channels',
        tone:
            hasChannels
                ? ChannelCoverageTone.ready
                : ChannelCoverageTone.attention,
      ),
      ChannelCoverageSignal(
        type: ChannelCoverageSignalType.fulfillment,
        label: 'Fulfillment',
        value: fulfillmentModeCountLabel,
        detail: fulfillmentSummary,
        tone:
            fulfillmentModes.isEmpty
                ? ChannelCoverageTone.attention
                : ChannelCoverageTone.ready,
      ),
      ...coverageRequirements.map(_coverageSignalForRequirement),
    ]);
  }

  bool get hasCoverageGaps {
    return coverageSignals.any((signal) => signal.needsAttention);
  }

  int get coverageGapCount {
    return coverageSignals.where((signal) => signal.needsAttention).length;
  }

  String get coverageHeadline {
    if (!hasCoverageGaps) return 'Channel coverage ready';
    return _count(coverageGapCount, 'coverage gap');
  }

  ChannelCoverageRequirement _coverageRequirement(
    ChannelCoverageRequirementType type,
  ) {
    for (final requirement in coverageRequirements) {
      if (requirement.type == type) return requirement;
    }

    return channelCoverageRequirementFor(type: type);
  }

  ChannelCoverageSignal _coverageSignalForRequirement(
    ChannelCoverageRequirement requirement,
  ) {
    return _coverageSignal(
      type: _signalTypeForRequirement(requirement.type),
      label: requirement.label,
      count: requirement.coveredChannelCount(channels),
      isRequired: requirement.isRequiredFor(capabilities),
      coveredDetail: requirement.coveredDetail,
      missingDetail: requirement.missingDetail,
      optionalDetail: requirement.optionalDetail,
      requirementId: requirement.id,
      recommendationTitle: requirement.recommendation?.title,
      recommendationDetail: requirement.recommendation?.detail,
      recommendationActionLabel: requirement.recommendation?.actionLabel,
      recommendationPriority: requirement.recommendation?.priority,
    );
  }
}

ChannelCoverageSignal _coverageSignal({
  required ChannelCoverageSignalType type,
  required String label,
  required int count,
  required bool isRequired,
  required String coveredDetail,
  required String missingDetail,
  required String optionalDetail,
  String? requirementId,
  String? recommendationTitle,
  String? recommendationDetail,
  String? recommendationActionLabel,
  int? recommendationPriority,
}) {
  if (!isRequired && count == 0) {
    return ChannelCoverageSignal(
      type: type,
      label: label,
      value: 'Optional',
      detail: optionalDetail,
      tone: ChannelCoverageTone.ready,
      isRequired: false,
      requirementId: requirementId,
      recommendationTitle: recommendationTitle,
      recommendationDetail: recommendationDetail,
      recommendationActionLabel: recommendationActionLabel,
      recommendationPriority: recommendationPriority,
    );
  }

  return ChannelCoverageSignal(
    type: type,
    label: label,
    value: _coverageLabel(count),
    detail: count == 0 ? missingDetail : coveredDetail,
    tone: isRequired ? _coverageTone(count) : ChannelCoverageTone.ready,
    isRequired: isRequired,
    requirementId: requirementId,
    recommendationTitle: recommendationTitle,
    recommendationDetail: recommendationDetail,
    recommendationActionLabel: recommendationActionLabel,
    recommendationPriority: recommendationPriority,
  );
}

ChannelCoverageSignalType _signalTypeForRequirement(
  ChannelCoverageRequirementType type,
) {
  return switch (type) {
    ChannelCoverageRequirementType.payments =>
      ChannelCoverageSignalType.payments,
    ChannelCoverageRequirementType.customers =>
      ChannelCoverageSignalType.customers,
    ChannelCoverageRequirementType.fulfillmentTracking =>
      ChannelCoverageSignalType.fulfillmentTracking,
    ChannelCoverageRequirementType.custom =>
      ChannelCoverageSignalType.channelRequirement,
  };
}

int _countChannelsWithCapability(
  Iterable<POSCommerceChannel> channels,
  POSCommerceChannelCapability capability,
) {
  return channels
      .where((channel) => channel.supportsCapability(capability))
      .length;
}

String _coverageLabel(int count) {
  if (count <= 0) return 'Not covered';
  return _count(count, 'channel');
}

ChannelCoverageTone _coverageTone(int count) {
  return count <= 0 ? ChannelCoverageTone.attention : ChannelCoverageTone.ready;
}

String _count(int count, String singular) {
  return '$count ${count == 1 ? singular : '${singular}s'}';
}
