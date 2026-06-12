import 'billing_product_release_edition.dart';

String billingProductReleaseChannelKey(String id) {
  return id.trim().toLowerCase().replaceAll(RegExp(r'[\s-]+'), '_');
}

class BillingProductReleaseChannelDefinition {
  final String id;
  final String label;
  final String description;
  final String surfaceLabel;
  final List<String> targetEditionKeys;

  BillingProductReleaseChannelDefinition({
    required this.id,
    required this.label,
    required this.description,
    required this.surfaceLabel,
    required Iterable<String> targetEditionKeys,
  }) : targetEditionKeys = List.unmodifiable(
         targetEditionKeys.map(billingProductReleaseEditionKey),
       ) {
    if (id.trim().isEmpty) {
      throw StateError('Billing product release channel id is required.');
    }
    if (label.trim().isEmpty) {
      throw StateError('Billing product release channel $id needs a label.');
    }
    if (this.targetEditionKeys.isEmpty) {
      throw StateError(
        'Billing product release channel $id needs target editions.',
      );
    }

    final seenKeys = <String>{};
    for (final key in this.targetEditionKeys) {
      if (!seenKeys.add(key)) {
        throw StateError(
          'Duplicate target edition in billing release channel $id.',
        );
      }
    }
  }

  String get key => billingProductReleaseChannelKey(id);

  bool targetsEdition(String id) {
    return targetEditionKeys.contains(billingProductReleaseEditionKey(id));
  }
}

class BillingProductReleaseChannelRegistry {
  final List<BillingProductReleaseChannelDefinition> channels;

  BillingProductReleaseChannelRegistry({
    Iterable<BillingProductReleaseChannelDefinition> channels = const [],
  }) : channels = List.unmodifiable(_ensureUniqueChannels(channels));

  bool get isEmpty => channels.isEmpty;

  int get channelCount => channels.length;

  List<String> get channelKeys {
    return List.unmodifiable(channels.map((channel) => channel.key));
  }

  BillingProductReleaseChannelDefinition? find(String id) {
    final key = billingProductReleaseChannelKey(id);

    for (final channel in channels) {
      if (channel.key == key) return channel;
    }

    return null;
  }

  BillingProductReleaseChannelDefinition requireChannel(String id) {
    final channel = find(id);
    if (channel == null) {
      throw StateError('No billing product release channel exists for $id.');
    }

    return channel;
  }

  static List<BillingProductReleaseChannelDefinition> _ensureUniqueChannels(
    Iterable<BillingProductReleaseChannelDefinition> channels,
  ) {
    final seenKeys = <String>{};
    final uniqueChannels = <BillingProductReleaseChannelDefinition>[];

    for (final channel in channels) {
      if (!seenKeys.add(channel.key)) {
        throw StateError(
          'Duplicate billing product release channel registered for '
          '${channel.key}.',
        );
      }
      uniqueChannels.add(channel);
    }

    return uniqueChannels;
  }
}

BillingProductReleaseChannelRegistry
standardBillingProductReleaseChannelRegistry() {
  return BillingProductReleaseChannelRegistry(
    channels: [
      BillingProductReleaseChannelDefinition(
        id: 'pos_counter',
        label: 'POS counter',
        description: 'Cashier, kiosk, and in-store checkout release path.',
        surfaceLabel: 'Cashier and store teams',
        targetEditionKeys: const ['commerce_essentials', 'omni_business'],
      ),
      BillingProductReleaseChannelDefinition(
        id: 'admin_back_office',
        label: 'Admin back office',
        description: 'Finance, owner, and operations console release path.',
        surfaceLabel: 'Operators and finance teams',
        targetEditionKeys: const [
          'commerce_essentials',
          'project_operations',
          'digital_subscriptions',
          'service_billing',
          'omni_business',
        ],
      ),
      BillingProductReleaseChannelDefinition(
        id: 'self_serve_portal',
        label: 'Self-serve portal',
        description: 'Customer-facing subscriptions, invoices, and renewals.',
        surfaceLabel: 'Customers and account admins',
        targetEditionKeys: const ['digital_subscriptions', 'omni_business'],
      ),
      BillingProductReleaseChannelDefinition(
        id: 'field_operations',
        label: 'Field operations',
        description: 'Mobile and field-team billing release path.',
        surfaceLabel: 'Field and service teams',
        targetEditionKeys: const ['project_operations', 'service_billing'],
      ),
      BillingProductReleaseChannelDefinition(
        id: 'partner_api',
        label: 'Partner API',
        description: 'External, integration, and automation release path.',
        surfaceLabel: 'Partners and integration teams',
        targetEditionKeys: const [
          'project_operations',
          'digital_subscriptions',
          'omni_business',
        ],
      ),
    ],
  );
}
