import 'pos_commerce_channel.dart';

enum POSCommerceChannelRegistryIssueType {
  emptyRegistry,
  blankChannelId,
  duplicateChannelId,
  missingDefaultChannel,
  blankLabel,
  emptyFulfillmentModes,
  emptyCapabilities,
  blankTrait,
}

class POSCommerceChannelRegistryIssue {
  final POSCommerceChannelRegistryIssueType type;
  final String channelId;
  final String message;

  const POSCommerceChannelRegistryIssue({
    required this.type,
    required this.channelId,
    required this.message,
  });

  @override
  String toString() => message;
}

class POSCommerceChannelRegistry {
  final List<POSCommerceChannel> channels;
  final String defaultChannelId;

  POSCommerceChannelRegistry({
    required Iterable<POSCommerceChannel> channels,
    required this.defaultChannelId,
  }) : channels = List.unmodifiable(channels);

  List<String> get channelIds {
    return List.unmodifiable(channels.map((channel) => channel.id));
  }

  POSCommerceChannel get defaultChannel => channelForId(defaultChannelId);

  POSCommerceChannel channelForId(String id) {
    final normalizedId = id.trim();
    for (final channel in channels) {
      if (channel.id == normalizedId) return channel;
    }

    throw StateError('No POS commerce channel registered for "$normalizedId".');
  }

  POSCommerceChannel? findById(String id) {
    final normalizedId = id.trim();
    for (final channel in channels) {
      if (channel.id == normalizedId) return channel;
    }

    return null;
  }

  List<POSCommerceChannel> channelsForCapability(
    POSCommerceChannelCapability capability,
  ) {
    return List.unmodifiable(
      channels.where((channel) => channel.supportsCapability(capability)),
    );
  }

  List<POSCommerceChannel> channelsForFulfillment(POSFulfillmentMode mode) {
    return List.unmodifiable(
      channels.where((channel) => channel.supportsFulfillment(mode)),
    );
  }

  List<POSCommerceChannelRegistryIssue> validate() {
    final issues = <POSCommerceChannelRegistryIssue>[];
    if (channels.isEmpty) {
      issues.add(
        const POSCommerceChannelRegistryIssue(
          type: POSCommerceChannelRegistryIssueType.emptyRegistry,
          channelId: '',
          message: 'No POS commerce channels are registered.',
        ),
      );
      return List.unmodifiable(issues);
    }

    final idCounts = <String, int>{};
    for (final channel in channels) {
      final id = channel.id.trim();
      if (id.isNotEmpty) idCounts[id] = (idCounts[id] ?? 0) + 1;
    }

    for (final channel in channels) {
      if (channel.id.trim().isEmpty) {
        issues.add(
          POSCommerceChannelRegistryIssue(
            type: POSCommerceChannelRegistryIssueType.blankChannelId,
            channelId: channel.id,
            message: 'POS commerce channel id cannot be blank.',
          ),
        );
      }

      if (channel.label.trim().isEmpty) {
        issues.add(
          POSCommerceChannelRegistryIssue(
            type: POSCommerceChannelRegistryIssueType.blankLabel,
            channelId: channel.id,
            message:
                'POS commerce channel "${channel.id}" label cannot be blank.',
          ),
        );
      }

      if (channel.fulfillmentModes.isEmpty) {
        issues.add(
          POSCommerceChannelRegistryIssue(
            type: POSCommerceChannelRegistryIssueType.emptyFulfillmentModes,
            channelId: channel.id,
            message:
                'POS commerce channel "${channel.id}" must declare at least one fulfillment mode.',
          ),
        );
      }

      if (channel.capabilities.isEmpty) {
        issues.add(
          POSCommerceChannelRegistryIssue(
            type: POSCommerceChannelRegistryIssueType.emptyCapabilities,
            channelId: channel.id,
            message:
                'POS commerce channel "${channel.id}" must declare at least one capability.',
          ),
        );
      }

      if (channel.traits.any((trait) => trait.trim().isEmpty)) {
        issues.add(
          POSCommerceChannelRegistryIssue(
            type: POSCommerceChannelRegistryIssueType.blankTrait,
            channelId: channel.id,
            message: 'POS commerce channel "${channel.id}" has a blank trait.',
          ),
        );
      }
    }

    for (final entry in idCounts.entries) {
      if (entry.value <= 1) continue;
      issues.add(
        POSCommerceChannelRegistryIssue(
          type: POSCommerceChannelRegistryIssueType.duplicateChannelId,
          channelId: entry.key,
          message: 'Duplicate POS commerce channel id "${entry.key}" found.',
        ),
      );
    }

    if (findById(defaultChannelId) == null) {
      issues.add(
        POSCommerceChannelRegistryIssue(
          type: POSCommerceChannelRegistryIssueType.missingDefaultChannel,
          channelId: defaultChannelId,
          message:
              'Default POS commerce channel "$defaultChannelId" is not registered.',
        ),
      );
    }

    return List.unmodifiable(issues);
  }

  void throwIfInvalid() {
    final issues = validate();
    if (issues.isEmpty) return;

    throw StateError(issues.map((issue) => issue.message).join('\n'));
  }
}
