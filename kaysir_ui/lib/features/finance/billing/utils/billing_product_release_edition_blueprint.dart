import 'billing_product_package.dart';

String billingProductReleaseEditionKey(String id) {
  return id.trim().toLowerCase().replaceAll(RegExp(r'[\s-]+'), '_');
}

class BillingProductReleaseEditionBlueprint {
  final String id;
  final String label;
  final String description;
  final String audienceLabel;
  final List<String> requiredPackageKeys;
  final List<String> optionalPackageKeys;

  BillingProductReleaseEditionBlueprint({
    required this.id,
    required this.label,
    required this.description,
    required this.audienceLabel,
    required Iterable<String> requiredPackageKeys,
    Iterable<String> optionalPackageKeys = const [],
  }) : requiredPackageKeys = List.unmodifiable(
         requiredPackageKeys.map(billingProductPackageKey),
       ),
       optionalPackageKeys = List.unmodifiable(
         optionalPackageKeys.map(billingProductPackageKey),
       ) {
    if (id.trim().isEmpty) {
      throw StateError('Billing product release edition id is required.');
    }
    if (label.trim().isEmpty) {
      throw StateError('Billing product release edition $id needs a label.');
    }
    if (this.requiredPackageKeys.isEmpty) {
      throw StateError(
        'Billing product release edition $id needs required packages.',
      );
    }

    _ensureUnique(
      values: this.requiredPackageKeys,
      message: 'Duplicate required package in billing release edition $id.',
    );
    _ensureUnique(
      values: this.optionalPackageKeys,
      message: 'Duplicate optional package in billing release edition $id.',
    );

    for (final packageKey in this.optionalPackageKeys) {
      if (this.requiredPackageKeys.contains(packageKey)) {
        throw StateError(
          'Billing product release edition $id cannot mark $packageKey as '
          'both required and optional.',
        );
      }
    }
  }

  String get key => billingProductReleaseEditionKey(id);
}

class BillingProductReleaseEditionRegistry {
  final List<BillingProductReleaseEditionBlueprint> editions;

  BillingProductReleaseEditionRegistry({
    Iterable<BillingProductReleaseEditionBlueprint> editions = const [],
  }) : editions = List.unmodifiable(_ensureUniqueEditions(editions));

  bool get isEmpty => editions.isEmpty;

  int get editionCount => editions.length;

  List<String> get editionKeys {
    return List.unmodifiable(editions.map((edition) => edition.key));
  }

  BillingProductReleaseEditionBlueprint? find(String id) {
    final key = billingProductReleaseEditionKey(id);

    for (final edition in editions) {
      if (edition.key == key) return edition;
    }

    return null;
  }

  BillingProductReleaseEditionBlueprint requireEdition(String id) {
    final edition = find(id);
    if (edition == null) {
      throw StateError('No billing product release edition exists for $id.');
    }

    return edition;
  }

  static List<BillingProductReleaseEditionBlueprint> _ensureUniqueEditions(
    Iterable<BillingProductReleaseEditionBlueprint> editions,
  ) {
    final seenKeys = <String>{};
    final uniqueEditions = <BillingProductReleaseEditionBlueprint>[];

    for (final edition in editions) {
      if (!seenKeys.add(edition.key)) {
        throw StateError(
          'Duplicate billing product release edition registered for '
          '${edition.key}.',
        );
      }
      uniqueEditions.add(edition);
    }

    return uniqueEditions;
  }
}

BillingProductReleaseEditionRegistry
standardBillingProductReleaseEditionRegistry() {
  return BillingProductReleaseEditionRegistry(
    editions: [
      BillingProductReleaseEditionBlueprint(
        id: 'commerce_essentials',
        label: 'Commerce essentials',
        description: 'Checkout-led billing for stores, counters, and commerce.',
        audienceLabel: 'Retail, grocery, and commerce operators',
        requiredPackageKeys: const ['commerce_checkout'],
        optionalPackageKeys: const ['omni_channel_billing'],
      ),
      BillingProductReleaseEditionBlueprint(
        id: 'project_operations',
        label: 'Project operations',
        description: 'Milestone and service billing for delivery teams.',
        audienceLabel: 'Construction, field, and project operators',
        requiredPackageKeys: const ['project_billing', 'service_operations'],
      ),
      BillingProductReleaseEditionBlueprint(
        id: 'digital_subscriptions',
        label: 'Digital subscriptions',
        description: 'Recurring, renewal, and usage billing for digital teams.',
        audienceLabel: 'SaaS and digital product businesses',
        requiredPackageKeys: const ['digital_subscriptions'],
        optionalPackageKeys: const [
          'service_operations',
          'omni_channel_billing',
        ],
      ),
      BillingProductReleaseEditionBlueprint(
        id: 'service_billing',
        label: 'Service billing',
        description: 'Retainer and work-order billing for service teams.',
        audienceLabel: 'Agencies, service teams, and operators',
        requiredPackageKeys: const ['service_operations'],
        optionalPackageKeys: const ['project_billing', 'digital_subscriptions'],
      ),
      BillingProductReleaseEditionBlueprint(
        id: 'omni_business',
        label: 'Omni business',
        description: 'Hybrid commerce and subscription billing for expansion.',
        audienceLabel: 'Multi-channel commerce and subscription teams',
        requiredPackageKeys: const [
          'commerce_checkout',
          'digital_subscriptions',
          'omni_channel_billing',
        ],
        optionalPackageKeys: const ['service_operations'],
      ),
    ],
  );
}

void _ensureUnique({
  required Iterable<String> values,
  required String message,
}) {
  final seen = <String>{};
  for (final value in values) {
    if (!seen.add(value)) {
      throw StateError(message);
    }
  }
}
