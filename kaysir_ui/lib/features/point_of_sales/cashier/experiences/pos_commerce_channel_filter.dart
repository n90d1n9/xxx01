import '../states/pos_layout_provider.dart';
import 'pos_commerce_channel.dart';
import 'pos_commerce_channel_registry.dart';

typedef POSCommerceChannelSearchTermsBuilder =
    Iterable<String> Function(POSCommerceChannel channel);

enum POSCommerceChannelFilterStatus {
  all,
  current,
  inPerson,
  online,
  delivery,
  account,
}

class POSCommerceChannelFilter {
  final String query;
  final POSCommerceChannelFilterStatus status;

  const POSCommerceChannelFilter({
    this.query = '',
    this.status = POSCommerceChannelFilterStatus.all,
  });

  bool get isActive =>
      query.trim().isNotEmpty || status != POSCommerceChannelFilterStatus.all;

  POSCommerceChannelFilterResult apply({
    required POSCommerceChannelRegistry registry,
    required POSCommerceChannel currentChannel,
    POSCommerceChannelSearchTermsBuilder? extraSearchTermsBuilder,
  }) {
    final sectionsByTitle = <String, List<POSCommerceChannel>>{};

    for (final channel in registry.channels) {
      if (!_matchesChannel(channel, currentChannel, extraSearchTermsBuilder)) {
        continue;
      }

      sectionsByTitle
          .putIfAbsent(_sectionTitle(channel), () => <POSCommerceChannel>[])
          .add(channel);
    }

    return POSCommerceChannelFilterResult(
      filter: this,
      sections: [
        for (final entry in sectionsByTitle.entries)
          POSCommerceChannelFilterSection(
            title: entry.key,
            channels: entry.value,
          ),
      ],
      totalCount: registry.channels.length,
    );
  }

  bool _matchesChannel(
    POSCommerceChannel channel,
    POSCommerceChannel currentChannel,
    POSCommerceChannelSearchTermsBuilder? extraSearchTermsBuilder,
  ) {
    return _matchesStatus(channel, currentChannel) &&
        _matchesQuery(channel, extraSearchTermsBuilder);
  }

  bool _matchesStatus(
    POSCommerceChannel channel,
    POSCommerceChannel currentChannel, [
    POSCommerceChannelFilterStatus? targetStatus,
  ]) {
    final resolvedStatus = targetStatus ?? status;

    switch (resolvedStatus) {
      case POSCommerceChannelFilterStatus.all:
        return true;
      case POSCommerceChannelFilterStatus.current:
        return channel.id == currentChannel.id;
      case POSCommerceChannelFilterStatus.inPerson:
        return _isInPersonChannel(channel);
      case POSCommerceChannelFilterStatus.online:
        return _isOnlineChannel(channel);
      case POSCommerceChannelFilterStatus.delivery:
        return channel.supportsFulfillment(POSFulfillmentMode.delivery) ||
            channel.supportsFulfillment(POSFulfillmentMode.shipment) ||
            channel.supportsFulfillment(POSFulfillmentMode.fieldDelivery);
      case POSCommerceChannelFilterStatus.account:
        return channel.supportsCapability(
              POSCommerceChannelCapability.customerIdentity,
            ) ||
            channel.supportsCapability(
              POSCommerceChannelCapability.priceLists,
            ) ||
            channel.supportsCapability(
              POSCommerceChannelCapability.orderScheduling,
            );
    }
  }

  bool _matchesQuery(
    POSCommerceChannel channel,
    POSCommerceChannelSearchTermsBuilder? extraSearchTermsBuilder,
  ) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return true;

    return _searchableTerms(
      channel,
      extraSearchTermsBuilder,
    ).any((term) => term.toLowerCase().contains(normalizedQuery));
  }

  Iterable<String> _searchableTerms(
    POSCommerceChannel channel,
    POSCommerceChannelSearchTermsBuilder? extraSearchTermsBuilder,
  ) sync* {
    yield channel.id;
    yield channel.kind.label;
    yield channel.label;
    yield channel.description;
    yield channel.preferredLayout.label;
    yield channel.fulfillmentSummary;
    yield channel.capabilitySummary;
    yield channel.traitSummary;
    yield _sectionTitle(channel);

    for (final mode in channel.fulfillmentModes) {
      yield mode.label;
    }
    for (final capability in channel.capabilities) {
      yield capability.label;
    }
    for (final trait in channel.traits) {
      yield trait;
    }

    final extraTerms = extraSearchTermsBuilder;
    if (extraTerms == null) return;

    yield* extraTerms(channel);
  }

  POSCommerceChannelFilter copyWith({
    String? query,
    POSCommerceChannelFilterStatus? status,
  }) {
    return POSCommerceChannelFilter(
      query: query ?? this.query,
      status: status ?? this.status,
    );
  }
}

class POSCommerceChannelFilterSection {
  final String title;
  final List<POSCommerceChannel> channels;

  POSCommerceChannelFilterSection({
    required this.title,
    required Iterable<POSCommerceChannel> channels,
  }) : channels = List.unmodifiable(channels);

  int get channelCount => channels.length;
}

class POSCommerceChannelFilterResult {
  final POSCommerceChannelFilter filter;
  final List<POSCommerceChannelFilterSection> sections;
  final int totalCount;

  POSCommerceChannelFilterResult({
    required this.filter,
    required Iterable<POSCommerceChannelFilterSection> sections,
    required this.totalCount,
  }) : sections = List.unmodifiable(sections);

  Iterable<POSCommerceChannel> get channels {
    return sections.expand((section) => section.channels);
  }

  int get matchCount => channels.length;

  bool get isEmpty => matchCount == 0;
}

class POSCommerceChannelFilterCounts {
  final int all;
  final int current;
  final int inPerson;
  final int online;
  final int delivery;
  final int account;

  const POSCommerceChannelFilterCounts({
    required this.all,
    required this.current,
    required this.inPerson,
    required this.online,
    required this.delivery,
    required this.account,
  });

  factory POSCommerceChannelFilterCounts.fromRegistry({
    required POSCommerceChannelRegistry registry,
    required POSCommerceChannel currentChannel,
    String query = '',
    POSCommerceChannelSearchTermsBuilder? extraSearchTermsBuilder,
  }) {
    final filter = POSCommerceChannelFilter(query: query);
    var all = 0;
    var current = 0;
    var inPerson = 0;
    var online = 0;
    var delivery = 0;
    var account = 0;

    for (final channel in registry.channels) {
      if (!filter._matchesQuery(channel, extraSearchTermsBuilder)) continue;

      all += 1;
      if (filter._matchesStatus(
        channel,
        currentChannel,
        POSCommerceChannelFilterStatus.current,
      )) {
        current += 1;
      }
      if (filter._matchesStatus(
        channel,
        currentChannel,
        POSCommerceChannelFilterStatus.inPerson,
      )) {
        inPerson += 1;
      }
      if (filter._matchesStatus(
        channel,
        currentChannel,
        POSCommerceChannelFilterStatus.online,
      )) {
        online += 1;
      }
      if (filter._matchesStatus(
        channel,
        currentChannel,
        POSCommerceChannelFilterStatus.delivery,
      )) {
        delivery += 1;
      }
      if (filter._matchesStatus(
        channel,
        currentChannel,
        POSCommerceChannelFilterStatus.account,
      )) {
        account += 1;
      }
    }

    return POSCommerceChannelFilterCounts(
      all: all,
      current: current,
      inPerson: inPerson,
      online: online,
      delivery: delivery,
      account: account,
    );
  }

  int countFor(POSCommerceChannelFilterStatus status) {
    switch (status) {
      case POSCommerceChannelFilterStatus.all:
        return all;
      case POSCommerceChannelFilterStatus.current:
        return current;
      case POSCommerceChannelFilterStatus.inPerson:
        return inPerson;
      case POSCommerceChannelFilterStatus.online:
        return online;
      case POSCommerceChannelFilterStatus.delivery:
        return delivery;
      case POSCommerceChannelFilterStatus.account:
        return account;
    }
  }
}

extension POSCommerceChannelFilterStatusLabel
    on POSCommerceChannelFilterStatus {
  String get label {
    switch (this) {
      case POSCommerceChannelFilterStatus.all:
        return 'All';
      case POSCommerceChannelFilterStatus.current:
        return 'Current';
      case POSCommerceChannelFilterStatus.inPerson:
        return 'In-person';
      case POSCommerceChannelFilterStatus.online:
        return 'Online';
      case POSCommerceChannelFilterStatus.delivery:
        return 'Delivery';
      case POSCommerceChannelFilterStatus.account:
        return 'Account';
    }
  }
}

bool _isInPersonChannel(POSCommerceChannel channel) {
  switch (channel.kind) {
    case POSCommerceChannelKind.inStore:
    case POSCommerceChannelKind.kiosk:
    case POSCommerceChannelKind.mobilePOS:
    case POSCommerceChannelKind.tableService:
      return true;
    case POSCommerceChannelKind.webStore:
    case POSCommerceChannelKind.marketplace:
    case POSCommerceChannelKind.socialOrder:
    case POSCommerceChannelKind.deliveryApp:
    case POSCommerceChannelKind.wholesale:
    case POSCommerceChannelKind.fieldSales:
    case POSCommerceChannelKind.phoneOrder:
      return false;
  }
}

bool _isOnlineChannel(POSCommerceChannel channel) {
  switch (channel.kind) {
    case POSCommerceChannelKind.webStore:
    case POSCommerceChannelKind.marketplace:
    case POSCommerceChannelKind.socialOrder:
    case POSCommerceChannelKind.deliveryApp:
    case POSCommerceChannelKind.phoneOrder:
      return true;
    case POSCommerceChannelKind.inStore:
    case POSCommerceChannelKind.kiosk:
    case POSCommerceChannelKind.mobilePOS:
    case POSCommerceChannelKind.wholesale:
    case POSCommerceChannelKind.fieldSales:
    case POSCommerceChannelKind.tableService:
      return false;
  }
}

String _sectionTitle(POSCommerceChannel channel) {
  if (_isInPersonChannel(channel)) return 'In-person channels';
  if (_isOnlineChannel(channel)) return 'Online channels';

  return 'Account and field channels';
}
